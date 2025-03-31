#include <hxcpp.h>
#include <jni.h>

#ifndef BIND_JNI_CONCAT_INTERNAL
#define BIND_JNI_CONCAT_INTERNAL(a, b) a##b
#endif

#ifndef BIND_JNI_CONCAT
#define BIND_JNI_CONCAT(a, b) BIND_JNI_CONCAT_INTERNAL(a, b)
#endif

#ifndef BIND_JNI_SUPPORT
#define BIND_JNI_SUPPORT bind_Support
#endif

#ifndef BIND_JNI_FUNCTION
#define BIND_JNI_FUNCTION(package, function) BIND_JNI_CONCAT(Java_, BIND_JNI_CONCAT(package, BIND_JNI_CONCAT(_, function)))
#endif

namespace bindhx {

    namespace jni {

        JNIEnv *GetJNIEnv();

        jstring HxcppToJString(::String str);

        ::String JStringToHxcpp(jstring str);

        ::cpp::Pointer<void> ResolveJClass(::String className);

        ::cpp::Pointer<void> ResolveStaticJMethodID(::cpp::Pointer<void> jclassRef, ::String name, ::String signature);

        void ReleaseJObject(::cpp::Pointer<void> jobjectRef);

        jstring HObjectToJString(::Dynamic hobjectRef);

        ::Dynamic JStringToHObject(jstring address);

        void SetHasNativeRunnables(bool value);

        bool HasNativeRunnables();

        void RunAwaitingRunnables(::cpp::Pointer<void> class_, ::cpp::Pointer<void> method_);

        bool IsInitialized();

    }

}

extern "C" {

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, nativeInit)(JNIEnv *env, jclass clazz);

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, releaseHObject)(JNIEnv *env, jclass clazz, jstring address);

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, nativeSetHasRunnables)(JNIEnv *env, jclass clazz, jint value);

    JNIEXPORT void JNICALL BIND_JNI_FUNCTION(BIND_JNI_SUPPORT, notifyReady)(JNIEnv *env, jclass clazz);

}
