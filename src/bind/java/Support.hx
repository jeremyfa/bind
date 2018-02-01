package bind.java;

import cpp.Pointer;

typedef JClass = Pointer<Void>;
typedef JObject = Pointer<Void>;
typedef JMethodID = Pointer<Void>;

@:keep
class Support {

    static var jclasses:Map<String,JClass> = new Map();

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

} //Support_Extern
