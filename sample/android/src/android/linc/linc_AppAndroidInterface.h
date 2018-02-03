#include <hxcpp.h>
#include <jni.h>

/** Java/Android interface */
namespace android {

    /** Get shared instance */
    ::cpp::Pointer<void> AppAndroidInterface_sharedInterface(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_);

    /** Constructor */
    ::cpp::Pointer<void> AppAndroidInterface_constructor(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_);

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    void AppAndroidInterface_hello(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::String name, ::Dynamic done);

    /** hello */
    ::String AppAndroidInterface_callbackTest(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic callback);

    /** Get Android version string */
    ::String AppAndroidInterface_androidVersionString(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** Get Android version number */
    int AppAndroidInterface_androidVersionNumber(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    ::String AppAndroidInterface_testTypes(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, int aBool, int anInt, double aFloat, ::String aList, ::String aMap);

}

