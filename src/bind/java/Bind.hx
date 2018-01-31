package bind.java;

import haxe.io.Path;

using StringTools;

typedef BindContext = {
    var javaClass:bind.Class;
    var indent:Int;
    var files:Array<bind.File>;
    var namespace:String;
    var pack:String;
    var currentFile:bind.File;
    var javaPath:String;
    var javaCode:String;
}

class Bind {

    public static function createContext():BindContext {

        return {
            javaClass: null,
            indent: 0,
            files: [],
            namespace: null,
            pack: null,
            currentFile: null,
            javaPath: null,
            javaCode: null
        };

    } //createContext

    /** Reads bind.Class object informations and generate files
        To bind the related Java class to Haxe.
        The files are returned as an array of bind.File objects.
        Nothing is written to disk at this stage. */
    public static function bindClass(javaClass:bind.Class, ?options:{?namespace:String, ?pack:String, ?javaPath:String, ?javaCode:String}):Array<bind.File> {

        var ctx = createContext();
        ctx.javaClass = javaClass;

        if (options != null) {
            if (options.namespace != null) ctx.namespace = options.namespace;
            if (options.pack != null) ctx.pack = options.pack;
            if (options.javaPath != null) ctx.javaPath = options.javaPath;
            if (options.javaCode != null) ctx.javaCode = options.javaCode;
        }

        // Generate Haxe file
        generateHaxeFile(ctx);

        // Generate Java intermediate file
        generateJavaFile(ctx);

        /*// Copy Objective C header file
        copyObjcHeaderFile(ctx);

        // Generate Objective C++ file
        generateObjCPPFile(ctx, true);
        generateObjCPPFile(ctx);

        // Generate Haxe file
        generateHaxeFile(ctx);

        // Generate Linc (XML) file
        generateLincFile(ctx);*/

        return ctx.files;

    } //bindClass

    public static function generateHaxeFile(ctx:BindContext):Void {

        var reserved = ['new', 'with'];

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        var haxeName = ctx.javaClass.name;

        ctx.currentFile = { path: dir + haxeName + '.hx', content: '' };

        var packPrefix = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            packPrefix = ctx.pack.trim() + '.';
            writeLine('package ' + ctx.pack.trim() + ';', ctx);
        } else {
            writeLine('package;', ctx);
        }

        writeLine('// This file was generated with bind library', ctx);
        writeLineBreak(ctx);

        // Objc support
        writeLine('import bind.java.Support;', ctx);

        writeLineBreak(ctx);

        // Class comment
        if (ctx.javaClass.description != null && ctx.javaClass.description.trim() != '') {
            writeComment(ctx.javaClass.description, ctx);
        }

