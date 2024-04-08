package;

import ios.AppNativeInterface;
import ios.AppSwiftInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        // Test Objective-C interface
        testObjc(function() {

            // Then test Swift interface
            testSwift();
        });

    }

    static function testObjc(done:Void->Void):Void {

        Sys.println(' -- TEST OBJC --');

        // Get native inferface
        var nativeObjc = AppNativeInterface.sharedInterface();

        // Print iOS version
        trace('IOS versionString: ' + nativeObjc.iosVersionString());
        trace('IOS versionNumber: ' + nativeObjc.iosVersionNumber());

        // Test various types
        var aBool = true;
        var anInt = 21;
        var aFloat = 451.1;
        var anArray:Array<Dynamic> = ['Once', null, 1, 'time', false];
        var aDict = {
            key1: 'value1',
            key2: 2,
            key3: true,
            key4: -65.76,
            key5: null
        };
        var result = nativeObjc.testTypes(aBool, anInt, aFloat, anArray, aDict);
        trace('Result on Haxe side: ' + result);

        // Wait until root view controller is visible
        nativeObjc.viewDidAppear = function(animated) {
            trace('viewDidAppear(animated=$animated)');

            // Display native iOS dialog
            nativeObjc.lastName = 'Doe';
            nativeObjc.hello('John', function() {
                trace('Objc done, continue with Swift test..');
                done();
            });
        };

    }

    static function testSwift():Void {

        Sys.println(' -- TEST SWIFT --');

        // Get native inferface
        // Could be used as well (creates a new instance):
        //     var nativeSwift = new AppSwiftInterface().init();
        var nativeSwift = AppSwiftInterface.sharedInterface;

        // Print iOS version
        trace('IOS versionString: ' + nativeSwift.iosVersionString());
        trace('IOS versionNumber: ' + nativeSwift.iosVersionNumber());

        // Test various types
        var aBool = true;
        var anInt = 21;
        var aFloat = 451.1;
        var anArray:Array<Dynamic> = ['Once', null, 1, 'time', false];
        var aDict = {
            key1: 'value1',
            key2: 2,
            key3: true,
            key4: -65.76,
            key5: null
        };
        var result = nativeSwift.testTypes(aBool, anInt, aFloat, anArray, aDict);
        trace('Result on Haxe side: ' + result);

        // Call native swift
        nativeSwift.lastName = 'Swift';
        nativeSwift.hello('Taylor', function() {
            // Done
            trace('Swift done.');
        });

    }

}
