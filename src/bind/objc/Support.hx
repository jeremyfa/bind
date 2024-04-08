package bind.objc;

@:keep
@:include('linc_Objc.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('Objc', './'))
#end
@:headerCode('
namespace bind {
    namespace objc {
        void flushHaxeQueue();
    }
}
')
class Support {

    @:keep public static function flushHaxeQueue():Void {
        untyped __cpp__('::bind::objc::flushHaxeQueue()');
    }

}
