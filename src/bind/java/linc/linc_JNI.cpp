#include "linc_JNI.h"

#include <map>
#include <string>
#include <atomic>

#ifndef INCLUDED_bind_java_HObject
#include <bind/java/HObject.h>
#endif

#ifndef INCLUDED_bind_java_Support
#include <bind/java/Support.h>
#endif

#include <android/log.h>

namespace bind {

    namespace jni {

        /** Java classes cache */
        std::map<std::string, jclass> jclasses;

        /** A counter to provide addresses as long type */
        std::atomic<int64_t> nextAddress(2);

        /** Mapping of kepts Haxe object pointers */
        std::map<int64_t,hx::Object*> hobjectMap;

        /** Whether Runnable instances are waiting to be executed from Haxe/Native thread */
        std::atomic<bool> hasNativeRunnables(false);

        /** Whether JNI is initialized and ready to use */
        std::atomic<bool> isInitialized(false);

        /** JNI env (attached to Haxe/Native thread) */
        JNIEnv *env = NULL;

        /** JNI jvm (use from any thread) */
        JavaVM *jvm = NULL;

        JNIEnv *GetJNIEnv() {

            if (env == NULL) {
                JNIEnv *env_;
                int status = jvm->AttachCurrentThread(&env_, NULL);
                if (status < 0) {
                    return NULL;
                }
                env = env_;
            }

            return env;

        } //GetJNIEnv

        jstring HxcppToJString(::String str) {

            if (hx::IsNotNull(str)) {
                return GetJNIEnv()->NewStringUTF(str.c_str());
            }
            return NULL;

        } //HxcppToJString

        ::String JStringToHxcpp(jstring str) {

            if (str != NULL) {
                jboolean is_copy;
                const char *c_str = GetJNIEnv()->GetStringUTFChars(str, &is_copy);
                ::String result = ::String(c_str);
                GetJNIEnv()->ReleaseStringUTFChars(str, c_str);
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
                
            jclass result = GetJNIEnv()->FindClass(className.c_str());
            
            if (!result) {
                return null();
            }
            
            globalRef = (jclass)GetJNIEnv()->NewGlobalRef(result);
            jclasses[cppClassName] = globalRef;
            GetJNIEnv()->DeleteLocalRef(result);
            
            return ::cpp::Pointer<void>(globalRef);
            
        } //ResolveJClass

        ::cpp::Pointer<void> ResolveStaticJMethodID(::cpp::Pointer<void> jclassRef, ::String name, ::String signature) {
            
            jclass cls = (jclass) jclassRef.ptr;
            jmethodID mid = GetJNIEnv()->GetStaticMethodID(cls, name.c_str(), signature.c_str());

            if (!mid) {
                return null();
            }

            return ::cpp::Pointer<void>(mid);
            
        } //ResolveStaticJMethodID

        void ReleaseJObject(::cpp::Pointer<void> jobjectRef) {

            jobject obj = (jobject) jobjectRef.ptr;
            GetJNIEnv()->DeleteGlobalRef(obj);

        } //ReleaseJObject

        jstring HObjectToJString(::Dynamic hobjectRef) {

            if (hx::IsNotNull(hobjectRef)) {
                /*int64_t address = nextAddress++;
                while (hobjectMap.find(address) != hobjectMap.end()) {
                    address = nextAddress++;
                }
                __android_log_print(ANDROID_LOG_ERROR, "BIND", "NEW ADDRESS: %lld", (unsigned long long)address);
                hx::Object *objPointer = hobjectRef.mPtr;
                hobjectMap[address] = objPointer;
                jlong addr = (jlong) address;
                __android_log_print(ANDROID_LOG_ERROR, "BIND", "NEW ADDRESS: %lld", (unsigned long long)addr);
                return addr;*/
                return HxcppToJString(::bind::java::HObject_obj::idOf(hobjectRef));
            }
            return NULL;

        } //HObjectToJString

        ::Dynamic JStringToHObject(jstring address) {

            if (address == NULL) return null();

            /*int64_t address = (int64_t) addr;
             __android_log_print(ANDROID_LOG_ERROR, "BIND", "GET FROM ADDR: %lld", (unsigned long long)address);

            if (address == 0) {
                return null();
            }
            hx::Object *objPointer = hobjectMap[address];
            ::Dynamic result = ::Dynamic();
            result.mPtr = objPointer;
            return result;*/

            return ::bind::java::HObject_obj::getById(JStringToHxcpp(address));

        } //JStringToHObject

        void SetHasNativeRunnables(bool value) {

            hasNativeRunnables = value;

        } //SetHasNativeRunnables

        bool HasNativeRunnables() {

            return hasNativeRunnables.load();

        } //HasNativeRunnables

        void RunAwaitingRunnables(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_) {

            ::bind::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr);

        } //RunAndReleaseRunnable

        bool IsInitialized() {

            return isInitialized.load();

        } //IsInitialized

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_nativeInit(JNIEnv *env, jclass clazz) {

        // Keep java VM instance to get JNIEnv instance later on the correct thread
        JavaVM *jvm_;
        env->GetJavaVM(&jvm_);
        ::bind::jni::jvm = jvm_;

    } //init

    JNIEXPORT void JNICALL Java_bind_Support_notifyReady(JNIEnv *env, jclass clazz) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::bind::jni::isInitialized = true;
        ::bind::java::Support_obj::notifyReady();

        hx::SetTopOfStack((int *)0, true);

    } //notifyReady

    JNIEXPORT void JNICALL Java_bind_Support_releaseHaxeObject(JNIEnv *env, jclass clazz, jstring address) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::Dynamic hobjectRef = ::bind::jni::JStringToHObject(address);
        //::bind::jni::hobjectMap.erase(address);
        if (hx::IsNotNull(hobjectRef)) {
            ((::bind::java::HObject)hobjectRef)->destroy();
        }

        hx::SetTopOfStack((int *)0, true);

    } //releaseHaxeObject

    JNIEXPORT void JNICALL Java_bind_Support_nativeSetHasRunnables(JNIEnv *env, jclass clazz, jint value) {

        ::bind::jni::SetHasNativeRunnables(value != 0);

    } //nativeSetHasRunnables
 
}
