package bindhx.objc;

@:keep
@:include('linc_Objc.h')
#if !display
@:build(bindhx.Linc.touch())
@:build(bindhx.Linc.xml('Objc', './'))
#end
@:headerCode('
namespace bindhx {
    namespace objc {
        void flushHaxeQueue();
    }
}
')
class Support {

    @:keep public static function flushHaxeQueue():Void {
        untyped __cpp__('::bindhx::objc::flushHaxeQueue()');
    }

}
