package bind;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import bind.Support.*;

import yourcompany.androidsample.AppAndroidInterface;

public class bind_AppAndroidInterface {

    private static class Result_ {
        Object value = null;
    }

    private static Handler sHandler_ = null;

    public static Object context() {
        if (Looper.getMainLooper().getThread() == Thread.currentThread()) {
            return AppAndroidInterface.context;
        }
        else {
            Object lock_ = new Object();
            final Result_ result_ = new Result_();
            if (sHandler_ == null) sHandler_ = new Handler(Looper.getMainLooper());
            sHandler_.post(new Runnable() {
                public void run() {
                    result_.value = AppAndroidInterface.context;
                }
            });
            try {
                lock_.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return result_.value;
        }
    }

    public static void setContext(Object context) {
        AppAndroidInterface.context = (Context)context;
    }

} //bind_AppAndroidInterface

