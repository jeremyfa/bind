package;

import haxe.io.Path;

class Run {

    public static function main():Void {

        var code = 0;

        // Build cli if needed
        if (!sys.FileSystem.exists(Path.join([Sys.getCwd(), 'cpp/Main']))) {
            code = Sys.command('haxe', [Path.join([Sys.getCwd(), 'cli.hxml'])]);
            if (code != 0) Sys.exit(code);
        }

        // Run cli with c++
        var cmd = Path.join([Sys.getCwd(), 'cpp/Main']);
        var args = Sys.args();
        code = Sys.command(cmd, args);
        if (code != 0) Sys.exit(code);

    } //main

} //Run
