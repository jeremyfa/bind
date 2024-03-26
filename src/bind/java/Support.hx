package bind.java;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import cpp.Pointer;

typedef JClass = Pointer<Void>;
typedef JMethodID = Pointer<Void>;

@:keep
class JObject {

    public var pointer:Pointer<Void> = null;

    public function new(pointer:Pointer<Void>) {

        this.pointer = pointer;

        cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(_finalize));

    }

    @:keep public function destroy():Void {

        if (pointer == null) return;

        Support_Extern.releaseJObject(pointer);

        pointer = null;

    }

    @:noCompletion
    @:void public static function _finalize(jobjectRef:JObject):Void {

        jobjectRef.destroy();

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
@:build(bind.java.Support.build())
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

    static var jclasses:Map<String,JClass> = new Map();

    static var hobjects:Map<String,HObject> = new Map();

    static var onceReadyCallbacks:Array<Void->Void> = [];

    private static final BIND_SUPPORT = "bind/Support";

    private static var _jclass = Support.resolveJClass(BIND_SUPPORT);

    public #if !debug inline #end static function resolveJClass(className:String):JClass {

        if (jclasses.exists(className)) return jclasses.get(className);

        var result:JClass = Support_Extern.resolveJClass(className);
        jclasses.set(className, result);

        return result;

    }

    public #if !debug inline #end static function resolveStaticJMethodID(className:String, name:String, signature:String):JMethodID {

        return Support_Extern.resolveStaticJMethodID(resolveJClass(className), name, signature);

    }

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

/// Native runnable logic

    private static var _mid_runRunnables:JMethodID = null;

    #if !debug inline #end public static function flushRunnables():Void {

        if (!Support_Extern.hasNativeRunnables()) return;

        if (_mid_runRunnables == null) {
            _mid_runRunnables = Support.resolveStaticJMethodID(BIND_SUPPORT, "runAwaitingNativeRunnables", "()V");
        }

        Support_Extern.runAwaitingRunnables(_jclass, _mid_runRunnables);

    }

    #end

}

#if !macro
@:keep
@:include('linc_JNI.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('JNI', './'))
#end
@:allow(bind.java.Support)
private extern class Support_Extern {

    @:native('bind::jni::ResolveJClass')
    static function resolveJClass(className:String):Pointer<Void>;

    @:native('bind::jni::ResolveStaticJMethodID')
    static function resolveStaticJMethodID(jclass:Pointer<Void>, name:String, signature:String):Pointer<Void>;

    @:native('bind::jni::ReleaseJObject')
    static function releaseJObject(jobjectRef:Pointer<Void>):Void;

    @:native('bind::jni::SetHasNativeRunnables')
    static function setHasNativeRunnables(value:Bool):Void;

    @:native('bind::jni::HasNativeRunnables')
    static function hasNativeRunnables():Bool;

    @:native('bind::jni::RunAwaitingRunnables')
    static function runAwaitingRunnables(class_:JClass, method_:JMethodID):Void;

    @:native('bind::jni::IsInitialized')
    static function isInitialized():Bool;

}
#end
