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

