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
        ::cpp::Pointer<void> return_hxcpp_ = ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_));
        return return_hxcpp_;
    }

    /** Constructor */
    ::cpp::Pointer<void> AppAndroidInterface_constructor(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_) {
        jobject return_jni_ = ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr);
        ::cpp::Pointer<void> return_hxcpp_ = ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef(return_jni_));
        return return_hxcpp_;
    }

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    void AppAndroidInterface_hello(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::String name, ::Dynamic done) {
        jstring name_jni_ = ::bind::jni::HxcppToJString(name);
        jlong done_jni_ = ::bind::jni::HObjectToJLong(done);
        ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, name_jni_, done_jni_);
    }

    /** hello */
    ::String AppAndroidInterface_callbackTest(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_, ::cpp::Pointer<void> instance_, ::Dynamic callback) {
        jlong callback_jni_ = ::bind::jni::HObjectToJLong(callback);
        jstring return_jni_ = (jstring) ::bind::jni::GetJNIEnv()->CallStaticObjectMethod((jclass) class_.ptr, (jmethodID) method_.ptr, (jobject) instance_.ptr, callback_jni_);
        ::String return_hxcpp_ = ::bind::jni::JStringToHxcpp(return_jni_);
        return return_hxcpp_;
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

}

extern "C" {

    JNIEXPORT void Java_yourcompany_androidsample_bind_1AppAndroidInterface_call_1Void(JNIEnv *env, jlong address) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        ::Dynamic func_hobject_ = ::bind::jni::JLongToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::java::HObject_obj::unwrap(func_hobject_);
        func_unwrapped_->__run();
        hx::SetTopOfStack((int *)0, true);
    }

    JNIEXPORT jfloat Java_yourcompany_androidsample_bind_1AppAndroidInterface_call_1ListStringFloat(JNIEnv *env, jlong address, jstring arg1, jstring arg2) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        ::String arg1_hxcpp_ = ::bind::jni::JStringToHxcpp(arg1);
        ::String arg2_hxcpp_ = ::bind::jni::JStringToHxcpp(arg2);
        ::Dynamic func_hobject_ = ::bind::jni::JLongToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::java::HObject_obj::unwrap(func_hobject_);
        double return_hxcpp_ = func_unwrapped_->__run(arg1_hxcpp_, arg2_hxcpp_);
        jfloat return_jni_ = (jfloat) return_hxcpp_;
        hx::SetTopOfStack((int *)0, true);
        return return_jni_;
    }

}

