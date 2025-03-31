package bindhx.java;

import Sys.println;

using StringTools;

typedef ParseContext = {
    var i:Int;
    var types:Map<String,bindhx.Class.Type>;
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
    static var RE_GETTER = ~/^get([A-Z][a-zA-Z0-9_]*)$/;

    static var RE_FUNC = ~/^Func([0-9]+)$/;
    static var RE_FUNC_OPEN = ~/^Func([0-9]+)\s*</;
    static var RE_FINAL = ~/^\s*final\s+/;
    static var RE_TYPE_PARAM_COMMENT = ~/\/\*+\s*([a-zA-Z][a-zA-Z0-9_]*)\s*\*+\/\s*(,|>)?$/;

    public static function createContext():ParseContext {
        return { i: 0, types: new Map() };
    }

    /** Parse Objective-C header content to get class informations. */
    public static function parseClass(code:String, ?ctx:ParseContext):bindhx.Class {

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

        var result:bindhx.Class = {
            name: null,
            path: null,
            properties: [],
            methods: [],
            description: null,
            orig: {
                pack: null,
                imports: [],
                staticImports: []
            }
        };

        // Clean code
        var cleanedCode = getCodeWithEmptyCommentsAndStrings(code);

        /** Skip java content but take care of handling parenthesis, brackets and braces imbrications. */
        function consumeUntil(until:String) {

            var openBraces = 0;
            var openParens = 0;
            var openBrackets = 0;

            while (i < len) {
                c = cleanedCode.charAt(i);

                if (openBraces <= 0 && openParens <= 0 && openBrackets <= 0) {
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

                i++;
            }

        }

        function consumeBlock() {

            consumeUntil('}');

        }

        function consumeStatement() {

            consumeUntil(';');

        }

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
            if ((i == 0 || (pc != '' &&
                !inSingleLineComment &&
                !inMultilineComment &&
                RE_WORD_SEP.match(pc))) &&
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

                // Class
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
                        result.description = comment != null && comment.trim() != '' ? comment : null;
                        if (modifiers.exists('static')) Reflect.setField(result.orig, 'static', true);
                        if (modifiers.exists('final')) Reflect.setField(result.orig, 'final', true);
                        comment = null;

                        i += RE_DECL.matched(0).length;
                    }

                }
                else if (inClass) {
                    if (word != '') {
                        // Property
                        if (RE_PROPERTY.match(after)) {

                            var modifiers = extractModifiers(RE_PROPERTY.matched(1));
                            var name = RE_PROPERTY.matched(3);
                            var javaTypeWithComments = code.substr(i + after.indexOf(RE_PROPERTY.matched(2)), RE_PROPERTY.matched(2).length);
                            var javaType = RE_PROPERTY.matched(2);
                            var end = RE_PROPERTY.matched(4);

                            i += RE_PROPERTY.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                if (end != ';') consumeStatement();
                            }
                            else {
                                // Add property info
                                var property:bindhx.Class.Property = {
                                    type: parseType(javaType, javaTypeWithComments),
                                    orig: {},
                                    name: name,
                                    instance: !modifiers.exists('static'),
                                    description: comment != null && comment.trim() != '' ? comment : null
                                };
                                comment = null;

                                // A java final property can't be modified, so let's consider it's readonly
                                if (modifiers.exists('final')) property.orig.readonly = true;

                                result.properties.push(property);
                            }

                        }
                        // Constructor
                        else if (RE_CONSTRUCTOR.match(after)) {

                            var modifiers = extractModifiers(RE_CONSTRUCTOR.matched(1));
                            var name = 'constructor';
                            var type = parseType(RE_CONSTRUCTOR.matched(2), null);
                            var argsWithComments = code.substr(i + after.indexOf(RE_METHOD.matched(3)), RE_METHOD.matched(3).length);
                            var args = extractArgs(RE_CONSTRUCTOR.matched(3), argsWithComments);

                            i += RE_CONSTRUCTOR.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                consumeBlock();
                            }
                            else {
                                // Add property info
                                var method:bindhx.Class.Method = {
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
                        // Method
                        else if (RE_METHOD.match(after)) {

                            var modifiers = extractModifiers(RE_METHOD.matched(1));
                            var name = RE_METHOD.matched(3);
                            var typeWithComments = code.substr(i + after.indexOf(RE_METHOD.matched(2)), RE_METHOD.matched(2).length);
                            var type = parseType(RE_METHOD.matched(2), typeWithComments);
                            var argsWithComments = code.substr(i + after.indexOf(RE_METHOD.matched(4)), RE_METHOD.matched(4).length);
                            var args = extractArgs(RE_METHOD.matched(4), argsWithComments);
                            var end = RE_METHOD.matched(5);

                            i += RE_METHOD.matched(0).length;

                            // Skip private/protected/abstract stuff
                            if (!modifiers.exists('public') || modifiers.exists('abstract')) {
                                if (end != ';') consumeBlock();
                            }
                            else {
                                // Add property info
                                var method:bindhx.Class.Method = {
                                    type: type,
                                    args: args,
                                    orig: {},
                                    name: name,
                                    instance: !modifiers.exists('static'),
                                    description: comment != null && comment.trim() != '' ? comment : null
                                };
                                comment = null;

                                result.methods.push(method);

                                if (end != ';') consumeBlock();
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
                // Package
                else if (word == 'package') {
                    i += word.length;
                    var pack = '';
                    c = cleanedCode.charAt(i);
                    while (c != ';') {
                        pack += c;
                        i++;
                        c = cleanedCode.charAt(i);
                    }
                    i++;
                    if (result.orig.pack == null) result.orig.pack = pack.trim();
                }
                // Import
                else if (word == 'import') {

                    if (!RE_IMPORT.match(after)) {
                        throw 'Failed to parse import';
                    }

                    var pack = RE_IMPORT.matched(2);
                    var isStatic = RE_IMPORT.matched(1) != null && RE_IMPORT.matched(1).trim() == 'static';

                    if (isStatic) {
                        result.orig.staticImports.push(pack);
                    }
                    else {
                        result.orig.imports.push(pack);
                    }

                    i += RE_IMPORT.matched(0).length;

                }
                else {
                    i++;
                }

            }
        }

        ctx.i = i;

        extractPropertyMethods(result);

        if (result.name == null) {
            return null;
        }
        else {
            return result;
        }

    }

    public static function parseType(input:String, inputWithComments:String, ?ctx:ParseContext, inTypeParam = false):bindhx.Class.Type {

        if (ctx == null) ctx = createContext();

        var baseType = '';
        var typeParameters:Array<{type:bindhx.Class.Type, name:String}> = [];
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
                var typeParam = parseType(input, inputWithComments, ctx, true);
                if (typeParam == null) return null;
                var name = null;
                var typeParamWithComments = inputWithComments.substring(i, ctx.i);
                if (RE_TYPE_PARAM_COMMENT.match(typeParamWithComments)) {
                    name = RE_TYPE_PARAM_COMMENT.matched(1);
                }
                i = ctx.i;
                typeParameters.push({
                    type: typeParam,
                    name: name
                });
                before = input.substring(0, i).rtrim();

                if (before.endsWith('>')) {
                    endI = i;
                    i++;
                    if (inTypeParam) {
                        while (input.charAt(i-1).trim() == '') {
                            i++;
                        }
                    }
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
            var type:bindhx.Class.Type;
            var javaType = removeSpacesForType(input.substring(startI, endI));

            switch (baseType) {
                case 'String':
                    type = String({
                        type: javaType
                    });
                case 'Runnable':
                    type = Function([], Void({ type: 'void' }), {
                        type: javaType
                    });
                case 'List', 'AbstractList', 'ArrayList', 'AbstractSequentialList', 'AttributeList', 'CopyOnWriteArrayList', 'LinkedList', 'Stack', 'Vector':
                    type = Array(typeParameters.length > 0 ? typeParameters[0].type : null, {
                        type: javaType
                    });
                case 'Map', 'Attributes', 'ConcurrentHashMap', 'HashMap', 'Hashtable', 'LinkedHashMap', 'TreeMap':
                    type = Map(typeParameters.length > 1 ? typeParameters[1].type : null, {
                        type: javaType
                    });
                case 'boolean', 'Boolean':
                    type = Bool({
                        type: javaType
                    });
                case 'short', 'byte', 'int', 'long', 'char', 'Short', 'Byte', 'Integer', 'Long', 'Char':
                    type = Int({
                        type: javaType
                    });
                case 'float', 'double', 'Float', 'Double':
                    type = Float({
                        type: javaType
                    });
                case 'Func0', 'Func1', 'Func2', 'Func3', 'Func4', 'Func5', 'Func6', 'Func7', 'Func8', 'Func9', 'Func10', 'Func11', 'Func12', 'Func13', 'Func14', 'Func15', 'Func16':
                    RE_FUNC.match(baseType);
                    var numArgs = Std.parseInt(RE_FUNC.matched(1));
                    var args = [];
                    for (n in 0...numArgs) {
                        args.push({
                            type: typeParameters[n].type,
                            name: typeParameters[n].name != null ? typeParameters[n].name : 'arg' + (n + 1)
                        });
                    }
                    var ret = typeParameters[numArgs].type;
                    type = Function(args, ret, {
                        type: javaType
                    });
                case 'void', 'Void':
                    type = Void({
                        type: javaType
                    });
                default:
                    // Unknown object
                    type = Object({
                        type: javaType
                    });
            }

            return type;
        }

    }

    static function extractPropertyMethods(result:bindhx.Class):Void {

        var existingMethods:Map<String,bindhx.Class.Method> = new Map();
        var existingProperties:Map<String,bindhx.Class.Property> = new Map();

        for (method in result.methods) {
            existingMethods.set(method.name, method);
        }
        for (property in result.properties) {
            existingProperties.set(property.name, property);
        }

        // Link or imply getters and setters from public properties
        for (property in result.properties) {
            // Getter
            var getterName = 'get' + property.name.charAt(0).toUpperCase() + property.name.substring(1);
            if (!existingMethods.exists(getterName)) {
                result.methods.push({
                    name: getterName,
                    args: [],
                    type: property.type,
                    instance: property.instance,
                    description: property.description,
                    orig: extendOrig(property.orig, {
                        implicit: true,
                        getter: true,
                        property: {
                            name: property.name
                        }
                    })
                });
            }
            else {
                var method = existingMethods.get(getterName);
                if (method.orig == null) method.orig = {};
                if (method.orig.property == null) {
                    method.orig.property = {
                        name: property.name
                    }
                    method.orig.getter = true;
                }
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
                        instance: property.instance,
                        description: property.description,
                        orig: extendOrig(property.orig, {
                            implicit: true,
                            setter: true,
                            property: {
                                name: property.name
                            }
                        })
                    });
                }
                else {
                    var method = existingMethods.get(setterName);
                    if (method.orig == null) method.orig = {};
                    if (method.orig.property == null) {
                        method.orig.property = {
                            name: property.name
                        }
                        method.orig.setter = true;
                    }
                }
            }
        }

        // Resolve properties from public getters and setters
        for (method in result.methods) {
            if (RE_GETTER.match(method.name)) {
                var propertyName = RE_GETTER.matched(1).charAt(0).toLowerCase() + RE_GETTER.matched(1).substring(1);
                var getterName = 'get' + RE_GETTER.matched(1);
                var setterName = 'set' + RE_GETTER.matched(1);
                var setter = existingMethods.get(setterName);
                var getter = existingMethods.get(getterName);
                var canImplyProperty = true;
                if (!existingProperties.exists(propertyName)) {
                    // We resolve an implicit property from its public getters and setters
                    var readonly = true;
                    if (getter != null && setter != null) {
                        var getterType = toJavaType(getter.type);
                        // Ensure setter shares the same type as getter
                        if (setter.args.length == 1) {
                            var setterType = toJavaType(setter.args[0].type);
                            if (getterType != setterType) {
                                canImplyProperty = false;
                            }
                            else {
                                // Setter matches, property is not readonly then
                                readonly = false;
                            }
                        }
                        else {
                            canImplyProperty = false;
                        }
                    }

                    // Disable this feature for now by default, because it has bugs
                    #if !bind_java_implicit_properties
                    canImplyProperty = false;
                    #end

                    if (canImplyProperty) {
                        // Add implicit property
                        result.properties.push({
                            type: getter.type,
                            orig: {
                                implicit: true,
                                readonly: readonly
                            },
                            name: propertyName,
                            instance: getter.instance,
                            description: getter.description
                        });
                    }
                }
            }
        }

    }

    static function extendOrig(orig:Dynamic, extension:Dynamic):Dynamic {

        var result:Dynamic = {};

        for (field in Reflect.fields(orig)) {
            Reflect.setField(result, field, Reflect.field(orig, field));
        }

        for (field in Reflect.fields(extension)) {
            Reflect.setField(result, field, Reflect.field(extension, field));
        }

        return result;

    }

    static function toJavaType(type:bindhx.Class.Type):String {

        var orig:Dynamic = null;

        switch (type) {
            case Void(orig_): orig = orig_;
            case Int(orig_): orig = orig_;
            case Float(orig_): orig = orig_;
            case Bool(orig_): orig = orig_;
            case String(orig_): orig = orig_;
            case Array(itemType_, orig_): orig = orig_;
            case Map(itemType_, orig_): orig = orig_;
            case Object(orig_): orig = orig_;
            case Function(args, ret, orig_): orig = orig_;
        }

        while (orig.orig != null) {
            orig = orig.orig;
        }

        return orig.type;

    }

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

    }

    static function extractArgs(inArgs:String, inArgsWithComments:String):Array<bindhx.Class.Arg> {

        var args = [];

        var i = 0;
        var len = inArgs.length;
        var type = null;
        var name = null;
        var orig:Dynamic = {};

        while (i < len) {

            var after = inArgs.substring(i);
            if (RE_FINAL.match(after)) {
                Reflect.setField(orig, 'final', true);
                i += RE_FINAL.matched(0).length;
            }

            var ctx = createContext();
            ctx.i = i;
            type = parseType(inArgs, inArgsWithComments, ctx);
            i = ctx.i;

            if (type == null) break;

            if (!RE_ARG_END.match(inArgs.substring(i))) break;

            name = RE_ARG_END.matched(1);
            args.push({
                type: type,
                name: name,
                orig: orig
            });
            i += RE_ARG_END.matched(0).length;

        }

        return args;

    }

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

    }

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

    }

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

    }

}
