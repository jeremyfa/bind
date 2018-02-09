#include "linc_JNI.h"
#include "linc_AppAndroidInterface.h"
#ifndef INCLUDED_bind_java_HObject
#include <bind/java/HObject.h>
#endif

/** Java/Android interface */
namespace android {

    /** Get shared instance */
    ::cpp::Pointer<void> AppAndroidInterface_sharedInterface(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_) {
        jobject return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr);
        ::cpp::Pointer<void> return_hxcpp_ = return_jni_ != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_)) : null();
        return return_hxcpp_;
    }

    /** Constructor */
    ::cpp::Pointer<void> AppAndroidInterface_constructor(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_) {
        jobject return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr);
        ::cpp::Pointer<void> return_hxcpp_ = return_jni_ != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_)) : null();
        return return_hxcpp_;
    }

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    void AppAndroidInterface_hello(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::String name, ::Dynamic done) {
        jstring name_jni_ = ::bind::jni::HxcppToJString(name);
        jstring done_jni_ = ::bind::jni::HObjectToJString(done);
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, name_jni_, done_jni_);
    }

    /** Get Android version string */
    ::String AppAndroidInterface_androidVersionString(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_) {
        jstring return_jni_ = (jstring) ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr);
        ::String return_hxcpp_ = ::bind::jni::JStringToHxcpp(return_jni_);
        return return_hxcpp_;
    }

    /** Get Android version number */
    int AppAndroidInterface_androidVersionNumber(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_) {
        jint return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticIntMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr);
        int return_hxcpp_ = (int) return_jni_;
        return return_hxcpp_;
    }

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    ::String AppAndroidInterface_testTypes(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, int aBool, int anInt, double aFloat, ::String aList, ::String aMap) {
        jint aBool_jni_ = (jint) aBool;
        jint anInt_jni_ = (jint) anInt;
        jfloat aFloat_jni_ = (jfloat) aFloat;
        jstring aList_jni_ = ::bind::jni::HxcppToJString(aList);
        jstring aMap_jni_ = ::bind::jni::HxcppToJString(aMap);
        jstring return_jni_ = (jstring) ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, aBool_jni_, anInt_jni_, aFloat_jni_, aList_jni_, aMap_jni_);
        ::String return_hxcpp_ = ::bind::jni::JStringToHxcpp(return_jni_);
        return return_hxcpp_;
    }

    /** If provided, will be called when main activity is paused */
    ::Dynamic AppAndroidInterface_getOnPause(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_) {
        jobject return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr);
        ::Dynamic return_hxcpp_ = return_jni_ != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_)) : null();
        return return_hxcpp_;
    }

    /** If provided, will be called when main activity is paused */
    void AppAndroidInterface_setOnPause(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic onPause) {
        jstring onPause_jni_ = ::bind::jni::HObjectToJString(onPause);
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, onPause_jni_);
    }

    /** If provided, will be called when main activity is resumed */
    ::Dynamic AppAndroidInterface_getOnResume(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_) {
        jobject return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr);
        ::Dynamic return_hxcpp_ = return_jni_ != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_)) : null();
        return return_hxcpp_;
    }

    /** If provided, will be called when main activity is resumed */
    void AppAndroidInterface_setOnResume(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic onResume) {
        jstring onResume_jni_ = ::bind::jni::HObjectToJString(onResume);
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, onResume_jni_);
    }

    /** Define a last name for hello() */
    ::String AppAndroidInterface_getLastName(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_) {
        jstring return_jni_ = (jstring) ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr);
        ::String return_hxcpp_ = ::bind::jni::JStringToHxcpp(return_jni_);
        return return_hxcpp_;
    }

    /** Define a last name for hello() */
    void AppAndroidInterface_setLastName(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::String lastName) {
        jstring lastName_jni_ = ::bind::jni::HxcppToJString(lastName);
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, lastName_jni_);
    }

    void AppAndroidInterface_callJ_Void(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> callback_) {
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) callback_.ptr);
    }

}

extern "C" {

    JNIEXPORT void Java_yourcompany_androidsample_bind_1AppAndroidInterface_callN_1Void(JNIEnv *env, jclass clazz, jstring address) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        ::Dynamic func_hobject_ = ::bind::jni::JStringToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::java::HObject_obj::unwrap(func_hobject_);
        func_unwrapped_->__run();
        hx::SetTopOfStack((int *)0, true);
    }

}

