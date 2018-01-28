#import "hxcpp.h"

/** Swift interface */
namespace ios {

    ::Dynamic AppSwiftInterface_sharedInterface();

    /** Say hello to <code>name</code> with a native iOS dialog. Add a last name if any is known. */
    void AppSwiftInterface_hello(::Dynamic instance_, ::String name, ::Dynamic done);

    /** Get iOS version string */
    ::String AppSwiftInterface_iosVersionString(::Dynamic instance_);

    /** Get iOS version number */
    double AppSwiftInterface_iosVersionNumber(::Dynamic instance_);

    /** Dummy method to get Haxe types converted to Swift types that then get returned back as an array. */
    ::Dynamic AppSwiftInterface_testTypes(::Dynamic instance_, bool aBool, int anInt, double aFloat, ::Dynamic anArray, ::Dynamic aDict);

    ::Dynamic AppSwiftInterface_init();

    /** If provided, will be called when root view controller is visible on screen */
    ::Dynamic AppSwiftInterface_viewDidAppear(::Dynamic instance_);

    /** If provided, will be called when root view controller is visible on screen */
    void AppSwiftInterface_setViewDidAppear(::Dynamic instance_, ::Dynamic viewDidAppear);

    /** Define a last name for hello() */
    ::String AppSwiftInterface_lastName(::Dynamic instance_);

    /** Define a last name for hello() */
    void AppSwiftInterface_setLastName(::Dynamic instance_, ::String lastName);

}

