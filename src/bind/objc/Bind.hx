package bind.objc;

import haxe.io.Path;
using StringTools;

typedef BindContext = {
    var objcClass:bind.Class;
    var indent:Int;
    var files:Array<bind.File>;
    var namespace:String;
    var pack:String;
    var objcPrefix:String;
    var currentFile:bind.File;
    var headerPath:String;
    var headerCode:String;
    var lincFiles:Array<String>;
}

class Bind {

    public static function createContext():BindContext {

        return {
            objcClass: null,
            indent: 0,
            files: [],
            namespace: null,
            objcPrefix: null,
            pack: null,
            currentFile: null,
            headerPath: null,
            headerCode: null,
            lincFiles: []
        };

    }

    /** Reads bind.Class object informations and generate files
        To bind the related Objective-C class to Haxe.
        The files are returned as an array of bind.File objects.
        Nothing is written to disk at this stage. */
    public static function bindClass(objcClass:bind.Class, ?options:{?namespace:String, ?pack:String, ?objcPrefix:String, ?headerPath:String, ?headerCode:String, ?lincFiles:Array<String>}):Array<bind.File> {

        var ctx = createContext();
        ctx.objcClass = objcClass;

        if (options != null) {
            if (options.namespace != null) ctx.namespace = options.namespace;
            if (options.pack != null) ctx.pack = options.pack;
            if (options.objcPrefix != null) ctx.objcPrefix = options.objcPrefix;
            if (options.headerPath != null) ctx.headerPath = options.headerPath;
            if (options.headerCode != null) ctx.headerCode = options.headerCode;
            if (options.lincFiles != null) ctx.lincFiles = options.lincFiles;
        }

        // Copy Objective C header file
        copyObjcHeaderFile(ctx);

        // Generate Objective C++ file
        generateObjCPPFile(ctx, true);
        generateObjCPPFile(ctx);

        // Generate Haxe file
        generateHaxeFile(ctx);

        // Generate Linc (XML) file
        generateLincFile(ctx);

        return ctx.files;

    }

