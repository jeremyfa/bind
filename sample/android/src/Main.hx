package;

import android.AppAndroidInterface;
import bindhx.java.Support;

class Main {

    public static function main():Void {

        // Print something from Haxe
        trace('Hello From Haxe');

        testAndroid();

    }

    static function testAndroid():Void {

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

        nativeAndroid.lastName = 'Java';
        trace('Did set last name to: Java, will say hello');
        nativeAndroid.hello('Dansons la', function() {
            // Done
            trace('Java done.');
        });

        trace('Will set onPause');
        // Add some callback when app gets paused/resumed
        nativeAndroid.onPause = function() {
            trace('Activity.onPause');
        };
        trace('Will set onResume');
        nativeAndroid.onResume = function() {
            trace('Activity.onResume');
        };

    }

}
