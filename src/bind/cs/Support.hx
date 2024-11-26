package bind.cs;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import cpp.Pointer;

typedef CSClass = Any; // TODO?

@:keep
class CSObject {

    public var pointer:Pointer<Void> = null;

    public function new(pointer:Pointer<Void>) {

        this.pointer = pointer;

        cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(_finalize));

    }

    @:keep public function destroy():Void {

        if (pointer == null) return;

        // TODO not supported at the moment
        Support_Extern.releaseCSObject(pointer);

        pointer = null;

    }

    @:noCompletion
    @:void public static function _finalize(csobjectRef:CSObject):Void {

        csobjectRef.destroy();

    }

}

/** A wrapper to keep any haxe object in memory until destroy() is called. */
@:keep
class HObject {

    static var nextId:haxe.Int64 = 1;

    public var obj:Dynamic = null;

    /** An HObject instance is identified by its `id` field, which is a string.
        When java needs to reference an HObject instance, it needs to use this `id`.
        This could be optimized in the future. */
    public var id:String = null;

    public function new(obj:Dynamic) {

        this.obj = obj;

        // This will prevent this object from being destroyed
        // until destroy() is called explicitly
        id = '' + (nextId++);
        @:privateAccess Support.hobjects.set(id, this);

    }

    @:keep public function destroy():Void {

        // This will allow underlying object to be destroyed (if there is no other reference to it)
        @:privateAccess Support.hobjects.remove(id);
        obj = null;

    }

    @:keep public static function unwrap(wrapped:Dynamic):Dynamic {

        if (wrapped == null || !Std.isOfType(wrapped, HObject)) return null;
        var wrappedTyped:HObject = wrapped;
        return wrappedTyped.obj;

    }

    @:keep public static function wrap(obj:Dynamic):Dynamic {

        return new HObject(obj);

    }

    @:keep public static function getById(id:String):HObject {

        var result = @:privateAccess Support.hobjects.get(id);
        return result;

    }

    @:keep public static function idOf(wrapped:Dynamic):String {

        var wrappedTyped:HObject = wrapped;
        return wrappedTyped.id;

    }

}

#end

@:keep
#if !macro
@:build(bind.cs.Support.build())
#end
class Support {

    #if macro

    macro static public function build():Array<Field> {

        var fields = Context.getBuildFields();

        final bindSupportValue = Context.definedValue("bind_support");

        if (bindSupportValue != null) {

            // Update fields
            for (field in fields) {
                if (field.name == 'BIND_SUPPORT') {
                    switch field.kind {
                        case FVar(t, e):
                            field.kind = FVar(
                                t,
                                {
                                    expr: EConst(CString(bindSupportValue, DoubleQuotes)),
                                    pos: e.pos
                                }
                            );

                        case _:
                    }
                }
            }

        }

        return fields;

    }

    #else

    static var hobjects:Map<String,HObject> = new Map();

    static var onceReadyCallbacks:Array<Void->Void> = [];

    private static final BIND_SUPPORT = "bind/Support";

    public static function onceReady(callback:Void->Void):Void {

        if (Support_Extern.isInitialized()) {
            callback();
        }
        else {
            onceReadyCallbacks.push(callback);
        }

    }

    @:noCompletion
    public static function notifyReady():Void {

        var callbacks = onceReadyCallbacks;
        onceReadyCallbacks = [];

        for (cb in callbacks) {
            cb();
        }

    }

/// Native action logic

    #if !debug inline #end public static function flushHaxeQueue():Void {

        if (!Support_Extern.hasNativeActions()) return;

        Support_Extern.runAwaitingActions();

    }

    #end

/// Unity-compatible JSON

    /**
     * Because Unity's `JsonUtility` is very limited, it cannot parse
     * any arbitrary JSON value. This helper is solving that by serializing
     * the data in a way that can be handled by Unity's `JsonUtility` to
     * restore the same data structure recursively!
     */
    public static function toUnityJson(value:Dynamic):String {

        return switch (Type.typeof(value)) {
            case TObject: // Handle anonymous objects/maps
                var pairs = [];
                for (field in Reflect.fields(value)) {
                    var fieldValue = Reflect.field(value, field);
                    pairs.push([field, _toUnityJsonValue(fieldValue)[0], _toUnityJsonValue(fieldValue)[1]]);
                }
                haxe.Json.stringify(pairs);

            default:
                if (value is Array) { // Handle arrays
                    var arr:Array<Dynamic> = value;
                    var serialized = [];
                    for (item in arr) {
                        var val = _toUnityJsonValue(item);
                        serialized.push(val[0]);
                        serialized.push(val[1]);
                    }
                    haxe.Json.stringify(serialized);
                }
                else { // Handle primitive values by wrapping them in an array
                    var serialized = _toUnityJsonValue(value);
                    haxe.Json.stringify([serialized[0], serialized[1]]);
                }
        }

    }

    private static function _toUnityJsonValue(value:Dynamic):Array<String> {

        static final NULL_VALUE:Array<String> = ['', 'n'];

        if (value == null) return NULL_VALUE;

        return switch (Type.typeof(value)) {
            case TNull: NULL_VALUE;
            case TBool: [value ? '1' : '0', 'b'];
            case TInt | TFloat: [Std.string(value), 'd'];
            case TObject:
                var pairs = [];
                for (field in Reflect.fields(value)) {
                    var fieldValue = Reflect.field(value, field);
                    pairs.push([field, _toUnityJsonValue(fieldValue)[0], _toUnityJsonValue(fieldValue)[1]]);
                }
                [haxe.Json.stringify(pairs), 'o'];
            default:
                if (value is Array) {
                    var arr:Array<Dynamic> = value;
                    var serialized = [];
                    for (item in arr) {
                        var val = _toUnityJsonValue(item);
                        serialized.push(val[0]);
                        serialized.push(val[1]);
                    }
                    [haxe.Json.stringify(serialized), 'a'];
                }
                else {
                    [Std.string(value), 's'];
                }
        }

    }

}

#if !macro
@:keep
@:include('linc_CS.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('CS', './'))
#end
@:allow(bind.cs.Support)
private extern class Support_Extern {

    @:native('bind::cs::ReleaseCSObject')
    static function releaseCSObject(csobjectRef:Pointer<Void>):Void;

    @:native('bind::cs::SetHasNativeActions')
    static function setHasNativeActions(value:Bool):Void;

    @:native('bind::cs::HasNativeActions')
    static function hasNativeActions():Bool;

    @:native('bind::cs::RunAwaitingActions')
    static function runAwaitingActions():Void;

    @:native('bind::cs::IsInitialized')
    static function isInitialized():Bool;

}
#end

