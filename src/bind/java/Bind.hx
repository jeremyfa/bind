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
    var nativeCallbacks:Map<String,bind.Class.Type>;
    var javaCallbacks:Map<String,bind.Class.Type>;
    var bindSupport:String;
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
            javaCode: null,
            nativeCallbacks: new Map(),
            javaCallbacks: new Map(),
            bindSupport: 'bind.Support'
        };

    }

    /** Reads bind.Class object informations and generate files
        To bind the related Java class to Haxe.
        The files are returned as an array of bind.File objects.
        Nothing is written to disk at this stage. */
    public static function bindClass(javaClass:bind.Class, ?options:{?namespace:String, ?pack:String, ?javaPath:String, ?javaCode:String, ?bindSupport:String}):Array<bind.File> {

        var ctx = createContext();
        ctx.javaClass = javaClass;

        if (options != null) {
            if (options.namespace != null) ctx.namespace = options.namespace;
            if (options.pack != null) ctx.pack = options.pack;
            if (options.javaPath != null) ctx.javaPath = options.javaPath;
            if (options.javaCode != null) ctx.javaCode = options.javaCode;
            if (options.bindSupport != null) ctx.bindSupport = options.bindSupport;
        }

        // Copy Java support file
        copyJavaSupportFile(ctx);

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

    }

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

        // Support support
        writeLine('import bind.java.Support;', ctx);
        writeLine('import cpp.Pointer;', ctx);

        writeLineBreak(ctx);

        // Class comment
        if (ctx.javaClass.description != null && ctx.javaClass.description.trim() != '') {
            writeComment(ctx.javaClass.description, ctx);
        }

        writeLine('class ' + haxeName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private static var _jclassSignature = ' + Json.stringify(javaBindClassPath.replace('.', '/')) + ';', ctx);
        writeLine('private static var _jclass:JClass = null;', ctx);
        writeLineBreak(ctx);

        writeLine('private var _instance:JObject = null;', ctx);
        writeLineBreak(ctx);

        writeLine('public function new() {}', ctx);
        writeLineBreak(ctx);

        // Add properties
        for (property in ctx.javaClass.properties) {

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

        }

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
                write('function get_' + method.orig.property.name + '(' + args.join(', ') + '):', ctx);
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

            var jniSig = '(';
            if (method.instance && !isJavaConstructor) {
                jniSig += 'L' + javaClassPath.replace('.', '/') + ';';
            }
            for (arg in method.args) {
                jniSig += toJniSignatureType(arg.type, ctx);
            }
            jniSig += ')';
            jniSig += toJniFromJavaSignatureType(method.type, ctx);

            writeLine('if (_jclass == null) _jclass = Support.resolveJClass(_jclassSignature);', ctx);

            writeIndent(ctx);
            write('if (_mid_' + name + ' == null) _mid_' + name + ' = Support.resolveStaticJMethodID(', ctx);
            write(Json.stringify(javaBindClassPath.replace('.', '/')), ctx);
            write(', ', ctx);
            write(Json.stringify(method.name), ctx);
            write(', ', ctx);
            write(Json.stringify(jniSig), ctx);
            write(');', ctx);
            writeLineBreak(ctx);

            var index = 0;
            for (arg in method.args) {
                writeHaxeBindArgAssign(arg, index++, ctx);
            }

            if (isJavaConstructor) {
                writeIndent(ctx);
                write('var _instance_pointer = ', ctx);
            } else if (isJavaFactory) {
                writeIndent(ctx);
                write('var ret = new ' + haxeName + '();', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                write('var _instance_pointer = ', ctx);
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
                write('_instance.pointer', ctx);
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
                writeLine('_instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;', ctx);
                writeLine('return _instance != null ? this : null;', ctx);
            } else if (isJavaFactory) {
                writeLine('ret._instance = _instance_pointer != null ? new JObject(_instance_pointer) : null;', ctx);
                writeLine('return ret._instance != null ? ret : null;', ctx);
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

            writeIndent(ctx);
            write('private static var _mid_' + name + ':JMethodID = null;', ctx);
            writeLineBreak(ctx);

            writeLineBreak(ctx);

        }

        // Expose java callbacks to haxe
        for (key in ctx.javaCallbacks.keys()) {

            var func = ctx.javaCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    var jniSig = '(';
                    jniSig += toJniFromJavaSignatureType(func, ctx);
                    for (funcArg in args) {
                        jniSig += toJniSignatureType(funcArg.type, ctx);
                    }
                    jniSig += ')';
                    jniSig += toJniFromJavaSignatureType(ret, ctx);

                    writeIndent(ctx);
                    write('private static var _mid_callJ_' + key + ' = Support.resolveStaticJMethodID(', ctx);
                    write(Json.stringify(javaBindClassPath.replace('.', '/')), ctx);
                    write(', ', ctx);
                    write(Json.stringify('callJ_' + key), ctx);
                    write(', ', ctx);
                    write(Json.stringify(jniSig), ctx);
                    write(');', ctx);
                    writeLineBreak(ctx);

                default:
            }

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
            var ret = toHaxeBindFromJniType(method.type, ctx);

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
                args.push('instance_:Pointer<Void>');
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

        // Expose java callbacks to haxe c++ extern
        for (key in ctx.javaCallbacks.keys()) {

            var func = ctx.javaCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    // C++ method
                    writeIndent(ctx);
                    write('@:native(\'', ctx);
                    if (ctx.namespace != null && ctx.namespace.trim() != '') {
                        write(ctx.namespace.trim() + '::', ctx);
                    }
                    write(ctx.javaClass.name + '_callJ_' + key, ctx);
                    write('\')', ctx);
                    writeLineBreak(ctx);

                    writeIndent(ctx);

                    var externArgs = [];

                    // Class argument
                    externArgs.push('class_:JClass');

                    // Method argument
                    externArgs.push('method_:JMethodID');

                    // Callback handle
                    externArgs.push('callback_:Pointer<Void>');

                    for (funcArg in args) {
                        externArgs.push(funcArg.name + ':' + toHaxeBindType(funcArg.type, ctx));
                    }

                    // Whole method
                    write('static function callJ_' + key + '(' + externArgs.join(', ') + '):', ctx);
                    write(toHaxeBindFromJniType(ret, ctx), ctx);
                    write(';', ctx);

                    writeLineBreak(ctx);
                    writeLineBreak(ctx);

                default:
            }

        }

        // Class end
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

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

    }

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
            writeLine('#ifndef INCLUDED_bind_java_HObject', ctx);
            writeLine('#include <bind/java/HObject.h>', ctx);
            writeLine('#endif', ctx);
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

        function writeMethod(method:bind.Class.Method):Void {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Java callback called from native?
            var isJavaCallback = method.orig != null && method.orig.javaCallback == true;
            var javaCallbackType:String = null;
            if (isJavaCallback) {
                javaCallbackType = '' + method.orig.javaCallbackType;
            }

            // Method return type
            var ret = toHxcppType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Class handle
            args.push('::cpp::Pointer<void> class_');

            // Method handle
            args.push('::cpp::Pointer<void> method_');

            // Callback handle
            if (isJavaCallback) {
                args.push('::cpp::Pointer<void> callback_');
            }
            // Instance handle
            else if (method.instance && !isJavaConstructor) {
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

        // Add methods
        for (method in ctx.javaClass.methods) {

            writeMethod(method);

        }

        // Expose java callbacks to c++
        for (key in ctx.javaCallbacks.keys()) {

            var func = ctx.javaCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    writeMethod({
                        name: 'callJ_' + key,
                        args: args,
                        type: ret,
                        instance: false,
                        description: null,
                        orig: {
                            javaCallbackType: toJavaType(func, ctx),
                            javaCallback: true
                        }
                    });
                default:
            }

        }

        // Close namespaces
        for (name in namespaceEntries) {
            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);
        }

        // Native callbacks exposed to JNI
        var hasNativeCallbacks = false;
        for (key in ctx.nativeCallbacks.keys()) {

            if (!hasNativeCallbacks) {
                hasNativeCallbacks = true;
                writeLine('extern "C" {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;
            }

            var func = ctx.nativeCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    writeIndent(ctx);
                    var retType = toJniType(ret, ctx);
                    write('JNIEXPORT ' + retType + ' Java_', ctx);
                    var javaPack = (''+ctx.javaClass.orig.pack);
                    if (javaPack != '') {
                        write(javaPack.replace('.', '_') + '_', ctx);
                    }
                    write('bind_1' + ctx.javaClass.name + '_callN_1' + key + '(JNIEnv *env, jclass clazz, jstring address', ctx);

                    var n = 1;
                    for (funcArg in args) {
                        var argType = toJniType(funcArg.type, ctx);
                        write(', $argType arg' + (n++), ctx);
                    }

                    if (header) {
                        write(');', ctx);
                        writeLineBreak(ctx);
                    }
                    else {
                        write(') {', ctx);
                        writeLineBreak(ctx);
                        ctx.indent++;

                        writeLine('int haxe_stack_ = 99;', ctx);
                        writeLine('hx::SetTopOfStack(&haxe_stack_, true);', ctx);

                        var i = 0;
                        for (funcArg in args) {
                            writeHxcppArgAssign(funcArg, i++, ctx, false);
                        }

                        // Call
                        var hasReturn = false;
                        writeLine('::Dynamic func_hobject_ = ::bind::jni::JStringToHObject(address);', ctx);
                        writeLine('::Dynamic func_unwrapped_ = ::bind::java::HObject_obj::unwrap(func_hobject_);', ctx);
                        writeIndent(ctx);
                        switch (ret) {
                            case Void(orig):
                            default:
                                hasReturn = true;
                                write(toHxcppType(ret, ctx) + ' return_hxcpp_ = ', ctx);
                        }
                        write('func_unwrapped_->__run(', ctx);
                        i = 0;
                        for (funcArg in args) {
                            if (i++ > 0) write(', ', ctx);
                            write('arg' + i + '_hxcpp_', ctx);
                        }
                        write(');', ctx);
                        writeLineBreak(ctx);

                        if (hasReturn) {
                            writeJniArgAssign({
                                name: 'return',
                                type: ret
                            }, -1, ctx);
                            writeLine('hx::SetTopOfStack((int *)0, true);', ctx);
                            writeLine('return return_jni_;', ctx);
                        }
                        else {
                            writeLine('hx::SetTopOfStack((int *)0, true);', ctx);
                        }

                        ctx.indent--;
                        writeLine('}', ctx);
                    }

                    writeLineBreak(ctx);

                default:
            }

        }

        if (hasNativeCallbacks) {
            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);
        }

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

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
        if (imports.indexOf('bind.Support.*') == -1 && imports.indexOf('${ctx.bindSupport}.*') == -1) {
            writeLine('import ${ctx.bindSupport}.*;', ctx);
        }
        for (imp in imports) {
            if (imp == 'bind.Support' || imp.startsWith('bind.Support.')) {
                writeLine('import ${ctx.bindSupport}${imp.substr('bind.Support'.length)};', ctx);
            }
            else {
                writeLine('import $imp;', ctx);
            }
        }

        writeLineBreak(ctx);

        // Class comment
        if (ctx.javaClass.description != null && ctx.javaClass.description.trim() != '') {
            writeComment(ctx.javaClass.description, ctx);
        }

        writeLine('@SuppressWarnings("all")', ctx);
        writeLine('class ' + bindingName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private static class bind_Result {', ctx);
        ctx.indent++;
        writeLine('Object value = null;', ctx);
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        function writeMethod(method:bind.Class.Method) {

            // Constructor?
            var isJavaConstructor = isJavaConstructor(method, ctx);

            // Factori?
            var isJavaFactory = isJavaFactory(method, ctx);

            // Is it a getter or setter?
            var isGetter = method.orig != null && method.orig.getter == true;
            var isSetter = method.orig != null && method.orig.setter == true;

            // Java callback called from native?
            var isJavaCallback = method.orig != null && method.orig.javaCallback == true;
            var javaCallbackType:String = null;
            if (isJavaCallback) {
                javaCallbackType = '' + method.orig.javaCallbackType;
            }

            // Method return type
            var ret = toJavaBindFromJavaType(method.type, ctx);
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
            if (isJavaCallback) {
                args.push('final Object _callback');
            }
            else if (method.instance && !isJavaConstructor) {
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

            writeLine('if (!${ctx.bindSupport}.isUIThread()) {', ctx);
            ctx.indent++;
            if (hasReturn) {
                writeLine('final BindResult _bind_result = new BindResult();', ctx);
            }
            writeLine('${ctx.bindSupport}.getUIThreadHandler().post(new Runnable() {', ctx);
            ctx.indent++;
            writeLine('public void run() {', ctx);
            ctx.indent++;

            if (hasReturn) {
                writeLine('synchronized(_bind_result) {', ctx);
                ctx.indent++;
                writeLine('try {', ctx);
                ctx.indent++;
                writeIndent(ctx);
                write('_bind_result.value = bind_' + ctx.javaClass.name + '.' + method.name + '(', ctx);
            } else {
                writeIndent(ctx);
                write('bind_' + ctx.javaClass.name + '.' + method.name + '(', ctx);
            }

            var callArgs = [];
            if (isJavaCallback) {
                callArgs.push('_callback');
            }
            else if (method.instance && !isJavaConstructor) {
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
                writeLine('_bind_result.resolved = true;', ctx);
                writeLine('_bind_result.notifyAll();', ctx);
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
                writeLine('if (!_bind_result.resolved) {', ctx);
                ctx.indent++;
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

        // Add methods
        for (method in ctx.javaClass.methods) {

            writeMethod(method);

        }

        // Expose java callbacks to native
        for (key in ctx.javaCallbacks.keys()) {

            var func = ctx.javaCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    writeMethod({
                        name: 'callJ_' + key,
                        args: args,
                        type: ret,
                        instance: false,
                        description: null,
                        orig: {
                            javaCallbackType: toJavaType(func, ctx),
                            javaCallback: true
                        }
                    });
                default:
            }

        }

        // Expose native callbacks to java
        for (key in ctx.nativeCallbacks.keys()) {

            var func = ctx.nativeCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    writeIndent(ctx);
                    var retType = toJavaBindType(ret, ctx);
                    write('static native ' + retType + ' callN_' + key + '(String address', ctx);

                    var n = 1;
                    for (funcArg in args) {
                        var argType = toJavaBindType(funcArg.type, ctx);
                        write(', $argType arg' + (n++), ctx);
                    }

                    write(');', ctx);
                    writeLineBreak(ctx);
                    writeLineBreak(ctx);

                default:
            }

        }

        // Class end
        ctx.indent--;
        writeLine('}', ctx);
        writeLineBreak(ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

    public static function copyJavaSupportFile(ctx:BindContext):Void {

        if (ctx.javaPath == null) return;

        var pack = ctx.bindSupport.split('.');
        pack.pop();

        var javaContent = sys.io.File.getContent(Path.join([Path.directory(Sys.programPath()), 'support/java/bind/Support.java']));
        javaContent = javaContent.replace('package bind;', 'package ${pack.join('.')};');

        ctx.currentFile = {
            path: Path.join(['java', '${ctx.bindSupport.replace('.', '/')}.java']),
            content: '' + javaContent
        };

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

/// Java -> Haxe

    static function toHaxeType(type:bind.Class.Type, ctx:BindContext):String {

        var javaType = toJavaType(type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            return ctx.javaClass.name;
        }

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

    }

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
                        if (arg.name != null) {
                            resArgs.push(arg.name + ':' + haxeType);
                        }
                        else {
                            resArgs.push(haxeType);
                        }
                    }
                }
                result = '(' + resArgs.join(',') + ')';

                var haxeRetType = toHaxeType(ret, ctx);
                if (haxeRetType.indexOf('->') != -1) {
                    haxeRetType = '(' + haxeRetType + ')';
                }
                result += '->' + haxeRetType;

            default:
        }

        return result;

    }

    static function toHaxeBindType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'Void';
            case Int(orig): 'Int';
            case Float(orig): 'Float';
            case Bool(orig): 'Int';
            case String(orig): 'String';
            case Array(itemType, orig): 'String';
            case Map(itemType, orig): 'String';
            case Object(orig): 'Pointer<Void>';
            case Function(args, ret, orig): 'HObject';
        }

        return result;

    }

    static function toHaxeBindFromJniType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Function(args, ret, orig): 'Pointer<Void>';
            default: toHaxeBindType(type, ctx);
        }

        return result;

    }

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
            case Object(orig): '::cpp::Pointer<void>';
            case Function(args, ret, orig): '::Dynamic';
        }

        return result;

    }

    static function toJniType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'jint';
            case Float(orig):
                orig != null && (orig.type == 'Double' || orig.type == 'double')
                ? 'jdouble'
                : 'jfloat';
            case Bool(orig): 'jint';
            case String(orig): 'jstring';
            case Array(itemType, orig): 'jstring';
            case Map(itemType, orig): 'jstring';
            case Object(orig): 'jobject';
            case Function(args, ret, orig): 'jstring';
        }

        return result;

    }

    static function toJniFromJavaType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Function(args, ret, orig): 'jobject';
            default: toJniType(type, ctx);
        }

        return result;

    }

    static function toJniSignatureType(type:bind.Class.Type, ctx:BindContext):String {

        var javaType = toJavaType(type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            return 'L' + (ctx.javaClass.orig.pack + '.').replace('.', '/') + ctx.javaClass.name + ';';
        }

        var result = switch (type) {
            case Void(orig): 'V';
            case Int(orig): 'I';
            case Float(orig):
                orig != null && (orig.type == 'Double' || orig.type == 'double')
                ? 'D'
                : 'F';
            case Bool(orig): 'I';
            case String(orig): 'Ljava/lang/String;';
            case Array(itemType, orig): 'Ljava/lang/String;';
            case Map(itemType, orig): 'Ljava/lang/String;';
            case Object(orig): 'Ljava/lang/Object;';
            case Function(args, ret, orig): 'Ljava/lang/String;';
        }

        return result;

    }

    static function toJniFromJavaSignatureType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Function(args, ret, orig): 'Ljava/lang/Object;';
            default: toJniSignatureType(type, ctx);
        }

        return result;

    }

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

    }

    static function toJavaBindType(type:bind.Class.Type, ctx:BindContext):String {

        var javaType = toJavaType(type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            return javaType;
        }

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig):
                orig != null && (orig.type == 'Double' || orig.type == 'double')
                ? 'double'
                : 'float';
            case Bool(orig): 'int';
            case String(orig): 'String';
            case Array(itemType, orig): 'String';
            case Map(itemType, orig): 'String';
            case Object(orig): 'Object';
            case Function(args, ret, orig): 'String';
        }

        return result;

    }

    static function toJavaBindFromJavaType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Function(args, ret, orig): 'Object';
            default:
                toJavaBindType(type, ctx);
        }

        return result;

    }

    static function toNativeCallPart(part:String):String {

        if (part.startsWith('List<')) part = 'List';
        else if (part.startsWith('Map<')) part = 'Map';
        part = part.replace('<', '');
        part = part.replace('>', '');
        part = part.replace(',', '');
        part = part.charAt(0).toUpperCase() + part.substring(1);

        return part;

    }

