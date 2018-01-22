#include <hxcpp.h>

// Substantial portions of this code taken from HaxeFoundation/HXCPP repository Objc helpers code.

// Objective-C class that wraps a Haxe class
@interface BindObjcHaxeWrapperClass : NSObject {

    @public hx::Object *haxeObject;

}

- (id)init:(hx::Object *)inHaxe;

- (void)dealloc;

@end


namespace bind {

    namespace objc {

        NSString* HxcppToNSString(::String str);

        NSMutableString* HxcppToNSMutableString(::String str);

        const char* HxcppToConstCharString(::String str);

        char* HxcppToCharString(::String str);

        NSArray* HxcppToNSArray(::Dynamic d);

        NSMutableArray* HxcppToNSMutableArray(::Dynamic d);

        NSDictionary* HxcppToNSDictionary(::Dynamic d);

        NSMutableDictionary* HxcppToNSMutableDictionary(::Dynamic d);

        id HxcppToObjcId(::Dynamic value);

        id HxcppToUnwrappedObjcId(::Dynamic inVal);


        ::String NSStringToHxcpp(NSString* str);

        ::String CharStringToHxcpp(char* str);

        ::String ConstCharStringToHxcpp(const char* str);

        ::Dynamic NSArrayToHxcpp(NSArray* nsArray);

        ::Dynamic NSDictionaryToHxcpp(NSDictionary *inDictionary);

        ::Dynamic ObjcIdToHxcpp(id value);

        ::hx::Val ObjcIdToHxcppVal(id value);

        ::Dynamic WrappedObjcIdToHxcpp(const id inVal);

        ::Array<unsigned char> NSDataToHxcpp(NSData *data);

    }

}
