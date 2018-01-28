package bind.java;

import Sys.println;

using StringTools;

typedef ParseContext = {
    var i:Int;
    var types:Map<String,bind.Class.Type>;
}

class Parse {

    public static function createContext():ParseContext {
        return { i: 0, types: new Map() };
    }

    /** Parse Objective-C header content to get class informations. */
    public static function parseClass(code:String, ?ctx:ParseContext):bind.Class {

        //

        return null;

    } //parseClass

} //Parse
