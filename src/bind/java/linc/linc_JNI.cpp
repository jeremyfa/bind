#include "linc_JNI.h"

#include <map>
#include <vector>
#include <string>

namespace bind {

    namespace jni {

        std::map<std::string, int> _jclassIndexes;
        std::vector<jclass> _jclasses;
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

        int ResolveJClassRef(::String className) {
            
            jclass globalRef;
            std::string cppClassName(className.c_str());
            int index = -1;
                
            jclass tmp = env->FindClass(className);
            
            if (!tmp) {
                return -1;
            }
            
            globalRef = (jclass)env->NewGlobalRef(tmp);
            if (_jclassIndexes.find(cppClassName) == _jclassIndexes.end()) {
                index = _jclasses.size();
                _jclasses.push_back(globalRef);
                _jclassIndexes[cppClassName] = index;
            } else {
                index = _jclassIndexes[cppClassName];
                _jclasses[index] = globalRef;
            }
            env->DeleteLocalRef(tmp);
            
            return index;
            
        } //ResolveJClassRef

        inline jclass JClassFromRef(int index) {

            return index >= 0 ? _jclasses[index] : NULL;

        } //JClassFromRef

    }

}

extern "C" {

    JNIEXPORT void JNICALL Java_bind_Support_init(JNIEnv *env) {
        ::bind::jni::env = env;
    }
 
}
