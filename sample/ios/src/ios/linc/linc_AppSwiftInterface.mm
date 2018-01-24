#import "hxcpp.h"
#import "linc_Objc.h"
#import <Foundation/Foundation.h>
#import "linc_AppSwiftInterface.h"
#import "objc_IosSampleSwift-Swift.h"

/** Swift interface */
namespace ios {

    /** Say hello to name */
    void AppSwiftInterface_helloSwift(::Dynamic instance_, ::String name) {
        NSString* name_objc_ = ::bind::objc::HxcppToNSString(name);
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) helloSwift:name_objc_];
    }

    ::Dynamic AppSwiftInterface_init() {
        AppSwiftInterface* return_objc_ = [[AppSwiftInterface alloc] init];
        ::Dynamic return_hxcpp_ = ::bind::objc::WrappedObjcIdToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Define a last name for helloSwift */
    ::String AppSwiftInterface_lastName(::Dynamic instance_) {
        NSString* return_objc_ = [::bind::objc::HxcppToUnwrappedObjcId(instance_) lastName];
        ::String return_hxcpp_ = ::bind::objc::NSStringToHxcpp(return_objc_);
        return return_hxcpp_;
    }

    /** Define a last name for helloSwift */
    void AppSwiftInterface_setLastName(::Dynamic instance_, ::String lastName) {
        NSString* lastName_objc_ = ::bind::objc::HxcppToNSString(lastName);
        [::bind::objc::HxcppToUnwrappedObjcId(instance_) setLastName:lastName_objc_];
    }

}

