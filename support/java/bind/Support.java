package bind;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Java support file for bind.
 */
@SuppressWarnings("unchecked,unused,WeakerAccess")
public class Support {

/// Function types

    public interface Func0<T> {

        T run();

    } //Func0

    public interface Func1<A1,T> {

        T run(A1 arg1);

    } //Func1

    public interface Func2<A1,A2,T> {

        T run(A1 arg1, A2 arg2);

    } //Func2

    public interface Func3<A1,A2,A3,T> {

        T run(A1 arg1, A2 arg2, A3 arg3);

    } //Func3

    public interface Func4<A1,A2,A3,A4,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4);

    } //Func4

    public interface Func5<A1,A2,A3,A4,A5,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5);

    } //Func5

    public interface Func6<A1,A2,A3,A4,A5,A6,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6);

    } //Func6

    public interface Func7<A1,A2,A3,A4,A5,A6,A7,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7);

    } //Func7

    public interface Func8<A1,A2,A3,A4,A5,A6,A7,A8,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8);

    } //Func8

    public interface Func9<A1,A2,A3,A4,A5,A6,A7,A8,A9,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8, A9 arg9);

    } //Func9

/// Android context

    private static Object sContext = null;

    public static void setContext(Context context) {
        sContext = context;
    }

    public static Context getContext() {
        if (sContext == null) return null;
        return (Context) sContext;
    }

/// Initialize

    public static void init() {

        nativeInit();

    } //init

/// Native calls

    /** Utility to let java side notify native (haxe) side that it is ready and can call JNI stuff.
        This is not always necessary and is just a convenience when the setup requires it. */
    public static native void notifyReady();

    static native void nativeInit();

    static native void releaseHaxeObject(String address);

/// Helpers for native

    public static class HaxeObject {

        public String address;

        public HaxeObject(String address) {
            this.address = address;
        }

        @Override
        protected void finalize() throws Throwable {

            try {
                // TODO use ReferenceQueue/PhantomReferences instead of finalize()
                // (but it's ok as is for now)
                Support.notifyFinalize(address);
            }
            finally {
                super.finalize();
            }

        }

    } //HaxeObject

    static void notifyFinalize(final String address) {

        runInNativeThread(new Runnable() {
            public void run() {
                Support.releaseHaxeObject(address);
            }
        });

    } //notifyFinalize

