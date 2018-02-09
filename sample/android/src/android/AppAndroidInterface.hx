package android;
// This file was generated with bind library

import bind.java.Support;
import cpp.Pointer;

/** Java/Android interface */
class AppAndroidInterface {

    private static var _jclassSignature = "yourcompany/androidsample/bind_AppAndroidInterface";
    private static var _jclass:JClass = null;

    private var _instance:JObject = null;

    public function new() {}

    /** If provided, will be called when main activity is paused */
    public var onPause(get,set):Void->Void;

    /** If provided, will be called when main activity is resumed */
    public var onResume(get,set):Void->Void;

    /** Define a last name for hello() */
    public var lastName(get,set):String;

    /** Get shared instance */
    public static function sharedInterface():AppAndroidInterface {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_sharedInterface == null) _mid_sharedInterface = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "sharedInterface", "()Lyourcompany/androidsample/AppAndroidInterface;");
        var ret = new AppAndroidInterface();
        var _instance_pointer = AppAndroidInterface_Extern.sharedInterface(_jclass, _mid_sharedInterface);
        ret._instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;
        return ret._instance != null ? ret : null;
    }
    private static var _mid_sharedInterface:JMethodID = null;

    /** Constructor */
    public function init():AppAndroidInterface {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_constructor == null) _mid_constructor = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "constructor", "()Lyourcompany/androidsample/AppAndroidInterface;");
        var _instance_pointer = AppAndroidInterface_Extern.constructor(_jclass, _mid_constructor);
        _instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;
        return _instance != null ? this : null;
    }
    private static var _mid_constructor:JMethodID = null;

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_hello == null) _mid_hello = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "hello", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;Ljava/lang/String;)V");
        var name_jni_ = name;
        var done_jni_:HObject = null;
        if (done != null) {
            done_jni_ = new HObject(function() {
                done();
            });
        }
        AppAndroidInterface_Extern.hello(_jclass, _mid_hello, _instance.pointer, name_jni_, done_jni_);
    }
    private static var _mid_hello:JMethodID = null;

    /** Get Android version string */
    public function androidVersionString():String {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_androidVersionString == null) _mid_androidVersionString = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "androidVersionString", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/String;");
        var return_jni_ = AppAndroidInterface_Extern.androidVersionString(_jclass, _mid_androidVersionString, _instance.pointer);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_androidVersionString:JMethodID = null;

    /** Get Android version number */
    public function androidVersionNumber():Int {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_androidVersionNumber == null) _mid_androidVersionNumber = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "androidVersionNumber", "(Lyourcompany/androidsample/AppAndroidInterface;)I");
        var return_jni_ = AppAndroidInterface_Extern.androidVersionNumber(_jclass, _mid_androidVersionNumber, _instance.pointer);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_androidVersionNumber:JMethodID = null;

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    public function testTypes(aBool:Bool, anInt:Int, aFloat:Float, aList:Array<Dynamic>, aMap:Dynamic):Array<Dynamic> {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_testTypes == null) _mid_testTypes = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "testTypes", "(Lyourcompany/androidsample/AppAndroidInterface;IIFLjava/lang/String;Ljava/lang/String;)Ljava/lang/String;");
        var aBool_jni_ = aBool ? 1 : 0;
        var anInt_jni_ = anInt;
        var aFloat_jni_ = aFloat;
        var aList_jni_ = haxe.Json.stringify(aList);
        var aMap_jni_ = haxe.Json.stringify(aMap);
        var return_jni_ = AppAndroidInterface_Extern.testTypes(_jclass, _mid_testTypes, _instance.pointer, aBool_jni_, anInt_jni_, aFloat_jni_, aList_jni_, aMap_jni_);
        var return_haxe_:Array<Dynamic> = haxe.Json.parse(return_jni_);
        return return_haxe_;
    }
    private static var _mid_testTypes:JMethodID = null;

    /** If provided, will be called when main activity is paused */
    inline private function get_onPause():Void->Void {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_getOnPause == null) _mid_getOnPause = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getOnPause", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/Object;");
        var return_jni_ = AppAndroidInterface_Extern.getOnPause(_jclass, _mid_getOnPause, _instance.pointer);
        var return_haxe_:Void->Void = null;
        if (return_jni_ != null) {
            var return_haxe_jobj_ = new JObject(return_jni_);
            return_haxe_ = function() {
                AppAndroidInterface_Extern.callJ_Void(_jclass, _mid_callJ_Void, return_haxe_jobj_.pointer);
            };
        }
        return return_haxe_;
    }
    private static var _mid_getOnPause:JMethodID = null;

    /** If provided, will be called when main activity is paused */
    inline private function set_onPause(onPause:Void->Void):Void->Void {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_setOnPause == null) _mid_setOnPause = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setOnPause", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;)V");
        var onPause_jni_:HObject = null;
        if (onPause != null) {
            onPause_jni_ = new HObject(function() {
                onPause();
            });
        }
        AppAndroidInterface_Extern.setOnPause(_jclass, _mid_setOnPause, _instance.pointer, onPause_jni_);
        return onPause;
    }
    private static var _mid_setOnPause:JMethodID = null;

    /** If provided, will be called when main activity is resumed */
    inline private function get_onResume():Void->Void {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_getOnResume == null) _mid_getOnResume = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getOnResume", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/Object;");
        var return_jni_ = AppAndroidInterface_Extern.getOnResume(_jclass, _mid_getOnResume, _instance.pointer);
        var return_haxe_:Void->Void = null;
        if (return_jni_ != null) {
            var return_haxe_jobj_ = new JObject(return_jni_);
            return_haxe_ = function() {
                AppAndroidInterface_Extern.callJ_Void(_jclass, _mid_callJ_Void, return_haxe_jobj_.pointer);
            };
        }
        return return_haxe_;
    }
    private static var _mid_getOnResume:JMethodID = null;

    /** If provided, will be called when main activity is resumed */
    inline private function set_onResume(onResume:Void->Void):Void->Void {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_setOnResume == null) _mid_setOnResume = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setOnResume", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;)V");
        var onResume_jni_:HObject = null;
        if (onResume != null) {
            onResume_jni_ = new HObject(function() {
                onResume();
            });
        }
        AppAndroidInterface_Extern.setOnResume(_jclass, _mid_setOnResume, _instance.pointer, onResume_jni_);
        return onResume;
    }
    private static var _mid_setOnResume:JMethodID = null;

    /** Define a last name for hello() */
    inline private function get_lastName():String {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_getLastName == null) _mid_getLastName = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getLastName", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/String;");
        var return_jni_ = AppAndroidInterface_Extern.getLastName(_jclass, _mid_getLastName, _instance.pointer);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_getLastName:JMethodID = null;

    /** Define a last name for hello() */
    inline private function set_lastName(lastName:String):String {
        if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);
        if (_mid_setLastName == null) _mid_setLastName = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setLastName", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;)V");
        var lastName_jni_ = lastName;
        AppAndroidInterface_Extern.setLastName(_jclass, _mid_setLastName, _instance.pointer, lastName_jni_);
        return lastName;
    }
    private static var _mid_setLastName:JMethodID = null;

    private static var _mid_callJ_Void = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "callJ_Void", "(Ljava/lang/Object;)V");
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
    static function sharedInterface(class_:JClass, method_:JMethodID):Pointer<Void>;

    @:native('android::AppAndroidInterface_constructor')
    static function constructor(class_:JClass, method_:JMethodID):Pointer<Void>;

    @:native('android::AppAndroidInterface_hello')
    static function hello(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, name:String, done:HObject):Void;

    @:native('android::AppAndroidInterface_androidVersionString')
    static function androidVersionString(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):String;

    @:native('android::AppAndroidInterface_androidVersionNumber')
    static function androidVersionNumber(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Int;

    @:native('android::AppAndroidInterface_testTypes')
    static function testTypes(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, aBool:Int, anInt:Int, aFloat:Float, aList:String, aMap:String):String;

    @:native('android::AppAndroidInterface_getOnPause')
    static function getOnPause(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Pointer<Void>;

    @:native('android::AppAndroidInterface_setOnPause')
    static function setOnPause(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, onPause:HObject):Void;

    @:native('android::AppAndroidInterface_getOnResume')
    static function getOnResume(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Pointer<Void>;

    @:native('android::AppAndroidInterface_setOnResume')
    static function setOnResume(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, onResume:HObject):Void;

    @:native('android::AppAndroidInterface_getLastName')
    static function getLastName(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):String;

    @:native('android::AppAndroidInterface_setLastName')
    static function setLastName(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, lastName:String):Void;

    @:native('android::AppAndroidInterface_callJ_Void')
    static function callJ_Void(class_:JClass, method_:JMethodID, callback_:Pointer<Void>):Void;

}

