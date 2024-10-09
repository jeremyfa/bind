package;
// This file was generated with bind library

import bind.csharp.Support;
import cpp.Pointer;

class AppCsInterface {

    private static var _csclassSignature = "Sample/Bind_AppCsInterface";
    private static var _csclass:CSClass = null;

    private var _instance:CSObject = null;

    public function new() {}

    /** Load audio */
    public static function Load(audioId:Int, url:String, autoplay:Bool, onProgress:(playing:Bool,complete:Bool,position:Float)->Void, onWarning:()->Void, onError:(error:String)->Void):Void {
        AppCsInterface_Extern.Load(audioId, url, autoplay, onProgress, onWarning, onError);
    }

}

@:keep
@:include('linc_AppCsInterface.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('AppCsInterface', './'))
#end
@:allow(AppCsInterface)
private extern class AppCsInterface_Extern {

    @:native('myapp::unity::AppCsInterface_Load')
    static function Load(class_:CSClass, method_:CSMethodID, audioId:Int, url:String, autoplay:Bool, onProgress:(playing:Bool,complete:Bool,position:Float)->Void, onWarning:()->Void, onError:(error:String)->Void):Void;

}

