package bind.java;

import cpp.Pointer;
import cpp.vm.Mutex;

typedef JClass = Pointer<Void>;
typedef JMethodID = Pointer<Void>;

class JObject {

    public var pointer:Pointer<Void> = null;

    public function new(pointer:Pointer<Void>) {

        this.pointer = pointer;

        cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(_finalize));

    } //new

    public function destroy():Void {

        if (pointer == null) return;

        Support_Extern.releaseJObject(pointer);
        
        pointer = null;

    } //destroy

    @:noCompletion
    @:void public static function _finalize(jobjectRef:JObject):Void {

        jobjectRef.destroy();

    } //finalize

} //JObject

/** A wrapper to keep any haxe object in memory until destroy() is called. */
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

    } //new

    public function destroy():Void {

        // This will allow underlying object to be destroyed (if there is no other reference to it)
        @:privateAccess Support.hobjects.remove(id);
        obj = null;

    } //destroy

    public static function unwrap(wrapped:Dynamic):Dynamic {

        if (wrapped == null || !Std.is(wrapped, HObject)) return null;
        var wrappedTyped:HObject = wrapped;
        return wrappedTyped.obj;

    } //unwrap

    public static function wrap(obj:Dynamic):Dynamic {

        return new HObject(obj);

    } //wrap

    public static function getById(id:String):HObject {

        var result = @:privateAccess Support.hobjects.get(id);
        return result;

    } //getById

    public static function idOf(wrapped:Dynamic):String {

        var wrappedTyped:HObject = wrapped;
        return wrappedTyped.id;

    } //idOf

} //HObject

@:keep
class Support {

    static var jclasses:Map<String,JClass> = new Map();

    static var hobjects:Map<String,HObject> = new Map();

    static var onceReadyCallbacks:Array<Void->Void> = [];

    private static var _jclass = Support.resolveJClass("bind/Support");

    public #if !debug inline #end static function resolveJClass(className:String):JClass {

        if (jclasses.exists(className)) return jclasses.get(className);

        var result:JClass = Support_Extern.resolveJClass(className);
        jclasses.set(className, result);

        return result;

    } //resolveJClass

    public #if !debug inline #end static function resolveStaticJMethodID(className:String, name:String, signature:String):JMethodID {

        return Support_Extern.resolveStaticJMethodID(resolveJClass(className), name, signature);

    } //resolveJClass

    public static function onceReady(callback:Void->Void):Void {

        trace('ONCE READY');

        if (Support_Extern.isInitialized()) {
            callback();
        }
        else {
            onceReadyCallbacks.push(callback);
        }

    } //onceReady

    @:noCompletion
    public static function notifyReady():Void {

        trace('NOTIFY READY');

        var callbacks = onceReadyCallbacks;
        onceReadyCallbacks = [];

        for (cb in callbacks) {
            cb();
        }

    } //notifyReady

/// Native runnable logic

    private static var _mid_runRunnables:JMethodID = null;

    #if !debug inline #end public static function flushRunnables():Void {

        if (!Support_Extern.hasNativeRunnables()) return;

        if (_mid_runRunnables == null) {
            _mid_runRunnables = Support.resolveStaticJMethodID("bind/Support", "runAwaitingNativeRunnables", "()V");
        }

        Support_Extern.runAwaitingRunnables(_jclass, _mid_runRunnables);

    } //flushRunnables

} //Support

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

} //Support_Extern
