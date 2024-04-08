#include <hxcpp.h>
#import <Foundation/Foundation.h>
#import <atomic>

// Substantial portions of this code taken from HaxeFoundation/HXCPP repository Objc helpers code.

// Objective-C class that wraps a Haxe class
@interface BindObjcHaxeWrapperClass : NSObject {

    @public hx::Object *haxeObject;

}

- (id)init:(hx::Object *)inHaxe;

- (void)dealloc;

@end

// Objective-C class that enqueues callbacks
// in order to run them at the right time,
// from the right thread.
@interface BindObjcHaxeQueue : NSObject {

    NSMutableArray *blockQueue;

    std::atomic<bool> hasBlocks;

}

+ (instancetype)sharedQueue;

- (void)enqueue:(void (^)(void))block;

- (void)enqueueSync:(void (^)(void))block callerThread:(NSThread *)callerThread;

- (void)flush;

@end

namespace bind {

    namespace objc {

        void flushHaxeQueue();

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
