#import "hxcpp.h"

/** Example of Objective-C interface exposed to Haxe */
namespace ios {

    /** Get shared instance */
    ::Dynamic AppNativeInterface_sharedInterface();

    /** Say hello to `name` with a native iOS dialog. Add a last name if any is known. */
    void AppNativeInterface_hello(::Dynamic instance_, ::String name, ::Dynamic done);

    /** Get iOS version string */
    ::String AppNativeInterface_iosVersionString(::Dynamic instance_);

    /** Get iOS version number */
    double AppNativeInterface_iosVersionNumber(::Dynamic instance_);

    /** Dummy method to get Haxe types converted to ObjC types that then get returned back as an array. */
    ::Dynamic AppNativeInterface_testTypes(::Dynamic instance_, bool aBool, int anInt, double aFloat, ::Dynamic anArray, ::Dynamic aDict);

    ::Dynamic AppNativeInterface_init();

    /** If provided, will be called when root view controller is visible on screen */
    ::Dynamic AppNativeInterface_viewDidAppear(::Dynamic instance_);

    /** If provided, will be called when root view controller is visible on screen */
    void AppNativeInterface_setViewDidAppear(::Dynamic instance_, ::Dynamic viewDidAppear);

    /** Last name. If provided, will be used when saying hello. */
    ::String AppNativeInterface_lastName(::Dynamic instance_);

    /** Last name. If provided, will be used when saying hello. */
    void AppNativeInterface_setLastName(::Dynamic instance_, ::String lastName);

}

