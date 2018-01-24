package ios;
// This file was generated with bind library

import bind.objc.Support;

/** Swift interface */
class AppSwiftInterface {

    private var _instance:Dynamic = null;

    public function new() {}

    /** Define a last name for helloSwift */
    public var lastName(get,set):String;

    /** Say hello to name */
    public function helloSwift(name:String):Void {
        AppSwiftInterface_Extern.helloSwift(_instance, name);
    }

    public function init():AppSwiftInterface {
        _instance = AppSwiftInterface_Extern.init();
        return this;
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

    @:native('ios::AppSwiftInterface_helloSwift')
    static function helloSwift(instance_:Dynamic, name:String):Void;

    @:native('ios::AppSwiftInterface_init')
    static function init():Dynamic;

    @:native('ios::AppSwiftInterface_lastName')
    static function lastName(instance_:Dynamic):String;

    @:native('ios::AppSwiftInterface_setLastName')
    static function setLastName(instance_:Dynamic, lastName:String):Void;

}

