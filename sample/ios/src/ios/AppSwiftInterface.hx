package ios;
// This file was generated with bind library

import bind.objc.Support;

/** Swift interface */
class AppSwiftInterface {

    private var _instance:Dynamic = null;

    public function new() {}

    /** Get shared instance */
    public static var sharedInterface(get,never):AppSwiftInterface;

    /** If provided, will be called when root view controller is visible on screen */
    public var viewDidAppear(get,set):Void->Void;

    /** Define a last name for helloSwift */
    public var lastName(get,set):String;

    inline private static function get_sharedInterface():AppSwiftInterface {
        var ret = new AppSwiftInterface();
        ret._instance = AppSwiftInterface_Extern.sharedInterface();
        return ret;
    }

    /** Say hello to <code>name</code> with a native iOS dialog. Add a last name if any is known. */
    public function hello(name:String, done:Void->Void):Void {
        AppSwiftInterface_Extern.hello(_instance, name, done);
    }

    /** Get iOS version string */
    public function iosVersionString():String {
        return AppSwiftInterface_Extern.iosVersionString(_instance);
    }

    /** Get iOS version number */
    public function iosVersionNumber():Float {
        return AppSwiftInterface_Extern.iosVersionNumber(_instance);
    }

    /** Dummy method to get Haxe types converted to Swift types that then get returned back as an array. */
    public function testTypes(aBool:Bool, anInt:Int, aFloat:Float, anArray:Array<Dynamic>, aDict:Dynamic):Array<Dynamic> {
        return AppSwiftInterface_Extern.testTypes(_instance, aBool, anInt, aFloat, anArray, aDict);
    }

    public function init():AppSwiftInterface {
        _instance = AppSwiftInterface_Extern.init();
        return this;
    }

    /** If provided, will be called when root view controller is visible on screen */
    inline private function get_viewDidAppear():Void->Void {
        return AppSwiftInterface_Extern.viewDidAppear(_instance);
    }

    /** If provided, will be called when root view controller is visible on screen */
    inline private function set_viewDidAppear(viewDidAppear:Void->Void):Void->Void {
        AppSwiftInterface_Extern.setViewDidAppear(_instance, viewDidAppear);
        return viewDidAppear;
    }

    /** Define a last name for helloSwift */
    inline private function get_lastName():String {
        return AppSwiftInterface_Extern.lastName(_instance);
    }

    /** Define a last name for helloSwift */
    inline private function set_lastName(lastName:String):String {
        AppSwiftInterface_Extern.setLastName(_instance, lastName);
        return lastName;
    }

}

@:keep
@:include('linc_AppSwiftInterface.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('AppSwiftInterface', './'))
#end
@:allow(ios.AppSwiftInterface)
private extern class AppSwiftInterface_Extern {

    @:native('ios::AppSwiftInterface_sharedInterface')
    static function sharedInterface():Dynamic;

    @:native('ios::AppSwiftInterface_hello')
    static function hello(instance_:Dynamic, name:String, done:Void->Void):Void;

    @:native('ios::AppSwiftInterface_iosVersionString')
    static function iosVersionString(instance_:Dynamic):String;

    @:native('ios::AppSwiftInterface_iosVersionNumber')
    static function iosVersionNumber(instance_:Dynamic):Float;

    @:native('ios::AppSwiftInterface_testTypes')
    static function testTypes(instance_:Dynamic, aBool:Bool, anInt:Int, aFloat:Float, anArray:Array<Dynamic>, aDict:Dynamic):Array<Dynamic>;

    @:native('ios::AppSwiftInterface_init')
    static function init():Dynamic;

    @:native('ios::AppSwiftInterface_viewDidAppear')
    static function viewDidAppear(instance_:Dynamic):Void->Void;

    @:native('ios::AppSwiftInterface_setViewDidAppear')
    static function setViewDidAppear(instance_:Dynamic, viewDidAppear:Void->Void):Void;

    @:native('ios::AppSwiftInterface_lastName')
    static function lastName(instance_:Dynamic):String;

    @:native('ios::AppSwiftInterface_setLastName')
    static function setLastName(instance_:Dynamic, lastName:String):Void;

}

