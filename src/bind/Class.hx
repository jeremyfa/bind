package bind;

typedef Class = {

    var name:String;

    var path:String;

    var properties:Array<bind.Property>;

    var methods:Array<bind.Method>;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Property = {

    var name:String;

    var type:bind.Type;

    var instance:Bool;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Method = {

    var name:String;

    var args:Array<bind.Arg>;

    var type:bind.Type;

    var instance:Bool;

    var description:String;

    @:optional var orig:Dynamic;

}

typedef Arg = {

    var name:String;

    var type:bind.Type;

    @:optional var orig:Dynamic;

}

enum Type {

    Void(?orig:Dynamic);

    Int(?orig:Dynamic);

    Float(?orig:Dynamic);

    Bool(?orig:Dynamic);

    String(?orig:Dynamic);

    Array(?itemType:bind.Type, ?orig:Dynamic);

    Map(?itemType:bind.Type, ?orig:Dynamic);

    Object(?orig:Dynamic);

    Function(args:Array<bind.Arg>, ret:bind.Type, ?orig:Dynamic);

}
