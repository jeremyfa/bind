package yourcompany.androidsample;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Handler;
import android.util.Log;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import bind.Support.*;

/**
 * Java/Android interface
 */
public class AppAndroidInterface {

    static final String TAG = "AppJavaInterface";

    static AppAndroidInterface sSharedInterface = null;

    /**
     * Android Context
     */
    public static Context context = null;

    /**
     * Get shared instance
     */
    public static AppAndroidInterface sharedInterface() {

        if (sSharedInterface == null) sSharedInterface = new AppAndroidInterface();

        return sSharedInterface;

    } //sharedInterface

    /** Constructor */
    public AppAndroidInterface() {

    } //SharedInterface

    /**
     * If provided, will be called when main activity is started/resumed
     */
    public Func1<Boolean,Void> onResume = null;

    /**
     * Define a last name for hello()
     */
    public String lastName = null;

    /**
     * Say hello to `name` with a native Android dialog. Add a last name if any is known.
     */
    public void hello(String name, final Runnable done) {

        String sentence = "Hello " + name;

        if (lastName != null) {
            sentence += " " + lastName;
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Native Android")
                .setMessage(sentence)
                .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // Pressed OK
                        if (done != null) done.run();
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();

    } //hello

    public String callbackTest(final Func2<List<String>,String,Float> callback) {

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                float result = callback.run(Arrays.asList("a", "b", "c", "d"), "test");
            }
        }, 1000);

        return "wait 1 second.";

    } //callbackTest

    /**
     * Get Android version string
     */
    public String androidVersionString() {

        return Build.VERSION.RELEASE;

    } //androidVersionString

    /**
     * Get Android version number
     */
    public int androidVersionNumber() {

        return Build.VERSION.SDK_INT;

    } //androidVersionNumber

    /**
     * Dummy method to get Haxe types converted to Java types that then get returned back as an array.
     */
    public List<Object> testTypes(boolean aBool, int anInt, float aFloat, List<Object> aList, Map <String, Object> aMap) {

        Log.i(TAG, "Java types:");
        Log.i(TAG, "  Bool: " + aBool);
        Log.i(TAG, "  Int: " + anInt);
        Log.i(TAG, "  Float: " + aFloat);
        Log.i(TAG, "  List: " + aList);
        Log.i(TAG, "  Map: " + aMap);

        return Arrays.asList(
                aBool,
                anInt,
                aFloat,
                aList,
                aMap
        );

    } //testTypes

}
