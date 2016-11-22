package bind.objc;

using StringTools;

typedef BindContext = {
    var objcClass:bind.Class;
    var indent:Int;
    var files:Array<bind.File>;
    var namespace:String;
    var objcHandleType:String;
    var currentFile:bind.File;
}

class Bind {

    public static function createContext():BindContext {

        return {
            objcClass: null,
            indent: 0,
            files: [],
            namespace: null,
            currentFile: null,
            objcHandleType: null,
        };

    } //createContext

    /** Reads bind.Class object informations and generate files
        To bind the related Objective-C class to Haxe.
        The files are returned as an array of bind.File objects.
        Nothing is written to disk at this stage. */
    public static function bindClass(objcClass:bind.Class, ?options:{?namespace:String}):Array<bind.File> {

        trace(bind.Json.stringify(objcClass, true));
        trace('BIND CLASS ' + objcClass.name);

        var ctx = createContext();
        ctx.objcClass = objcClass;

        if (options != null) {
            if (options.namespace != null) ctx.namespace = options.namespace;
        }

        // Generate Objective C++ file
        generateObjCPPFile(ctx);

        return ctx.files;

    } //bindClass

    public static function generateObjCPPFile(ctx:BindContext, header:Bool = false):Void {

        ctx.currentFile = { path: 'bind_' + ctx.objcClass.name + '.mm', content: '' };

        writeLineBreak(ctx);

        var namespaceEntries = [];
        if (ctx.namespace != null && ctx.namespace.trim() != '') {
            namespaceEntries = ctx.namespace.split('::');
        }

        ctx.objcHandleType = 'ObjcHandle';
        if (ctx.namespace != 'bind') ctx.objcHandleType = '::bind::' + ctx.objcHandleType;

        // Class comment
        if (ctx.objcClass.description != null && ctx.objcClass.description.trim() != '') {
            writeComment(ctx.objcClass.description, ctx);
            if (namespaceEntries.length == 0) {
                writeLineBreak(ctx);
            }
        }

        // Open namespaces
        for (name in namespaceEntries) {
            writeLine('namespace $name {', ctx);
            ctx.indent++;
            writeLineBreak(ctx);
        }

        // Add methods
        for (method in ctx.objcClass.methods) {

            // Method return type
            var ret = toHxcppType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Instance handle as first argument
            if (method.instance) {
                args.push(ctx.objcHandleType + ' instance_');
            }

            // Method args
            for (arg in method.args) {
                args.push(toHxcppType(arg.type, ctx) + ' ' + arg.name);
            }

            // Method comment
            if (method.description != null && method.description.trim() != '') {
                writeComment(method.description, ctx);
            }

            // Whole method
            writeIndent(ctx);
            write(ret + ' ' + ctx.objcClass.name + '_' + name + '(' + args.join(', ') + ')', ctx);
            if (header) {
                write(';', ctx);
            }
            else {
                write(' {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Method body
                //
                // Convert args to Objc
                var toObjc = [];
                var i = 0;
                for (arg in method.args) {

                    writeObjcArgAssign(arg, i, ctx);

                    i++;

                }

                ctx.indent--;
                writeIndent(ctx);
                write('}', ctx);
            }
            writeLineBreak(ctx);
            writeLineBreak(ctx);

        }

        // Close namespaces
        for (name in namespaceEntries) {
            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);
        }

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    } //generateObjCPPFile

/// Objective-C -> HXCPP

    static function toHxcppType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig): 'double';
            case Bool(orig): 'bool';
            case String(orig): '::String';
            case Array(orig): toHxcppArrayType(type, ctx);
            case Map(orig): toHxcppMapType(type, ctx);
            case Object(orig): toHxcppObjectType(type, ctx);
            case Function(args, ret, orig): toHxcppFunctionType(type, ctx);
        }

        return result;

    } //toCPPType

    static function toHxcppArrayType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    } //toHxcppArrayType

    static function toHxcppMapType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    } //toHxcppMapType

    static function toHxcppObjectType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    } //toHxcppObjectType

    static function toHxcppFunctionType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    } //toHxcppFunctionType

/// HXCPP -> Objective-C

    static function toObjcType(type:bind.Class.Type, ctx:BindContext):String {

        var orig:Dynamic = null;

        switch (type) {
            case Void(orig_): orig = orig_;
            case Int(orig_): orig = orig_;
            case Float(orig_): orig = orig_;
            case Bool(orig_): orig = orig_;
            case String(orig_): orig = orig_;
            case Array(orig_): orig = orig_;
            case Map(orig_): orig = orig_;
            case Object(orig_): orig = orig_;
            case Function(args, ret, orig_): orig = orig_;
        }

        while (orig.orig != null) {
            orig = orig.orig;
        }

        return orig.type;

    } //toObjcArg

