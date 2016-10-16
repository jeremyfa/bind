package bind;

import Sys.println;
import bind.Class;

using StringTools;

class Objc {

    // These regular expressions are madness. I am aware of it. But, hey, it works.
    //
    static var RE_ALL_SPACES = ~/\s*/g;
    static var RE_BEFORE_COMMENT_LINE = ~/^[\s\*]*/g;
    static var RE_AFTER_COMMENT_LINE = ~/[\s\*]*$/g;

    static var RE_TYPE = ~/^([a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:\(\s*\^\s*([A-Za-z_][A-Za-z_0-9]*)?\s*\)|([A-Za-z_][A-Za-z_0-9]*)?)\s*(?:\(\s*((?:[a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?\s*/;
    static var RE_IDENTIFIER = ~/^[a-zA-Z_][a-zA-Z0-9_]*/;

    //                                                                                                                                                                                                                                  name                   | name/arg                            return type                              nullability                                    block arguments                                                                         argument name
    //static var RE_METHOD = ~/^(\-|\+)\s*\(\s*(([a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?)\s*\(?\s*\^?\s*([A-Za-z_][A-Za-z_0-9]*)?\s*\)?\s*(\(\s*((?:[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?)\s*\)\s*(([a-zA-Z_][a-zA-Z0-9_]*)|(([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*\(\s*([a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?)\s*\(?\s*\^?\s*([A-Za-z_][A-Za-z_0-9]*)?\s*\)?\s*(\(\s*((?:[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))?\s*\)\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*)+)\s*;/;
    //static var RE_METHOD = ~/^(\-|\+)\s*\(\s*([a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?)\s*\)\s*/;

    //                                       modifiers                           type                                                                (  name                    |          name                                  block arguments                                                                 )
    static var RE_PROPERTY = ~/^@property\s*(?:\((\s*(?:[a-z]+\s*,?\s*)*)\))?\s*([a-zA-Z_][a-zA-Z0-9_]*(?:\s*<\s*[a-zA-Z_][a-zA-Z0-9_]*\s*>)?[\*\s]*)(?:([a-zA-Z_][a-zA-Z0-9_]*)|\(\s*\^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)\s*\(\s*((?:[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?(?:[a-zA-Z_][a-zA-Z0-9_]*)?\s*,?\s*)*)?\s*\))\s*;/;

    static var RE_INTERFACE = ~/^@interface\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*(?::\s*([a-zA-Z_][a-zA-Z0-9_]*))?\s*(?:\(\s*([a-zA-Z_][a-zA-Z0-9_]*)?\s*\))?\s*(?:<(\s*(?:[a-zA-Z_][a-zA-Z0-9_]*\s*,?\s*)*)>)?/;
    static var RE_ARG = ~/^\s*(\s*\(?\s*[a-zA-Z_][a-zA-Z0-9_<>\s\*]*[\s\*]?\s*\)?\s*)([a-zA-Z_][a-zA-Z0-9_]*)?/;

    /** Parse Objective-C header content to get class informations. */
    public static function parseClass(code:String, ?ctx:{i:Int}):bind.Class {

        var i = ctx != null ? ctx.i : 0;
        var c;
        var cc;
        var len = code.length;
        var cleanedCode = getCodeWithEmptyComments(code);

        var inSingleLineComment = false;
        var inMultilineComment = false;
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

            if (inSingleLineComment) {

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
            else if (cc == '//' || c == '#') { // Treat preprocessor as comment

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
                        result.properties.push(method);
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

    public static function parseProperty(code:String, ?ctx:{i:Int}):bind.Property {

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
                var objcArgs = RE_PROPERTY.matched(5) != null
                    ? RE_PROPERTY.matched(5).split(',').map(function(s) return removeSpaces(s))
                    : [];

                var args = [];
                for (objcArg in objcArgs) {
                    args.push(parseArg(objcArg));
                }
                type = bind.Type.Function(args);
            }
            else {
                // Standard property
                type = parseType(objcType);
            }
            name = objcName;

            if (ctx != null) {
                ctx.i += RE_PROPERTY.matched(0).length;
            }

            return {
                name: name,
                type: type,
                instance: true,
                description: null
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

    public static function parseBlockArg(code:String):Void {

        if (RE_TYPE.match(code)) {
            trace("BLOCK MATCH");
        }
        else {
            trace("NO BLOCK");
        }
    }

    public static function parseMethod(code:String, ?ctx:{i:Int}):bind.Method {

        var i = ctx != null ? ctx.i : 0;
        var after;
        var len = code.length;
        var parsedSign = null;
        var inReturn = false;
        var inName = false;
        var c;
        var name = null;
        var methodParts = [];
        var lastI = -1;

        var returnType = null;

        while (i < len) {

            // TODO remove this
            if (lastI == i) break;
            lastI = i;

            c = code.charAt(i);
            after = code.substr(i);

            if (c.trim() == '') {
                i++;
            }
            else if (parsedSign == null) {
                if (c == '+' || c == '-') {
                    parsedSign = c;
                    name = '';
                    inReturn = true;
                    i++;
                }
                else {
                    return null;
                }
            }
            else if (inReturn) {
                if (c == '(') {
                    i++;
                    c = code.charAt(i);
                    while (c.trim() == '') {
                        i++;
                        c = code.charAt(i);
                    }
                    after = code.substr(i);
                    trace('test?');
                    if (RE_TYPE.match(after)) {
                        var objcReturnType = RE_TYPE.matched(0);
                        returnType = parseType(objcReturnType);
                        trace('return: ');
                        trace(returnType);
                        i += objcReturnType.length;
                    }
                    else {
                        return null;
                    }
                }
                else {
                    return null;
                }
            }
            else if (returnType == null) {
                if (RE_IDENTIFIER.match(after)) {
                    //
                }
                else {
                    return null;
                }
            }
        }

        // if (RE_METHOD.match(after)) {
        //
        //     trace("METHOD MATCH");
        //     for (i in 0...12) {
        //         trace(i+' -> '+RE_METHOD.matched(i));
        //     }
        //
        //     //var objcType =
        //
        //     var instance = RE_METHOD.matched(1) == '-';
        //
        //
        //     var objcModifiers = RE_PROPERTY.matched(1) != null
        //         ? RE_PROPERTY.matched(1).split(',').map(function(s) return s.trim())
        //         : [];
        //     var objcType = removeSpaces(RE_PROPERTY.matched(2));
        //     var objcName = RE_PROPERTY.matched(3).trim();
        //
        //     var name = objcName;
        //     var type = parseType(objcType);
        //
        //     if (ctx != null) {
        //         ctx.i += RE_PROPERTY.matched(0).length;
        //     }
        //
        //     return {
        //         name: name,
        //         type: type,
        //         args: [],
        //         instance: true,
        //         description: null
        //     };
        //
        //     //return null;
        // } else {
        //     trace('NO MATCH');
        // }

        return null;

    } //parseMethod

    public static function parseArg(objcArg):bind.Arg {

        if (RE_ARG.match(objcArg)) {
            var objcType = removeSpaces(RE_ARG.matched(1));
            var objcName = removeSpaces(RE_ARG.matched(2));

            var type = parseType(objcType);
            var name = objcName;

            return {
                type: type,
                name: name
            };
        }

        return null;

    } //parseArg

    public static function parseType(objcType:String):bind.Type {

        if (RE_TYPE.match(objcType)) {
            trace('MATCH $objcType');

            for (i in 0...5) {
                trace('MT($i) = ' + RE_TYPE.matched(i));
            }

        }

        return switch (objcType) {
            case 'int', 'NSInteger', 'long':
                Int;
            case 'float', 'double', 'CGFloat', 'NSTimeInterval':
                Float;
            case 'bool', 'BOOL':
                Bool;
            case 'NSString*', 'NSMutableString*':
                String;
            case 'NSArray*', 'NSMutableArray*':
                Array;
            case 'NSDictionary*', 'NSMutableDictionary*':
                Map;
            default:
                // TODO block -> Function
                Object;
        }

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

} //ObjcBind
