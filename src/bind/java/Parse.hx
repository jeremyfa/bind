package bind.java;

import Sys.println;

using StringTools;

typedef ParseContext = {
    var i:Int;
    var types:Map<String,bind.Class.Type>;
}

class Parse {

    static var RE_STRING = ~/^(?:"(?:[^"\\]*(?:\\.[^"\\]*)*)"|'(?:[^'\\]*(?:\\.[^'\\]*)*)')/;
    static var RE_IMPORT = ~/^import\s+(static\s+)?([^;\s]+)\s*;/;
    static var RE_DECL = ~/^((?:(?:public|private|protected|static|final|abstract)\s+)+)?(enum|interface|class)\s+([a-zA-Z0-9,<>\[\]_ ]+)((?:\s+(?:implements|extends)\s*(?:[a-zA-Z0-9,<>\[\]_ ]+)(?:\s*,\s*[a-zA-Z0-9,<>\[\]_ ]+)*)*)\s*{/;
    static var RE_PROPERTY = ~/^((?:(?:public|private|protected|static|final|dynamic)\s+)+)?([a-zA-Z0-9,<>\[\]_]+)\s+([a-zA-Z0-9_]+)\s*(;|=|,)/;
    static var RE_METHOD = ~/^((?:(?:public|private|protected|static|final)\s+)+)?([a-zA-Z0-9,<>\[\]_]+)\s+([a-zA-Z0-9_]+)\s*\(\s*([^\)]*)\s*\)\s*({|;)/;
    static var RE_CONSTRUCTOR = ~/^((?:(?:public|private|protected|final)\s+)+)?([a-zA-Z0-9,<>\[\]_]+)\s*\(\s*([^\)]*)\s*\)\s*{/;
    static var RE_ARG_END = ~/^\s*([a-zA-Z_][a-zA-Z_0-9]*)(?:(\s*,)?\s*)/;

    static var RE_BEFORE_COMMENT_LINE = ~/^[\s\*]*(\/\/)?\s*/g;
    static var RE_AFTER_COMMENT_LINE = ~/[\s\*]*$/g;
    static var RE_WORD_SEP = ~/^[^a-zA-Z0-9_]/;
    static var RE_WORD = ~/^[a-zA-Z0-9_]+/;
    static var RE_NOT_SEPARATOR = ~/[a-zA-Z0-9_]/g;

    static var RE_FUNC = ~/^Func([0-9])$/;

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
        var pc;
        var len = code.length;

        var inSingleLineComment = false;
        var inMultilineComment = false;
        
        var inClass = false;

        var comment = null;
        var word = '';
        var after = '';

        var result:bind.Class = {
            name: null,
            path: null,
            properties: [],
            methods: [],
            description: null
        };

        // Clean code
        var cleanedCode = getCodeWithEmptyCommentsAndStrings(code);

        /** Skip java content but take care of handling parenthesis, brackets and braces imbrications. */
        function consumeUntil(until:String) {

            var openBraces = 0;
            var openParens = 0;
            var openBrackets = 0;
            var openLts = 0;
            
            while (i < len) {
                c = cleanedCode.charAt(i);

                if (openBraces <= 0 && openParens <= 0 && openBrackets <= 0 && openLts <= 0) {
                    if (c == until) {
                        i++;
                        break;
                    }
                }

                if (c == '{') {
                    openBraces++;
                }
                else if (c == '}') {
                    openBraces--;
                }
                else if (c == '(') {
                    openParens++;
                }
                else if (c == ')') {
                    openParens--;
                }
                else if (c == '[') {
                    openBrackets++;
                }
                else if (c == ']') {
                    openBrackets--;
                }
                else if (c == '<') {
                    openLts++;
                }
                else if (c == '>') {
                    openLts--;
                }

                i++;
            }

        } //consumeUntil
        
        function consumeBlock() {

            consumeUntil('}');

        } //consumeBlock
        
        function consumeStatement() {

            consumeUntil(';');

        } //consumeStatement

        // Parse class
        var lastI = -1;
        var lastLineBreakI = -1;
        while (i < len) {

            if (lastI == i) break;
            lastI = i;

            c = code.charAt(i);
            cc = code.substr(i, 2);

            after = cleanedCode.substr(i);

            if (i > 0) {
                pc = code.charAt(i - 1);
            }
            else {
                pc = '';
            }
            if (pc != '' &&
                !inSingleLineComment &&
                !inMultilineComment &&
                RE_WORD_SEP.match(pc) &&
                RE_WORD.match(after)) {
                word = RE_WORD.matched(0);
            }
            else {
                word = '';
            }

            if (c == "\n") lastLineBreakI = i;

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
            else if (cc == '//') {

                inSingleLineComment = true;
                comment = '';
                i += 2;

                if (code.charAt(i) == '/') {
                    while (code.charAt(i) == '/') {
                        comment += ' ';
                        i++;
                    }
                }
            }
            else if (cc == '/*') {

                inMultilineComment = true;
                comment = '';
                i += 2;
                var pad = i - lastLineBreakI;
                while (pad-- > 0) comment += ' ';

            }
            else {

                // Class declaration?
                if (word != '' && RE_DECL.match(after)) {
                    
                    var modifiers = extractModifiers(RE_DECL.matched(1));
                    var name = RE_DECL.matched(3).trim();

                    var keyword = RE_DECL.matched(2);

                    if (modifiers.exists('private') || modifiers.exists('protected') || modifiers.exists('abstract') || keyword != 'class') {
                        // We don't care about private/protected stuff, abstract classes or anything that isn't a class
                        i += RE_DECL.matched(0).length;
                        consumeBlock();
                    }
                    else if (inClass) {
                        // We only handle top level class in file
                        i += RE_DECL.matched(0).length;
                        consumeBlock();
                    }
                    else {
                        // We are now inside a class
                        inClass = true;

                        // Keep class name
                        result.name = name;
                        result.orig = {};
                        result.description = comment != null && comment.trim() != '' ? comment : null;
                        if (modifiers.exists('static')) Reflect.setField(result.orig, 'static', true);
                        if (modifiers.exists('final')) Reflect.setField(result.orig, 'final', true);
                        comment = null;

                        i += RE_DECL.matched(0).length;
                    }

                }
                else if (inClass) {
                    if (word != '') {
                        if (RE_PROPERTY.match(after)) {

                            var modifiers = extractModifiers(RE_PROPERTY.matched(1));
                            var name = RE_PROPERTY.matched(3);
                            var javaType = RE_PROPERTY.matched(2);
                            var end = RE_PROPERTY.matched(4);

                            i += RE_PROPERTY.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                if (end != ';') consumeStatement();
                            }
                            else {
                                // Add property info
                                var property:bind.Class.Property = {
                                    type: parseType(javaType),
                                    orig: {},
                                    name: name,
                                    instance: !modifiers.exists('static'),
                                    description: comment != null && comment.trim() != '' ? comment : null
                                };
                                comment = null;

                                result.properties.push(property);
                            }

                        }
                        else if (RE_CONSTRUCTOR.match(after)) {

                            var modifiers = extractModifiers(RE_CONSTRUCTOR.matched(1));
                            var name = 'constructor';
                            var type = parseType(RE_CONSTRUCTOR.matched(2));
                            var args = extractArgs(RE_CONSTRUCTOR.matched(3));

                            i += RE_CONSTRUCTOR.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                consumeBlock();
                            }
                            else {
                                // Add property info
                                var method:bind.Class.Method = {
                                    type: type,
                                    args: args,
                                    orig: {},
                                    name: name,
                                    instance: !modifiers.exists('static'),
                                    description: comment != null && comment.trim() != '' ? comment : null
                                };
                                comment = null;

                                result.methods.push(method);
                            }

                            consumeBlock();
                            
                        }
                        else if (RE_METHOD.match(after)) {

                            var modifiers = extractModifiers(RE_METHOD.matched(1));
                            var name = RE_METHOD.matched(3);
                            var type = parseType(RE_METHOD.matched(2));
                            var args = extractArgs(RE_METHOD.matched(4));
                            var end = RE_METHOD.matched(5);
                            
                            i += RE_METHOD.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                if (end != ';') consumeBlock();
                            }
                            else {
                                // Add property info
                                var method:bind.Class.Method = {
                                    type: type,
                                    args: args,
                                    orig: {},
                                    name: name,
                                    instance: !modifiers.exists('static'),
                                    description: comment != null && comment.trim() != '' ? comment : null
                                };
                                comment = null;

                                result.methods.push(method);
                            }

                            if (end != ';') consumeBlock();

                        }
                        else {
                            i++;
                        }
                    }
                    else {
                        i++;
                    }
                }
                else {
                    i++;
                }

            }
        }

