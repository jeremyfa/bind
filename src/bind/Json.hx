package bind;

class Json {

    /** Get JSON output with correct bind.Type enum serialization */
    public static function stringify(input:Dynamic, pretty:Bool = false):String {

        return haxe.Json.stringify(jsonify(input), null, pretty ? '    ' : null);

    } //stringify

    static function jsonify(input:Dynamic):Dynamic {

        if (input == null) {
            return null;
        }
        else if (Std.is(input, Array)) {
            var array:Array<Dynamic> = input;
            var result = [];
            for (item in array) {
                result.push(jsonify(item));
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
                        var res:Dynamic = jsonifyTypeEnum(value);

                        Reflect.setField(result, key, res);
                    }
                    else {
                        // Unsupported enum
                        Reflect.setField(result, key, null);
                    }
                }
                else {
                    Reflect.setField(result, key, jsonify(value));
                }
            }

            return result;
        }
    }

    static function jsonifyTypeEnum(value:bind.Class.Type):Dynamic {

        return switch (value) {
            case Void(orig): { Void: {orig: jsonify(orig)} };
            case Int(orig): { Int: {orig: jsonify(orig)} };
            case Float(orig): { Float: {orig: jsonify(orig)} };
            case Bool(orig): { Bool: {orig: jsonify(orig)} };
            case String(orig): { String: {orig: jsonify(orig)} };
            case Array(orig): { Array: {orig: jsonify(orig)} };
            case Map(orig): { Map: {orig: jsonify(orig)} };
            case Object(orig): { Object: {orig: jsonify(orig)} };
            case Function(args, ret, orig): { Function: {args: jsonify(args), ret: jsonifyTypeEnum(ret), orig: jsonify(orig)} };
        }

    }

} //Json
