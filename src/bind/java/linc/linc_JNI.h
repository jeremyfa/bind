#include <hxcpp.h>
#include <jni.h>

namespace bind {

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

    JNIEXPORT void JNICALL Java_bind_Support_nativeInit(JNIEnv *env, jclass clazz);
    
    JNIEXPORT void JNICALL Java_bind_Support_releaseHaxeObject(JNIEnv *env, jclass clazz, jstring address);

    JNIEXPORT void JNICALL Java_bind_Support_nativeSetHasRunnables(JNIEnv *env, jclass clazz, jint value);

    JNIEXPORT void JNICALL Java_bind_Support_notifyReady(JNIEnv *env, jclass clazz);
 
}
