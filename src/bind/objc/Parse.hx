package bind.objc;

import Sys.println;

using StringTools;

typedef ParseContext = {
    var i:Int;
    var types:Map<String,bind.Class.Type>;
}

class Parse {

    // These regular expressions are madness. I am aware of it. But, hey, it works.
    //
    static var RE_ALL_SPACES = ~/\s+/g;
    static var RE_BEFORE_COMMENT_LINE = ~/^[\s\*]*(\/\/)?\s*/g;
    static var RE_AFTER_COMMENT_LINE = ~/[\s\*]*$/g;
    static var RE_C_MODIFIERS = ~/^\s*(?:(?:const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*/;
    static var RE_TYPEDEF_BLOCK_NAME = ~/(?:\(\s*\^\s*(?:[a-zA-Z_][a-zA-Z0-9_]*)\s*\))/;
    static var RE_TYPEDEF_NAME = ~/\s+([a-zA-Z_][a-zA-Z0-9_]*)?\s*$/;
    //                       type                         protocol                                   block nullability                        nullability                           block arguments
    static var RE_TYPE = ~/^((?:(const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:\(\s*\^\s*(_Nullable|_Nonnull|nullable|nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)?\s*\)|(_Nullable|_Nonnull|nullable|nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)?)\s*(\(\s*((?:(?:const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*(?:[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?\s*/;
    //                         type                         protocol                                   block type name                        type name                           block arguments                                                                                            type name
    static var RE_TYPEDEF = ~/^typedef\s+(((?:(?:const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:\(\s*\^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\))?\s*(\(\s*((?:[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?)\s*([a-zA-Z_][a-zA-Z0-9_]*)?\s*;/;
    static var RE_IDENTIFIER = ~/^[a-zA-Z_][a-zA-Z0-9_]*/;
    //                                       modifiers                           type                                                                (  name                    |          name                                  block arguments                                                                 )
    static var RE_PROPERTY = ~/^@property\s*(?:\((\s*(?:[a-z]+\s*,?\s*)*)\))?\s*((?:(?:const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:([a-zA-Z_][a-zA-Z0-9_]*)|\(\s*\^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)\s*\(\s*((?:(?:const|signed|unsigned|short|long|nullable|nonnull|_Nullable|_Nonnull|_Null_unspecified|__nullable|__nonnull|__null_unspecified)\s+)*(?:[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))\s*;/;
    static var RE_INTERFACE = ~/^@interface\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*(?::\s*([a-zA-Z_][a-zA-Z0-9_]*))?\s*(?:\(\s*([a-zA-Z_][a-zA-Z0-9_]*)?\s*\))?\s*(?:<(\s*(?:[a-zA-Z_][a-zA-Z0-9_]*\s*,?\s*)*)>)?/;

    public static function createContext():ParseContext {
        return { i: 0, types: new Map() };
    }

    /** Parse Objective-C header content to get class informations. */
    public static function parseClass(code:String, ?ctx:ParseContext):bind.Class {

        if (ctx == null) ctx = createContext();

        var i = ctx.i;
        var types = ctx.types;
        if (types == null) types = new Map();
        var c;
        var cc;
        var len = code.length;
        var cleanedCode = getCodeWithEmptyComments(code);

        var inSingleLineComment = false;
        var inMultilineComment = false;
        var inPreprocessorMacro = false;
        var inInterface = false;

        var comment = null;

        var result:bind.Class = {
            name: null,
            path: null,
            properties: [],
            methods: [],
            description: null
        };

        // Parse class
        var lastI = -1;
        var lastLineBreakI = -1;
        while (i < len) {

            if (lastI == i) break;
            lastI = i;

            c = code.charAt(i);
            cc = code.substr(i, 2);

            if (c == "\n") lastLineBreakI = i;

            if (inPreprocessorMacro) {

                if (c == "\n") {
                    inPreprocessorMacro = false;
                }

                i++;
            }
            else if (inSingleLineComment) {

                if (c == "\n") {
                    inSingleLineComment = false;
                    comment = cleanComment(comment);
                }
                else {
                    comment += c;
                }

                i++;
            }
            else if (inMultilineComment) {

                if (cc == '*/') {
                    inMultilineComment = false;
                    comment = cleanComment(comment);

                    i += 2;
                }
                else {
                    comment += c;
                    i++;
                }
            }
            else if (c == '#') {

                inPreprocessorMacro = true;
                i++;
            }
            else if (cc == '//') {

                inSingleLineComment = true;
                comment = '';
                i += 2;
            }
            else if (cc == '/*') {

                inMultilineComment = true;
                comment = '';
                i += 2;
                var pad = i - lastLineBreakI;
                while (pad-- > 0) comment += ' ';

            }
            else {

                var after = code.substr(i);

                if (c == '@') {

                    if (inInterface) {

                        if (after.startsWith('@property')) {

                            ctx.i = i;
                            var property = parseProperty(cleanedCode, ctx);
                            i = ctx.i;

                            if (property == null) {
                                println('invalid property: ' + code.substring(i, ctx.i));
                            } else {
                                if (comment != null) {
                                    property.description = comment;
                                }
                                result.properties.push(property);
                            }
                            comment = null;
                        }
                        else if (after.startsWith('@end')) {
                            inInterface = false;
                            i += 4;
                            break;
                        }
                    }
                    else {

                        if (after.startsWith('@interface')) {

                            ctx.i = i;
                            var className = parseClassName(cleanedCode, ctx);
                            i = ctx.i;
                            if (className == null) {
                                println('invalid interface');
                                break;
                            }

                            inInterface = true;
                            result.name = className;

                            if (comment != null) {
                                result.description = comment;
                                comment = null;
                            }
                        }
                        else {
                            i++;
                        }
                    }
                }
                else if (inInterface && (c == '-' || c == '+')) {

                    ctx.i = i;
                    var method = parseMethod(cleanedCode, ctx);
                    i = ctx.i;

                    if (method == null) {
                        println('invalid method: ' + code.substring(i, ctx.i));
                    } else {
                        if (comment != null) {
                            method.description = comment;
                        }
                        result.methods.push(method);
                    }
                    comment = null;
                }
                else if (after.startsWith('typedef')) {

                    ctx.i = i;
                    var type = parseTypedef(cleanedCode, ctx);
                    i = ctx.i;

                    if (type == null) {
                        println('invalid typedef: ' + code.substring(i, ctx.i));
                    }
                    comment = null;

                }
                else {
                    i++;
                }
            }

        }

        ctx.i = i;

        if (result.name != null) {

            extractPropertyMethods(result);

            return result;
        } else {
            return null;
        }

    } //getClass

    public static function parseProperty(code:String, ?ctx:ParseContext):bind.Class.Property {

        if (ctx == null) ctx = createContext();

        var i = ctx.i;
        var after = code.substr(i);

        if (RE_PROPERTY.match(after)) {

            var objcModifiers = RE_PROPERTY.matched(1) != null
                ? RE_PROPERTY.matched(1).split(',').map(function(s) return s.trim())
                : [];
            var objcType = removeSpacesForType(RE_PROPERTY.matched(2));
            var objcName = RE_PROPERTY.matched(3) != null ? RE_PROPERTY.matched(3).trim() : null;

            var name = null;
            var type = null;

            if (objcName == null) {
                // Block property
                objcName = RE_PROPERTY.matched(4).trim();
                var objcArgs = RE_PROPERTY.matched(5) != null && RE_PROPERTY.matched(5).trim() != ''
                    ? RE_PROPERTY.matched(5).split(',').map(function(s) return s.trim())
                    : [];

                var args:Array<bind.Class.Arg> = [];
                for (objcArg in objcArgs) {
                    args.push(parseArg(objcArg, ctx));
                }
                type = bind.Class.Type.Function(args, parseType(objcType, {i: 0, types: ctx.types}));
            }
            else {
                // Standard property
                type = parseType(objcType, {i: 0, types: ctx.types});
            }
            name = objcName;

            ctx.i += RE_PROPERTY.matched(0).length;

            var nullable = switch (type) {
                case Int(orig), Float(orig), Bool(orig):
                    objcModifiers.indexOf('nullable') != -1 || objcModifiers.indexOf('_Nullable') != -1 || objcModifiers.indexOf('__nullable') != -1;
                case _:
                    objcModifiers.indexOf('nonnull') == -1 && objcModifiers.indexOf('_Nullable') == -1 && objcModifiers.indexOf('__nullable') == -1;
            }

            return {
                name: name,
                type: type,
                instance: true,
                description: null,
                orig: {
                    nullable: nullable,
                    readonly: objcModifiers.indexOf('readonly') != -1
                }
            };
        }
        else {

            var semicolonIndex = after.indexOf(';');
            if (semicolonIndex == -1) {
                ctx.i += after.length;
            } else {
                ctx.i += semicolonIndex;
            }

            return null;
        }

    } //parseProperty

    public static function parseMethod(code:String, ?ctx:ParseContext):bind.Class.Method {

        if (ctx == null) ctx = createContext();

        var i = ctx.i;
        var after;
        var len = code.length;
        var c;
        var lastI = -1;

        var sign = null;
        var returnType = null;
        var name = null;

        var args:Array<bind.Class.Arg> = [];
        var nameSection = null;
        var fullNameSections = [];

        while (i < len) {

            c = code.charAt(i);
            after = code.substr(i);

            if (c.trim() == '') {
                i++;
            }
            else if (sign == null) {
                if (c == '+' || c == '-') {
                    sign = c;
                    i++;
                    continue;
                }
                return null;
            }
            else if (returnType == null) {
                if (c == '(') {
                    i++;
                    c = code.charAt(i);
                    while (c.trim() == '') {
                        i++;
                        c = code.charAt(i);
                    }
                    after = code.substr(i);
                    if (RE_TYPE.match(after)) {
                        var objcReturnType = RE_TYPE.matched(0);
                        returnType = parseType(objcReturnType, {i: 0, types: ctx.types});
                        i += objcReturnType.length;
                        while (code.charAt(i).trim() == '') i++;
                        if (code.charAt(i) == ')') {
                            i++;
                            continue;
                        }
                    }
                }
                return null;
            }
            else if (name == null) {
                if (RE_IDENTIFIER.match(after)) {
                    var objcName = RE_IDENTIFIER.matched(0);
                    name = objcName.trim();
                    nameSection = name;
                    fullNameSections.push(nameSection);
                    i += objcName.length;
                    continue;
                }
                return null;
            }
            else if (nameSection == null) {
                if (c == ';') {
                    i++;
                    break; // End
                }
                else if (RE_IDENTIFIER.match(after)) {
                    nameSection = RE_IDENTIFIER.matched(0);
                    fullNameSections.push(nameSection);
                    continue;
                }
                return null;
            }
            else {
                if (c == ';') {
                    i++;
                    break; // End
                }
                else if (c == ':') {
                    i++;
                    while (code.charAt(i).trim() == '') i++;
                    if (code.charAt(i) == '(') {
                        i++;
                        while (code.charAt(i).trim() == '') i++;
                        after = code.substr(i);

                        if (RE_TYPE.match(after)) {
                            var objcType = RE_TYPE.matched(0);
                            var argType = parseType(objcType, {i: 0, types: ctx.types});
                            i += objcType.length;

                            if (argType != null) {
                                while (code.charAt(i).trim() == '') i++;
                                if (code.charAt(i) == ')') {
                                    i++;
                                    while (code.charAt(i).trim() == '') i++;
                                    after = code.substr(i);
                                    if (RE_IDENTIFIER.match(after)) {
                                        var argName = RE_IDENTIFIER.matched(0).trim();
                                        i += argName.length;

                                        args.push({
                                            name: argName,
                                            type: argType,
                                            orig: {
                                                nameSection: nameSection
                                            }
                                        });

                                        nameSection = null;
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    return null;
                } else {
                    i++;
                }
            }
        }

        ctx.i = i;

        if (name == null) return null;

        return {
            name: name,
            instance: sign == '-',
            description: null,
            type: returnType,
            args: args
        };

    } //parseMethod

    public static function parseArg(objcArg:String, parentCtx:ParseContext):bind.Class.Arg {

        if (parentCtx == null) parentCtx = createContext();

        var ctx = {i: 0, types: parentCtx.types};
        var type = parseType(objcArg, ctx);
        if (type == null) return null;

        var remaining = objcArg.substr(ctx.i);
        var name = null;
        if (RE_IDENTIFIER.match(remaining)) {
            name = RE_IDENTIFIER.matched(0);
        }

        return {
            type: type,
            name: name
        };

        return null;

    } //parseArg

    public static function parseType(objcType:String, ?ctx:ParseContext):bind.Class.Type {

        if (ctx == null) ctx = createContext();

        if (ctx.i > 0) {
            objcType = objcType.substr(ctx.i);
        }

        if (RE_TYPE.match(objcType)) {
            var type = null;

            ctx.i += RE_TYPE.matched(0).length;

            if (RE_TYPE.matched(5) != null) {
                // Block type
                var objcReturnType = removeSpacesForType(removeNullabilityForType(RE_TYPE.matched(1)));

                var objcNullability = RE_TYPE.matched(3);

                var objcModifiers = [];
                if (RE_TYPE.matched(2) != null) {
                    for (part in RE_TYPE.matched(2).replace("\t", ' ').split(' ')) {
                        objcModifiers.push(part.trim());
                    }
                }

                if (objcNullability == null || objcNullability.trim() == '') {
                    if (objcModifiers.indexOf('_Nonnull') != -1) objcNullability = '_Nonnull';
                    else if (objcModifiers.indexOf('nonnull') != -1) objcNullability = 'nonnull';
                    else if (objcModifiers.indexOf('__nonnull') != -1) objcNullability = '__nonnull';
                }

                var objcArgs = RE_TYPE.matched(6) != null && RE_TYPE.matched(6).trim() != ''
                    ? RE_TYPE.matched(6).split(',').map(function(s) return s.trim())
                    : [];

                var args = [];
                for (objcArg in objcArgs) {
                    args.push(parseArg(objcArg, ctx));
                }

                return bind.Type.Function(args, parseType(objcReturnType, {i: 0, types: ctx.types}), {type: objcType, nullable: objcNullability != '_Nonnull' && objcNullability != 'nonnull' && objcNullability != '__nonnull'});
            }
            else {
                // Standard type
                var objcType = removeSpacesForType(removeNullabilityForType(RE_TYPE.matched(1)));
                var objcNullability = RE_TYPE.matched(4);
                
                var objcModifiers = [];
                if (RE_TYPE.matched(2) != null) {
                    for (part in RE_TYPE.matched(2).replace("\t", ' ').split(' ')) {
                        objcModifiers.push(part.trim());
                    }
                }

                if (objcNullability == null || objcNullability.trim() == '') {
                    if (objcModifiers.indexOf('_Nonnull') != -1) objcNullability = '_Nonnull';
                    else if (objcModifiers.indexOf('nonnull') != -1) objcNullability = 'nonnull';
                    else if (objcModifiers.indexOf('__nonnull') != -1) objcNullability = '__nonnull';
                }
                
                var notNonNull = objcNullability != '_Nonnull' && objcNullability != 'nonnull' && objcNullability != '__nonnull';
                var hasNullable = objcNullability == '_Nonnull' || objcNullability == 'nonnull' || objcNullability == '__nonnull';

                // Check if the type matches an existing typedef
                var matchedType = ctx.types.get(objcType);
                if (matchedType != null) {
                    return switch (matchedType) {
                        case Void(orig): Void({orig: orig, type: objcType, nullable: (hasNullable || orig.nullable)});
                        case Int(orig): Int({orig: orig, type: objcType, nullable: (hasNullable || orig.nullable)});
                        case Float(orig): Float({orig: orig, type: objcType, nullable: (hasNullable || orig.nullable)});
                        case Bool(orig): Bool({orig: orig, type: objcType, nullable: (hasNullable || orig.nullable)});
                        case String(orig): String({orig: orig, type: objcType, nullable: (notNonNull || orig.nullable)});
                        case Array(orig): Array({orig: orig, type: objcType, nullable: (notNonNull || orig.nullable)});
                        case Map(orig): Map({orig: orig, type: objcType, nullable: (notNonNull || orig.nullable)});
                        case Object(orig): Object({orig: orig, type: objcType, nullable: (notNonNull || orig.nullable)});
                        case Function(args, ret, orig): Function(args, ret, {orig: orig, type: objcType, nullable: (notNonNull || orig.nullable)});
                    }
                }

                // Otherwise, convert ObjC type to Haxe type
                return switch (objcType) {
                    case 'void':
                        Void({type: objcType, nullable: hasNullable});
                    case 'NSInteger',
                         'char',
                         'signed char',
                         'unsigned char',
                         'short',
                         'short int',
                         'signed short',
                         'signed short int',
                         'unsigned short',
                         'unsigned short int',
                         'int',
                         'signed',
                         'signed int',
                         'unsigned',
                         'unsigned int',
                         'long',
                         'long int',
                         'signed long',
                         'signed long int',
                         'unsigned long',
                         'unsigned long int',
                         'long long',
                         'long long int',
                         'signed long long',
                         'signed long long int',
                         'unsigned long long',
                         'unsigned long long int':
                        Int({type: objcType, nullable: hasNullable});
                    case 'float',
                         'double',
                         'long double',
                         'CGFloat',
                         'NSTimeInterval':
                        Float({type: objcType, nullable: hasNullable});
                    case 'bool',
                         'BOOL':
                        Bool({type: objcType, nullable: hasNullable});
                    case 'NSNumber*':
                        Float({type: objcType, nullable: notNonNull});
                    case 'NSString*',
                         'NSMutableString*',
                         'char*',
                         'const char*':
                        String({type: objcType, nullable: notNonNull});
                    case 'NSArray*',
                         'NSMutableArray*':
                        Array({type: objcType, nullable: notNonNull});
                    case 'NSDictionary*',
                         'NSMutableDictionary*':
                        Map({type: objcType, nullable: notNonNull});
                    default:
                        Object({type: objcType, nullable: notNonNull});
                }
            }
        }

        return null;

    } //parseType

    public static function parseTypedef(code:String, ?ctx:ParseContext):bind.Class.Type {

        if (ctx == null) ctx = createContext();

        var i = ctx.i;
        var after;
        var len = code.length;
        var after = code.substr(i);

        if (RE_TYPEDEF.match(after)) {

            i += RE_TYPEDEF.matched(0).length;
            if (ctx != null) ctx.i = i;

            var nameFromBlock = RE_TYPEDEF.matched(3);
            var nameAtEnd = RE_TYPEDEF.matched(6);
            var objcType = RE_TYPEDEF.matched(1);

            if (nameFromBlock == null && nameAtEnd == null) {
                if (RE_TYPEDEF_NAME.match(objcType)) {
                    nameAtEnd = RE_TYPEDEF_NAME.matched(0).trim();
                    objcType = objcType.substring(0, objcType.length - nameAtEnd.length);
                } else {
                    return null;
                }
            }

            if (nameFromBlock != null) {
                objcType = RE_TYPEDEF_BLOCK_NAME.replace(objcType, '(^)');
            }

            var name = nameFromBlock;
            if (name == null) name = nameAtEnd;

            objcType = removeSpacesForType(objcType);

            var type = parseType(objcType, {i: 0, types: ctx.types});

            ctx.types.set(name, type);

            return type;

        }

        return null;

    } //parseTypedef

    public static function parseClassName(code:String, ?ctx:ParseContext):String {

        if (ctx == null) ctx = createContext();

        var i = ctx.i;
        var after = code.substr(i);

        if (RE_INTERFACE.match(after)) {

            var name = RE_INTERFACE.matched(1).trim();
            var parent = removeSpaces(RE_INTERFACE.matched(2));
            var category = removeSpaces(RE_INTERFACE.matched(3));
            var protocols = RE_INTERFACE.matched(4) != null
                ? RE_INTERFACE.matched(4).split(',').map(function(s) return s.trim())
                : [];

            ctx.i += RE_INTERFACE.matched(0).rtrim().length;

            return name;
        }

        return null;

    } //parseClassName

/// Internal

    static function extractPropertyMethods(result:bind.Class):Void {

        var existingMethods:Map<String,Bool> = new Map();
        
        for (method in result.methods) {
            existingMethods.set(method.name, true);
        }

        for (property in result.properties) {
            // Getter
            if (!existingMethods.exists(property.name)) {
                result.methods.push({
                    name: property.name,
                    args: [],
                    type: property.type,
                    instance: true,
                    description: property.description,
                    orig: extendOrig(property.orig, {
                        getter: true,
                        property: {
                            name: property.name
                        }
                    })
                });
            }
            // Setter
            if (!property.orig.readonly) {
                var setterName = 'set' + property.name.charAt(0).toUpperCase() + property.name.substring(1);
                if (!existingMethods.exists(setterName)) {
                    result.methods.push({
                        name: setterName,
                        args: [{
                            name: property.name,
                            orig: extendOrig(property.orig, {
                                nameSection: setterName
                            }),
                            type: property.type
                        }],
                        type: Void({ type: 'void', nullable: false }),
                        instance: true,
                        description: property.description,
                        orig: extendOrig(property.orig, {
                            setter: true,
                            property: {
                                name: property.name
                            }
                        })
                    });
                }
            }
        }

    } //extractPropertyMethods

    static function extendOrig(orig:Dynamic, extension:Dynamic):Dynamic {

        var result:Dynamic = {};

        for (field in Reflect.fields(orig)) {
            Reflect.setField(result, field, Reflect.field(orig, field));
        }

        for (field in Reflect.fields(extension)) {
            Reflect.setField(result, field, Reflect.field(extension, field));
        }

        return result;

    } //extendOrig

    static function removeSpaces(input:String):String {

        if (input == null) return null;
        return RE_ALL_SPACES.replace(input, '');

    } //removeSpaces

    static function removeSpacesForType(input:String):String {

        if (input == null) return null;

        if (RE_C_MODIFIERS.match(input)) {
            var prefix = RE_C_MODIFIERS.matched(0);
            var suffix = input.substr(prefix.length);
            prefix = RE_ALL_SPACES.replace(prefix, ' ');
            return (prefix + RE_ALL_SPACES.replace(suffix, '')).trim();
        }

        return RE_ALL_SPACES.replace(input, '').trim();

    } //removeSpacesForType

    static function removeNullabilityForType(input:String):String {

        if (input == null) return null;

        return input
            .replace('_Nonnull', '').replace('nonnull', '').replace('__nonnull', '')
            .replace('_Nullable', '').replace('nullable', '').replace('__nullable', '')
            .replace('_Null_unspecified', '').replace('__null_unspecified', '')
            ;

    } //removeSpacesForType

    static function getCodeWithEmptyComments(input:String):String {

        var i = 0;
        var output = '';
        var len = input.length;
        var inSingleLineComment = false;
        var inMultilineComment = false;
        var k;
        var c, cc;

        while (i < len) {

            c = input.charAt(i);
            cc = input.substr(i, 2);

            if (inSingleLineComment) {
                if (c == "\n") {
                    inSingleLineComment = false;
                    output += "\n";
                }
                else {
                    output += ' ';
                }
                i++;
            }
            else if (inMultilineComment) {
                if (cc == '*/') {
                    inMultilineComment = false;
                    output += '  ';
                    i += 2;
                }
                else {
                    if (c == "\n") {
                        output += "\n";
                    }
                    else {
                        output += ' ';
                    }
                    i++;
                }
            }
            else if (cc == '//') {
                inSingleLineComment = true;
                output += '  ';
                i += 2;
            }
            else if (cc == '/*') {
                inMultilineComment = true;
                output += '  ';
                i += 2;
            }
            else {
                output += c;
                i++;
            }
        }

        return output;

    } //getCodeWithEmptyComments

    static function cleanComment(comment:String):String {

        var lines = [];

        // Remove noise (asterisks etc...)
        for (line in comment.split("\n")) {
            var lineLen = line.length;
            line = RE_BEFORE_COMMENT_LINE.replace(line, '');
            while (line.length < lineLen) {
                line = ' ' + line;
            }
            line = RE_AFTER_COMMENT_LINE.replace(line, '');
            lines.push(line);
        }

        if (lines.length == 0) return '';

        // Remove indent common with all lines
        var commonIndent = 99999;
        for (line in lines) {
            if (line.trim() != '') {
                commonIndent = Std.int(Math.min(commonIndent, line.length - line.ltrim().length));
            }
        }
        if (commonIndent > 0) {
            for (i in 0...lines.length) {
                lines[i] = lines[i].substring(commonIndent);
            }
        }

        return lines.join("\n").trim();

    } //cleanComment

} //Parse
