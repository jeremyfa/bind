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

}
