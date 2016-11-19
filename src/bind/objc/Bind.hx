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
        if (ctx.namespace != 'bind') ctx.objcHandleType = 'bind::' + ctx.objcHandleType;

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
            var ret = toHXCPPType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Instance handle as first argument
            if (method.instance) {
                args.push(ctx.objcHandleType + ' _instance');
            }

            // Method args
            for (arg in method.args) {
                args.push(toHXCPPType(arg.type, ctx) + ' ' + arg.name);
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

    static function toHXCPPType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig): 'double';
            case Bool(orig): 'bool';
            case String(orig): '::String';
            case Array(orig): toHXCPPArrayType(type, ctx);
            case Map(orig): toHXCPPMapType(type, ctx);
            case Object(orig): toHXCPPObjectType(type, ctx);
            case Function(args, ret, orig): toHXCPPFunctionType(type, ctx);
        }

        return result;

    } //toCPPType

    static function toHXCPPArrayType(type:bind.Class.Type, ctx:BindContext):String {

        return 'void*'; // TODO implement

    } //toHXCPPArrayType

    static function toHXCPPMapType(type:bind.Class.Type, ctx:BindContext):String {

        return 'void*'; // TODO implement

    } //toHXCPPMapType

    static function toHXCPPObjectType(type:bind.Class.Type, ctx:BindContext):String {

        return ctx.objcHandleType;

    } //toHXCPPObjectType

    static function toHXCPPFunctionType(type:bind.Class.Type, ctx:BindContext):String {

        return 'void*'; // TODO implement

    } //toHXCPPFunctionType

/// Write utils

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
