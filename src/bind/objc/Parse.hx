package bind.objc;

import Sys.println;

using StringTools;

class Parse {

    // These regular expressions are madness. I am aware of it. But, hey, it works.
    //
    static var RE_ALL_SPACES = ~/\s*/g;
    static var RE_BEFORE_COMMENT_LINE = ~/^[\s\*]*/g;
    static var RE_AFTER_COMMENT_LINE = ~/[\s\*]*$/g;
    //                       type                         protocol                                   block nullability                        nullability                           block arguments
    static var RE_TYPE = ~/^([a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:\(\s*\^\s*(_Nullable|_Nonnull)?\s*\)|(_Nullable|_Nonnull)?)\s*(\(\s*((?:[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?\s*/;
    static var RE_IDENTIFIER = ~/^[a-zA-Z_][a-zA-Z0-9_]*/;
    //                                       modifiers                           type                                                                (  name                    |          name                                  block arguments                                                                 )
    static var RE_PROPERTY = ~/^@property\s*(?:\((\s*(?:[a-z]+\s*,?\s*)*)\))?\s*([a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:([a-zA-Z_][a-zA-Z0-9_]*)|\(\s*\^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)\s*\(\s*((?:[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))\s*;/;
    static var RE_INTERFACE = ~/^@interface\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*(?::\s*([a-zA-Z_][a-zA-Z0-9_]*))?\s*(?:\(\s*([a-zA-Z_][a-zA-Z0-9_]*)?\s*\))?\s*(?:<(\s*(?:[a-zA-Z_][a-zA-Z0-9_]*\s*,?\s*)*)>)?/;

    /** Parse Objective-C header content to get class informations. */
    public static function parseClass(code:String, ?ctx:{i:Int}):bind.Class {

        var i = ctx != null ? ctx.i : 0;
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
        while (i < len) {

            // TODO remove this
            if (lastI == i) break;
            lastI = i;

            c = code.charAt(i);
            cc = code.substr(i, 2);

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

            }
            else {

                var after = code.substr(i);

                if (c == '@') {

                    if (inInterface) {

                        if (after.startsWith('@property')) {

                            if (ctx != null) ctx.i = i; else ctx = {i: i};
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

                            if (ctx != null) ctx.i = i; else ctx = {i: i};
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

                    if (ctx != null) ctx.i = i; else ctx = {i: i};
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
                else {
                    i++;
                }
            }

        }

        if (ctx != null) {
            ctx.i = i;
        }

        if (result.name != null) {
            return result;
        } else {
            return null;
        }

    } //getClass

    public static function parseProperty(code:String, ?ctx:{i:Int}):bind.Class.Property {

        var i = ctx != null ? ctx.i : 0;
        var after = code.substr(i);

        if (RE_PROPERTY.match(after)) {

            var objcModifiers = RE_PROPERTY.matched(1) != null
                ? RE_PROPERTY.matched(1).split(',').map(function(s) return s.trim())
                : [];
            var objcType = removeSpaces(RE_PROPERTY.matched(2));
            var objcName = RE_PROPERTY.matched(3).trim();

            var name = null;
            var type = null;

            if (objcName == null) {
                // Block property
                objcName = RE_PROPERTY.matched(4).trim();
                var objcArgs = RE_PROPERTY.matched(5) != null && RE_PROPERTY.matched(5).trim() != ''
                    ? RE_PROPERTY.matched(5).split(',').map(function(s) return s.trim())
                    : [];

                var args = [];
                for (objcArg in objcArgs) {
                    args.push(parseArg(objcArg));
                }
                type = bind.Class.Type.Function(args, parseType(objcType));
            }
            else {
                // Standard property
                type = parseType(objcType);
            }
            name = objcName;

            if (ctx != null) {
                ctx.i += RE_PROPERTY.matched(0).length;
            }

            var nullable = switch (type) {
                case Int(orig), Float(orig), Bool(orig):
                    objcModifiers.indexOf('nullable') != -1;
                case _:
                    objcModifiers.indexOf('nonnull') == -1;
            }

            return {
                name: name,
                type: type,
                instance: true,
                description: null,
                orig: {
                    nullable: nullable
                }
            };
        }
        else {

            if (ctx != null) {
                var semicolonIndex = after.indexOf(';');
                if (semicolonIndex == -1) {
                    ctx.i += after.length;
                } else {
                    ctx.i += semicolonIndex;
                }
            }

            return null;
        }

    } //parseProperty

    public static function parseMethod(code:String, ?ctx:{i:Int}):bind.Class.Method {

        var i = ctx != null ? ctx.i : 0;
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
                        returnType = parseType(objcReturnType);
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
                            var argType = parseType(objcType);
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
                }
            }
        }

        if (name == null) return null;

        return {
            name: name,
            instance: sign == '-',
            description: null,
            type: returnType,
            args: args
        };

    } //parseMethod

    public static function parseArg(objcArg):bind.Class.Arg {

        var ctx = {i: 0};
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

    public static function parseType(objcType:String, ?ctx:{i:Int}):bind.Class.Type {

        if (ctx != null && ctx.i > 0) {
            objcType = objcType.substr(ctx.i);
        }

        if (RE_TYPE.match(objcType)) {
            var type = null;

            if (ctx != null) ctx.i += RE_TYPE.matched(0).length;

            //trace('PARSE TYPE: ' + RE_TYPE.matched(0));

            if (RE_TYPE.matched(4) != null) {
                // Block type
                var objcReturnType = removeSpaces(RE_TYPE.matched(1));

                var objcNullability = RE_TYPE.matched(2);
                var objcArgs = RE_TYPE.matched(5) != null && RE_TYPE.matched(5).trim() != ''
                    ? RE_TYPE.matched(5).split(',').map(function(s) return s.trim())
                    : [];

                var args = [];
                for (objcArg in objcArgs) {
                    args.push(parseArg(objcArg));
                }

                return bind.Type.Function(args, parseType(objcReturnType));
            }
            else {
                // Standard type
                var objcType = removeSpaces(RE_TYPE.matched(1));
                var objcNullability = RE_TYPE.matched(3);

                return switch (objcType) {
                    case 'void':
                        Void({type: objcType, nullable: objcNullability == '_Nullable'});
                    case 'int', 'NSInteger', 'long':
                        Int({type: objcType, nullable: objcNullability == '_Nullable'});
                    case 'float', 'double', 'CGFloat', 'NSTimeInterval':
                        Float({type: objcType, nullable: objcNullability == '_Nullable'});
                    case 'bool', 'BOOL':
                        Bool({type: objcType, nullable: objcNullability == '_Nullable'});
                    case 'NSNumber*':
                        Float({type: objcType, nullable: objcNullability == '_Nonnull'});
                    case 'NSString*', 'NSMutableString*':
                        String({type: objcType, nullable: objcNullability != '_Nonnull'});
                    case 'NSArray*', 'NSMutableArray*':
                        Array({type: objcType, nullable: objcNullability != '_Nonnull'});
                    case 'NSDictionary*', 'NSMutableDictionary*':
                        Map({type: objcType, nullable: objcNullability != '_Nonnull'});
                    default:
                        Object({type: objcType});
                }
            }
        }

        return null;

    } //parseType

    public static function parseClassName(code:String, ?ctx:{i:Int}):String {

        var i = ctx != null ? ctx.i : 0;
        var after = code.substr(i);

        if (RE_INTERFACE.match(after)) {

            var name = RE_INTERFACE.matched(1).trim();
            var parent = removeSpaces(RE_INTERFACE.matched(2));
            var category = removeSpaces(RE_INTERFACE.matched(3));
            var protocols = RE_INTERFACE.matched(4) != null
                ? RE_INTERFACE.matched(4).split(',').map(function(s) return s.trim())
                : [];

            if (ctx != null) {
                ctx.i += RE_INTERFACE.matched(0).length;
            }

            return name;
        }

        return null;

    } //parseClassName

/// Internal

    static function removeSpaces(input:String):String {

        if (input == null) return null;
        return RE_ALL_SPACES.replace(input, '');

    } //removeSpaces

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

        for (line in comment.split("\n")) {
            line = RE_BEFORE_COMMENT_LINE.replace(line, '');
            line = RE_AFTER_COMMENT_LINE.replace(line, '');
            lines.push(line);
        }

        return lines.join("\n");

    } //cleanComment

} //Parse