        writeLine('class ' + haxeName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private var _instance:Dynamic = null;', ctx);
        writeLineBreak(ctx);

        writeLine('public function new() {}', ctx);
        writeLineBreak(ctx);

        // Add properties
        // TODO
        /*for (property in ctx.javaClass.properties) {

            // Read-only?
            var readonly = property.orig != null && property.orig.readonly == true;

            // Singleton?
            var isJavaSingleton = isJavaSingleton(property, ctx);

            // Property name
            var name = property.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            // Property type
            var type = toHaxeType(property.type, ctx);
            if (isJavaSingleton) {
                type = haxeName;
            }

            // Property comment
            if (property.description != null && property.description.trim() != '') {
                writeComment(property.description, ctx);
            }

            writeIndent(ctx);
            write('public ', ctx);

            // Static property?
            if (!property.instance) {
                write('static ', ctx);
            }

            write('var ' + name + '(get,' + (readonly ? 'never' : 'set') + '):' + type + ';', ctx);
            writeLineBreak(ctx);
            writeLineBreak(ctx);

        }*/

        // Add methods
        for (method in ctx.javaClass.methods) {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Factori?
            var isJavaFactory = isJavaFactory(method, ctx);

            // Is it a getter or setter?
            var isGetter = method.orig != null && method.orig.getter == true;
            var isSetter = method.orig != null && method.orig.setter == true;

            // Method return type
            var ret = toHaxeType(isSetter ? method.args[0].type : method.type, ctx);

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Method args
            for (arg in method.args) {
                args.push(arg.name + ':' + toHaxeType(arg.type, ctx));
            }

            // Method comment
            if (method.description != null && method.description.trim() != '') {
                writeComment(method.description, ctx);
            }

            writeIndent(ctx);
            if (isGetter || isSetter) {
                write('inline private ', ctx);
            } else {
                write('public ', ctx);
            }

            // Static method?
            if (!method.instance) {
                write('static ', ctx);
            }

            // Whole method
            if (isGetter) {
                write('function get_' + name + '(' + args.join(', ') + '):', ctx);
            } else if (isSetter) {
                write('function set_' + method.orig.property.name + '(' + args.join(', ') + '):', ctx);
            } else {
                write('function ' + name + '(' + args.join(', ') + '):', ctx);
            }
            if (isJavaConstructor) {
                write(haxeName, ctx);
            } else if (isJavaFactory) {
                write(haxeName, ctx);
            } else {
                write(ret, ctx);
            }
            write(' {', ctx);
            writeLineBreak(ctx);
            ctx.indent++;

            writeIndent(ctx);
            if (isJavaConstructor) {
                write('_instance = ', ctx);
            } else if (isJavaFactory) {
                write('var ret = new ' + haxeName + '();', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                write('ret._instance = ', ctx);
            } else {
                switch (method.type) {
                    case Void(orig):
                    default:
                        write('return ', ctx);
                }
            }
            write(ctx.javaClass.name + '_Extern.' + name + '(', ctx);
            var i = 0;
            if (!isJavaConstructor && method.instance) {
                write('_instance', ctx);
                i++;
            }
            for (arg in method.args) {
                if (i > 0) write(', ', ctx);
                write(arg.name, ctx);
                i++;
            }
            write(');', ctx);
            writeLineBreak(ctx);
            if (isJavaConstructor) {
                writeLine('return this;', ctx);
            } else if (isJavaFactory) {
                writeLine('return ret;', ctx);
            } else if (isSetter) {
                writeLine('return ' + method.orig.property.name + ';', ctx);
            }

            ctx.indent--;
            writeLine('}', ctx);

            writeLineBreak(ctx);

        }

        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        // Extern class declaration
        writeLine('@:keep', ctx);
        writeLine('@:include(\'linc_' + ctx.javaClass.name + '.h\')', ctx);
        writeLine('#if !display', ctx);
        writeLine('@:build(bind.Linc.touch())', ctx);
        writeLine('@:build(bind.Linc.xml(\'' + ctx.javaClass.name + '\', \'./\'))', ctx);
        writeLine('#end', ctx);
        writeLine('@:allow(' + packPrefix + haxeName + ')', ctx);
        writeLine('private extern class ' + haxeName + '_Extern {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        // Add methods
        for (method in ctx.javaClass.methods) {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Method return type
            var ret = toHaxeType(method.type, ctx);

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Instance argument
            if (method.instance && !isJavaConstructor) {
                args.push('instance_:Dynamic');
            }

            // Method args
            for (arg in method.args) {
                args.push(arg.name + ':' + toHaxeType(arg.type, ctx));
            }

            // C++ method
            writeIndent(ctx);
            write('@:native(\'', ctx);
            if (ctx.namespace != null && ctx.namespace.trim() != '') {
                write(ctx.namespace.trim() + '::', ctx);
            }
            write(ctx.javaClass.name + '_' + method.name, ctx);
            write('\')', ctx);
            writeLineBreak(ctx);

            writeIndent(ctx);

            // Whole method
            write('static function ' + name + '(' + args.join(', ') + '):' + ret, ctx);
            write(';', ctx);

            writeLineBreak(ctx);
            writeLineBreak(ctx);

        }

        // Class end
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    } //generateHaxeFile

    public static function generateJavaFile(ctx:BindContext):Void {

        var reserved = ['new', 'with'];

        var dir = '';
        var pack = '' + ctx.javaClass.orig.pack;
        dir = pack.replace('.', '/') + '/';

        var imports:Array<String> = ctx.javaClass.orig.imports;
        var bindingName = 'bind_' + ctx.javaClass.name;

        ctx.currentFile = { path: Path.join(['java', dir, bindingName + '.java']), content: '' };

        writeLine('package ' + pack + ';', ctx);

        writeLine('// This file was generated with bind library', ctx);
        writeLineBreak(ctx);

        // Imports
        if (imports.indexOf('bind.Support.*') == -1) {
            writeLine('import bind.Support.*;', ctx);
        }
        for (imp in imports) {
            writeLine('import $imp;', ctx);
        }

        writeLineBreak(ctx);

        // Class comment
        if (ctx.javaClass.description != null && ctx.javaClass.description.trim() != '') {
            writeComment(ctx.javaClass.description, ctx);
        }

        writeLine('@SuppressWarnings("unchecked")', ctx);
        writeLine('class ' + bindingName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private static class bind_Result {', ctx);
        ctx.indent++;
        writeLine('Object value = null;', ctx);
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        // Add methods
        for (method in ctx.javaClass.methods) {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Factori?
            var isJavaFactory = isJavaFactory(method, ctx);

            // Is it a getter or setter?
            var isGetter = method.orig != null && method.orig.getter == true;
            var isSetter = method.orig != null && method.orig.setter == true;

            // Method return type
            var ret = toJavaBindType(isSetter ? method.args[0].type : method.type, ctx);
            if (isJavaConstructor) {
                ret = ctx.javaClass.name;
            }

            // Has return
            var hasReturn = ret != 'void';

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Method args
            if (method.instance && !isJavaConstructor) {
                args.push('final ' + ctx.javaClass.name + ' _instance');
            }
            for (arg in method.args) {
                args.push('final ' + toJavaBindType(arg.type, ctx) + ' ' + arg.name);
            }

            // Method comment
            if (method.description != null && method.description.trim() != '') {
                writeComment(method.description, ctx);
            }

            writeIndent(ctx);
            write('public ', ctx);
            write('static ', ctx);

            write(ret + ' ', ctx);
            write(name + '(', ctx);
            write(args.join(', '), ctx);
            write(') {', ctx);
            writeLineBreak(ctx);
            ctx.indent++;

            writeLine('if (!bind.Support.isUIThread()) {', ctx);
            ctx.indent++;
            if (hasReturn) {
                writeLine('final Object _bind_lock = new Object();', ctx);
                writeLine('final bind_Result _bind_result = new bind_Result();', ctx);
            }
            writeLine('bind.Support.runInUIThread(new Runnable() {', ctx);
            ctx.indent++;
            writeLine('public void run() {', ctx);
            ctx.indent++;

            if (hasReturn) {
                writeLine('try {', ctx);
                ctx.indent++;
                writeIndent(ctx);
                write('_bind_result.value = bind_' + ctx.javaClass.name + '.' + method.name + '(', ctx);
            } else {
                writeIndent(ctx);
                write('bind_' + ctx.javaClass.name + '.' + method.name + '(', ctx);
            }

            var callArgs = [];
            if (method.instance && !isJavaConstructor) {
                callArgs.push('_instance');
            }
            for (arg in method.args) {
                callArgs.push(arg.name);
            }
            write(callArgs.join(', '), ctx);
            write(');', ctx);
            writeLineBreak(ctx);

            if (hasReturn) {
                ctx.indent--;
                writeLine('} catch (Throwable e) {', ctx);
                ctx.indent++;
                writeLine('e.printStackTrace();', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                writeLine('_bind_lock.notify();', ctx);
            }

            ctx.indent--;
            writeLine('}', ctx);
            ctx.indent--;
            writeLine('});', ctx);

            if (hasReturn) {
                writeLine('try {', ctx);
                ctx.indent++;
                writeLine('_bind_lock.wait();', ctx);
                ctx.indent--;
                writeLine('} catch (Throwable e) {', ctx);
                ctx.indent++;
                writeLine('e.printStackTrace();', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                writeLine('return (' + ret + ') _bind_result.value;', ctx);
            }

            ctx.indent--;
            writeLine('} else {', ctx);
            ctx.indent++;

            var index = 0;
            for (arg in method.args) {
                writeJavaArgAssign(arg, index++, ctx);
            }
            // Call Java
            writeJavaCall(method, ctx);

            ctx.indent--;
            writeLine('}', ctx);

            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);

        }

        // Class end
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    } //generateJavaFile

/// Java -> Haxe

    static function toHaxeType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'Void';
            case Int(orig): 'Int';
            case Float(orig): 'Float';
            case Bool(orig): 'Bool';
            case String(orig): 'String';
            case Array(itemType, orig): 'Array<Dynamic>';
            case Map(itemType, orig): 'Dynamic';
            case Object(orig): 'Dynamic';
            case Function(args, ret, orig): toHaxeFunctionType(type, ctx);
        }

        return result;

    } //toHaxeType

    static function toHaxeFunctionType(type:bind.Class.Type, ctx:BindContext):String {

        var result = 'Dynamic';

        switch (type) {
            case Function(args, ret, orig):
                var resArgs = [];
                if (args.length == 0) {
                    resArgs.push('Void');
                } else {
                    for (arg in args) {
                        var haxeType = toHaxeType(arg.type, ctx);
                        if (haxeType.indexOf('->') != -1) {
                            haxeType = '(' + haxeType + ')';
                        }
                        resArgs.push(haxeType);
                    }
                }
                var haxeType = toHaxeType(ret, ctx);
                if (haxeType.indexOf('->') != -1) {
                    haxeType = '(' + haxeType + ')';
                }
                resArgs.push(haxeType);
                result = resArgs.join('->');
            default:
        }

        return result;

    } //toHaxeFunctionType

/// HXCPP -> Java

    static function toJavaType(type:bind.Class.Type, ctx:BindContext):String {

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

    } //toJavaType

    static function toJavaBindType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig): 'float';
            case Bool(orig): 'int';
            case String(orig): 'String';
            case Array(itemType, orig): 'String';
            case Map(itemType, orig): 'String';
            case Object(orig): 'Object';
            case Function(args, ret, orig): 'Object';
        }

        return result;

    } //toJavaBindType

/// Helpers

