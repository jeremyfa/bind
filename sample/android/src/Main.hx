package;

import android.AppAndroidInterface;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        testAndroid(function() {});

    } //main

    static function testAndroid(done:Void->Void):Void {

        Sys.println(' -- TEST ANDROID --');

        // Get native inferface
        var nativeAndroid = AppAndroidInterface.sharedInterface();

        // Print Android version
        trace('Android versionString: ' + nativeAndroid.androidVersionString());
        trace('Android versionNumber: ' + nativeAndroid.androidVersionNumber());

        // Test various types
        var aBool = true;
        var anInt = 21;
        var aFloat = 451.1;
        var anArray:Array<Dynamic> = ['Once', null, 1, 'time', false];
        var aMap = {
            key1: 'value1',
            key2: 2,
            key3: true,
            key4: -65.76,
            key5: null
        };
        var result = nativeAndroid.testTypes(aBool, anInt, aFloat, anArray, aMap);
        trace('Result on Haxe side: ' + result);

        nativeAndroid.hello('Jérémy', function() {
            trace('-- called back haxe from java --');
            done();
        });

    } //testAndroid

} //Main
