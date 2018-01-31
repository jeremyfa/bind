package android;
// This file was generated with bind library

import bind.java.Support;

/** Java/Android interface */
class AppAndroidInterface {

    private var _instance:Dynamic = null;

    public function new() {}

    /** Get shared instance */
    public static function sharedInterface():AppAndroidInterface {
        var ret = new AppAndroidInterface();
        ret._instance = AppAndroidInterface_Extern.sharedInterface();
        return ret;
    }

    /** Constructor */
    public function constructor():AppAndroidInterface {
        _instance = AppAndroidInterface_Extern.constructor();
        return this;
    }

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        AppAndroidInterface_Extern.hello(_instance, name, done);
    }

    /** Get Android version string */
    public function androidVersionString():String {
        return AppAndroidInterface_Extern.androidVersionString(_instance);
    }

    /** Get Android version number */
    public function androidVersionNumber():Int {
        return AppAndroidInterface_Extern.androidVersionNumber(_instance);
    }

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    public function testTypes(aBool:Bool, anInt:Int, aFloat:Float, aList:Array<Dynamic>, aMap:Dynamic):Array<Dynamic> {
        return AppAndroidInterface_Extern.testTypes(_instance, aBool, anInt, aFloat, aList, aMap);
    }

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
    static function sharedInterface():Dynamic;

    @:native('android::AppAndroidInterface_constructor')
    static function constructor():Dynamic;

    @:native('android::AppAndroidInterface_hello')
    static function hello(instance_:Dynamic, name:String, done:Void->Void):Void;

    @:native('android::AppAndroidInterface_androidVersionString')
    static function androidVersionString(instance_:Dynamic):String;

    @:native('android::AppAndroidInterface_androidVersionNumber')
    static function androidVersionNumber(instance_:Dynamic):Int;

    @:native('android::AppAndroidInterface_testTypes')
    static function testTypes(instance_:Dynamic, aBool:Bool, anInt:Int, aFloat:Float, aList:Array<Dynamic>, aMap:Dynamic):Array<Dynamic>;

}

