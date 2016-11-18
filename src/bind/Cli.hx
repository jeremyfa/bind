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
        var fileArgs = [];
        for (i in 1...args.length) {
            var arg = args[i];
            if (arg.startsWith('--')) {
                if (arg == '--json') options.json = true;
                if (arg == '--parse-only') options.parseOnly = true;
                if (arg == '--pretty') options.pretty = true;
            }
            else {
                fileArgs.push(arg);
            }
        }

        var kind = args[0];
        var json = [];

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

                    if (options.json && options.parseOnly) {
                        json.push(bind.Json.stringify(result, options.pretty));
                    }

                    if (!options.parseOnly) {
                        bind.objc.Bind.bindClass(result);
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

    } //run

} //Cli
