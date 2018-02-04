package android;
// This file was generated with bind library

import bind.java.Support;
import cpp.Pointer;

/** Java/Android interface */
class AppAndroidInterface {

    private static var _jclass = Support.resolveJClass("yourcompany/androidsample/bind_AppAndroidInterface");

    private var _instance:JObject = null;

    public function new() {}

    /** Android Context */
    public static var context(get,set):JObject;

    /** If provided, will be called when main activity is started/resumed */
    public var onResume(get,set):Bool->Void;

    public var onDone1(get,set):Void->Void;

    /** Define a last name for hello() */
    public var lastName(get,set):String;

    /** Get shared instance */
    public static function sharedInterface():AppAndroidInterface {
        var ret = new AppAndroidInterface();
        var _instance_pointer = AppAndroidInterface_Extern.sharedInterface(_jclass, _mid_sharedInterface);
        ret._instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;
        return ret._instance != null ? ret : null;
    }
    private static var _mid_sharedInterface = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "sharedInterface", "()Lyourcompany/androidsample/AppAndroidInterface;");

    /** Constructor */
    public function init():AppAndroidInterface {
        var _instance_pointer = AppAndroidInterface_Extern.constructor(_jclass, _mid_constructor);
        _instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;
        return _instance != null ? this : null;
    }
    private static var _mid_constructor = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "constructor", "()Lyourcompany/androidsample/AppAndroidInterface;");

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        var name_jni_ = name;
        var done_jni_:HObject = null;
        if (done != null) {
            done_jni_ = new HObject(function() {
                done();
            });
        }
        AppAndroidInterface_Extern.hello(_jclass, _mid_hello, _instance.pointer, name_jni_, done_jni_);
    }
    private static var _mid_hello = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "hello", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;J)V");

    /** hello */
    public function callbackTest(callback:Array<Dynamic>->String->Float):String {
        var callback_jni_:HObject = null;
        if (callback != null) {
            callback_jni_ = new HObject(function(arg1_cl:String, arg2_cl:String) {
                var arg1_cl_haxe_:Array<Dynamic> = haxe.Json.parse(arg1_cl);
                var arg2_cl_haxe_ = arg2_cl;
                var return_haxe_ = callback(arg1_cl_haxe_, arg2_cl_haxe_);
                var return_jni_ = return_haxe_;
                return return_jni_;
            });
        }
        var return_jni_ = AppAndroidInterface_Extern.callbackTest(_jclass, _mid_callbackTest, _instance.pointer, callback_jni_);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_callbackTest = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "callbackTest", "(Lyourcompany/androidsample/AppAndroidInterface;J)Ljava/lang/String;");

    /** Get Android version string */
    public function androidVersionString():String {
        var return_jni_ = AppAndroidInterface_Extern.androidVersionString(_jclass, _mid_androidVersionString, _instance.pointer);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_androidVersionString = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "androidVersionString", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/String;");

    /** Get Android version number */
    public function androidVersionNumber():Int {
        var return_jni_ = AppAndroidInterface_Extern.androidVersionNumber(_jclass, _mid_androidVersionNumber, _instance.pointer);
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
        var return_jni_ = AppAndroidInterface_Extern.testTypes(_jclass, _mid_testTypes, _instance.pointer, aBool_jni_, anInt_jni_, aFloat_jni_, aList_jni_, aMap_jni_);
        var return_haxe_:Array<Dynamic> = haxe.Json.parse(return_jni_);
        return return_haxe_;
    }
    private static var _mid_testTypes = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "testTypes", "(Lyourcompany/androidsample/AppAndroidInterface;IIFLjava/lang/String;Ljava/lang/String;)Ljava/lang/String;");

    /** Android Context */
    inline private static function get_context():JObject {
        var return_jni_ = AppAndroidInterface_Extern.getContext(_jclass, _mid_getContext);
        var return_haxe_ = new JObject(return_jni_);
        return return_haxe_;
    }
    private static var _mid_getContext = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getContext", "()Ljava/lang/Object;");

    /** Android Context */
    inline private static function set_context(context:JObject):JObject {
        var context_jni_ = context.pointer;
        AppAndroidInterface_Extern.setContext(_jclass, _mid_setContext, context_jni_);
        return context;
    }
    private static var _mid_setContext = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setContext", "(Ljava/lang/Object;)V");

    /** If provided, will be called when main activity is started/resumed */
    inline private function get_onResume():Bool->Void {
        var return_jni_ = AppAndroidInterface_Extern.getOnResume(_jclass, _mid_getOnResume, _instance.pointer);
        var return_haxe_:Bool->Void = null;
        if (return_jni_ != null) {
            var return_haxe_jobj_ = new JObject(return_jni_);
            return_haxe_ = function(arg1_cl:Bool) {
                var arg1_cl_jni_ = arg1_cl ? 1 : 0;
                AppAndroidInterface_Extern.callJ_BooleanVoid(_jclass, _mid_callJ_BooleanVoid, return_haxe_jobj_.pointer, arg1_cl_jni_);
            };
        }
        return return_haxe_;
    }
    private static var _mid_getOnResume = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getOnResume", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/Object;");

    /** If provided, will be called when main activity is started/resumed */
    inline private function set_onResume(onResume:Bool->Void):Bool->Void {
        var onResume_jni_:HObject = null;
        if (onResume != null) {
            onResume_jni_ = new HObject(function(arg1_cl:Int) {
                var arg1_cl_haxe_ = arg1_cl != 0;
                onResume(arg1_cl_haxe_);
            });
        }
        AppAndroidInterface_Extern.setOnResume(_jclass, _mid_setOnResume, _instance.pointer, onResume_jni_);
        return onResume;
    }
    private static var _mid_setOnResume = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setOnResume", "(Lyourcompany/androidsample/AppAndroidInterface;J)V");

    inline private function get_onDone1():Void->Void {
        var return_jni_ = AppAndroidInterface_Extern.getOnDone1(_jclass, _mid_getOnDone1, _instance.pointer);
        var return_haxe_:Void->Void = null;
        if (return_jni_ != null) {
            var return_haxe_jobj_ = new JObject(return_jni_);
            return_haxe_ = function() {
                AppAndroidInterface_Extern.callJ_Void(_jclass, _mid_callJ_Void, return_haxe_jobj_.pointer);
            };
        }
        return return_haxe_;
    }
    private static var _mid_getOnDone1 = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getOnDone1", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/Object;");

    inline private function set_onDone1(onDone1:Void->Void):Void->Void {
        var onDone1_jni_:HObject = null;
        if (onDone1 != null) {
            onDone1_jni_ = new HObject(function() {
                onDone1();
            });
        }
        AppAndroidInterface_Extern.setOnDone1(_jclass, _mid_setOnDone1, _instance.pointer, onDone1_jni_);
        return onDone1;
    }
    private static var _mid_setOnDone1 = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setOnDone1", "(Lyourcompany/androidsample/AppAndroidInterface;J)V");

    /** Define a last name for hello() */
    inline private function get_lastName():String {
        var return_jni_ = AppAndroidInterface_Extern.getLastName(_jclass, _mid_getLastName, _instance.pointer);
        var return_haxe_ = return_jni_;
        return return_haxe_;
    }
    private static var _mid_getLastName = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "getLastName", "(Lyourcompany/androidsample/AppAndroidInterface;)Ljava/lang/String;");

    /** Define a last name for hello() */
    inline private function set_lastName(lastName:String):String {
        var lastName_jni_ = lastName;
        AppAndroidInterface_Extern.setLastName(_jclass, _mid_setLastName, _instance.pointer, lastName_jni_);
        return lastName;
    }
    private static var _mid_setLastName = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "setLastName", "(Lyourcompany/androidsample/AppAndroidInterface;Ljava/lang/String;)V");

    private static var _mid_callJ_BooleanVoid = Support.resolveStaticJMethodID("yourcompany/androidsample/bind_AppAndroidInterface", "callJ_BooleanVoid", "(Ljava/lang/Object;I)V");
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

    @:native('android::AppAndroidInterface_callbackTest')
    static function callbackTest(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, callback:HObject):String;

    @:native('android::AppAndroidInterface_androidVersionString')
    static function androidVersionString(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):String;

    @:native('android::AppAndroidInterface_androidVersionNumber')
    static function androidVersionNumber(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Int;

    @:native('android::AppAndroidInterface_testTypes')
    static function testTypes(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, aBool:Int, anInt:Int, aFloat:Float, aList:String, aMap:String):String;

    @:native('android::AppAndroidInterface_getContext')
    static function getContext(class_:JClass, method_:JMethodID):Pointer<Void>;

    @:native('android::AppAndroidInterface_setContext')
    static function setContext(class_:JClass, method_:JMethodID, context:Pointer<Void>):Void;

    @:native('android::AppAndroidInterface_getOnResume')
    static function getOnResume(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Pointer<Void>;

    @:native('android::AppAndroidInterface_setOnResume')
    static function setOnResume(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, onResume:HObject):Void;

    @:native('android::AppAndroidInterface_getOnDone1')
    static function getOnDone1(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):Pointer<Void>;

    @:native('android::AppAndroidInterface_setOnDone1')
    static function setOnDone1(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, onDone1:HObject):Void;

    @:native('android::AppAndroidInterface_getLastName')
    static function getLastName(class_:JClass, method_:JMethodID, instance_:Pointer<Void>):String;

    @:native('android::AppAndroidInterface_setLastName')
    static function setLastName(class_:JClass, method_:JMethodID, instance_:Pointer<Void>, lastName:String):Void;

    @:native('android::AppAndroidInterface_callJ_BooleanVoid')
    static function callJ_BooleanVoid(class_:JClass, method_:JMethodID, callback_:Pointer<Void>, arg1:Int):Void;

    @:native('android::AppAndroidInterface_callJ_Void')
    static function callJ_Void(class_:JClass, method_:JMethodID, callback_:Pointer<Void>):Void;

}

