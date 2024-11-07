package bind.cs;

class Support {

    /**
     * Because Unity's `JsonUtility` is very limited, it cannot parse
     * any arbitrary JSON value. This helper is solving that by serializing
     * the data in a way that can be handled by Unity's `JsonUtility` to
     * restore the same data structure recursively!
     */
    public static function toUnityJson(value:Dynamic):String {

        return switch (Type.typeof(value)) {
            case TObject: // Handle anonymous objects/maps
                var pairs = [];
                for (field in Reflect.fields(value)) {
                    var fieldValue = Reflect.field(value, field);
                    pairs.push([field, _toUnityJsonValue(fieldValue)[0], _toUnityJsonValue(fieldValue)[1]]);
                }
                haxe.Json.stringify(pairs);

            case TClass(Array): // Handle arrays
                var arr:Array<Dynamic> = value;
                var serialized = arr.map(serializeValue).flatten();
                haxe.Json.stringify(serialized);

            default: // Handle primitive values by wrapping them in an array
                var serialized = _toUnityJsonValue(value);
                haxe.Json.stringify([serialized[0], serialized[1]]);
        }

    }

    private static function _toUnityJsonValue(value:Dynamic):Array<String> {

        static final NULL_VALUE:Array<String> = ['', 'n'];

        if (value == null) return NULL_VALUE;

        return switch (Type.typeof(value)) {
            case TNull: NULL_VALUE;
            case TBool: [value ? '1' : '0', 'b'];
            case TInt | TFloat: [Std.string(value), 'd'];
            case TClass(String): [value, 's'];
            case TClass(Array):
                var arr:Array<Dynamic> = value;
                var serialized = [];
                for (item in arr) {
                    var val = _toUnityJsonValue(item);
                    serialized.push(val[0]);
                    serialized.push(val[1]);
                }
                [haxe.Json.stringify(serialized), 'a'];
            case TObject:
                var pairs = [];
                for (field in Reflect.fields(value)) {
                    var fieldValue = Reflect.field(value, field);
                    pairs.push([field, _toUnityJsonValue(fieldValue)[0], _toUnityJsonValue(fieldValue)[1]]);
                }
                [haxe.Json.stringify(pairs), 'o'];
            default:
                [Std.string(value), 's'];
        }

    }

}
