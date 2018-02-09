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

    /** Get Android version string */
    ::String AppAndroidInterface_androidVersionString(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** Get Android version number */
    int AppAndroidInterface_androidVersionNumber(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    ::String AppAndroidInterface_testTypes(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, int aBool, int anInt, double aFloat, ::String aList, ::String aMap);

    /** If provided, will be called when main activity is paused */
    ::Dynamic AppAndroidInterface_getOnPause(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** If provided, will be called when main activity is paused */
    void AppAndroidInterface_setOnPause(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic onPause);

    /** If provided, will be called when main activity is resumed */
    ::Dynamic AppAndroidInterface_getOnResume(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** If provided, will be called when main activity is resumed */
    void AppAndroidInterface_setOnResume(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic onResume);

    /** Define a last name for hello() */
    ::String AppAndroidInterface_getLastName(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_);

    /** Define a last name for hello() */
    void AppAndroidInterface_setLastName(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::String lastName);

    void AppAndroidInterface_callJ_Void(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> callback_);

}

extern "C" {

    JNIEXPORT void Java_yourcompany_androidsample_bind_1AppAndroidInterface_callN_1Void(JNIEnv *env, jclass clazz, jstring address);

}

