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

        // Generate Objective C++ file
        generateCPPFile(ctx, true);
        generateCPPFile(ctx);

        // Generate Linc (XML) file
        generateLincFile(ctx);

        return ctx.files;

    } //bindClass

    public static function generateHaxeFile(ctx:BindContext):Void {

        var reserved = ['new', 'with', 'init'];

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        var haxeName = ctx.javaClass.name;
        var javaBindClassPath = 'bind_' + ctx.javaClass.name;
        var javaClassPath = '' + ctx.javaClass.name;
        var javaPack = '' + ctx.javaClass.orig.pack;
        if (javaPack != '') {
            javaBindClassPath = javaPack + '.' + javaBindClassPath;
            javaClassPath = javaPack + '.' + javaClassPath;
        }

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

        writeLine('private static var _jclass = Support.resolveJClass(' + Json.stringify(javaBindClassPath.replace('.', '/')) + ');', ctx);
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
            } else if (isJavaConstructor) {
                write('function init(' + args.join(', ') + '):', ctx);
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

            var index = 0;
            for (arg in method.args) {
                writeHaxeBindArgAssign(arg, index++, ctx);
            }

            if (isJavaConstructor) {
                writeIndent(ctx);
                write('_instance = ', ctx);
            } else if (isJavaFactory) {
                writeIndent(ctx);
                write('var ret = new ' + haxeName + '();', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                write('ret._instance = ', ctx);
            } else {
                switch (method.type) {
                    case Void(orig):
                        writeIndent(ctx);
                    default:
                        writeIndent(ctx);
                        write('var return_jni_ = ', ctx);
                }
            }

            write(ctx.javaClass.name + '_Extern.' + name + '(', ctx);
            var i = 0;
            write('_jclass, ', ctx);
            i++;
            write('_mid_' + method.name, ctx);
            i++;
            if (!isJavaConstructor && method.instance) {
                if (i > 0) write(', ', ctx);
                write('_instance', ctx);
                i++;
            }
            for (arg in method.args) {
                if (i > 0) write(', ', ctx);
                write(arg.name + '_jni_', ctx);
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
            else {
                switch (method.type) {
                    case Void(orig):
                    default:
                        writeHaxeArgAssign({
                            name: 'return',
                            type: method.type
                        }, -1, ctx);
                        writeLine('return return_haxe_;', ctx);
                }
            }

            ctx.indent--;
            writeLine('}', ctx);

            var jniSig = '(';
            if (method.instance && !isJavaConstructor) {
                jniSig += 'L' + javaClassPath.replace('.', '/') + ';';
            }
            for (arg in method.args) {
                jniSig += toJniSignatureType(arg.type, ctx);
            }
            jniSig += ')';
            jniSig += toJniSignatureType(method.type, ctx);

            writeIndent(ctx);
            write('private static var _mid_' + name + ' = Support.resolveStaticJMethodID(', ctx);
            write(Json.stringify(javaBindClassPath.replace('.', '/')), ctx);
            write(', ', ctx);
            write(Json.stringify(method.name), ctx);
            write(', ', ctx);
            write(Json.stringify(jniSig), ctx);
            write(');', ctx);
            writeLineBreak(ctx);

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
            var ret = toHaxeBindType(method.type, ctx);

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Class argument
            args.push('class_:JClass');

            // Method argument
            args.push('method_:JMethodID');

            // Instance argument
            if (method.instance && !isJavaConstructor) {
                args.push('instance_:JObject');
            }

            // Method args
            for (arg in method.args) {
                args.push(arg.name + ':' + toHaxeBindType(arg.type, ctx));
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

    public static function generateLincFile(ctx:BindContext, header:Bool = false):Void {

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.javaClass.name + '.xml', content: '' };

        writeLine('<xml>', ctx);
        ctx.indent++;
        writeLine('<files id="haxe">', ctx);
        ctx.indent++;
        writeLine('<compilerflag value="-I$'+'{LINC_' + ctx.javaClass.name.toUpperCase() + '_PATH}linc/" />', ctx);
        writeLine('<file name="$'+'{LINC_' + ctx.javaClass.name.toUpperCase() + '_PATH}linc/linc_' + ctx.javaClass.name + '.cpp" />', ctx);
        ctx.indent--;
        writeLine('</files>', ctx);
        writeLine('<target id="haxe">', ctx);
        writeLine('</target>', ctx);
        ctx.indent--;
        writeLine('</xml>', ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    } //generateLincFile

    public static function generateCPPFile(ctx:BindContext, header:Bool = false):Void {

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.javaClass.name + (header ? '.h' : '.cpp'), content: '' };

        if (header) {
            writeLine('#include <hxcpp.h>', ctx);
            writeLine('#include <jni.h>', ctx);
        } else {
            writeLine('#include "linc_JNI.h"', ctx);
            writeLine('#include "linc_' + ctx.javaClass.name + '.h"', ctx);
        }

        writeLineBreak(ctx);

        var namespaceEntries = [];
        if (ctx.namespace != null && ctx.namespace.trim() != '') {
            namespaceEntries = ctx.namespace.split('::');
        }

        // Class comment
        if (ctx.javaClass.description != null && ctx.javaClass.description.trim() != '') {
            writeComment(ctx.javaClass.description, ctx);
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
        for (method in ctx.javaClass.methods) {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Method return type
            var ret = toHxcppType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Class handle
            args.push('::cpp::Pointer<void> class_');

            // Method handle
            args.push('::cpp::Pointer<void> method_');

            // Instance handle
            if (method.instance && !isJavaConstructor) {
                args.push('::cpp::Pointer<void> instance_');
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
            write(ret + ' ' + ctx.javaClass.name + '_' + name + '(' + args.join(', ') + ')', ctx);
            if (header) {
                write(';', ctx);
            }
            else {
                write(' {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Method body
                //
                // Convert args to JNI
                var i = 0;
                for (arg in method.args) {
                    writeJniArgAssign(arg, i, ctx);
                    i++;
                }
                // Call jni
                writeJniCall(method, ctx);

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

    } //generateCPPFile

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
                writeLine('final BindResult _bind_result = new BindResult();', ctx);
            }
            writeLine('bind.Support.getUIThreadHandler().post(new Runnable() {', ctx);
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
                writeLine('synchronized(_bind_result) {', ctx);
                ctx.indent++;
                writeLine('if (_bind_result.status == 1) {', ctx);
                ctx.indent++;
                writeLine('_bind_result.status = 2;', ctx);
                writeLine('_bind_result.notify();', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                ctx.indent--;
                writeLine('}', ctx);
            }

            ctx.indent--;
            writeLine('}', ctx);
            ctx.indent--;
            writeLine('});', ctx);

            if (hasReturn) {
                writeLine('synchronized(_bind_result) {', ctx);
                ctx.indent++;
                writeLine('if (_bind_result.status == 0) {', ctx);
                ctx.indent++;
                writeLine('_bind_result.status = 1;', ctx);
                writeLine('try {', ctx);
                ctx.indent++;
                writeLine('_bind_result.wait();', ctx);
                ctx.indent--;
                writeLine('} catch (Throwable e) {', ctx);
                ctx.indent++;
                writeLine('e.printStackTrace();', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                ctx.indent--;
                writeLine('}', ctx);
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
            case Object(orig): 'JObject';
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

    static function toHaxeBindType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'Void';
            case Int(orig): 'Int';
            case Float(orig): 'Float';
            case Bool(orig): 'Int';
            case String(orig): 'String';
            case Array(itemType, orig): 'String';
            case Map(itemType, orig): 'String';
            case Object(orig): 'Dynamic';
            case Function(args, ret, orig): 'Dynamic';
        }

        return result;

    } //toHaxeBindType

/// Haxe -> HXCPP

    static function toHxcppType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig): 'double';
            case Bool(orig): 'int';
            case String(orig): '::String';
            case Array(itemType, orig): '::String';
            case Map(itemType, orig): '::String';
            case Object(orig): '::Dynamic';
            case Function(args, ret, orig): '::Dynamic';
        }

        return result;

    } //toHxcppType

    static function toJniType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'jint';
            case Float(orig): 'jfloat';
            case Bool(orig): 'jint';
            case String(orig): 'jstring';
            case Array(itemType, orig): 'jstring';
            case Map(itemType, orig): 'jstring';
            case Object(orig): 'jobject';
            case Function(args, ret, orig): 'jobject';
        }

        return result;

    } //toJniType

    static function toJniSignatureType(type:bind.Class.Type, ctx:BindContext):String {

        var javaType = toJavaType(type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            return 'L' + (ctx.javaClass.orig.pack + '.').replace('.', '/') + ctx.javaClass.name + ';';
        }

        var result = switch (type) {
            case Void(orig): 'V';
            case Int(orig): 'I';
            case Float(orig): 'F';
            case Bool(orig): 'I';
            case String(orig): 'Ljava/lang/String;';
            case Array(itemType, orig): 'Ljava/lang/String;';
            case Map(itemType, orig): 'Ljava/lang/String;';
            case Object(orig): 'Ljava/lang/Object;';
            case Function(args, ret, orig): 'Ljava/lang/Object;';
        }

        return result;

    } //toJniType

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

        var javaType = toJavaType(type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            return javaType;
        }

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

    static function writeJniArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toJniType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_hxcpp_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                write('$type $name = NULL; // Not implemented yet', ctx);
                writeLineBreak(ctx);

            case String(orig):
                write('$type $name = ::bind::jni::HxcppToJString($value);', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                write('$type $name = ::bind::jni::HxcppToJString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                write('$type $name = ::bind::jni::HxcppToJString($value);', ctx);
                writeLineBreak(ctx);

            case Object(orig):
                write('$type $name = NULL; // Not implemented yet', ctx);
                writeLineBreak(ctx);

            default:
                write('$type $name = NULL; // Not implemented yet', ctx);
                writeLineBreak(ctx);
        }

    } //writeJniArgAssign

    static function writeJniCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isJavaConstructor = isJavaConstructor(method, ctx);

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            var jniType = toJniType(method.type, ctx);
            write(jniType + ' return_jni_ = ', ctx);
            if (jniType == 'jstring') {
                write('(jstring) ', ctx);
            }
        }

        write('::bind::jni::GetJNIEnv()->CallStatic', ctx);

        switch (method.type) {

            case Function(args, ret, orig):
                write('Object', ctx);
            case String(orig):
                write('Object', ctx);
            case Bool(orig):
                write('Int', ctx);
            case Int(orig):
                write('Int', ctx);
            case Float(orig):
                write('Float', ctx);
            case Array(itemType, orig):
                write('Object', ctx);
            case Map(itemType, orig):
                write('Object', ctx);
            case Object(orig):
                write('Object', ctx);
            case Void(orig):
                write('Void', ctx);
            default:
                write('Object', ctx);
        }

        write('Method((jclass) class_.ptr, (jmethodID) method_.ptr', ctx);
        if (method.instance && !isJavaConstructor) {
            write(', (jobject) instance_.ptr', ctx);
        }
        
        for (arg in method.args) {
            write(', ' + arg.name + '_jni_', ctx);
        }
        write(');', ctx);
        writeLineBreak(ctx);
        if (hasReturn) {
            writeHxcppArgAssign({
                name: 'return',
                type: method.type
            }, -1, ctx);
            writeLine('return return_hxcpp_;', ctx);
        }

    } //writeJniCall

    static function writeHaxeArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toHaxeType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_haxe_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine('var $name:Dynamic = null; // Not implemented yet', ctx);

            case String(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('var $name = $value ? 1 : 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('var $name:$type = haxe.Json.parse($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('var $name:$type = haxe.Json.parse($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('var $name:$type = $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeHaxeArgAssign

    static function writeHaxeBindArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toHaxeBindType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_haxe_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine('var $name:Dynamic = null; // Not implemented yet', ctx);

            case String(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('var $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('var $name = $value ? 1 : 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('var $name = haxe.Json.stringify($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('var $name = haxe.Json.stringify($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('var $name:$type = $value;', ctx);
                writeLineBreak(ctx);
        }

    } //writeHaxeBindArgAssign

    static function writeHxcppArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toHxcppType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_hxcpp_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):

                // Keep track of java instance on haxe side
                writeLine('::Dynamic closure_' + name + ' = null(); // Not implemented yet', ctx);

            case String(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::jni::JStringToHxcpp($value);', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Array(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::jni::JStringToHxcpp($value);', ctx);
                writeLineBreak(ctx);

            case Map(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::jni::JStringToHxcpp($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = null(); // Not implemented yet', ctx);
                writeLineBreak(ctx);
        }

    } //writeHxcppArgAssign

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
                    write('Object return_java_ = ', ctx);
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