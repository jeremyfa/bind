#include <hxcpp.h>
#include <jni.h>

namespace bind {

    namespace jni {

        jstring HxcppToJString(::String str);

        ::String JStringToHxcpp(jstring str);

        int ResolveJClassRef(::String className);

        inline jclass JClassFromRef(int index);

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env);
 
}