    public static function copyObjcHeaderFile(ctx:BindContext):Void {

        if (ctx.headerCode == null) return;

        // Patch Swift Framework header to make it compile fine
        ctx.headerCode = ctx.headerCode.replace('typedef uint_least16_t char16_t;', '//typedef uint_least16_t char16_t;');
        ctx.headerCode = ctx.headerCode.replace('typedef uint_least32_t char32_t;', '//typedef uint_least32_t char32_t;');

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        ctx.currentFile = {
            path: dir + 'linc/objc_' + Path.withoutDirectory(ctx.headerPath),
            content: ctx.headerCode
        };

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

    public static function generateObjCPPFile(ctx:BindContext, header:Bool = false):Void {

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.objcClass.name + (header ? '.h' : '.mm'), content: '' };

        writeLine('#import "hxcpp.h"', ctx);
        if (header) {
            //
        } else {
            writeLine('#import "linc_Objc.h"', ctx);
            writeLine('#import <Foundation/Foundation.h>', ctx);
            writeLine('#import "linc_' + ctx.objcClass.name + '.h"', ctx);
            if (ctx.headerPath != null) {
                writeLine('#import "objc_' + Path.withoutDirectory(ctx.headerPath) + '"', ctx);
            } else {
                writeLine('#import "' + ctx.objcClass.name + '.h"', ctx);
            }
        }

        writeLineBreak(ctx);

        var namespaceEntries = [];
        if (ctx.namespace != null && ctx.namespace.trim() != '') {
            namespaceEntries = ctx.namespace.split('::');
        }

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

            // Constructor?
            var isObjcConstructor = isObjcConstructor(method, ctx);

            // Method return type
            var ret = toHxcppType(method.type, ctx);

            // Method name
            var name = method.name;

            var args = [];

            // Instance handle as first argument
            if (method.instance && !isObjcConstructor) {
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

                // Autorelease pool
                writeIndent(ctx);
                write('@autoreleasepool {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Get current thread
                writeIndent(ctx);
                write('NSThread *objc_caller_thread_ = [NSThread currentThread];', ctx);
                writeLineBreak(ctx);

                // Convert args to Objc
                var toObjc = [];
                var i = 0;
                for (arg in method.args) {
                    writeObjcArgAssign(arg, i, ctx);
                    i++;
                }

                // Check if it is main thread
                writeIndent(ctx);
                write('if (![objc_caller_thread_ isMainThread]) {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;
                writeWrapToObjcThreadCall(method, ctx);
                ctx.indent--;
                writeIndent(ctx);
                write('}', ctx);
                writeLineBreak(ctx);

                // Call Objc
                writeObjcCall(method, ctx);

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

        // Close namespaces
        for (name in namespaceEntries) {
            ctx.indent--;
            writeLine('}', ctx);
            writeLineBreak(ctx);
        }

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

    public static function generateHaxeFile(ctx:BindContext, header:Bool = false):Void {

        var reserved = ['new', 'with'];

        var dir = '';
        if (ctx.pack != null && ctx.pack.trim() != '') {
            dir = ctx.pack.replace('.', '/') + '/';
        }

        var haxeName = ctx.objcClass.name;
        if (ctx.objcPrefix != null && ctx.objcPrefix.trim() != '') {
            if (haxeName.startsWith(ctx.objcPrefix.trim())) {
                haxeName = haxeName.substring(ctx.objcPrefix.trim().length);
            }
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
        writeLine('import bind.objc.Support;', ctx);

        writeLineBreak(ctx);

        // Class comment
        if (ctx.objcClass.description != null && ctx.objcClass.description.trim() != '') {
            writeComment(ctx.objcClass.description, ctx);
        }

        writeLine('class ' + haxeName + ' {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        writeLine('private var _instance:Dynamic = null;', ctx);
        writeLineBreak(ctx);

        writeLine('public function new() {}', ctx);
        writeLineBreak(ctx);

        // Add properties
        for (property in ctx.objcClass.properties) {

            // Read-only?
            var readonly = property.orig != null && property.orig.readonly == true;

            // Singleton?
            var isObjcSingleton = isObjcSingleton(property, ctx);

            // Property name
            var name = property.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            // Property type
            var type = toHaxeType(property.type, ctx);
            if (isObjcSingleton) {
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
        for (method in ctx.objcClass.methods) {

            // Constructor?
            var isObjcConstructor = isObjcConstructor(method, ctx);

            // Factory?
            var isObjcFactory = isObjcFactory(method, ctx);

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
            if (isObjcConstructor) {
                write(haxeName, ctx);
            } else if (isObjcFactory) {
                write(haxeName, ctx);
            } else {
                write(ret, ctx);
            }
            write(' {', ctx);
            writeLineBreak(ctx);
            ctx.indent++;

            writeIndent(ctx);
            if (isObjcConstructor) {
                write('_instance = ', ctx);
            } else if (isObjcFactory) {
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
            if (!isObjcConstructor && method.instance) {
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
            if (isObjcConstructor) {
                writeLine('return this;', ctx);
            } else if (isObjcFactory) {
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
        writeLine('@:include(\'linc_' + ctx.objcClass.name + '.h\')', ctx);
        writeLine('#if !display', ctx);
        writeLine('@:build(bind.Linc.touch())', ctx);
        writeLine('@:build(bind.Linc.xml(\'' + ctx.objcClass.name + '\', \'./\'))', ctx);
        writeLine('#end', ctx);
        writeLine('@:allow(' + packPrefix + haxeName + ')', ctx);
        writeLine('private extern class ' + haxeName + '_Extern {', ctx);
        ctx.indent++;
        writeLineBreak(ctx);

        // Add methods
        for (method in ctx.objcClass.methods) {

            // Constructor?
            var isObjcConstructor = isObjcConstructor(method, ctx);

            // Method return type
            var ret = toHaxeType(method.type, ctx);

            // Method name
            var name = method.name;
            if (reserved.indexOf(name) != -1) {
                name = '_' + name;
            }

            var args = [];

            // Instance argument
            if (method.instance && !isObjcConstructor) {
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
            write(ctx.objcClass.name + '_' + method.name, ctx);
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

        ctx.currentFile = { path: dir + 'linc/linc_' + ctx.objcClass.name + '.xml', content: '' };

        writeLine('<xml>', ctx);
        ctx.indent++;
        writeLine('<files id="haxe">', ctx);
        ctx.indent++;
        writeLine('<compilerflag value="-I$'+'{LINC_' + ctx.objcClass.name.toUpperCase() + '_PATH}linc/" />', ctx);
        writeLine('<file name="$'+'{LINC_' + ctx.objcClass.name.toUpperCase() + '_PATH}linc/linc_' + ctx.objcClass.name + '.mm" />', ctx);

        if (ctx.lincFiles != null) {
            for (lincFilePath in ctx.lincFiles) {
                if (lincFilePath.endsWith('.h')) {

                }
                else {
                    writeLine('<file name="$'+'{LINC_' + ctx.objcClass.name.toUpperCase() + '_PATH}linc/${Path.withoutDirectory(lincFilePath)}" />', ctx);
                }

                var file:bind.File = {
                    content: sys.io.File.getContent(lincFilePath),
                    path: dir + 'linc/' + Path.withoutDirectory(lincFilePath)
                };
                ctx.files.push(file);
            }
        }

        ctx.indent--;
        writeLine('</files>', ctx);
        writeLine('<target id="haxe">', ctx);
        writeLine('</target>', ctx);
        ctx.indent--;
        writeLine('</xml>', ctx);

        ctx.files.push(ctx.currentFile);
        ctx.currentFile = null;

    }

    static function isObjcConstructor(method:bind.Class.Method, ctx:BindContext):Bool {

        var isObjcConstructor = false;
        var objcType = toObjcType(method.type, ctx);
        if (method.instance && method.name.startsWith('init') && (objcType == 'instancetype' || objcType == ctx.objcClass.name + '*')) {
            isObjcConstructor = true;
        }

        return isObjcConstructor;

    }

    static function isObjcFactory(method:bind.Class.Method, ctx:BindContext):Bool {

        var isObjcFactory = false;
        var objcType = toObjcType(method.type, ctx);
        if (!method.instance && (objcType == 'instancetype' || objcType == ctx.objcClass.name + '*')) {
            isObjcFactory = true;
        }

        return isObjcFactory;

    }

    static function isObjcSingleton(property:bind.Class.Property, ctx:BindContext):Bool {

        var isObjcSingleton = false;
        var objcType = toObjcType(property.type, ctx);
        if (!property.instance && (objcType == 'instancetype' || objcType == ctx.objcClass.name + '*')) {
            isObjcSingleton = true;
        }

        return isObjcSingleton;

    }

/// Objective-C -> Haxe

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

/// Objective-C -> HXCPP

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

/// HXCPP -> Objective-C

    static function toObjcType(type:bind.Class.Type, ctx:BindContext):String {

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

/// Write utils (specific)

    static function writeHxcppArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        var type = toHxcppType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_hxcpp_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_objc_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                var funcType = toHxcppType(arg.type, ctx);
                var funcRetType = toHxcppType(ret, ctx);

                // Keep track of objc instance on haxe side
                writeLine('::Dynamic closure_' + name + ' = ::bind::objc::WrappedObjcIdToHxcpp(' + value + ');', ctx);
                writeIndent(ctx);

                // Assign haxe function from objc block
                write('HX_BEGIN_LOCAL_FUNC_S1(hx::LocalFunc, _hx_Closure_' + name, ctx);
                write(', ::Dynamic, closure_' + name, ctx);
                write(') HXARGC(' + args.length + ')', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                write(funcRetType + ' _hx_run(', ctx);

                var i = 0;
                for (funcArg in args) {
                    if (i++ > 0) write(', ', ctx);

                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);

                    write(toHxcppType(funcArg.type, ctx) + ' ' + argName, ctx);
                }

                write(') {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Convert haxe args into objc args
                i = 0;
                for (funcArg in args) {

                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);

                    writeObjcArgAssign(funcArg, i, ctx);

                    i++;
                }

                // Unwrap block
                var blockReturnType = toObjcType(ret, ctx);
                writeIndent(ctx);
                write(blockReturnType + ' ', ctx);
                write('(^closure_' + value + ')(', ctx);
                i = 0;
                for (blockArg in args) {
                    if (i++ > 0) write(', ', ctx);

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + i;
                    write(toObjcType(blockArg.type, ctx) + ' ' + argName, ctx);
                }
                write(') = ::bind::objc::HxcppToUnwrappedObjcId(closure_' + name + ');', ctx);
                writeLineBreak(ctx);

                // Call block
                writeIndent(ctx);
                if (funcRetType != 'void') {
                    write(toObjcType(ret, ctx) + ' return_objc_ = ', ctx);
                }
                write('closure_' + value + '(', ctx);

                i = 0;
                for (funcArg in args) {
                    if (i > 0) write(', ', ctx);

                    var argName = funcArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);
                    var objcName = argName + '_objc_';

                    write(objcName, ctx);

                    i++;
                }

                write(');', ctx);
                writeLineBreak(ctx);

                if (funcRetType != 'void') {
                    writeHxcppArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return return_hxcpp_;', ctx);
                }

                ctx.indent--;
                writeLine('}', ctx);
                writeIndent(ctx);
                write('HX_END_LOCAL_FUNC' + args.length, ctx);
                switch (ret) {
                    case Void(orig):
                        write('((void))', ctx);
                    default:
                        write('(return)', ctx);
                }
                writeLineBreak(ctx);

                writeIndent(ctx);
                write('::Dynamic ' + name + ' = ::Dynamic(new _hx_Closure_' + name + '(closure_' + name + '));', ctx);
                writeLineBreak(ctx);

            case String(orig):
                writeIndent(ctx);
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

            case Int(orig):
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            case Float(orig):
                writeIndent(ctx);
                var objcType = toObjcType(arg.type, ctx);
                switch (objcType) {
                    case 'NSNumber*':
                        write('$type $name = ($type) ::bind::objc::ObjcIdToHxcpp($value);', ctx);
                    default:
                        write('$type $name = ($type) $value;', ctx);
                }
                writeLineBreak(ctx);

            case Bool(orig):
                writeIndent(ctx);
                write('$type $name = ($type) $value;', ctx);
                writeLineBreak(ctx);

            default:
                writeIndent(ctx);
                var objcType = toObjcType(arg.type, ctx);
                if (objcType == 'instancetype' || objcType == ctx.objcClass.name + '*') {
                    write('::Dynamic $name = ::bind::objc::WrappedObjcIdToHxcpp($value);', ctx);
                } else {
                    write('$type $name = ::bind::objc::ObjcIdToHxcpp($value);', ctx);
                }
                writeLineBreak(ctx);
        }

    }

    static function writeObjcArgAssign(arg:bind.Class.Arg, index:Int, ctx:BindContext):Void {

        writeIndent(ctx);

        var type = toObjcType(arg.type, ctx);
        var name = (arg.name != null ? arg.name : 'arg' + (index + 1)) + '_objc_';
        var value = (arg.name != null ? arg.name : 'arg' + (index + 1)) + (index == -1 ? '_hxcpp_' : '');

        switch (arg.type) {

            case Function(args, ret, orig):
                // Keep track of haxe instance on objc side
                write('BindObjcHaxeWrapperClass *' + name + 'wrapper_ = [[BindObjcHaxeWrapperClass alloc] init:' + arg.name + '.mPtr];', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                // Assign objc block from haxe function
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
                    if (i++ > 0) write(', ', ctx);

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);

                    write(toObjcType(blockArg.type, ctx) + ' ' + argName, ctx);
                }
                write(') {', ctx);
                ctx.indent++;
                writeLineBreak(ctx);

                if (blockReturnType != 'void') {
                    writeLine('__block ' + toObjcType(ret, ctx) + ' return_fromthread_objc_;', ctx);
                }

                writeIndent(ctx);
                if (blockReturnType == 'void') {
                    write('[[BindObjcHaxeQueue sharedQueue] enqueue:^{', ctx);
                }
                else {
                    write('[[BindObjcHaxeQueue sharedQueue] enqueueSync:^{', ctx);
                }
                writeLineBreak(ctx);
                ctx.indent++;

                writeIndent(ctx);
                write('@autoreleasepool {', ctx);
                writeLineBreak(ctx);
                ctx.indent++;

                // Push HXCPP stack lock
                writeIndent(ctx);
                write('int haxe_stack_ = 99;', ctx);
                writeLineBreak(ctx);
                writeIndent(ctx);
                write('hx::SetTopOfStack(&haxe_stack_, true);', ctx);
                writeLineBreak(ctx);

                // Convert objc args into haxe args
                i = 0;
                for (blockArg in args) {

                    var argName = blockArg.name;
                    if (argName == null) argName = 'arg' + (i + 1);

                    writeHxcppArgAssign(blockArg, i, ctx);

                    i++;
                }

                // Call function
                writeIndent(ctx);
                if (blockReturnType != 'void') {
                    write(toHxcppType(ret, ctx) + ' return_hxcpp_ = ', ctx);
                }
                write(name + 'wrapper_->haxeObject->__run(', ctx);

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

                // Pop HXCPP stack lock
                writeIndent(ctx);
                write('hx::SetTopOfStack((int*)0, true);', ctx);
                writeLineBreak(ctx);

                if (blockReturnType != 'void') {
                    writeObjcArgAssign({
                        name: 'return',
                        type: ret
                    }, -1, ctx);
                    writeLine('return_fromthread_objc_ = return_objc_;', ctx);
                }

                ctx.indent--;
                writeIndent(ctx);
                write('}', ctx);
                writeLineBreak(ctx);

                ctx.indent--;
                writeIndent(ctx);
                if (blockReturnType == 'void') {
                    write('}];', ctx);
                }
                else {
                    write('} callerThread:objc_caller_thread_];', ctx);
                }
                writeLineBreak(ctx);

                if (blockReturnType != 'void') {
                    writeLine('return return_fromthread_objc_;', ctx);
                }

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

            case Array(itemType, orig):
                switch (type) {
                    case 'NSArray*':
                        write('$type $name = ::bind::objc::HxcppToNSArray($value);', ctx);
                    case 'NSMutableArray*':
                        write('$type $name = ::bind::objc::HxcppToNSMutableArray($value);', ctx);
                }
                writeLineBreak(ctx);

            case Object(orig):
                if (type == 'instancetype' || type == ctx.objcClass.name + '*') {
                    write(ctx.objcClass.name + '* $name = ::bind::objc::HxcppToUnwrappedObjcId($value);', ctx);
                } else if (type.endsWith('*')) {
                    write('$type $name = ::bind::objc::HxcppToObjcId((Dynamic)$value);', ctx);
                } else {
                    write('$type $name = ($type) $value;', ctx);
                }
                writeLineBreak(ctx);

            default:
                if (type.endsWith('*')) {
                    write('$type $name = ::bind::objc::HxcppToObjcId((Dynamic)$value);', ctx);
                } else {
                    write('$type $name = ($type) $value;', ctx);
                }
                writeLineBreak(ctx);
        }

    }

    static function writeWrapToObjcThreadCall(method:bind.Class.Method, ctx:BindContext):Void {

        var hasReturn = false;
        var isObjcConstructor = isObjcConstructor(method, ctx);

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            switch (method.type) {
                case Function(args, ret, orig):
                    write('__block id return_fromthread_objc_;', ctx);
                default:
                    var objcType = toObjcType(method.type, ctx);
                    if (objcType == 'instancetype') objcType = ctx.objcClass.name + '*';
                    write('__block ' + objcType + ' return_fromthread_objc_;', ctx);
            }
            writeLineBreak(ctx);
            writeIndent(ctx);
            write('dispatch_sync(dispatch_get_main_queue(), ^{', ctx);
        }
        else {
            write('dispatch_async(dispatch_get_main_queue(), ^{', ctx);
        }
        writeLineBreak(ctx);
        ctx.indent++;

        writeObjcCall(method, ctx, false);
        if (hasReturn) {
            writeIndent(ctx);
            write('return_fromthread_objc_ = return_objc_;', ctx);
            writeLineBreak(ctx);
        }

        ctx.indent--;
        writeIndent(ctx);
        write('});', ctx);
        writeLineBreak(ctx);

        if (hasReturn) {
            writeHxcppArgAssign({
                name: 'return_fromthread',
                type: method.type
            }, -1, ctx);
            writeIndent(ctx);
            write('return return_fromthread_hxcpp_;', ctx);
            writeLineBreak(ctx);
        }
        else {
            writeIndent(ctx);
            write('return;', ctx);
            writeLineBreak(ctx);
        }

    }

    static function writeObjcCall(method:bind.Class.Method, ctx:BindContext, convertReturnToHaxe:Bool = true):Void {

        var hasReturn = false;
        var isObjcConstructor = isObjcConstructor(method, ctx);

        writeIndent(ctx);
        switch (method.type) {
            case Void(orig):
            default:
                hasReturn = true;
        }
        if (hasReturn) {
            switch (method.type) {
                case Function(args, ret, orig):
                    write('id return_objc_ = ', ctx);
                default:
                    var objcType = toObjcType(method.type, ctx);
                    if (objcType == 'instancetype') objcType = ctx.objcClass.name + '*';
                    write(objcType + ' return_objc_ = ', ctx);
            }
        }
        if (isObjcConstructor) {
            write('[[' + ctx.objcClass.name + ' alloc]', ctx);
        } else if (method.instance) {
            write('[::bind::objc::HxcppToUnwrappedObjcId(instance_)', ctx);
        } else {
            write('[' + ctx.objcClass.name, ctx);
        }
        if (method.args.length > 0) {
            for (arg in method.args) {
                var nameSection = arg.orig.nameSection;
                write(' ' + nameSection + ':', ctx);
                write(arg.name + '_objc_', ctx);
            }
        } else {
            write(' ' + method.name, ctx);
        }
        write('];', ctx);
        writeLineBreak(ctx);
        if (hasReturn) {
            if (convertReturnToHaxe) {
                writeHxcppArgAssign({
                    name: 'return',
                    type: method.type
                }, -1, ctx);
                writeLine('return return_hxcpp_;', ctx);
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
