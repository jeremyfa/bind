package bind;

/** Utility to convert bind.CLass format to/from JSON,
    including bind.Class.Type enums. */
class Json {

    /** Get JSON output with correct bind.Class.Type enum serialization */
    public static function stringify(input:Dynamic, pretty:Bool = false):String {

        return haxe.Json.stringify(toJson(input), null, pretty ? '    ' : null);

    } //stringify

    /** Parse JSON input and restores bind.Class.Type enum instances */
    public static function parse(input:String):Dynamic {

        return fromJson(haxe.Json.parse(input));

    } //parse

/// Internal (to json)

    static function toJson(input:Dynamic):Dynamic {

        if (input == null) {
            return null;
        }
        else if (Std.is(input, Array)) {
            var array:Array<Dynamic> = input;
            var result = [];
            for (item in array) {
                result.push(toJson(item));
            }
            return result;
        }
        else if (Std.is(input, String) || Std.is(input, Int) || Std.is(input, Float) || Std.is(input, Bool)) {
            return input;
        }
        else {
            var result:Dynamic = {};

            for (key in Reflect.fields(input)) {

                var value:Dynamic = Reflect.field(input, key);
                if (Reflect.isEnumValue(value)) {
                    if (key == 'type') {
                        // bind.Class.Type enum
                        var res:Dynamic = typeEnumToJson(value);
                        Reflect.setField(result, key, res);
                    }
                    else {
                        // Unsupported enum
                        Reflect.setField(result, key, null);
                    }
                }
                else {
                    Reflect.setField(result, key, toJson(value));
                }
            }

            return result;
        }

    } //toJson

    static function typeEnumToJson(value:bind.Class.Type):Dynamic {

        return switch (value) {
            case Void(orig): { Void: {orig: toJson(orig)} };
            case Int(orig): { Int: {orig: toJson(orig)} };
            case Float(orig): { Float: {orig: toJson(orig)} };
            case Bool(orig): { Bool: {orig: toJson(orig)} };
            case String(orig): { String: {orig: toJson(orig)} };
            case Array(orig): { Array: {orig: toJson(orig)} };
            case Map(orig): { Map: {orig: toJson(orig)} };
            case Object(orig): { Object: {orig: toJson(orig)} };
            case Function(args, ret, orig): { Function: {args: toJson(args), ret: typeEnumToJson(ret), orig: toJson(orig)} };
        }

    } //typeEnumToJson

/// Internal (to json)

    static function fromJson(input:Dynamic):Dynamic {

        if (input == null) {
            return null;
        }
        else if (Std.is(input, Array)) {
            var array:Array<Dynamic> = input;
            var result = [];
            for (item in array) {
                result.push(fromJson(item));
            }
            return result;
        }
        else if (Std.is(input, String) || Std.is(input, Int) || Std.is(input, Float) || Std.is(input, Bool)) {
            return input;
        }
        else {
            var result:Dynamic = {};

            for (key in Reflect.fields(input)) {

                var value:Dynamic = Reflect.field(input, key);
                var isTypeEnum = false;

                if (key == 'type'
                && value != null
                && !Std.is(value, String)
                && !Std.is(input, Int)
                && !Std.is(input, Float)
                && !Std.is(input, Bool)
                && !Std.is(input, Array)) {

                    var subKeys = Reflect.fields(value);
                    if (subKeys.length == 1
                        && subKeys[0].charAt(0).toUpperCase() == subKeys[0].charAt(0)) {

                        isTypeEnum = true;
                    }
                }

                if (isTypeEnum) {
                    var res:Dynamic = typeEnumFromJson(value);
                    Reflect.setField(result, key, res);
                }
                else {
                    Reflect.setField(result, key, fromJson(value));
                }
            }

            return result;
        }

    } //fromJson

    static function typeEnumFromJson(value:Dynamic):bind.Class.Type {

        var name = Reflect.fields(value)[0];
        var params:Dynamic = Reflect.field(value, name);

        return switch (name) {
            case 'Void': Void(fromJson(params.orig));
            case 'Int': Int(fromJson(params.orig));
            case 'Float': Float(fromJson(params.orig));
            case 'Bool': Bool(fromJson(params.orig));
            case 'String': String(fromJson(params.orig));
            case 'Array': Array(fromJson(params.orig));
            case 'Map': Map(fromJson(params.orig));
            case 'Object': Object(fromJson(params.orig));
            case 'Function': Function(fromJson(params.args), fromJson(params.ret), fromJson(params.orig));
            default: null;
        }

    } //typeEnumFromJson

} //Json
