package;

import android.AppAndroidInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        var nativeAndroid = AppAndroidInterface.sharedInterface();

        trace('Got shared interface!');

        nativeAndroid.hello('Jérémy', null);

    } //main

} //Main
