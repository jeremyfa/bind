package bind;

import Sys.println;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class Cli {

    var args:Array<String>;

    var cwd:String;

    public function new(args:Array<String>, cwd:String) {

        this.args = args;
        this.cwd = cwd;

    } //new

    public function run():Void {

        if (args.length < 2) {
            println("Usage: haxelib run bind objc SomeHeaderFile.h");
            return;
        }

        // Extract options
        var options = {
            json: false,
            parseOnly: false,
            pretty: false
        };
        var bindClassOptions:Dynamic = {};
        var fileArgs = [];
        var i = 1;
        while (i < args.length) {

            var arg = args[i];

            if (arg.startsWith('--')) {
                if (arg == '--json') options.json = true;
                if (arg == '--parse-only') options.parseOnly = true;
                if (arg == '--pretty') options.pretty = true;
                if (arg == '--namespace') {
                    i++;
                    bindClassOptions.namespace = args[i];
                }
            }
            else {
                fileArgs.push(arg);
            }

            i++;
        }

        var kind = args[0];
        var json = [];
        var output = '';

        // Parse
        if (kind == 'objc') {

            for (i in 0...fileArgs.length) {
                var file = fileArgs[i];

                var path = Path.isAbsolute(file) ? file : Path.join([cwd, file]);
                var code = File.getContent(path);

                var ctx = {i: 0, types: new Map()};
                var result = null;
                while ((result = bind.objc.Parse.parseClass(code, ctx)) != null) {
                    result.path = path;

                    if (options.json) {
                        if (options.parseOnly) {
                            json.push(bind.Json.stringify(result, options.pretty));
                        }
                        else {
                            for (entry in bind.objc.Bind.bindClass(result)) {
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
                                output += entry.content + "\n";
                                output += '-- END ' + entry.path + " --\n";
                            }
                        }
                    }
                }
            }
        }

        if (options.json) {
            if (options.pretty) {
                println('['+json.join(',\n')+']');
            } else {
                println('['+json.join(',')+']');
            }
        }
        else {
            if (output.trim() != '') {
                println(output.rtrim());
            }
        }

    } //run

} //Cli
