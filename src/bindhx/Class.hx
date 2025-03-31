package bindhx;

typedef Class = {

    var name:String;

    var path:String;

    var properties:Array<bindhx.Property>;

    var methods:Array<bindhx.Method>;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Property = {

    var name:String;

    var type:bindhx.Type;

    var instance:Bool;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Method = {

    var name:String;

    var args:Array<bindhx.Arg>;

    var type:bindhx.Type;

    var instance:Bool;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Arg = {

    var name:String;

    var type:bindhx.Type;

    @:optional var orig:Dynamic;

}

enum Type {

    Void(?orig:Dynamic);

    Int(?orig:Dynamic);

    Float(?orig:Dynamic);

    Bool(?orig:Dynamic);

    String(?orig:Dynamic);

    Array(?itemType:bindhx.Type, ?orig:Dynamic);

    Map(?itemType:bindhx.Type, ?orig:Dynamic);

    Object(?orig:Dynamic);

    Function(args:Array<bindhx.Arg>, ret:bindhx.Type, ?orig:Dynamic);

}
