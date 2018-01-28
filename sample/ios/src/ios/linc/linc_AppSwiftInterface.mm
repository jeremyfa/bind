#import "hxcpp.h"
#import "linc_Objc.h"
#import <Foundation/Foundation.h>
#import "linc_AppSwiftInterface.h"
#import "objc_IosSampleSwift-Swift.h"

/** Swift interface */
namespace ios {

    ::Dynamic AppSwiftInterface_sharedInterface() {
        AppSwiftInterface* return_objc_ = [AppSwiftInterface sharedInterface];
        ::Dynamic return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Say hello to <code>name</code> with a native iOS dialog. Add a last name if any is known. */
    void AppSwiftInterface_hello(::Dynamic instance_, ::String name, ::Dynamic done) {
        NSString* name_objc_ = ::bind::objc::HxcppToNSString(name);
        BindObjcHaxeWrapperClass *done_objc_wrapper_ = [[BindObjcHaxeWrapperClass alloc] init:done.mPtr];
        void (^done_objc_)() = ^() {
            done_objc_wrapper_->haxeObject->__run();
        };
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) hello:name_objc_ done:done_objc_];
    }

    /** Get iOS version string */
    ::String AppSwiftInterface_iosVersionString(::Dynamic instance_) {
        NSString* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) iosVersionString];
        ::String return_hxcpp_ = ::bind::objc::NSStringToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Get iOS version number */
    double AppSwiftInterface_iosVersionNumber(::Dynamic instance_) {
        float return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) iosVersionNumber];
        double return_hxcpp_ = (double) return_objc_;
        return return_hxcpp_;
    }

    /** Dummy method to get Haxe types converted to Swift types that then get returned back as an array. */
    ::Dynamic AppSwiftInterface_testTypes(::Dynamic instance_, bool aBool, int anInt, double aFloat, ::Dynamic anArray, ::Dynamic aDict) {
        BOOL aBool_objc_ = (BOOL) aBool;
        NSInteger anInt_objc_ = (NSInteger) anInt;
        float aFloat_objc_ = (float) aFloat;
        NSArray* anArray_objc_ = ::bind::objc::HxcppToNSArray(anArray);
        NSDictionary<NSString*,id>* aDict_objc_ = ::bind::objc::HxcppToObjcId((Dynamic)aDict);
        NSArray* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) testTypes:aBool_objc_ anInt:anInt_objc_ aFloat:aFloat_objc_ anArray:anArray_objc_ aDict:aDict_objc_];
        ::Dynamic return_hxcpp_ = ::bind::objc::ObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    ::Dynamic AppSwiftInterface_init() {
        AppSwiftInterface* return_objc_ = [[AppSwiftInterface alloc] init];
        ::Dynamic return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** If provided, will be called when root view controller is visible on screen */
    ::Dynamic AppSwiftInterface_viewDidAppear(::Dynamic instance_) {
        id return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) viewDidAppear];
        ::Dynamic closure_return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        HX_BEGIN_LOCAL_FUNC_S1(hx::LocalFunc, _hx_Closure_return_hxcpp_, ::Dynamic, closure_return_hxcpp_) HXARGC(1)
        void _hx_run(bool arg2) {
            BOOL arg1_objc_ = (BOOL) arg1;
            void (^closure_return_objc_)(BOOL arg1) = ::bind::objc::HxcppToUnwrappedObjcId(closure_return_hxcpp_);
            closure_return_objc_(arg1_objc_);
        }
        HX_END_LOCAL_FUNC1((void))
        ::Dynamic return_hxcpp_ = ::Dynamic(new _hx_Closure_return_hxcpp_(closure_return_hxcpp_));
        return return_hxcpp_;
    }

    /** If provided, will be called when root view controller is visible on screen */
    void AppSwiftInterface_setViewDidAppear(::Dynamic instance_, ::Dynamic viewDidAppear) {
        BindObjcHaxeWrapperClass *viewDidAppear_objc_wrapper_ = [[BindObjcHaxeWrapperClass alloc] init:viewDidAppear.mPtr];
        void (^viewDidAppear_objc_)(BOOL arg1) = ^(BOOL arg2) {
            bool arg1_hxcpp_ = (bool) arg1;
            viewDidAppear_objc_wrapper_->haxeObject->__run(arg1_hxcpp_);
        };
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) setViewDidAppear:viewDidAppear_objc_];
    }

    /** Define a last name for hello() */
    ::String AppSwiftInterface_lastName(::Dynamic instance_) {
        NSString* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) lastName];
        ::String return_hxcpp_ = ::bind::objc::NSStringToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Define a last name for hello() */
    void AppSwiftInterface_setLastName(::Dynamic instance_, ::String lastName) {
        NSString* lastName_objc_ = ::bind::objc::HxcppToNSString(lastName);
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) setLastName:lastName_objc_];
    }

}

