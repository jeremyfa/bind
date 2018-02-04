package yourcompany.androidsample;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import org.haxe.HXCPP;

public class MainActivity extends AppCompatActivity {

    static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Set correct android context
        AppAndroidInterface.context = this;

        // Start Haxe
        HXCPP.run("Main");
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