        ctx.i = i;

        if (result.name == null) {
            return null;
        }
        else {
            return result;
        }

    } //parseClass

    public static function parseType(input:String, ?ctx:ParseContext, inTypeParam = false):bind.Class.Type {

        if (ctx == null) ctx = createContext();

        var baseType = '';
        var typeParameters = [];
        var len = input.length;
        var i = ctx.i;
        var startI = i;
        var endI = i;
        var c = '';
        var before = '';
        var expectNextTypeParam = false;
        var firstCharAfterSpace = '';

        while (i < len) {

            c = input.charAt(i);

            if (c == '<' || expectNextTypeParam) {
                if (baseType == '') return null;

                if (c == '<') i++;
                ctx.i = i;
                var typeParam = parseType(input, ctx, true);
                if (typeParam == null) return null;
                i = ctx.i;
                typeParameters.push(typeParam);
                before = input.substring(0, i).rtrim();

                if (before.endsWith('>')) {
                    endI = i;
                    break;
                } else {
                    expectNextTypeParam = true;
                }
            }
            else if (inTypeParam && (c == '>' || c == ',')) {
                endI = i;
                i++;
                break;
            }
            else if (c.trim() == '') {
                firstCharAfterSpace = input.substring(i).ltrim().charAt(0);
                if (baseType == '' || firstCharAfterSpace == '<') {
                    i++;
                }
                else if (inTypeParam && (firstCharAfterSpace == '>' || firstCharAfterSpace == ',')) {
                    i++;
                }
                else {
                    endI = i;
                    break;
                }
            }
            else {
                baseType += c;
                i++;
            }
            
            endI = i;
        }

        ctx.i = i;
        if (baseType == '') {
            return null;
        }
        else {
            var type:bind.Class.Type;
            var javaType = removeSpacesForType(input.substring(startI, endI));

            switch (baseType) {
                case 'String':
                    type = String({
                        javaType: javaType
                    });
                case 'Runnable':
                    type = Function([], Void({ javaType: 'void' }), {
                        javaType: javaType
                    });
                case 'List', 'AbstractList', 'ArrayList', 'AbstractSequentialList', 'AttributeList', 'CopyOnWriteArrayList', 'LinkedList', 'Stack', 'Vector':
                    type = Array(typeParameters.length > 0 ? typeParameters[0] : null, {
                        javaType: javaType
                    });
                case 'Map', 'Attributes', 'ConcurrentHashMap', 'HashMap', 'Hashtable', 'LinkedHashMap', 'TreeMap':
                    type = Map(typeParameters.length > 1 ? typeParameters[1] : null, {
                        javaType: javaType
                    });
                case 'Boolean', 'boolean':
                    type = Bool({
                        javaType: javaType
                    });
                case 'short', 'byte', 'int', 'long', 'char':
                    type = Int({
                        javaType: javaType
                    });
                case 'float', 'double':
                    type = Float({
                        javaType: javaType
                    });
                case 'Func0', 'Func1', 'Func2', 'Func3', 'Func4', 'Func5', 'Func6', 'Func7', 'Func8', 'Func9':
                    RE_FUNC.match(baseType);
                    var numArgs = Std.parseInt(RE_FUNC.matched(1));
                    var args = [];
                    for (n in 0...numArgs) {
                        args.push({
                            type: typeParameters[n],
                            name: 'arg' + (n + 1)
                        });
                    }
                    var ret = typeParameters[numArgs];
                    type = Function(args, ret, {
                        javaType: javaType
                    });
                case 'void', 'Void':
                    type = Void({
                        javaType: javaType
                    });
                default:
                    // Unknown object
                    type = Object({
                        javaType: javaType
                    });
            }

            return type;
        }

    } //parseType

