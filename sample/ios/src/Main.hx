package;

import ios.AppNativeInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        // Get native inferface
        var native = AppNativeInterface.sharedInterface();

        // Wait until root view controller is visible
        native.viewDidAppear = function() {
            trace('viewDidAppear()');

            // Display native iOS dialog
            native.lastName = 'Doe';
            native.hello('John');
        };

    } //main

} //Main
