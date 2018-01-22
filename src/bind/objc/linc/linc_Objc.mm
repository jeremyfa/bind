#import <Foundation/Foundation.h>
#import "linc_Objc.h"

// Substantial portions of this code taken from HaxeFoundation/HXCPP repository Objc helpers code.

@implementation BindObjcHaxeWrapperClass

- (id)init:( hx::Object * )inHaxe  {
   self = [super init];
   haxeObject = inHaxe;
   hx::GCAddRoot(&haxeObject);
   if (self!=nil) {
   }
   return self;
}

- (void)dealloc {
   GCRemoveRoot(&haxeObject);
   #ifndef OBJC_ARC
   [super dealloc];
   #endif
}

@end

namespace bind {

    namespace objc {

#ifndef HXCPP_OBJC

        class BindHaxeObjcData : public hx::Object
        {
        public:
            inline void *operator new( size_t inSize, hx::NewObjectType inAlloc=hx::NewObjAlloc,const char *inName="bind.objc.BoxedType")
            { return hx::Object::operator new(inSize,inAlloc,inName); }

            BindHaxeObjcData(const id inValue) : mValue(inValue)
            {
#ifndef OBJC_ARC
                [ inValue retain ];
#endif
                mFinalizer = new hx::InternalFinalizer(this,clean);
            };

            static void clean(hx::Object *inObj)
            {
                BindHaxeObjcData *m = dynamic_cast<BindHaxeObjcData *>(inObj);
                if (m)
                {
#ifndef OBJC_ARC
                    [m->mValue release];
#else
                    m->mValue = nil;
#endif
                }
            }

#ifdef HXCPP_VISIT_ALLOCS
            void __Visit(hx::VisitContext *__inCtx) { mFinalizer->Visit(__inCtx); }
#endif

            hx::Class __GetClass() const { return NULL; }

            #if (HXCPP_API_LEVEL<331)
            bool __Is(hx::Object *inClass) const { return dynamic_cast< ObjcData *>(inClass); }
            #endif

            // k_cpp_objc
            int __GetType() const { return vtAbstractBase + 4; }
#ifdef OBJC_ARC
            void * __GetHandle() const { return (__bridge void *) mValue; }
#else
            void * __GetHandle() const { return (void *) mValue; }
#endif
            String toString()
            {
                return String(!mValue ? "null" : [[mValue description] UTF8String]);
            }
            String __ToString() const { return String(!mValue ? "null" : [[mValue description] UTF8String]); }

            int __Compare(const hx::Object *inRHS) const
            {
                if (!inRHS)
                    return mValue == 0 ? 0 : 1;
                const BindHaxeObjcData *data = dynamic_cast< const BindHaxeObjcData *>(inRHS);
                if (data)
                {
                    return [data->mValue isEqual:mValue] ? 0 : mValue < data->mValue ? -1 : 1;
                }
                else
                {
                    void *r = inRHS->__GetHandle();

#ifdef OBJC_ARC
                    void * ptr = (__bridge void *) mValue;
#else
                    void * ptr = (void *) mValue;
#endif

                    return ptr < r ? -1 : ptr==r ? 0 : 1;
                }
            }

#ifdef OBJC_ARC
            id mValue;
#else
            const id mValue;
#endif
            hx::InternalFinalizer *mFinalizer;
        };
#endif

        NSString* HxcppToNSString(::String str) {
            if (hx::IsNull(str)) return nil;
            return @(str.c_str());
        }

        NSMutableString* HxcppToNSMutableString(::String str) {
            if (hx::IsNull(str)) return nil;
            return [NSMutableString stringWithUTF8String:str.c_str()];
        }

        const char* HxcppToConstCharString(::String str) {
            if (hx::IsNull(str)) return NULL;
            return str.c_str();
        }

        char* HxcppToCharString(::String str) {
            if (hx::IsNull(str)) return NULL;
            return (char*) str.c_str();
        }

        ::String NSStringToHxcpp(NSString* str) {
            if (str == nil) return null();
            const char* val = [str UTF8String];
            return ::String(val);
        }

        ::String CharStringToHxcpp(char* str) {
            const char* val = (const char*) str;
            return ::String(val);
        }

        ::String ConstCharStringToHxcpp(const char* str) {
            return ::String(str);
        }

        NSArray* HxcppToNSArray(::Dynamic d) {
            if (hx::IsNull(d)) return nil;

           cpp::VirtualArray varray = d;
           int len = varray->get_length();
           NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
           for (int i=0; i<len; i++) {
              id val = HxcppToObjcId( varray->__get(i) );
              if (val) {
                  array[i] = val;
              } else {
                  array[i] == [NSNull null];
              }
           }

           return array;
        }

        NSMutableArray* HxcppToNSMutableArray(::Dynamic d) {
            return [HxcppToNSArray(d) mutableCopy];
        }

        ::Dynamic NSArrayToHxcpp(NSArray* nsArray) {
            if (nsArray == nil) return null();

            cpp::VirtualArray varray = cpp::VirtualArray_obj::__new();
            for(id object in nsArray)
               varray->push( ObjcIdToHxcpp(object) );

            return varray;
        }

