#include "linc_JNI.h"

#include <map>
#include <string>
#include <atomic>

#ifndef INCLUDED_bind_java_HObject
#include <bindhx/java/HObject.h>
#endif

#ifndef INCLUDED_bind_java_Support
#include <bindhx/java/Support.h>
#endif

#include <android/log.h>

namespace bindhx {

    namespace jni {

        /** Java classes cache */
        std::map<std::string, jclass> jclasses;

        /** Whether Runnable instances are waiting to be executed from Haxe/Native thread */
        std::atomic<bool> hasNativeRunnables(false);

        /** Whether JNI is initialized and ready to use */
        std::atomic<bool> isInitialized(false);

        /** JNI env (attached to Haxe/Native thread) */
        JNIEnv *env = NULL;

        /** JNI jvm (use from any thread) */
        JavaVM *jvm = NULL;

        JNIEnv *GetJNIEnv() {

            JNIEnv *env = NULL;

            int stat = jvm->GetEnv((void **)&env, JNI_VERSION_1_6);
            if (stat == JNI_EDETACHED) {
                int status = jvm->AttachCurrentThread(&env, NULL);
                if (status < 0) {
                    return NULL;
                }
            }
            else if (stat == JNI_OK) {
                // Alright
            }
            else if (stat == JNI_EVERSION) {
                // Version not supported?
            }

            return env;

        }

        jstring HxcppToJString(::String str) {

            if (hx::IsNotNull(str)) {
                return GetJNIEnv()->NewStringUTF(str.c_str());
            }
            return NULL;

        }

        ::String JStringToHxcpp(jstring str) {

            if (str != NULL) {
                jboolean is_copy;
                const char *c_str = GetJNIEnv()->GetStringUTFChars(str, &is_copy);
                ::String result = ::String(c_str);
                GetJNIEnv()->ReleaseStringUTFChars(str, c_str);
                return result;
            }
            return null();

        }

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

        }

        ::cpp::Pointer<void> ResolveStaticJMethodID(::cpp::Pointer<void> jclassRef, ::String name, ::String signature) {

            jclass cls = (jclass) jclassRef.ptr;
            jmethodID mid = GetJNIEnv()->GetStaticMethodID(cls, name.c_str(), signature.c_str());

            if (!mid) {
                return null();
            }

            return ::cpp::Pointer<void>(mid);

        }

        void ReleaseJObject(::cpp::Pointer<void> jobjectRef) {

            jobject obj = (jobject) jobjectRef.ptr;
            GetJNIEnv()->DeleteGlobalRef(obj);

        }

        jstring HObjectToJString(::Dynamic hobjectRef) {

            if (hx::IsNotNull(hobjectRef)) {
                return HxcppToJString(::bindhx::java::HObject_obj::idOf(hobjectRef));
            }
            return NULL;

        }

        ::Dynamic JStringToHObject(jstring address) {

            if (address == NULL) return null();

            return ::bindhx::java::HObject_obj::getById(JStringToHxcpp(address));

        }

        void SetHasNativeRunnables(bool value) {

            hasNativeRunnables = value;

        }

        bool HasNativeRunnables() {

            return hasNativeRunnables.load();

        }

        void RunAwaitingRunnables(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_) {

            ::bindhx::jni::GetJNIEnv()->CallStaticVoidMethod((jclass) class_.ptr, (jmethodID) method_.ptr);

        }

        bool IsInitialized() {

            return isInitialized.load();

        }

    }

}

extern "C" {

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, nativeInit)(JNIEnv *env, jclass clazz) {

        // Keep java VM instance to get JNIEnv instance later on the correct thread
        JavaVM *jvm_;
        env->GetJavaVM(&jvm_);
        ::bindhx::jni::jvm = jvm_;

    }

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, notifyReady)(JNIEnv *env, jclass clazz) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::bindhx::jni::isInitialized = true;
        ::bindhx::java::Support_obj::notifyReady();

        hx::SetTopOfStack((int *)0, true);

    }

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, releaseHObject)(JNIEnv *env, jclass clazz, jstring address) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::Dynamic hobjectRef = ::bindhx::jni::JStringToHObject(address);
        if (hx::IsNotNull(hobjectRef)) {
            ((::bindhx::java::HObject)hobjectRef)->destroy();
        }

        hx::SetTopOfStack((int *)0, true);

    }

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, nativeSetHasRunnables)(JNIEnv *env, jclass clazz, jint value) {

        ::bindhx::jni::SetHasNativeRunnables(value != 0);

    }

}
