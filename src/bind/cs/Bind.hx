package bind.cs;

import haxe.io.Path;

using StringTools;

typedef BindContext = {
    var csharpClass:bind.Class;
    var indent:Int;
    var files:Array<bind.File>;
    var namespace:String;
    var pack:String;
    var currentFile:bind.File;
    var csharpPath:String;
    var csharpCode:String;
    var nativeCallbacks:Map<String,bind.Class.Type>;
    var csharpCallbacks:Map<String,bind.Class.Type>;
    var bindSupport:String;
}

class Bind {

    public static function createContext():BindContext {

        return {
            csharpClass: null,
            indent: 0,
            files: [],
            namespace: null,
            pack: null,
            currentFile: null,
            csharpPath: null,
            csharpCode: null,
            nativeCallbacks: new Map(),
            csharpCallbacks: new Map(),
            bindSupport: 'Bind.Support'
        };

    }

    /** Reads bind.Class object informations and generate files
        To bind the related C# class to Haxe.
        The files are returned as an array of bind.File objects.
        Nothing is written to disk at this stage. */
    public static function bindClass(csharpClass:bind.Class, ?options:{?namespace:String, ?pack:String, ?csharpPath:String, ?csharpCode:String, ?bindSupport:String}):Array<bind.File> {

        var ctx = createContext();
        ctx.csharpClass = csharpClass;

        if (options != null) {
            if (options.namespace != null) ctx.namespace = options.namespace;
            if (options.pack != null) ctx.pack = options.pack;
            if (options.csharpPath != null) ctx.csharpPath = options.csharpPath;
            if (options.csharpCode != null) ctx.csharpCode = options.csharpCode;
            if (options.bindSupport != null) ctx.bindSupport = options.bindSupport;
        }

        // Copy C# support file
        copyCSharpSupportFile(ctx);

        // Generate Haxe file
        generateHaxeFile(ctx);

        // Generate C# intermediate file
        generateCSharpFile(ctx);

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

        var haxeName = ctx.csharpClass.name;
        var csharpBindClassPath = 'Bind_' + ctx.csharpClass.name;
        var csharpClassPath = '' + ctx.csharpClass.name;
        var csharpNamespace = '' + ctx.csharpClass.orig.namespace;
        if (csharpNamespace != '') {
            csharpBindClassPath = csharpNamespace + '.' + csharpBindClassPath;
            csharpClassPath = csharpNamespace + '.' + csharpClassPath;
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

        // Support
        writeLine('import bind.csharp.Support;', ctx);
        writeLine('import cpp.Pointer;', ctx);

        writeLineBreak(ctx);

        // Class comment
        if (ctx.csharpClass.description != null && ctx.csharpClass.description.trim() != '') {
            writeComment(ctx.csharpClass.description, ctx);
        }

        writeLine('class ' + haxeName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private static var _csclassSignature = ' + Json.stringify(csharpBindClassPath.replace('.', '/')) + ';', ctx);
        writeLine('private static var _csclass:CSClass = null;', ctx);
        writeLineBreak(ctx);

        writeLine('private var _instance:CSObject = null;', ctx);
        writeLineBreak(ctx);

        writeLine('public function new() {}', ctx);
        writeLineBreak(ctx);

        // Add properties
        for (property in ctx.csharpClass.properties) {

            // Read-only?
            var readonly = property.orig != null && property.orig.readonly == true;

            // Singleton?
            var isCSharpSingleton = isCSharpSingleton(property, ctx);

            // Property name
            var name = property.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            // Property type
            var type = toHaxeType(property.type, ctx);
            if (isCSharpSingleton) {
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
        for (method in ctx.csharpClass.methods) {

            // Constructor?
            var isCSharpConstructor = isCSharpConstructor(method, ctx);

            // Factory?
            var isCSharpFactory = isCSharpFactory(method, ctx);

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
            } else if (isCSharpConstructor) {
                write('function init(' + args.join(', ') + '):', ctx);
            } else {
                write('function ' + name + '(' + args.join(', ') + '):', ctx);
            }
            if (isCSharpConstructor) {
                write(haxeName, ctx);
            } else if (isCSharpFactory) {
                write(haxeName, ctx);
            } else {
                write(ret, ctx);
            }
            write(' {', ctx);
            writeLineBreak(ctx);
            ctx.indent++;

            writeIndent(ctx);
            if (isCSharpConstructor) {
                write('_instance = ', ctx);
            } else if (isCSharpFactory) {
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
            write(haxeName + '_Extern.' + name + '(', ctx);
            var i = 0;
            if (!isCSharpConstructor && method.instance) {
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
            if (isCSharpConstructor) {
                writeLine('return this;', ctx);
            } else if (isCSharpFactory) {
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
        writeLine('@:include(\'linc_' + ctx.csharpClass.name + '.h\')', ctx);
        writeLine('#if !display', ctx);
        writeLine('@:build(bind.Linc.touch())', ctx);
        writeLine('@:build(bind.Linc.xml(\'' + ctx.csharpClass.name + '\', \'./\'))', ctx);
        writeLine('#end', ctx);
        writeLine('@:allow(' + packPrefix + haxeName + ')', ctx);
        writeLine('private extern class ' + haxeName + '_Extern {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        // Add methods
        for (method in ctx.csharpClass.methods) {

            // Constructor?
            var isCSharpConstructor = isCSharpConstructor(method, ctx);

            // Method return type
            var ret = toHaxeType(method.type, ctx);

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Class argument
            args.push('class_:CSClass');

            // Method argument
            args.push('method_:CSMethodID');

            // Instance argument
            if (method.instance && !isCSharpConstructor) {
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
            write(ctx.csharpClass.name + '_' + method.name, ctx);
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

    }

    public static function generateLincFile(ctx:BindContext, header:Bool = false):Void {

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.csharpClass.name + '.xml', content: '' };

        writeLine('<xml>', ctx);
        ctx.indent++;
        writeLine('<files id="haxe">', ctx);
        ctx.indent++;
        writeLine('<compilerflag value="-I$'+'{LINC_' + ctx.csharpClass.name.toUpperCase() + '_PATH}linc/" />', ctx);
        writeLine('<file name="$'+'{LINC_' + ctx.csharpClass.name.toUpperCase() + '_PATH}linc/linc_' + ctx.csharpClass.name + '.cpp" />', ctx);
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

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.csharpClass.name + (header ? '.h' : '.cpp'), content: '' };

        if (header) {
            writeLine('#include <hxcpp.h>', ctx);
        } else {
            writeLine('#include "linc_CSharp.h"', ctx);
            writeLine('#include "linc_' + ctx.csharpClass.name + '.h"', ctx);
            writeLine('#ifndef INCLUDED_bind_csharp_HObject', ctx);
            writeLine('#include <bind/csharp/HObject.h>', ctx);
            writeLine('#endif', ctx);
        }


        writeLineBreak(ctx);

        var namespaceEntries = [];
        if (ctx.namespace != null && ctx.namespace.trim() != '') {
            namespaceEntries = ctx.namespace.split('::');
        }

        // Class comment
        if (ctx.csharpClass.description != null && ctx.csharpClass.description.trim() != '') {
            writeComment(ctx.csharpClass.description, ctx);
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

            var isCSharpConstructor = isCSharpConstructor(method, ctx);

            // Method return type
            var ret = toHxcppType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Instance handle as first argument
            if (method.instance && !isCSharpConstructor) {
                args.push('::Dynamic instance_');
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
            write(ret + ' ' + ctx.csharpClass.name + '_' + name + '(' + args.join(', ') + ')', ctx);
            if (header) {
                write(';', ctx);
            }
            else {
                write(' {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Method body
                //

                // Convert args to C#-compatible
                var toCSharpC = [];
                var i = 0;
                for (arg in method.args) {
                    writeCSharpCArgAssign(arg, i, ctx);
                    i++;
                }

                // Call C#
                writeCSharpCCall(method, ctx);

                ctx.indent--;
                writeIndent(ctx);
                write('}', ctx);
                writeLineBreak(ctx);

                ctx.indent--;
                writeIndent(ctx);
                write('}', ctx);
            }
            writeLineBreak(ctx);
            writeLineBreak(ctx);

        }

        // Add methods
        for (method in ctx.csharpClass.methods) {

            writeMethod(method);

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
                    var retType = toCSharpCType(ret, ctx);
                    write(retType + ' ', ctx);
                    var csharpNamespace = (''+ctx.csharpClass.orig.namespace);
                    if (csharpNamespace != '') {
                        write(csharpNamespace.replace('.', '_') + '_', ctx);
                    }
                    write(ctx.csharpClass.name + '_callN_' + key + '(JNIEnv *env, jclass clazz, jstring address', ctx);

                    var n = 1;
                    for (funcArg in args) {
                        var argType = toCSharpCType(funcArg.type, ctx);
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
                        writeLine('::Dynamic func_hobject_ = ::bind::cs::CSStringToHObject(address);', ctx);
                        writeLine('::Dynamic func_unwrapped_ = ::bind::cs::HObject_obj::unwrap(func_hobject_);', ctx);
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
                            writeCSharpCArgAssign({
                                name: 'return',
                                type: ret
                            }, -1, ctx);
                            writeLine('hx::SetTopOfStack((int *)0, true);', ctx);
                            writeLine('return return_csc_;', ctx);
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

    public static function generateCSharpFile(ctx:BindContext):Void {

        var reserved = ['new', 'with'];

        var dir = '';
        var pack = '' + ctx.csharpClass.orig.namespace;
        dir = pack.replace('.', '/') + '/';

        var imports:Array<String> = ctx.csharpClass.orig.imports;
        var bindingName = 'Bind_' + ctx.csharpClass.name;

        ctx.currentFile = { path: Path.join(['cs', dir, bindingName + '.cs']), content: '' };

        writeLine('// This file was generated with bind library', ctx);
        writeLineBreak(ctx);

        // Imports
        if (imports.indexOf('Bind.Support') == -1 && imports.indexOf('${ctx.bindSupport}') == -1) {
            writeLine('using ${ctx.bindSupport};', ctx);
        }
        for (imp in imports) {
            if (imp == 'Bind.Support' || imp.startsWith('Bind.Support.')) {
                writeLine('using ${ctx.bindSupport}${imp.substr('Bind.Support'.length)};', ctx);
            }
            else {
                writeLine('using $imp;', ctx);
            }
        }

        writeLineBreak(ctx);

        // Open namespaces
        if (pack.length > 0) {
            for (name in pack.split('.')) {
                writeLine('namespace $name {', ctx);
                ctx.indent++;
                writeLineBreak(ctx);
            }
        }

        // Class comment
        if (ctx.csharpClass.description != null && ctx.csharpClass.description.trim() != '') {
            writeComment(ctx.csharpClass.description, ctx);
        }

        writeLine('class ' + bindingName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        function writeMethod(method:bind.Class.Method) {

            // Constructor?
            var isCSharpConstructor = isCSharpConstructor(method, ctx);

            // Factori?
            var isCSharpFactory = isCSharpFactory(method, ctx);

            // Is it a getter or setter?
            var isGetter = method.orig != null && method.orig.getter == true;
            var isSetter = method.orig != null && method.orig.setter == true;

            // Java callback called from native?
            var isCSharpCallback = method.orig != null && method.orig.csharpCallback == true;
            var csharpCallbackType:String = null;
            if (isCSharpCallback) {
                csharpCallbackType = '' + method.orig.csharpCallbackType;
            }

            // Method return type
            var ret = toCSharpBindFromCSharpType(method.type, ctx);
            if (isCSharpConstructor) {
                ret = ctx.csharpClass.name;
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
            if (isCSharpCallback) {
                args.push('object _callback');
            }
            else if (method.instance && !isCSharpConstructor) {
                args.push(ctx.csharpClass.name + ' _instance');
            }
            for (arg in method.args) {
                args.push(toCSharpBindType(arg.type, ctx) + ' ' + arg.name);
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

            writeLine('if (!${ctx.bindSupport}.isCSMainThread()) {', ctx);
            ctx.indent++;
            if (hasReturn) {
                writeLine(ret + ' _bind_result;', ctx);
            }
            if (hasReturn) {
                writeLine('${ctx.bindSupport}.RunInCSMainThreadSync(() => {', ctx);
            }
            else {
                writeLine('${ctx.bindSupport}.RunInCSMainThreadAsync(() => {', ctx);
            }
            ctx.indent++;

            if (hasReturn) {
                writeIndent(ctx);
                write('_bind_result = Bind_' + ctx.csharpClass.name + '.' + method.name + '(', ctx);
            } else {
                writeIndent(ctx);
                write('Bind_' + ctx.csharpClass.name + '.' + method.name + '(', ctx);
            }

            var callArgs = [];
            if (isCSharpCallback) {
                callArgs.push('_callback');
            }
            else if (method.instance && !isCSharpConstructor) {
                callArgs.push('_instance');
            }
            for (arg in method.args) {
                callArgs.push(arg.name);
            }
            write(callArgs.join(', '), ctx);
            write(');', ctx);
            writeLineBreak(ctx);

            ctx.indent--;
            writeLine('});', ctx);

            if (hasReturn) {
                writeLine('return _bind_result;', ctx);
            }

            ctx.indent--;
            writeLine('} else {', ctx);
            ctx.indent++;

            var index = 0;
            for (arg in method.args) {
                writeCSharpArgAssign(arg, index++, ctx);
            }

            // Call C#
            writeCSharpCall(method, ctx);

            ctx.indent--;
            writeLine('}', ctx);

            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);

        }

        // Add methods
        for (method in ctx.csharpClass.methods) {

            writeMethod(method);

        }

        // Expose C# callbacks to native
        for (key in ctx.csharpCallbacks.keys()) {

            var func = ctx.csharpCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):
                    writeMethod({
                        name: 'callCS_' + key,
                        args: args,
                        type: ret,
                        instance: false,
                        description: null,
                        orig: {
                            csharpCallbackType: toCSharpType(func, ctx),
                            csharpCallback: true
                        }
                    });
                default:
            }

        }

        // Expose native callbacks to C#
        for (key in ctx.nativeCallbacks.keys()) {

            var func = ctx.nativeCallbacks.get(key);

            switch (func) {
                case Function(args, ret, orig):

                    writeLine('[DllImport(Bind_DllName, CallingConvention = CallingConvention.Cdecl)]', ctx);

                    writeIndent(ctx);
                    var retType = toCSharpBindType(ret, ctx);
                    write('private static extern ' + retType + ' CallN_' + key + '(IntPtr address', ctx);

                    var n = 1;
                    for (funcArg in args) {
                        var argType = toCSharpBindType(funcArg.type, ctx);
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

        // Close namespaces
        if (pack.length > 0) {
            for (name in pack.split('.')) {
                ctx.indent--;
                writeLine('}', ctx);
                writeLineBreak(ctx);
            }
        }

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

    public static function copyCSharpSupportFile(ctx:BindContext):Void {

        if (ctx.csharpPath == null) return;

        var pack = ctx.bindSupport.split('.');
        pack.pop();

        var csContent = sys.io.File.getContent(Path.join([Path.directory(Sys.programPath()), 'support/cs/Bind/Support.cs']));

        // TODO: fix this to handle composed namespaces
        csContent = csContent.replace('namespace Bind;', 'namespace ${pack.join('.')};');

        ctx.currentFile = {
            path: Path.join(['cs', '${ctx.bindSupport.replace('.', '/')}.cs']),
            content: '' + csContent
        };

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

/// C# -> Haxe

    static function toHaxeType(type:bind.Class.Type, ctx:BindContext):String {

        var csharpType = toCSharpType(type, ctx);
        if (csharpType == ctx.csharpClass.name || csharpType == ctx.csharpClass.orig.namespace + '.' + ctx.csharpClass.name) {
            return ctx.csharpClass.name;
        }

        var result = switch (type) {
            case Void(orig): 'Void';
            case Int(orig): 'Int';
            case Float(orig): 'Float';
            case Bool(orig): 'Bool';
            case String(orig): 'String';
            case Array(itemType, orig): 'Array<Dynamic>';
            case Map(itemType, orig): 'Dynamic';
            case Object(orig): 'HObject';
            case Function(args, ret, orig): toHaxeFunctionType(type, ctx);
        }

        return result;

    }

    static function toHaxeFunctionType(type:bind.Class.Type, ctx:BindContext):String {

        var result = 'Dynamic';

        switch (type) {
            case Function(args, ret, orig):
                var resArgs = [];
                if (args.length > 0) {
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

/// Haxe -> HXCPP

    static function toHxcppType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig): 'double';
            case Bool(orig): 'bool';
            case String(orig): '::String';
            case Array(itemType, orig): toHxcppArrayType(type, ctx);
            case Map(itemType, orig): toHxcppMapType(type, ctx);
            case Object(orig): toHxcppObjectType(type, ctx);
            case Function(args, ret, orig): toHxcppFunctionType(type, ctx);
        }

        return result;

    }

    static function toHxcppArrayType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    }

    static function toHxcppMapType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    }

    static function toHxcppObjectType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    }

    static function toHxcppFunctionType(type:bind.Class.Type, ctx:BindContext):String {

        return '::Dynamic';

    }

/// HXCPP -> C#-compatible C

    static function toCSharpCType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig):
                orig != null && (orig.type == 'Double' || orig.type == 'double')
                ? 'double'
                : 'float';
            case Bool(orig): 'int';
            case String(orig): 'const char*';
            case Array(Int(_), orig): 'int*';
            case Array(Float(floatOrig), orig): toCSharpCType(Float(floatOrig), ctx) + '*';
            case Array(Bool(_), orig): 'int*';
            case Array(String(_), orig): 'const char**';
            case Array(itemType, orig): 'const char*'; // Serialized as JSON
            case Map(String(_), orig): 'const char**';
            case Map(itemType, orig): 'const char*'; // Serialized as JSON
            case Object(orig): 'void*';
            case Function(args, ret, orig): 'const char*';
        }

        return result;

    }

/// HXCPP -> C#

    static function toCSharpType(type:bind.Class.Type, ctx:BindContext):String {

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

    static function toCSharpBindType(type:bind.Class.Type, ctx:BindContext):String {

        var csharpType = toCSharpType(type, ctx);
        if (csharpType == ctx.csharpClass.name || csharpType == ctx.csharpClass.orig.namespace + '.' + ctx.csharpClass.name) {
            return csharpType;
        }

        var result = switch (type) {
            case Void(orig): 'void';
            case Int(orig): 'int';
            case Float(orig):
                orig != null && (orig.type == 'Double' || orig.type == 'double')
                ? 'double'
                : 'float';
            case Bool(orig): 'int';
            case String(orig): 'IntPtr';

            case Array(Int(_), orig): 'int[]';
            case Array(Float(floatOrig), orig): toCSharpBindType(Float(floatOrig), ctx) + '[]';
            case Array(Bool(_), orig): 'int[]';
            case Array(String(_), orig): 'IntPtr';//'string[]';
            case Array(itemType, orig): 'IntPtr';//'string'; // Serialized as JSON
            case Map(String(_), orig): 'IntPtr';//'string[]';
            case Map(itemType, orig): 'IntPtr';//'string'; // Serialized as JSON

            case Object(orig): orig;
            case Function(args, ret, orig): 'IntPtr';//'string';
        }

        return result;

    }

    static function toCSharpBindFromCSharpType(type:bind.Class.Type, ctx:BindContext):String {

        var result = switch (type) {
            case Function(args, ret, orig): 'IntPtr';//'string';
            default:
                toCSharpBindType(type, ctx);
        }

        return result;

    }

    static function toNativeCallPart(part:String):String {

        if (part.startsWith('List<')) part = 'List';
        else if (part.startsWith('Dictionary<')) part = 'Dictionary';
        part = part.replace('<', '');
        part = part.replace('>', '');
        part = part.replace(',', '');
        part = part.charAt(0).toUpperCase() + part.substring(1);

        return part;

    }

/// Helpers

    static function isCSharpConstructor(method:bind.Class.Method, ctx:BindContext):Bool {

        return method.name == 'constructor';

    }

    static function isCSharpFactory(method:bind.Class.Method, ctx:BindContext):Bool {

        var isCSharpFactory = false;
        var csharpType = toCSharpType(method.type, ctx);
        if (csharpType == ctx.csharpClass.name || csharpType == ctx.csharpClass.orig.namespace + '.' + ctx.csharpClass.name) {
            isCSharpFactory = true;
        }

        return isCSharpFactory;

    }

    static function isCSharpSingleton(property:bind.Class.Property, ctx:BindContext):Bool {

        var isCSharpSingleton = false;
        var csharpType = toCSharpType(property.type, ctx);
        if (!property.instance && (csharpType == ctx.csharpClass.name || csharpType == ctx.csharpClass.orig.namespace + '.' + ctx.csharpClass.name)) {
            isCSharpSingleton = true;
        }

        return isCSharpSingleton;

    }

/// Write utils (specific)

    static function writeCSharpArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toCSharpType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_cs_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_csc_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                var retType = toCSharpType(ret, ctx);
                var hasReturn = retType != 'void' && retType != 'Void';

                writeLine('HObject ' + name + 'hobj_ = $value == null ? null : new HObject($value);', ctx);

                writeIndent(ctx);
                write('' + type + ' ' + name + ' = $value == null ? null : (', ctx);
                var i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);
                    var argType = toCSharpType(funcArg.type, ctx);
                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    write('$argType ' + argName, ctx);
                }
                write(') => {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Convert C# args into C#-bind args
                i = 0;
                for (funcArg in args) {
                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    writeCSharpBindArgAssign(funcArg, i, ctx);
                    i++;
                }

                if (hasReturn) {
                    var csharpBindRetType = toCSharpBindType(ret, ctx);
                    writeLine(csharpBindRetType + ' return_csc_result_;', ctx);
                    writeLine('${ctx.bindSupport}.RunInNativeThreadSync(() => {', ctx);
                } else {
                    writeLine('${ctx.bindSupport}.RunInNativeThreadAsync(() => {', ctx);
                }
                ctx.indent++;

                // Call
                writeIndent(ctx);
                if (hasReturn) {
                    write('return_csc_result_ = ', ctx);
                }
                write('Bind_' + ctx.csharpClass.name + '.CallN_', ctx);

                i = 0;
                var allParts = '';
                for (funcArg in args) {
                    var part = toCSharpType(funcArg.type, ctx);
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
                    write(', ' + funcArg.name + '_csc_', ctx);
                }

                write(');', ctx);
                writeLineBreak(ctx);

                // Release data allocated by C# for this call
                var shouldRelease = false;
                for (funcArg in args) {
                    if (shouldReleaseCSharpBindArg(funcArg)) {
                        shouldRelease = true;
                        break;
                    }
                }
                if (shouldRelease) {
                    // TODO: wrap in a main thread call? (so far not needed so not implemented)
                    // writeLine('${ctx.bindSupport}.RunInCSMainThreadAsync(() => {', ctx);
                    // ctx.indent++;

                    i = 0;
                    for (funcArg in args) {
                        var argName = funcArg.name;
                        if (argName == null) argName = 'arg' + (i + 1);
                        writeCSharpBindArgRelease(funcArg, i, ctx);
                        i++;
                    }

                    // ctx.indent--;
                    // writeLine('});', ctx);
                }

                ctx.indent--;
                writeLine('});', ctx);

                if (retType == 'Void') {
                    writeLine('return null;', ctx);
                }
                else if (retType != 'void') {
                    var csharpBindRetType = toCSharpBindType(ret, ctx);
                    writeLine(csharpBindRetType + ' return_csc_ = return_csc_result_;', ctx);
                    writeCSharpArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return return_csc_;', ctx);
                }

                ctx.indent--;
                writeLine('};', ctx);

            case String(orig):
                writeIndent(ctx);
                write('$type $name = Bind.Support.UTF8CStringToString($value);', ctx);
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
                write('$type $name = $value != 0 ? true : false;', ctx);
                writeLineBreak(ctx);

            case Array(itemType, orig):
                writeIndent(ctx);
                write('$type $name = ${ctx.bindSupport}.JSONStringTo${type.charAt(0).toUpperCase() + type.substr(1)}($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('$type $name = ${ctx.bindSupport}.JSONStringTo${type.charAt(0).toUpperCase() + type.substr(1)}($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeCSharpBindArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toCSharpBindFromCSharpType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_csc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_cs_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeLine(type + ' ' + name + ' = $value;', ctx);

                var retType = toCSharpType(ret, ctx);

                var allParts = '';
                for (funcArg in args) {
                    var part = toCSharpType(funcArg.type, ctx);
                    part = toNativeCallPart(part);
                    allParts += part;
                }
                var part = toNativeCallPart(retType);
                allParts += part;

                if (!ctx.csharpCallbacks.exists(allParts)) {
                    ctx.csharpCallbacks.set(allParts, arg.type);
                }

            case String(orig):
                writeIndent(ctx);
                write('$type $name = Bind.Support.StringToCSCString($value);', ctx);
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
                write('$type $name = ${ctx.bindSupport}.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                writeIndent(ctx);
                write('$type $name = ${ctx.bindSupport}.toJSONString($value);', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeCSharpBindArgRelease(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toCSharpBindFromCSharpType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_csc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_cs_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                // TODO?

            case String(orig):
                writeLine('Bind.Support.ReleaseCSCString($name);', ctx);

            case Int(orig):

            case Float(orig):

            case Bool(orig):

            case Array(itemType, orig):
                switch itemType {
                    case Int(orig) | Bool(orig):
                        writeLine('Bind.Support.ReleaseCSCIntArray($name);', ctx);
                    case Float(orig):
                        if (orig.type == 'Double' || orig.type == 'double') {
                            writeLine('Bind.Support.ReleaseCSCDoubleArray($name);', ctx);
                        } else {
                            writeLine('Bind.Support.ReleaseCSCFloatArray($name);', ctx);
                        }
                    case String(orig):
                        writeLine('Bind.Support.ReleaseCSCStringArray($name);', ctx);
                    case _:
                        writeLine('Bind.Support.ReleaseCSCString($name);', ctx);
                }

            case Map(itemType, orig):
                switch itemType {
                    case String(orig):
                        writeLine('Bind.Support.ReleaseCSCStringArray($name);', ctx);
                    case _:
                        writeLine('Bind.Support.ReleaseCSCString($name);', ctx);
                }

            default:
        }

    }

    static function shouldReleaseCSharpBindArg(arg:bind.Class.Arg):Bool {

        return switch (arg.type) {

            case String(orig):
                true;

            case Array(itemType, orig):
                true;

            case Map(itemType, orig):
                true;

            case _:
                false;
        }

    }

    static function writeCSharpCArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toCSharpCType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_csc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_hxcpp_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                write('$type $name = ::bind::cs::HObjectToCSString($value);', ctx);
                writeLineBreak(ctx);

            case String(orig):
                write('$type $name = ::bind::cs::HxcppToCSString($value);', ctx);
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

            // TODO typed arrays and maps

            case Array(itemType, orig):
                write('$type $name = ::bind::cs::HxcppToCSString($value);', ctx);
                writeLineBreak(ctx);

            case Map(itemType, orig):
                write('$type $name = ::bind::cs::HxcppToCSString($value);', ctx);
                writeLineBreak(ctx);

            case Object(orig):
                write('$type $name = (void*) (hx::IsNotNull($value) ? $value.ptr : NULL);', ctx);
                writeLineBreak(ctx);

            default:
                write('$type $name = NULL; // Not implemented', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeCSharpCCall(method:bind.Class.Method, ctx:BindContext):Void {

        // TODO
        writeLine('// TODO C# C call', ctx);

    }

    static function writeHxcppArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext, keepName:Bool = true):Void {

        var type = toHxcppType(arg.type, ctx);
        var name = (keepName && arg.name != null ? arg.name : 'arg' + (index + 1)) + '_hxcpp_';
        var value = (keepName && arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_csc_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                writeIndent(ctx);
                write('$type $name = $value != NULL ? ::cpp::Pointer<void>($value) : null();', ctx);
                writeLineBreak(ctx);

            case String(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::cs::CSStringToHxcpp($value);', ctx);
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
                write('$type $name = ($value != 0 ? true : false);', ctx);
                writeLineBreak(ctx);

            case Array(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::cs::CSStringToHxcpp($value);', ctx);
                writeLineBreak(ctx);

            case Map(orig):
                writeIndent(ctx);
                write('$type $name = ::bind::cs::CSStringToHxcpp($value);', ctx);
                writeLineBreak(ctx);

            case Object(orig):
                writeIndent(ctx);
                write('$type $name = $value != NULL ? ::cpp::Pointer<void>($value) : null();', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                write('$type $name = null(); // Not implemented', ctx);
                writeLineBreak(ctx);
        }

    }

    static function writeCSharpCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isCSharpConstructor = isCSharpConstructor(method, ctx);
        var isCSharpCallback = method.orig != null && method.orig.csCallback == true;
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
                    write('Object return_cs_ = ', ctx);
                default:
                    var csharpType = toCSharpType(method.type, ctx);
                    write(csharpType + ' return_cs_ = ', ctx);
            }
        }
        if (isCSharpCallback) {
            var csharpCallbackType = '' + method.orig.csharpCallbackType;
            write('(($csharpCallbackType)_callback)(', ctx);
        }
        else if (isImplicit) {
            if (method.instance) {
                write('_instance.' + method.orig.property.name, ctx);
            } else {
                write(ctx.csharpClass.name + '.' + method.orig.property.name, ctx);
            }
            if (isSetter) {
                write(' = ', ctx);
            }
        }
        else if (isCSharpConstructor) {
            write('new ' + ctx.csharpClass.name + '(', ctx);
        } else if (method.instance) {
            write('_instance.' + method.name + '(', ctx);
        } else {
            write(ctx.csharpClass.name + '.' + method.name + '(', ctx);
        }
        var n = 0;
        for (arg in method.args) {
            if (n++ > 0) write(', ', ctx);
            write(arg.name + '_cs_', ctx);
        }
        if (isImplicit) {
            write(';', ctx);
        } else {
            write(');', ctx);
        }
        writeLineBreak(ctx);
        if (hasReturn) {
            if (isCSharpConstructor) {
                writeLine('return return_cs_;', ctx);
            } else {
                writeCSharpBindArgAssign({
                    name: 'return',
                    type: method.type
                }, -1, ctx);
                writeLine('return return_csc_;', ctx);
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