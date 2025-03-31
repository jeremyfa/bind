#include "linc_CS.h"

#include <map>
#include <string>
#include <atomic>

#ifndef INCLUDED_bind_cs_HObject
#include <bindhx/cs/HObject.h>
#endif

#ifndef INCLUDED_bind_cs_Support
#include <bindhx/cs/Support.h>
#endif

namespace bindhx {

    namespace cs {

        static BIND_CS_TYPEDEF_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions) BIND_CS_PTR_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions) = nullptr;

        /** Whether Action instances are waiting to be executed from Haxe/Native thread */
        std::atomic<bool> hasNativeActions(false);

        /** Whether C# side is initialized and ready to use */
        std::atomic<bool> isInitialized(false);

        const char * HxcppToCSString(::String str) {

            if (hx::IsNotNull(str)) {
                // Ok, because the hx string will be retained long enough
                // (TODO: retain on haxe side though!)
                return str.c_str();
            }
            return nullptr;

        }

        ::String CSStringToHxcpp(const char * str) {

            if (str != nullptr) {
                ::String result = ::String(str); // Makes a copy of (C) str
                return result;
            }
            return null();

        }

        void ReleaseCSObject(::cpp::Pointer<void> csobjectRef) {

            // Not supported at the moment

        }

        const char * HObjectToCSString(::Dynamic hobjectRef) {

            if (hx::IsNotNull(hobjectRef)) {
                return HxcppToCSString(::bindhx::cs::HObject_obj::idOf(hobjectRef));
            }
            return nullptr;

        }

        ::Dynamic CSStringToHObject(const char * address) {

            if (address == nullptr) return null();

            return ::bindhx::cs::HObject_obj::getById(CSStringToHxcpp(address));

        }

        void SetHasNativeActions(bool value) {

            hasNativeActions = value;

        }

        bool HasNativeActions() {

            return hasNativeActions.load();

        }

        void RunAwaitingActions() {

            BIND_CS_PTR_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions)();

        }

        bool IsInitialized() {

            return isInitialized.load();

        }

    }

}

extern "C" {

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NativeInit)(void *runAwaitingNativeActions_ptr) {

        ::bindhx::cs::BIND_CS_PTR_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions) =
            reinterpret_cast<::bindhx::cs::BIND_CS_TYPEDEF_FUNCTION(BIND_CS_SUPPORT, RunAwaitingNativeActions)>(runAwaitingNativeActions_ptr);

    }

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NotifyReady)() {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::bindhx::cs::isInitialized = true;
        ::bindhx::cs::Support_obj::notifyReady();

        hx::SetTopOfStack((int *)0, true);

    }

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, ReleaseHObject)(const char* address) {

        int haxe_stack_ = 99;
        hx::SetTopOfStack(&haxe_stack_, true);

        ::Dynamic hobjectRef = ::bindhx::cs::CSStringToHObject(address);
        if (hx::IsNotNull(hobjectRef)) {
            ((::bindhx::cs::HObject)hobjectRef)->destroy();
        }

        hx::SetTopOfStack((int *)0, true);

    }

    BIND_CS_EXPORT void BIND_CS_FUNCTION(BIND_CS_SUPPORT, NativeSetHasActions)(int value) {

        ::bindhx::cs::SetHasNativeActions(value != 0);

    }

}