    static function isJavaConstructor(method:bind.Class.Method, ctx:BindContext):Bool {

        return method.name == 'constructor';

    } //isJavaConstructor

    static function isJavaFactory(method:bind.Class.Method, ctx:BindContext):Bool {

        var isJavaFactory = false;
        var javaType = toJavaType(method.type, ctx);
        if (!method.instance && (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name)) {
            isJavaFactory = true;
        }

        return isJavaFactory;

    } //isJavaFactory

    static function isJavaSingleton(property:bind.Class.Property, ctx:BindContext):Bool {

        var isJavaSingleton = false;
        var javaType = toJavaType(property.type, ctx);
        if (!property.instance && (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name)) {
            isJavaSingleton = true;
        }

        return isJavaSingleton;

    } //isJavaSingleton

/// Write utils (specific)

    static function writeJavaArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toJavaType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_java_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine(type + ' ' + name + ' = null; // Not implemented yet', ctx);

            case String(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('$type $name = $value != 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('$type $name = ($type) bind.Support.fromJSONString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('$type $name = ($type) bind.Support.fromJSONString($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeJavaArgAssign

    static function writeJavaBindArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toJavaBindType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_java_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine(type + ' ' + name + ' = null; // Not implemented yet', ctx);

            case String(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('$type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('$type $name = $value ? 1 : 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('$type $name = bind.Support.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('$type $name = bind.Support.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeJavaBindArgAssign

    static function writeJavaCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isJavaConstructor = isJavaConstructor(method, ctx);

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            switch (method.type) {
                case Function(args, ret, orig):
                    write('id return_java_ = ', ctx);
                default:
                    var javaType = toJavaType(method.type, ctx);
                    write(javaType + ' return_java_ = ', ctx);
            }
        }
        if (isJavaConstructor) {
            write('new ' + ctx.javaClass.name + '(', ctx);
        } else if (method.instance) {
            write('_instance.' + method.name + '(', ctx);
        } else {
            write(ctx.javaClass.name + '.' + method.name + '(', ctx);
        }
        var n = 0;
        for (arg in method.args) {
            if (n++ > 0) write(', ', ctx);
            write(arg.name + '_java_', ctx);
        }
        write(');', ctx);
        writeLineBreak(ctx);
        if (hasReturn) {
            if (isJavaConstructor) {
                writeLine('return return_java_;', ctx);
            } else {
                writeJavaBindArgAssign({
                    name: 'return',
                    type: method.type
                }, -1, ctx);
                writeLine('return return_jni_;', ctx);
            }
        }

    } //writeJavaCall

/// Write utils (generic)

    static function writeComment(comment:String, ctx:BindContext):Void {

        writeIndent(ctx);
        write('/** ', ctx);
        var spaces = getLastLineIndent(ctx);
        var i = 0;
        var lines = comment.split("\n");
        while (i < lines.length) {

            var line = lines[i];

            if (i > 0) {
                writeLineBreak(ctx);
                write(spaces, ctx);
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

    static function getLastLineIndent(ctx:BindContext):String {

        var lines = ctx.currentFile.content.split("\n");
        var numChars = lines[lines.length - 1].length;
        var spaces = '';
        for (i in 0...numChars) {
            spaces += ' ';
        }
        return spaces;

    } //getLastLineIndent

}