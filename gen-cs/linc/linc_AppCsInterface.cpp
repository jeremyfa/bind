#include "linc_CSharp.h"
#include "linc_AppCsInterface.h"
#ifndef INCLUDED_bind_csharp_HObject
#include <bind/csharp/HObject.h>
#endif

namespace myapp {

    namespace unity {

        /** Load audio */
        void AppCsInterface_Load(int audioId, ::String url, bool autoplay, ::Dynamic onProgress, ::Dynamic onWarning, ::Dynamic onError) {
            int audioId_csc_ = (int) audioId;
            const char* url_csc_ = ::bind::cs::HxcppToCSString(url);
            int autoplay_csc_ = (int) autoplay;
            const char* onProgress_csc_ = ::bind::cs::HObjectToCSString(onProgress);
            const char* onWarning_csc_ = ::bind::cs::HObjectToCSString(onWarning);
            const char* onError_csc_ = ::bind::cs::HObjectToCSString(onError);
            // TODO C# C call
        }


    }

}

extern "C" {

    void CS_Sample_AppCsInterface_CallN_BoolBoolDoubleVoid(const char* address, int arg1, int arg2, double arg3) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        bool arg1_hxcpp_ = (arg1 != 0 ? true : false);
        bool arg2_hxcpp_ = (arg2 != 0 ? true : false);
        double arg3_hxcpp_ = (double) arg3;
        ::Dynamic func_hobject_ = ::bind::cs::CSStringToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::cs::HObject_obj::unwrap(func_hobject_);
        func_unwrapped_->__run(arg1_hxcpp_, arg2_hxcpp_, arg3_hxcpp_);
        hx::SetTopOfStack((int *)0, true);
    }

    void CS_Sample_AppCsInterface_CallN_StringVoid(const char* address, const char* arg1) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        ::String arg1_hxcpp_ = ::bind::cs::CSStringToHxcpp(arg1);
        ::Dynamic func_hobject_ = ::bind::cs::CSStringToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::cs::HObject_obj::unwrap(func_hobject_);
        func_unwrapped_->__run(arg1_hxcpp_);
        hx::SetTopOfStack((int *)0, true);
    }

    void CS_Sample_AppCsInterface_CallN_Void(const char* address) {
        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);
        ::Dynamic func_hobject_ = ::bind::cs::CSStringToHObject(address);
        ::Dynamic func_unwrapped_ = ::bind::cs::HObject_obj::unwrap(func_hobject_);
        func_unwrapped_->__run();
        hx::SetTopOfStack((int *)0, true);
    }

}

