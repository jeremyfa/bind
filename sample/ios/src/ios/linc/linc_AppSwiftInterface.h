#import "hxcpp.h"

/** Swift interface */
namespace ios {

    /** Say hello to name */
    void AppSwiftInterface_helloSwift(::Dynamic instance_, ::String name);

    ::Dynamic AppSwiftInterface_init();

    /** Define a last name for helloSwift */
    ::String AppSwiftInterface_lastName(::Dynamic instance_);

    /** Define a last name for helloSwift */
    void AppSwiftInterface_setLastName(::Dynamic instance_, ::String lastName);

}

