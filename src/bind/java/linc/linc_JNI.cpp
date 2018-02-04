#include "linc_JNI.h"

#include <map>
#include <string>

#ifndef INCLUDED_bind_java_HObject
#include <bind/java/HObject.h>
#endif

namespace bind {

    namespace jni {

        std::map<std::string, jclass> jclasses;
        JNIEnv *env;

        JNIEnv *GetJNIEnv() {

            return env;

        } //GetJNIEnv

        jstring HxcppToJString(::String str) {

            if (hx::IsNotNull(str)) {
                return env->NewStringUTF(str.c_str());
            }
            return NULL;

        } //HxcppToJString

        ::String JStringToHxcpp(jstring str) {

            if (str != NULL) {
                jboolean is_copy;
                const char *c_str = env->GetStringUTFChars(str, &is_copy);
                ::String result = ::String(c_str);
                env->ReleaseStringUTFChars(str, c_str);
                return result;
            }
            return null();

        } //JStringToHxcpp

        ::cpp::Pointer<void> ResolveJClass(::String className) {
            
            jclass globalRef;
            std::string cppClassName(className.c_str());

            if (jclasses.find(cppClassName) != jclasses.end()) {
                return ::cpp::Pointer<void>(jclasses[cppClassName]);
            }
                
            jclass result = env->FindClass(className.c_str());
            
            if (!result) {
                return null();
            }
            
            globalRef = (jclass)env->NewGlobalRef(result);
            jclasses[cppClassName] = globalRef;
            env->DeleteLocalRef(result);
            
            return ::cpp::Pointer<void>(globalRef);
            
        } //ResolveJClass

        ::cpp::Pointer<void> ResolveStaticJMethodID(::cpp::Pointer<void> jclassRef, ::String name, ::String signature) {
            
            jclass cls = (jclass) jclassRef.ptr;
            jmethodID mid = env->GetStaticMethodID(cls, name.c_str(), signature.c_str());

            if (!mid) {
                return null();
            }

            return ::cpp::Pointer<void>(mid);
            
        } //ResolveStaticJMethodID

        void ReleaseJObject(::cpp::Pointer<void> jobjectRef) {

            jobject obj = (jobject) jobjectRef.ptr;
            env->DeleteGlobalRef(obj);

        } //ReleaseJObject

        jlong HObjectToJLong(::Dynamic hobjectRef) {

            if (hx::IsNotNull(hobjectRef)) {
                hx::Object *objPointer = hobjectRef.mPtr;
                return (jlong)(void*)objPointer;
            }
            return 0;

        } //HObjectToJLong

        ::Dynamic JLongToHObject(jlong address) {

            if (address == 0) {
                return null();
            }
            ::Dynamic result = ::Dynamic();
            result.mPtr = (hx::Object*)(void*)address;
            return result;

        } //HObjectToJLong

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env) {

        ::bind::jni::env = env;

    } //init

    JNIEXPORT void JNICALL Java_bind_Support_releaseHaxeObject(JNIEnv *env, jlong address) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::Dynamic hobjectRef = ::bind::jni::JLongToHObject(address);
        if (hx::IsNotNull(hobjectRef)) {
            ((::bind::java::HObject)hobjectRef)->destroy();
        }

        hx::SetTopOfStack((int *)0, true);

    } //releaseHaxeObject
 
}
