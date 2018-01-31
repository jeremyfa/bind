#include "linc_JNI.h"

#include <map>
#include <vector>
#include <string>

namespace bind {

    namespace jni {

        std::map<std::string, jclass> jclasses;
        JNIEnv *env;

        jstring HxcppToJString(::String str) {

            return env->NewStringUTF(str.c_str());

        } //HxcppToJString

        ::String JStringToHxcpp(jstring str) {

            jboolean is_copy;
            const char *c_str = env->GetStringUTFChars(str, &is_copy);
            ::String result = ::String(c_str);
            env->ReleaseStringUTFChars(str, c_str);
            return result;

        } //JStringToHxcpp

        ::cpp::Pointer<void> ResolveJClass(::String className) {
            
            jclass globalRef;
            std::string cppClassName(className.c_str());

            if (jclasses.find(cppClassName) != jclasses.end()) {
                return ::cpp::Pointer<void>(jclasses[cppClassName]);
            }
                
            jclass result = env->FindClass(className);
            
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

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env) {
        ::bind::jni::env = env;
    }
 
}