        NSDictionary* HxcppToNSDictionary(::Dynamic d)
        {
           if (d==null())
              return nil;

           Array<String> fields = Array_obj<String>::__new();
           d->__GetFields(fields);

           NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:fields->length ];
           NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:fields->length ];
           for(int i=0; i <fields->length; i++)
           {
              id val = HxcppToObjcId( d->__Field(fields[i], hx::paccDynamic ) );
              if (val) {
                  objects[i] = val;
              } else {
                  objects[i] = [NSNull null];
              }
              keys[i] = HxcppToNSString(fields[i]);
           }

           NSDictionary *result = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

           return result;
        }

        NSMutableDictionary* HxcppToNSMutableDictionary(::Dynamic d) {
            return [HxcppToNSDictionary(d) mutableCopy];
        }

        id HxcppToUnwrappedObjcId(::Dynamic inVal)
        {
            #ifndef HXCPP_OBJC
            return ((BindHaxeObjcData*)inVal.mPtr)->mValue;
            #else
            return ((ObjcData*)inVal.mPtr)->mValue;
            #endif
        }

        ::Dynamic NSDictionaryToHxcpp(NSDictionary *inDictionary)
        {
           if (!inDictionary)
              return null();
           hx::Anon obj = new hx::Anon_obj();

           for (NSString *key in inDictionary)
           {
              id value = inDictionary[key];
              obj->__SetField( String(key), ObjcIdToHxcpp(value), hx::paccDynamic);
           }
           return obj;
        }

        ::Dynamic ObjcIdToHxcpp(id value)
        {
            return ObjcIdToHxcppVal(value);
        }

        ::hx::Val ObjcIdToHxcppVal(id value)
        {
           if (value==nil || value==[NSNull null])
              return null();

           else if ([value isKindOfClass:[NSNumber class]])
              return [value floatValue];

           else if ([value isKindOfClass:[NSString class]])
              return String( (NSString *)value );

          else if ([value isKindOfClass:[NSDictionary class]])
              return NSDictionaryToHxcpp( (NSDictionary *) value);

          else if ([value isKindOfClass:[NSArray class]])
          {
              NSArray *array = value;
              cpp::VirtualArray varray = cpp::VirtualArray_obj::__new();
              for(id object in array)
                 varray->push( ObjcIdToHxcpp(object) );

              return varray;
          }
          else if ([value isKindOfClass:[NSData class]])
          {
             return NSDataToHxcpp(value);
          }
          else
             return WrappedObjcIdToHxcpp(value);
        }

        ::Dynamic WrappedObjcIdToHxcpp(const id inVal)
        {
            if (!inVal) {
                return Dynamic(0);
            }
            #ifndef HXCPP_OBJC
            return Dynamic((hx::Object *)new BindHaxeObjcData(inVal));
            #else
            return Dynamic((hx::Object *)new ObjcData(inVal));
            #endif
        }

        ::Array<unsigned char> NSDataToHxcpp(NSData *data)
        {
             return Array_obj<unsigned char>::fromData((const unsigned char *)data.bytes, data.length);
        }

        id HxcppToObjcId(::Dynamic d) {

           if (!d.mPtr)
              return nil;

           switch(d->__GetType())
           {
              case vtNull:
              case vtUnknown:
                return nil;

              case vtInt:
              case vtBool:
                 return [ NSNumber numberWithInt: (int)d ];
              case vtInt64:
                 return [ NSNumber numberWithLongLong: (cpp::Int64)d ];
              case vtFloat:
                 return [ NSNumber numberWithDouble: (double)d ];
              case vtString:
                 return HxcppToNSString(d);
              case vtObject:
                 return HxcppToNSDictionary(d);
              case vtArray:
                 {
                    Array_obj<unsigned char> *bytes = dynamic_cast< Array_obj<unsigned char> * >(d.mPtr);
                    if (bytes)
                    {
                       if (!bytes->length)
                          return [NSData alloc];
                       else
                          return [NSData dataWithBytes:bytes->GetBase() length:bytes->length];
                    }
                    else
                    {
                       cpp::VirtualArray varray = d;
                       int len = varray->get_length();
                       NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
                       for (int i=0; i<len; i++) {
                          id val = HxcppToObjcId( varray->__get(i) );
                          if (val) {
                              array[i] = val;
                          } else {
                              array[i] == [NSNull null];
                          }
                       }
                       return array;
                    }
                 }
              case vtClass:
                 if (d->__GetClass()->mName==HX_CSTRING("haxe.io.Bytes"))
                 {
                    return HxcppToObjcId( d->__Field( HX_CSTRING("b"), hx::paccDynamic ) );
                 }
                 // else fallthough...

              case vtFunction:
              case vtEnum:
              case vtAbstractBase:
                 {
                 return HxcppToNSString(d->toString());
                 }
           }
           return nil;
        }

    }

}
