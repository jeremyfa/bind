package bind.java;

import cpp.Pointer;

typedef JClass = Pointer<Void>;
typedef JMethodID = Pointer<Void>;

@:keep
class Support {

    public inline static function resolveJClass(className:String):JClass {

        return Support_Extern.resolveJClass(className);

    } //resolveJClass

    public inline static function ResolveStaticJMethodID(jclass:JClass, name:String, signature:String):JMethodID {

        return Support_Extern.resolveStaticJMethodID(jclass, name, signature);

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

} //Support_Extern