/// Converters

    public static String toJSONString(Object value) {

        if (value == null) return null;
        return toJSONValue(value).toString();

    } //toJSONString

    public static Object toJSONValue(Object value) {

        if (value == null) return null;
        if (value instanceof List) {
            return toJSONArray((List<Object>)value);
        }
        else if (value instanceof Map) {
            return toJSONObject((Map<String,Object>)value);
        }
        else {
            return value;
        }

    } //toJSONValue

    public static JSONObject toJSONObject(Map<String,Object> map) {

        if (map == null) return null;
        try {
            JSONObject json = new JSONObject();

            for (String key : map.keySet()) {
                json.put(key, toJSONValue(map.get(key)));
            }

            return json;

        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

    } //toJSONObject

    public static JSONArray toJSONArray(List<Object> list) {

        if (list == null) return null;

        JSONArray json = new JSONArray();

        for (Object value : list) {
            json.put(toJSONValue(value));
        }

        return json;

    } //toJSONArray

    public static Object fromJSONObject(JSONObject json) {

        try {
            Map<String,Object> map = new HashMap<>();
            Iterator<String> keys = json.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = json.get(key);
                if (value instanceof JSONArray) {
                    map.put(key, fromJSONArray((JSONArray)value));
                }
                else if (value instanceof JSONObject) {
                    map.put(key, fromJSONObject((JSONObject)value));
                }
                else {
                    map.put(key, value);
                }
            }
            return map;

        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

    } //fromJSONObject

    public static List<Object> fromJSONArray(JSONArray json) {

        try {
            int len = json.length();
            List<Object> list = new ArrayList<>(len);
            for (int i = 0; i < len; i++) {
                Object value = json.get(i);
                if (value instanceof JSONArray) {
                    list.add(fromJSONArray((JSONArray)value));
                }
                else if (value instanceof JSONObject) {
                    list.add(fromJSONObject((JSONObject)value));
                }
                else {
                    list.add(value);
                }
            }
            return list;

        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

    } //fromJSONArray

    public static Object fromJSONString(String jsonString) {

        try {
            if (jsonString == null) return null;
            if (jsonString.length() == 0) return null;
            if (jsonString.charAt(0) == '[') {
                return fromJSONArray(new JSONArray(jsonString));
            }
            return fromJSONObject(new JSONObject(jsonString));

        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

    } //fromJSONString

/// Thread safety

    public static class BindResult {

        public Object value = null;

        public boolean resolved = false;

    } //BindResult

    public static void runInNativeThread(Runnable r) {

        if (sUseNativeRunnableStack) {
            pushNativeRunnable(r);
        }
        else if (sGLSurfaceView != null) {
            ((GLSurfaceView)sGLSurfaceView).queueEvent(r);
        }
        else if (sNativeThreadHandler != null) {
            if (sNativeThreadHandler.getLooper().getThread() != Thread.currentThread()) {
                sNativeThreadHandler.post(r);
            } else {
                r.run();
            }
        }
        else {
            runInUIThread(r);
        }

    } //runInNativeThread

    public static void runInNativeThreadSync(final Runnable r) {

        if (!isNativeThread()) {
            final BindResult result = new BindResult();
            runInNativeThread(new Runnable() {
                @Override
                public void run() {
                    synchronized(result) {
                        r.run();
                        result.resolved = true;
                        result.notifyAll();
                    }
                }
            });
            synchronized(result) {
                if (!result.resolved) {
                    try {
                        result.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        else {
            r.run();
        }

    } //runInNativeThreadSync

    public static void runInUIThread(Runnable r) {

        if (!isUIThread()) {
            getUIThreadHandler().post(r);
        }
        else {
            r.run();
        }

    } //runInUIThread

    public static void runInUIThreadSync(final Runnable r) {

        if (!isUIThread()) {
            final BindResult result = new BindResult();
            sUIThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    synchronized(result) {
                        r.run();
                        result.resolved = true;
                        result.notifyAll();
                    }
                }
            });
            synchronized(result) {
                if (!result.resolved) {
                    try {
                        result.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        else {
            r.run();
        }

    } //runInUIThreadSync

    /**
     * If set to `true`, native side will take care of executing
     * Runnable instances that need to be run in native thread.
     */
    static boolean sUseNativeRunnableStack = false;
    static List<Runnable> sNativeRunnables = new ArrayList<>();
    static volatile Thread sNativeRunnableStackThread = null;

    public static void setUseNativeRunnableStack(boolean value) {
        sUseNativeRunnableStack = value;
        sNativeRunnableStackThread = null;
    }

    public static boolean isUseNativeRunnableStack() {
        return sUseNativeRunnableStack;
    }

    static void pushNativeRunnable(final Runnable r) {

        synchronized (sNativeRunnables) {
            sNativeRunnables.add(r);
            nativeSetHasRunnables(1);
        }

    } //pushNativeRunnable

    /** Inform native/JNI that some Runnable instances are waiting to be run frpù native thread. */
    static native void nativeSetHasRunnables(int value);

    /** Called by native/JNI to run a Runnable from its thread */
    public static void runAwaitingNativeRunnables() {

        synchronized (sNativeRunnables) {
            if (sNativeRunnableStackThread == null) sNativeRunnableStackThread = Thread.currentThread();
            nativeSetHasRunnables(0);
            List<Runnable> toRun = sNativeRunnables;
            sNativeRunnables = new ArrayList<>();
            for (Runnable r : toRun) {
                r.run();
            }
        }

    } //runRunnable

    /**
     * If provided, calls to JNI will be done on this GLSurfaceView's renderer thread.
     */
    static Object sGLSurfaceView = null;
    static volatile Thread sGLSurfaceViewThread = null;

    public static GLSurfaceView getGLSurfaceView() {
        return (GLSurfaceView) sGLSurfaceView;
    }

    public static void setGLSurfaceView(GLSurfaceView surfaceView) {
        sGLSurfaceView = surfaceView;
        sGLSurfaceViewThread = null;
        if (sGLSurfaceView != null) {
            ((GLSurfaceView)sGLSurfaceView).queueEvent(new Runnable() {
                @Override
                public void run() {
                    sGLSurfaceViewThread = Thread.currentThread();
                }
            });
        }
    }

    /**
     * If provided, calls to JNI/Native will be done on this Handler's thread.
     * Ignored if a GLSurfaceView instance is defined instead.
     */
    static Handler sNativeThreadHandler = null;

    public static Handler getNativeThreadHandler() {
        return sNativeThreadHandler;
    }

    public static void setNativeThreadHandler(Handler handler) {
        sNativeThreadHandler = handler;
    }

    /** Android/UI thread handler. */
    static Handler sUIThreadHandler = null;

    public static Handler getUIThreadHandler() {
        if (sUIThreadHandler == null) sUIThreadHandler = new Handler(Looper.getMainLooper());
        return sUIThreadHandler;
    }

    public static boolean isUIThread() {
        return Looper.getMainLooper().getThread() == Thread.currentThread();
    }

    public static boolean isNativeThread() {
        if (sUseNativeRunnableStack) {
            if (sNativeRunnableStackThread != null) return !isUIThread();
            return sNativeRunnableStackThread == Thread.currentThread();
        }
        else if (sGLSurfaceView != null) {
            if (sGLSurfaceViewThread != null) return !isUIThread();
            return sGLSurfaceViewThread == Thread.currentThread();
        }
        else if (sNativeThreadHandler != null) {
            return sNativeThreadHandler.getLooper().getThread() == Thread.currentThread();
        }
        else {
            return isUIThread();
        }
    }

} //Support
