#include <hxcpp.h>

namespace myapp {

    namespace unity {

        /** Load audio */
        void AppCsInterface_Load(int audioId, ::String url, bool autoplay, ::Dynamic onProgress, ::Dynamic onWarning, ::Dynamic onError);

    }

}

extern "C" {

    void CS_Sample_AppCsInterface_CallN_BoolBoolDoubleVoid(const char* address, int arg1, int arg2, double arg3);

    void CS_Sample_AppCsInterface_CallN_StringVoid(const char* address, const char* arg1);

    void CS_Sample_AppCsInterface_CallN_Void(const char* address);

}

