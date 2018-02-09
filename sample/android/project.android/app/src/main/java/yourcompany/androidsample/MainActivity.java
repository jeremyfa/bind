package yourcompany.androidsample;

import android.os.Handler;
import android.os.HandlerThread;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import org.haxe.HXCPP;

import bind.Support;

public class MainActivity extends AppCompatActivity {

    static final String TAG = "MainActivity";

    /**
     * Set to `true` to run Haxe in a separate background Thread.
     * This is useful to test generated bindings cope well
     * when Haxe runs in a separate thread than main Android's UI Thread.
     */
    static final boolean HAXE_IN_BACKGROUND = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Keep android context
        bind.Support.setContext(this);

        // Start Haxe
        if (HAXE_IN_BACKGROUND) {
            HandlerThread handlerThread = new HandlerThread("HaxeThread");
            handlerThread.start();
            Handler handler = new Handler(handlerThread.getLooper());
            bind.Support.setNativeThreadHandler(handler);
            handler.post(new Runnable() {
                @Override
                public void run() {
                    Log.i(TAG, "Run Haxe in background thread (isUIThread=" + bind.Support.isUIThread() + " isNativeThread=" + bind.Support.isNativeThread() + ")");
                    HXCPP.run("Main");
                }
            });
        } else {
            Log.i(TAG, "Run Haxe in UI/Main thread (isUIThread=" + bind.Support.isUIThread() + " isNativeThread=" + bind.Support.isNativeThread() + ")");
            HXCPP.run("Main");
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        AppAndroidInterface appInterface = AppAndroidInterface.sharedInterface();
        if (appInterface.onPause != null) appInterface.onPause.run();
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();

        AppAndroidInterface appInterface = AppAndroidInterface.sharedInterface();
        if (appInterface.onResume != null) appInterface.onResume.run();
    }
}
