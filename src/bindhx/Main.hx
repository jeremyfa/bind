package bindhx;

using StringTools;

class Main {

    public static function main():Void {

        #if nodejs
        // Better source map support for node
        var sourceMapSupport:Dynamic = js.Node.require('source-map-support');
        sourceMapSupport.install();
        #end

        var args:Array<String> = args();
        var cwd = args.pop();

        new bindhx.Cli(cast args, cwd).run();

    }

    static function args():Array<String> {

        var args = [].concat(Sys.args());
        return args;

    }

}