/// Internal

    static function extractModifiers(inModifiers:String):Map<String,Bool> {

        var modifiers = new Map<String,Bool>();

        if (inModifiers != null) {
            for (item in inModifiers.replace("\t", ' ').split(' ')) {
                item = item.trim();
                if (item != '') {
                    modifiers.set(item, true);
                }
            }
        }

        return modifiers;

    } //extractModifiers

    static function extractArgs(inArgs:String):Array<bind.Class.Arg> {

        var args = [];

        var i = 0;
        var len = inArgs.length;
        var type = null;
        var name = null;

        while (i < len) {

            var ctx = createContext();
            ctx.i = i;
            type = parseType(inArgs, ctx);
            i = ctx.i;

            if (type == null) break;

            if (!RE_ARG_END.match(inArgs.substring(i))) break;

            name = RE_ARG_END.matched(1);
            args.push({
                type: type,
                name: name
            });
            i += RE_ARG_END.matched(0).length;

        }

        return args;

    } //extractArgs

    static function getCodeWithEmptyCommentsAndStrings(input:String):String {

        var i = 0;
        var output = '';
        var len = input.length;
        var inSingleLineComment = false;
        var inMultilineComment = false;
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
            else if ((c == '"' || c == '\'') && RE_STRING.match(input.substring(i))) {
                var len = RE_STRING.matched(0).length - 2;
                output += c;
                while (len-- > 0) {
                    output += ' ';
                }
                output += c;
                i += RE_STRING.matched(0).length;
            }
            else {
                output += c;
                i++;
            }
        }

        return output;

    } //getCodeWithEmptyComments

    static function removeSpacesForType(input:String):String {

        if (input == null) return null;

        var result = '';
        var i = 0;
        var len = input.length;
        var inSpace = false;
        var lastIsSeparator = false;
        var c = '';
        while (i < len) {

            c = input.charAt(i);

            if (c.trim() == '') {
                // Space
                inSpace = true;
            }
            else if (RE_NOT_SEPARATOR.match(c)) {
                // Non-separator
                if (inSpace) {
                    inSpace = false;
                    if (!lastIsSeparator) result += ' ';
                }
                lastIsSeparator = false;
                result += c;
            }
            else {
                if (inSpace) {
                    inSpace = false;
                }
                // Separator
                lastIsSeparator = true;
                result += c;
            }

            i++;
        }

        return result.trim();

    } //removeSpacesForType

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
