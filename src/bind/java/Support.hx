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

    static var mutex = new Mutex();

    public var obj:Dynamic = null;

    public function new(obj:Dynamic) {

        this.obj = obj;

        // This will prevent this object from being destroyed
        // until destroy() is called explicitly
        mutex.acquire();
        @:privateAccess Support.hobjects.set(this, true);
        mutex.release();

    } //new

    public function destroy():Void {

        mutex.acquire();
        @:privateAccess Support.hobjects.remove(this);
        mutex.release();
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

} //HObject

@:keep
class Support {

    static var jclasses:Map<String,JClass> = new Map();

    static var hobjects:Map<HObject,Bool> = new Map();

    public inline static function resolveJClass(className:String):JClass {

        if (jclasses.exists(className)) return jclasses.get(className);

        var result:JClass = Support_Extern.resolveJClass(className);
        jclasses.set(className, result);

        return result;

    } //resolveJClass

    public inline static function resolveStaticJMethodID(className:String, name:String, signature:String):JMethodID {

        return Support_Extern.resolveStaticJMethodID(resolveJClass(className), name, signature);

    } //resolveJClass

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

} //Support_Extern
