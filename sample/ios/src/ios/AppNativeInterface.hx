package ios;
// This file was generated with bind library

import bind.objc.Support;

/** Example of Objective-C interface exposed to Haxe */
class AppNativeInterface {

    private var _instance:Dynamic = null;

    public function new() {}

    /** If provided, will be called when root view controller is visible on screen */
    public var viewDidAppear(get,set):Bool->Void;

    /** Last name. If provided, will be used when saying hello. */
    public var lastName(get,set):String;

    /** Get shared instance */
    public static function sharedInterface():AppNativeInterface {
        var ret = new AppNativeInterface();
        ret._instance = AppNativeInterface_Extern.sharedInterface();
        return ret;
    }

    /** Say hello to `name` with a native iOS dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        AppNativeInterface_Extern.hello(_instance, name, done);
    }

    /** Get iOS version string */
    public function iosVersionString():String {
        return AppNativeInterface_Extern.iosVersionString(_instance);
    }

    /** Get iOS version number */
    public function iosVersionNumber():Float {
        return AppNativeInterface_Extern.iosVersionNumber(_instance);
    }

    /** Dummy method to get Haxe types converted to ObjC types that then get returned back as an array. */
    public function testTypes(aBool:Bool, anInt:Int, aFloat:Float, anArray:Array<Dynamic>, aDict:Dynamic):Array<Dynamic> {
        return AppNativeInterface_Extern.testTypes(_instance, aBool, anInt, aFloat, anArray, aDict);
    }

    public function init():AppNativeInterface {
        _instance = AppNativeInterface_Extern.init();
        return this;
    }

    /** If provided, will be called when root view controller is visible on screen */
    inline private function get_viewDidAppear():Bool->Void {
        return AppNativeInterface_Extern.viewDidAppear(_instance);
    }

    /** If provided, will be called when root view controller is visible on screen */
    inline private function set_viewDidAppear(viewDidAppear:Bool->Void):Bool->Void {
        AppNativeInterface_Extern.setViewDidAppear(_instance, viewDidAppear);
        return viewDidAppear;
    }

    /** Last name. If provided, will be used when saying hello. */
    inline private function get_lastName():String {
        return AppNativeInterface_Extern.lastName(_instance);
    }

    /** Last name. If provided, will be used when saying hello. */
    inline private function set_lastName(lastName:String):String {
        AppNativeInterface_Extern.setLastName(_instance, lastName);
        return lastName;
    }

}

@:keep
@:include('linc_AppNativeInterface.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('AppNativeInterface', './'))
#end
@:allow(ios.AppNativeInterface)
private extern class AppNativeInterface_Extern {

    @:native('ios::AppNativeInterface_sharedInterface')
    static function sharedInterface():Dynamic;

    @:native('ios::AppNativeInterface_hello')
    static function hello(instance_:Dynamic, name:String, done:Void->Void):Void;

    @:native('ios::AppNativeInterface_iosVersionString')
    static function iosVersionString(instance_:Dynamic):String;

    @:native('ios::AppNativeInterface_iosVersionNumber')
    static function iosVersionNumber(instance_:Dynamic):Float;

    @:native('ios::AppNativeInterface_testTypes')
    static function testTypes(instance_:Dynamic, aBool:Bool, anInt:Int, aFloat:Float, anArray:Array<Dynamic>, aDict:Dynamic):Array<Dynamic>;

    @:native('ios::AppNativeInterface_init')
    static function init():Dynamic;

    @:native('ios::AppNativeInterface_viewDidAppear')
    static function viewDidAppear(instance_:Dynamic):Bool->Void;

    @:native('ios::AppNativeInterface_setViewDidAppear')
    static function setViewDidAppear(instance_:Dynamic, viewDidAppear:Bool->Void):Void;

    @:native('ios::AppNativeInterface_lastName')
    static function lastName(instance_:Dynamic):String;

    @:native('ios::AppNativeInterface_setLastName')
    static function setLastName(instance_:Dynamic, lastName:String):Void;

}

