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
    void AppNativeInterface_hello(::Dynamic instance_, ::String name, ::Dynamic done) {
        NSString* name_objc_ = ::bind::objc::HxcppToNSString(name);
        BindObjcHaxeWrapperClass *done_objc_wrapper_ = [[BindObjcHaxeWrapperClass alloc] init:done.mPtr];
        void (^done_objc_)() = ^() {
            done_objc_wrapper_->haxeObject->__run();
        };
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) hello:name_objc_ done:done_objc_];
    }

    /** Get iOS version string */
    ::String AppNativeInterface_iosVersionString(::Dynamic instance_) {
        NSString* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) iosVersionString];
        ::String return_hxcpp_ = ::bind::objc::NSStringToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Get iOS version number */
    double AppNativeInterface_iosVersionNumber(::Dynamic instance_) {
        CGFloat return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) iosVersionNumber];
        double return_hxcpp_ = (double) return_objc_;
        return return_hxcpp_;
    }

    /** Dummy method to get Haxe types converted to ObjC types that then get returned back as an array. */
    ::Dynamic AppNativeInterface_testTypes(::Dynamic instance_, bool aBool, int anInt, double aFloat, ::Dynamic anArray, ::Dynamic aDict) {
        BOOL aBool_objc_ = (BOOL) aBool;
        NSInteger anInt_objc_ = (NSInteger) anInt;
        CGFloat aFloat_objc_ = (CGFloat) aFloat;
        NSArray* anArray_objc_ = ::bind::objc::HxcppToNSArray(anArray);
        NSDictionary* aDict_objc_ = ::bind::objc::HxcppToObjcId((Dynamic)aDict);
        NSArray* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) testTypes:aBool_objc_ anInt:anInt_objc_ aFloat:aFloat_objc_ anArray:anArray_objc_ aDict:aDict_objc_];
        ::Dynamic return_hxcpp_ = ::bind::objc::ObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    ::Dynamic AppNativeInterface_init() {
        AppNativeInterface* return_objc_ = [[AppNativeInterface alloc] init];
        ::Dynamic return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
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