/// Write utils (specific)

    static function writeHxcppArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toHxcppType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_objc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1));

        switch (arg.type) {

            case Function(args, ret, orig):
                var funcType = toHxcppType(arg.type, ctx);
                write(funcType + ' = NULL; // TODO implement', ctx);

            case String(orig):
                var objcType = toObjcType(arg.type, ctx);
                switch (objcType) {
                    case 'NSString*', 'NSMutableString*':
                        write('$type $name = ::bind::objc::NSStringToHxcpp($value);', ctx);
                    case 'char*':
                        write('$type $name = ::bind::objc::CharStringToHxcpp($value);', ctx);
                    case 'const char*':
                        write('$type $name = ::bind::objc::ConstCharStringToHxcpp($value);', ctx);
                }
                writeLineBreak(ctx);

            default:
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeHxcppArgAssign

    static function writeObjcArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toObjcType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_objc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1));

        switch (arg.type) {

            case Function(args, ret, orig):
                var blockReturnType = toObjcType(ret, ctx);
                write(blockReturnType + ' ', ctx);
                write('(^' + name + ')(', ctx);
                var i = 0;
                for (blockArg in args) {
                    if (i++ > 0) write(', ', ctx);

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + i;
                    write(toObjcType(blockArg.type, ctx) + ' ' + argName, ctx);
                }
                write(') = ^' + (blockReturnType != 'void' ? blockReturnType : '') + '(', ctx);
                i = 0;
                for (blockArg in args) {
                    if (i > 0) write(', ', ctx);

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);

                    write(toObjcType(blockArg.type, ctx) + ' ' + argName, ctx);

                    i++;
                }
                write(') {', ctx);
                ctx.indent++;
                writeLineBreak(ctx);

                i = 0;
                for (blockArg in args) {

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    var hxcppName = argName + '_hxcpp_';

                    writeHxcppArgAssign(blockArg, i, ctx);

                    i++;
                }

                writeIndent(ctx);
                if (blockReturnType != 'void') write('return ', ctx);
                write(arg.name + '(', ctx);

                i = 0;
                for (blockArg in args) {
                    if (i > 0) write(', ', ctx);

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    var hxcppName = argName + '_hxcpp_';

                    write(hxcppName, ctx);

                    i++;
                }

                write(');', ctx);
                writeLineBreak(ctx);

                ctx.indent--;
                writeIndent(ctx);
                write('};', ctx);
                writeLineBreak(ctx);

            case String(orig):
                switch (type) {
                    case 'NSString*':
                        write('$type $name = ::bind::objc::HxcppToNSString($value);', ctx);
                    case 'NSMutableString*':
                        write('$type $name = ::bind::objc::HxcppToNSMutableString($value);', ctx);
                    case 'char*':
                        write('$type $name = ::bind::objc::HxcppToCharString($value);', ctx);
                    case 'const char*':
                        write('$type $name = ::bind::objc::HxcppToConstCharString($value);', ctx);
                }
                writeLineBreak(ctx);

            case Array(orig):
                switch (type) {
                    case 'NSArray*':
                        write('$type $name = ::bind::objc::HxcppToNSArray($value);', ctx);
                    case 'NSMutableArray*':
                        write('$type $name = ::bind::objc::HxcppToNSMutableArray($value);', ctx);
                }
                writeLineBreak(ctx);

            case Object(orig):
                if (type.endsWith('*')) {
                    write('$type $name = ::bind::objc::HxcppToObjcId((Dynamic)$value);', ctx);
                } else {
                    write('$type $name = ($type) $value;', ctx);
                }
                writeLineBreak(ctx);

            default:
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeObjcArgAssign

/// Write utils (generic)

    static function writeComment(comment:String, ctx:BindContext):Void {

        writeIndent(ctx);
        write('/** ', ctx);
        var i = 0;
        var lines = comment.split("\n");
        while (i < lines.length) {

            var line = lines[i];

            if (i > 0) {
                writeLineBreak(ctx);
                write('    ', ctx);
            }

            write(line, ctx);

            i++;
        }

        write(' */', ctx);
        writeLineBreak(ctx);

    } //writeLine

    static function writeLine(line:String, ctx:BindContext):Void {

        writeIndent(ctx);
        write(line, ctx);
        writeLineBreak(ctx);

    } //writeLine

    static function writeIndent(ctx:BindContext):Void {

        var space = '';
        var i = 0;
        var indent = ctx.indent;
        while (i < indent) {
            space += '    ';
            i++;
        }

        write(space, ctx);

    } //writeIndent

    static function writeLineBreak(ctx:BindContext):Void {

        write("\n", ctx);

    } //writeLineBreak

    static function write(input:String, ctx:BindContext):Void {

        ctx.currentFile.content += input;

    } //write

} //Bind