/// Helpers

    static function isJavaConstructor(method:bind.Class.Method, ctx:BindContext):Bool {

        return method.name == 'constructor';

    }

    static function isJavaFactory(method:bind.Class.Method, ctx:BindContext):Bool {

        var isJavaFactory = false;
        var javaType = toJavaType(method.type, ctx);
        if (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name) {
            isJavaFactory = true;
        }

        return isJavaFactory;

    }

    static function isJavaSingleton(property:bind.Class.Property, ctx:BindContext):Bool {

        var isJavaSingleton = false;
        var javaType = toJavaType(property.type, ctx);
        if (!property.instance && (javaType == ctx.javaClass.name || javaType == ctx.javaClass.orig.pack + '.' + ctx.javaClass.name)) {
            isJavaSingleton = true;
        }

        return isJavaSingleton;

    }

/// Write utils (specific)

    static function writeJavaArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toJavaType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_java_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                var retType = toJavaType(ret, ctx);
                var hasReturn = retType != 'void' && retType != 'Void';

                writeLine('final HaxeObject ' + name + 'hobj_ = $value == null ? null : new HaxeObject($value);', ctx);
                writeLine('final ' + type + ' ' + name + ' = $value == null ? null : new ' + type + '() {', ctx);
                ctx.indent++;
                writeIndent(ctx);
                write('public $retType run(', ctx);
                var i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);
                    var argType = toJavaType(funcArg.type, ctx);
                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    write('final $argType ' + argName, ctx);
                }
                write(') {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Convert java args into java-bind args
                i = 0;
                for (funcArg in args) {
                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    writeJavaBindArgAssign(funcArg, i, ctx);
                    i++;
                }

                if (hasReturn) {
                    writeLine('final BindResult return_jni_result_ = new BindResult();', ctx);
                    writeLine('${ctx.bindSupport}.runInNativeThreadSync(new Runnable() {', ctx);
                } else {
                    writeLine('${ctx.bindSupport}.runInNativeThread(new Runnable() {', ctx);
                }
                ctx.indent++;
                writeLine('public void run() {', ctx);
                ctx.indent++;

                // Call
                writeIndent(ctx);
                if (hasReturn) {
                    write('return_jni_result_.value = ', ctx);
                }
                write('bind_' + ctx.javaClass.name + '.callN_', ctx);

                i = 0;
                var allParts = '';
                for (funcArg in args) {
                    var part = toJavaType(funcArg.type, ctx);
                    part = toNativeCallPart(part);
                    allParts += part;
                    write(part, ctx);
                }
                var part = toNativeCallPart(retType);
                allParts += part;
                write(part, ctx);

                if (!ctx.nativeCallbacks.exists(allParts)) {
                    ctx.nativeCallbacks.set(allParts, arg.type);
                }

                write('(', ctx);
                write(name + 'hobj_.address', ctx);

                for (funcArg in args) {
                    write(', ' + funcArg.name + '_jni_', ctx);
                }

                write(');', ctx);
                writeLineBreak(ctx);

                ctx.indent--;
                writeLine('}', ctx);
                ctx.indent--;
                writeLine('});', ctx);

                if (retType == 'Void') {
                    writeLine('return null;', ctx);
                }
                else if (retType != 'void') {
                    var javaBindRetType = toJavaBindType(ret, ctx);
                    writeLine(javaBindRetType + ' return_jni_ = ($javaBindRetType) return_jni_result_.value;', ctx);
                    writeJavaArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return return_java_;', ctx);
                }

                ctx.indent--;
                writeLine('}', ctx);
                ctx.indent--;
                writeLine('};', ctx);

            case String(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('final $type $name = $value != 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('final $type $name = ($type) ${ctx.bindSupport}.fromJSONString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('final $type $name = ($type) ${ctx.bindSupport}.fromJSONString($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('final $type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeJavaBindArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toJavaBindFromJavaType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_java_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine('final ' + type + ' ' + name + ' = $value;', ctx);

                var retType = toJavaType(ret, ctx);

                var allParts = '';
                for (funcArg in args) {
                    var part = toJavaType(funcArg.type, ctx);
                    part = toNativeCallPart(part);
                    allParts += part;
                }
                var part = toNativeCallPart(retType);
                allParts += part;

                if (!ctx.javaCallbacks.exists(allParts)) {
                    ctx.javaCallbacks.set(allParts, arg.type);
                }

            case String(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Int(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                write('final $type $name = $value;', ctx);
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('final $type $name = $value ? 1 : 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('final $type $name = ${ctx.bindSupport}.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('final $type $name = ${ctx.bindSupport}.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('final $type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeJniArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toJniType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_hxcpp_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                write('$type $name = ::bind::jni::HObjectToJString($value);', ctx);
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
                write('$type $name = (jobject) (hx::IsNotNull($value) ? $value.ptr : NULL);', ctx);
                writeLineBreak(ctx);

            default:
                write('$type $name = NULL; // Not implemented', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeJniCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isJavaConstructor = isJavaConstructor(method, ctx);
        var isJavaCallback = method.orig != null && method.orig.javaCallback == true;

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            var jniType = toJniFromJavaType(method.type, ctx);
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
        if (isJavaCallback) {
            write(', (jobject) callback_.ptr', ctx);
        }
        else if (method.instance && !isJavaConstructor) {
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

    }

    static function writeHaxeArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toHaxeType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_haxe_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine('var $name:$type = null;', ctx);
                writeLine('if ($value != null) {', ctx);
                ctx.indent++;
                writeLine('var ' + name + 'jobj_ = new JObject($value);', ctx);
                writeIndent(ctx);
                write('$name = function(', ctx);
                var i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);
                    write(funcArg.name + '_cl:' + toHaxeType(funcArg.type, ctx), ctx);
                }
                write(') {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                i = 0;
                for (funcArg in args) {
                    writeHaxeBindArgAssign({
                        name: funcArg.name + '_cl',
                        type: funcArg.type,
                        orig: funcArg.orig
                    }, i++, ctx);
                }

                // Call
                writeIndent(ctx);
                var hasReturn = false;
                switch (ret) {
                    case Void(orig):
                    default:
                        hasReturn = true;
                        write('var return_jni_ = ', ctx);
                }
                write(ctx.javaClass.name + '_Extern.callJ_', ctx);

                var retType = toJavaType(ret, ctx);

                var allParts = '';
                for (funcArg in args) {
                    var part = toJavaType(funcArg.type, ctx);
                    part = toNativeCallPart(part);
                    allParts += part;
                }
                var part = toNativeCallPart(retType);
                allParts += part;

                if (!ctx.javaCallbacks.exists(allParts)) {
                    ctx.javaCallbacks.set(allParts, arg.type);
                }

                write(allParts + '(_jclass, _mid_callJ_' + allParts + ', ' + arg.name + '_haxe_jobj_.pointer', ctx);
                for (funcArg in args) {
                    write(', ', ctx);
                    write(funcArg.name + '_cl_jni_', ctx);
                }
                write(');', ctx);
                writeLineBreak(ctx);
                if (hasReturn) {
                    writeHaxeArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return return_haxe_;', ctx);
                }

                ctx.indent--;
                writeLine('};', ctx);
                ctx.indent--;
                writeLine('}', ctx);

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
                write('var $name = $value != 0;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('var $name:$type = haxe.Json.parse($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('var $name:$type = haxe.Json.parse($value);', ctx);
                writeLineBreak(ctx);

            case Object(orig):
                if (type == ctx.javaClass.name) {
                    writeIndent(ctx);
                    write('var $name = new $type();', ctx);
                    writeLineBreak(ctx);
                    writeIndent(ctx);
                    write('$name._instance = $value;', ctx);
                    writeLineBreak(ctx);
                } else {
                    writeIndent(ctx);
                    write('var $name = new JObject($value);', ctx);
                    writeLineBreak(ctx);
                }

            default:
                writeIndent(ctx);
                write('var $name:$type = $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeHaxeBindArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var haxeType = toHaxeType(arg.type, ctx);
        var type = toHaxeBindType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_jni_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_haxe_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine('var $name:HObject = null;', ctx);
                writeLine('if ($value != null) {', ctx);
                ctx.indent++;
                writeIndent(ctx);
                write('$name = new HObject(function(', ctx);
                var i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);
                    write(funcArg.name + '_cl:' + toHaxeBindType(funcArg.type, ctx), ctx);
                }
                write(') {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                i = 0;
                for (funcArg in args) {
                    writeHaxeArgAssign({
                        name: funcArg.name + '_cl',
                        type: funcArg.type,
                        orig: funcArg.orig
                    }, i++, ctx);
                }

                // Call
                writeIndent(ctx);
                var hasReturn = false;
                switch (ret) {
                    case Void(orig):
                    default:
                        hasReturn = true;
                        write('var return_haxe_ = ', ctx);
                }
                write(arg.name + '(', ctx);
                i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);
                    write(funcArg.name + '_cl_haxe_', ctx);
                }
                write(');', ctx);
                writeLineBreak(ctx);
                if (hasReturn) {
                    writeHaxeBindArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return return_jni_;', ctx);
                }

                ctx.indent--;
                writeLine('});', ctx);
                ctx.indent--;
                writeLine('}', ctx);

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

            case Object(orig):
                if (haxeType == ctx.javaClass.name) {
                    writeIndent(ctx);
                    write('var $name = $value._instance.pointer;', ctx);
                    writeLineBreak(ctx);
                } else {
                    writeIndent(ctx);
                    write('var $name = $value.pointer;', ctx);
                    writeLineBreak(ctx);
                }

            default:
                writeIndent(ctx);
                write('var $name:$type = $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeHxcppArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext, keepName:Bool = true):Void {

        var type = toHxcppType(arg.type, ctx);
        var name = (keepName && arg.name != null ? arg.name : 'arg' + (index + 1)) + '_hxcpp_';
        var value = (keepName && arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_jni_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeIndent(ctx);
                write('$type $name = $value != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef($value)) : null();', ctx);
                writeLineBreak(ctx);

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

            case Object(orig):
                writeIndent(ctx);
                write('$type $name = $value != NULL ? ::cpp::Pointer<void>(::bind::jni::GetJNIEnv()->NewGlobalRef($value)) : null();', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = null(); // Not implemented', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeJavaCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isJavaConstructor = isJavaConstructor(method, ctx);
        var isJavaCallback = method.orig != null && method.orig.javaCallback == true;
        var isGetter = method.orig != null && method.orig.getter == true;
        var isSetter = method.orig != null && method.orig.setter == true;
        var isImplicit = method.orig != null && method.orig.implicit == true;

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            switch (method.type) {
                case Function(args, ret, orig):
                    write('final Object return_java_ = ', ctx);
                default:
                    var javaType = toJavaType(method.type, ctx);
                    write('final ' + javaType + ' return_java_ = ', ctx);
            }
        }
        if (isJavaCallback) {
            var javaCallbackType = '' + method.orig.javaCallbackType;
            if (javaCallbackType == 'Runnable' || javaCallbackType == 'Func0<Void>') {
                write('Runnable _callback_runnable = null;', ctx);
                writeLineBreak(ctx);
                writeLine('if (_callback instanceof Func0) {', ctx);
                ctx.indent++;
                writeLine('final Func0<Void> _callback_func0 = (Func0<Void>) _callback;', ctx);
                writeLine('_callback_runnable = new Runnable() {', ctx);
                ctx.indent++;
                writeLine('public void run() {', ctx);
                ctx.indent++;
                writeLine('_callback_func0.run();', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                ctx.indent--;
                writeLine('};', ctx);
                ctx.indent--;
                writeLine('} else {', ctx);
                ctx.indent++;
                writeLine('_callback_runnable = (Runnable) _callback;', ctx);
                ctx.indent--;
                writeLine('}', ctx);
                writeIndent(ctx);
                write('_callback_runnable.run(', ctx);
            } else {
                write('(($javaCallbackType)_callback).run(', ctx);
            }
        }
        else if (isImplicit) {
            if (method.instance) {
                write('_instance.' + method.orig.property.name, ctx);
            } else {
                write(ctx.javaClass.name + '.' + method.orig.property.name, ctx);
            }
            if (isSetter) {
                write(' = ', ctx);
            }
        }
        else if (isJavaConstructor) {
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
        if (isImplicit) {
            write(';', ctx);
        } else {
            write(');', ctx);
        }
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

    }

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

    }

    static function writeLine(line:String, ctx:BindContext):Void {

        writeIndent(ctx);
        write(line, ctx);
        writeLineBreak(ctx);

    }

    static function writeIndent(ctx:BindContext):Void {

        var space = '';
        var i = 0;
        var indent = ctx.indent;
        while (i < indent) {
            space += '    ';
            i++;
        }

        write(space, ctx);

    }

    static function writeLineBreak(ctx:BindContext):Void {

        write("\n", ctx);

    }

    static function write(input:String, ctx:BindContext):Void {

        ctx.currentFile.content += input;

    }

    static function getLastLineIndent(ctx:BindContext):String {

        var lines = ctx.currentFile.content.split("\n");
        var numChars = lines[lines.length - 1].length;
        var spaces = '';
        for (i in 0...numChars) {
            spaces += ' ';
        }
        return spaces;

    }

}