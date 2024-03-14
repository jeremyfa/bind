package bind.objc;

@:keep
@:include('linc_Objc.h')
#if !display
@:build(bind.Linc.touch())
@:build(bind.Linc.xml('Objc', './'))
#end
class Support {

}
