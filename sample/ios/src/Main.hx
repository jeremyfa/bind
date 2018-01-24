package;

import ios.AppNativeInterface;
import ios.AppSwiftInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        testObjc();

        testSwift();

    } //main

    static function testObjc():Void {

        // Get native inferface
        var nativeObjc = AppNativeInterface.sharedInterface();

        // Wait until root view controller is visible
        nativeObjc.viewDidAppear = function() {
            trace('viewDidAppear()');

            // Display native iOS dialog
            nativeObjc.lastName = 'Doe';
            nativeObjc.hello('John');
        };

    } //testObjc

    static function testSwift():Void {

        // Get native inferface
        var nativeSwift = new AppSwiftInterface().init();

        // Call native swift
        nativeSwift.lastName = 'Swift';
        nativeSwift.helloSwift('Taylor');

    } //testSwift

} //Main
