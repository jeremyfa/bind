package android;
// This file was generated with bind library

import bind.java.Support;

/** Java/Android interface */
class AppAndroidInterface {

    private static var _jclass = Support.resolveJClass("yourcompany/androidsample/bind_AppAndroidInterface");

    private var _instance:Dynamic = null;

    public function new() {}

    /** Get shared instance */
    public static function sharedInterface():AppAndroidInterface {
        var ret = new AppAndroidInterface();
        ret._instance = AppAndroidInterface_Extern.sharedInterface(_jclass, _mid_sharedInterface);
        return ret;
    }
    private static var _mid_sharedInterface = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "sharedInterface", "()Lyourcompany/androidsample/AppAndroidInterface;");

    /** Constructor */
    public function init():AppAndroidInterface {
        _instance = AppAndroidInterface_Extern.constructor(_jclass, _mid_constructor);
        return this;
    }
    private static var _mid_constructor = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "constructor", "()Lyourcompany/androidsample/AppAndroidInterface;");

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        var name_jni_ = name;
        var done_jni_:Dynamic = null; // Not implemented yet
        AppAndroidInterface_Extern.hello(_jclass, _mid_hello, _instance, name_jni_, done_jni_);
    }
    private static var _mid_hello = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "hello", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;Ljava/lang/Object;)V");

    /** Get Android version string */
    public function androidVersionString():String {
        var return_jni_ = AppAndroidInterface_Extern.androidVersionString(_jclass, _mid_androidVersionString, _instance);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_androidVersionString = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "androidVersionString", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/String;");

    /** Get Android version number */
    public function androidVersionNumber():Int {
        var return_jni_ = AppAndroidInterface_Extern.androidVersionNumber(_jclass, _mid_androidVersionNumber, _instance);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_androidVersionNumber = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "androidVersionNumber", "(Lyourcompany/androidsample/AppAndroidInterface;)I");

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    public function testTypes(aBool:Bool, anInt:Int, aFloat:Float, aList:Array<Dynamic>, aMap:Dynamic):Array<Dynamic> {
        var aBool_jni_ = aBool ? 1 : 0;
        var anInt_jni_ = anInt;
        var aFloat_jni_ = aFloat;
        var aList_jni_ = haxe.Json.stringify(aList);
        var aMap_jni_ = haxe.Json.stringify(aMap);
        var return_jni_ = AppAndroidInterface_Extern.testTypes(_jclass, _mid_testTypes, _instance, aBool_jni_, anInt_jni_, aFloat_jni_, aList_jni_, aMap_jni_);
        var return_haxe_:Array<Dynamic> = haxe.Json.parse(return_jni_);
        return return_haxe_;
    }
    private static var _mid_testTypes = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "testTypes", "(Lyourcompany/androidsample/AppAndroidInterface;IIFLjava/lang/String;Ljava/lang/String;)Ljava/lang/String;");

}

@:keep
@:include('linc_AppAndroidInterface.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('AppAndroidInterface', './'))
#end
@:allow(android.AppAndroidInterface)
private extern class AppAndroidInterface_Extern {

    @:native('android::AppAndroidInterface_sharedInterface')
    static function sharedInterface(class_:JClass, method_:JMethodID):Dynamic;

    @:native('android::AppAndroidInterface_constructor')
    static function constructor(class_:JClass, method_:JMethodID):Dynamic;

    @:native('android::AppAndroidInterface_hello')
    static function hello(class_:JClass, method_:JMethodID, instance_:JObject, name:String, done:Dynamic):Void;

    @:native('android::AppAndroidInterface_androidVersionString')
    static function androidVersionString(class_:JClass, method_:JMethodID, instance_:JObject):String;

    @:native('android::AppAndroidInterface_androidVersionNumber')
    static function androidVersionNumber(class_:JClass, method_:JMethodID, instance_:JObject):Int;

    @:native('android::AppAndroidInterface_testTypes')
    static function testTypes(class_:JClass, method_:JMethodID, instance_:JObject, aBool:Int, anInt:Int, aFloat:Float, aList:String, aMap:String):String;

}

