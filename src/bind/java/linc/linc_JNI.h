#include <hxcpp.h>
#include <jni.h>

namespace bind {

    namespace jni {

        JNIEnv *GetJNIEnv();

        jstring HxcppToJString(::String str);

        ::String JStringToHxcpp(jstring str);

        ::cpp::Pointer<void> ResolveJClass(::String className);

        ::cpp::Pointer<void> ResolveStaticJMethodID(::cpp::Pointer<void> jclassRef, ::String name, ::String signature);

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env);
 
}
