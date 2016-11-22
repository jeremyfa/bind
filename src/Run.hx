package;

import haxe.io.Path;

class Run {

    public static function main():Void {

        var code = 0;

        if (Sys.args().indexOf('--nodejs') != -1) {
            // Run cli with node.js

            // Build and install required node modules if needed
            if (!sys.FileSystem.exists(Path.join([Sys.getCwd(), 'index.js']))) {
                code = Sys.command('haxe', [Path.join([Sys.getCwd(), 'cli-nodejs.hxml'])]);
                if (code != 0) Sys.exit(code);
                code = Sys.command('npm', ['install']);
                if (code != 0) Sys.exit(code);
            }

            // Run
            var cmd = 'node';
            var args = [Path.join([Sys.getCwd(), 'index.js'])];
            for (arg in Sys.args()) {
                if (arg != '--nodejs') {
                    args.push(arg);
                }
            }
            code = Sys.command(cmd, args);
            if (code != 0) Sys.exit(code);
        }
        else {
            // Run cli with c++
            //

            // Build if needed
            if (!sys.FileSystem.exists(Path.join([Sys.getCwd(), 'cpp/Main']))) {
                code = Sys.command('haxe', [Path.join([Sys.getCwd(), 'cli-cpp.hxml'])]);
                if (code != 0) Sys.exit(code);
            }

            // Run
            var cmd = Path.join([Sys.getCwd(), 'cpp/Main']);
            var args = Sys.args();
            code = Sys.command(cmd, args);
            if (code != 0) Sys.exit(code);
        }


    } //main

} //Run
