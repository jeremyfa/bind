#import "hxcpp.h"
#import "linc_Objc.h"
#import <Foundation/Foundation.h>
#import "linc_AppNativeInterface.h"
#import "objc_AppNativeInterface.h"

/** Example of Objective-C interface exposed to Haxe */
namespace ios {

    /** Get shared instance */
    ::Dynamic AppNativeInterface_sharedInterface() {
        AppNativeInterface* return_objc_ = [AppNativeInterface sharedInterface];
        ::Dynamic return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Say hello to `name` with a native iOS dialog. Add a last name if any is known. */
    void AppNativeInterface_hello(::Dynamic instance_, ::String name) {
        NSString* name_objc_ = ::bind::objc::HxcppToNSString(name);
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) hello:name_objc_];
    }

    /** If provided, will be called when root view controller is visible on screen */
    ::Dynamic AppNativeInterface_viewDidAppear(::Dynamic instance_) {
        id return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) viewDidAppear];
        ::Dynamic closure_return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        HX_BEGIN_LOCAL_FUNC_S1(hx::LocalFunc, _hx_Closure_return_hxcpp_, ::Dynamic, closure_return_hxcpp_) HXARGC(0)
        void _hx_run() {
            void (^closure_return_objc_)() = ::bind::objc::HxcppToUnwrappedObjcId(closure_return_hxcpp_);
            closure_return_objc_();
        }
        HX_END_LOCAL_FUNC0((void))
        ::Dynamic return_hxcpp_ = ::Dynamic(new _hx_Closure_return_hxcpp_(closure_return_hxcpp_));
        return return_hxcpp_;
    }

    /** If provided, will be called when root view controller is visible on screen */
    void AppNativeInterface_setViewDidAppear(::Dynamic instance_, ::Dynamic viewDidAppear) {
        BindObjcHaxeWrapperClass *viewDidAppear_objc_wrapper_ = [[BindObjcHaxeWrapperClass alloc] init:viewDidAppear.mPtr];
        void (^viewDidAppear_objc_)() = ^() {
            viewDidAppear_objc_wrapper_->haxeObject->__run();
        };
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) setViewDidAppear:viewDidAppear_objc_];
    }

    /** Last name. If provided, will be used when saying hello. */
    ::String AppNativeInterface_lastName(::Dynamic instance_) {
        NSString* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) lastName];
        ::String return_hxcpp_ = ::bind::objc::NSStringToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Last name. If provided, will be used when saying hello. */
    void AppNativeInterface_setLastName(::Dynamic instance_, ::String lastName) {
        NSString* lastName_objc_ = ::bind::objc::HxcppToNSString(lastName);
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) setLastName:lastName_objc_];
    }

}

