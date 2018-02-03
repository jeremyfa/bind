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

        jlong HObjectToJLong(::Dynamic hobjectRef);

        ::Dynamic JLongToHObject(jlong jlongValue);

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env);
    
    JNIEXPORT void JNICALL Java_bind_Support_releaseHaxeObject(JNIEnv *env, jlong address);
 
}
