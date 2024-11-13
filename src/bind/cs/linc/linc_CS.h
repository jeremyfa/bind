#include <hxcpp.h>

#ifndef BIND_CS_EXPORT
    #if defined _WIN32 || defined __CYGWIN__
        #ifdef __GNUC__
            #define BIND_CS_EXPORT __attribute__ ((dllexport))
        #else
            #define BIND_CS_EXPORT __declspec(dllexport)
        #endif
    #else
        #if __GNUC__ >= 4
            #define BIND_CS_EXPORT __attribute__ ((visibility ("default")))
        #else
            #define BIND_CS_EXPORT
        #endif
    #endif
#endif

#ifndef BIND_CS_CONCAT_INTERNAL
#define BIND_CS_CONCAT_INTERNAL(a, b) a##b
#endif

#ifndef BIND_CS_CONCAT
#define BIND_CS_CONCAT(a, b) BIND_CS_CONCAT_INTERNAL(a, b)
#endif

#ifndef BIND_CS_SUPPORT
#define BIND_CS_SUPPORT Bind_Support
#endif

#ifndef BIND_CS_FUNCTION
#define BIND_CS_FUNCTION(package, function) BIND_CS_CONCAT(CS_, BIND_CS_CONCAT(package, BIND_CS_CONCAT(_, function)))
#endif

#ifndef BIND_CS_TYPEDEF_FUNCTION
#define BIND_CS_TYPEDEF_FUNCTION(package, function) BIND_CS_CONCAT(CS_, BIND_CS_CONCAT(package, BIND_CS_CONCAT(_, BIND_CS_CONCAT(function, _CSFunc_))))
#endif

#ifndef BIND_CS_PTR_FUNCTION
#define BIND_CS_PTR_FUNCTION(package, function) BIND_CS_CONCAT(CS_, BIND_CS_CONCAT(package, BIND_CS_CONCAT(_, BIND_CS_CONCAT(function, _csfunc_))))
#endif

#ifndef BIND_CS_LINC_FUNCTION
#define BIND_CS_LINC_FUNCTION(package, function) BIND_CS_CONCAT(package, BIND_CS_CONCAT(_, function))
#endif

namespace bind {

    namespace cs {

        typedef void (BIND_CS_TYPEDEF_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions)*)()

        const char * HxcppToCSString(::String str);

        ::String CSStringToHxcpp(const char * str);

        void ReleaseCSObject(::cpp::Pointer<void> csobjectRef);

        jstring HObjectToCSString(::Dynamic hobjectRef);

        ::Dynamic CSStringToHObject(const char * address);

        void SetHasNativeActions(bool value);

        bool HasNativeActions(void);

        void RunAwaitingActions(void);

        bool IsInitialized(void);

    }

}

extern "C" {

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NativeInit)(void *runAwaitingNativeActions_ptr);

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, ReleaseHObject)(const char* address);

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NativeSetHasActions)(int value);

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NotifyReady)(void);

}
