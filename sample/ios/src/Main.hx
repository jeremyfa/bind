package;

import ios.AppNativeInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        Sys.println('Hello From Haxe');

        // Display a native iOS Dialog
        var native = AppNativeInterface.sharedInterface();
        native.lastName = 'Doe';
        native.hello('John');

    } //main

} //Main
