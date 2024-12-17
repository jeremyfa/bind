package bind;

import Sys.println;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Cli {

    var args:Array<String>;

    var cwd:String;

    public function new(args:Array<String>, cwd:String) {

        this.args = args;
        this.cwd = cwd;

    }

    public function run():Void {

        if (args.length < 2) {
            println("Usage: haxelib run bind objc SomeHeaderFile.h");
            return;
        }

        // Extract options
        var options = {
            json: false,
            parseOnly: false,
            pretty: false,
            export: null,
            mute: false,
            bindSupport: 'bind.Support',
            noBindHeader: false
        };
        var bindClassOptions:Dynamic = {};
        var fileArgs = [];
        var i = 1;
        while (i < args.length) {

            var arg = args[i];

            if (arg.startsWith('--')) {
                if (arg == '--json') options.json = true;
                else if (arg == '--parse-only') options.parseOnly = true;
                else if (arg == '--pretty') options.pretty = true;
                else if (arg == '--export') {
                    i++;
                    options.export = args[i];
                    options.json = true;
                }
                else if (arg == '--mute') {
                    options.mute = true;
                }
                else if (arg == '--no-bind-header') {
                    options.noBindHeader = true;
                    bindClassOptions.noBindHeader = true;
                }
                else if (arg == '--bind-support') {
                    i++;
                    options.bindSupport = args[i];
                    bindClassOptions.bindSupport = args[i];
                }
                else if (arg == '--namespace') {
                    i++;
                    bindClassOptions.namespace = args[i];
                }
                else if (arg == '--linc-file') {
                    i++;
                    if (bindClassOptions.lincFiles == null)
                        bindClassOptions.lincFiles = [];
                    bindClassOptions.lincFiles.push(args[i]);
                }
                else if (arg == '--package') {
                    i++;
                    bindClassOptions.pack = args[i];
                }
                else if (arg == '--objc-prefix') {
                    i++;
                    bindClassOptions.objcPrefix = args[i];
                }
                else if (arg == '--cwd') {
                    i++;
                    this.cwd = args[i];
                    Sys.setCwd(args[i]);
                }
            }
            else {
                fileArgs.push(arg);
            }

            i++;
        }

        if (bindClassOptions.lincFiles != null) {
            var lincFiles:Array<String> = bindClassOptions.lincFiles;
            for (n in 0...lincFiles.length) {
                var path = lincFiles[n];
                if (!Path.isAbsolute(path)) {
                    path = Path.join([cwd, path]);
                    lincFiles[n] = path;
                }
            }
        }

        var kind = args[0];
        var json = [];
        var output = '';

        // Parse
        if (kind == 'objc') {

            for (i in 0...fileArgs.length) {
                var file = fileArgs[i];

                var path = Path.isAbsolute(file) ? file : Path.join([cwd, file]);
                if (!FileSystem.exists(path)) {
                    throw "Header file doesn't exist at path " + path;
                }
                if (FileSystem.isDirectory(path)) {
                    throw "Expected a header file but got a directory at path " + path;
                }
                var code = File.getContent(path);

                bindClassOptions.headerPath = path;
                bindClassOptions.headerCode = code;

                var ctx = {i: 0, types: new Map()};
                var result = null;
                while ((result = bind.objc.Parse.parseClass(code, ctx)) != null) {
                    result.path = path;

                    if (options.json) {
                        if (options.parseOnly) {
                            json.push(bind.Json.stringify(result, options.pretty));
                        }
                        else {
                            for (entry in bind.objc.Bind.bindClass(result, bindClassOptions)) {
                                json.push(bind.Json.stringify(entry, options.pretty));
                            }
                        }
                    }
                    else {
                        if (options.parseOnly) {
                            output += '' + result;
                        }
                        else {
                            for (entry in bind.objc.Bind.bindClass(result, bindClassOptions)) {
                                output += '-- BEGIN ' + entry.path + " --\n";
                                output += entry.content.rtrim() + "\n\n";
                                output += '-- END ' + entry.path + " --\n";
                            }
                        }
                    }
                }
            }

        }

        else if (kind == 'java') {

            for (i in 0...fileArgs.length) {
                var file = fileArgs[i];

                var path = Path.isAbsolute(file) ? file : Path.join([cwd, file]);
                if (!FileSystem.exists(path)) {
                    throw "Java file doesn't exist at path " + path;
                }
                if (FileSystem.isDirectory(path)) {
                    throw "Expected a java file but got a directory at path " + path;
                }
                var code = File.getContent(path);

                bindClassOptions.javaPath = path;
                bindClassOptions.javaCode = code;

                var ctx = {i: 0, types: new Map()};
                var result = null;
                while ((result = bind.java.Parse.parseClass(code, ctx)) != null) {
                    result.path = path;

                    if (options.json) {
                        if (options.parseOnly) {
                            json.push(bind.Json.stringify(result, options.pretty));
                        }
                        else {
                            for (entry in bind.java.Bind.bindClass(result, bindClassOptions)) {
                                json.push(bind.Json.stringify(entry, options.pretty));
                            }
                        }
                    }
                    else {
                        if (options.parseOnly) {
                            output += '' + result;
                        }
                        else {
                            for (entry in bind.java.Bind.bindClass(result, bindClassOptions)) {
                                output += '-- BEGIN ' + entry.path + " --\n";
                                output += entry.content.rtrim() + "\n\n";
                                output += '-- END ' + entry.path + " --\n";
                            }
                        }
                    }
                }
            }

        }

        else if (kind == 'cs') {

            if (options.bindSupport == 'bind.Support') {
                options.bindSupport = 'Bind.Support';
            }
            if (bindClassOptions.bindSupport == 'bind.Support') {
                bindClassOptions.bindSupport = 'Bind.Support';
            }

            for (i in 0...fileArgs.length) {
                var file = fileArgs[i];

                var path = Path.isAbsolute(file) ? file : Path.join([cwd, file]);
                if (!FileSystem.exists(path)) {
                    throw "C# file doesn't exist at path " + path;
                }
                if (FileSystem.isDirectory(path)) {
                    throw "Expected a C# file but got a directory at path " + path;
                }
                var code = File.getContent(path);

                bindClassOptions.csharpPath = path;
                bindClassOptions.csharpCode = code;

                var ctx = {i: 0, types: new Map()};
                var result = null;
                while ((result = bind.cs.Parse.parseClass(code, ctx)) != null) {
                    result.path = path;

                    if (options.json) {
                        if (options.parseOnly) {
                            json.push(bind.Json.stringify(result, options.pretty));
                        }
                        else {
                            for (entry in bind.cs.Bind.bindClass(result, bindClassOptions)) {
                                json.push(bind.Json.stringify(entry, options.pretty));
                            }
                        }
                    }
                    else {
                        if (options.parseOnly) {
                            output += '' + result;
                        }
                        else {
                            for (entry in bind.cs.Bind.bindClass(result, bindClassOptions)) {
                                output += '-- BEGIN ' + entry.path + " --\n";
                                output += entry.content.rtrim() + "\n\n";
                                output += '-- END ' + entry.path + " --\n";
                            }
                        }
                    }
                }
            }

        }

        if (options.json) {
            if (options.export != null) {

                if (!FileSystem.exists(options.export)) {
                    FileSystem.createDirectory(options.export);
                }

                for (jsonItem in json) {

                    var fileInfo:{path:String,content:String} = Json.parse(jsonItem);

                    var filePath = Path.join([options.export, fileInfo.path]);

                    if (!FileSystem.exists(Path.directory(filePath))) {
                        FileSystem.createDirectory(Path.directory(filePath));
                    }

                    if (FileSystem.exists(filePath)) {
                        var existing = File.getContent(filePath);
                        if (existing != fileInfo.content) {
                            File.saveContent(filePath, fileInfo.content);
                        }
                    }
                    else {
                        File.saveContent(filePath, fileInfo.content);
                    }
                }

            }
            else {
                if (options.pretty) {
                    if (!options.mute) println('['+json.join(',\n')+']');
                } else {
                    if (!options.mute) println('['+json.join(',')+']');
                }
            }
        }
        else {
            if (output.trim() != '') {
                if (!options.mute) println(output.rtrim());

            }
        }

    }

}
