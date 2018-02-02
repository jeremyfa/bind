package org.haxe;

/**
 * Created by jeremyfa on 30/01/2018.
 */

public class HXCPP {

    private static boolean sInit = false;

    public static native void main();

    public static void run(String inClassName) {

        // Load binary
        System.loadLibrary(inClassName);

        // Init bindings
        bind.Support.init();

        // Start haxe
        if (!sInit) {
            sInit = true;
            main();
        }
    }
}
