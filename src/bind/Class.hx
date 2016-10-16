package bind;

typedef Class = {

    var name:String;

    var path:String;

    var properties:Array<bind.Property>;

    var methods:Array<bind.Method>;

    var description:String;

} //Class

typedef Property = {

    var name:String;

    var type:bind.Type;

    var instance:Bool;

    var description:String;

} //Property

typedef Method = {

    var name:String;

    var args:Array<bind.Arg>;

    var type:bind.Type;

    var instance:Bool;

    var description:String;

} //Method

typedef Arg = {

    var name:String;

    var type:bind.Type;

} //Arg

enum Type {

    Int;

    Float;

    Bool;

    String;

    Array;

    Map;

    Object;

    Function(args:Array<bind.Arg>);

} //Type
