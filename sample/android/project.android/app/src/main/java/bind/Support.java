package bind;

import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONStringer;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Java support file for bind.
 */
@SuppressWarnings("unchecked")
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

    public interface Func3<A1,A2,A3,A4,A5,A6,A7,A8,A9,T> {

        T run(A1 arg1, A2 arg2, A3 arg3, A4 arg4, A5 arg5, A6 arg6, A7 arg7, A8 arg8, A9 arg9);

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

/// Native init

    public static native void init();

/// Helpers for native

    private static class TrackedJavaObject {

        int mObjectId;

        public TrackedJavaObject(int objectId) {
            mObjectId = objectId;
        }

        @Override
        protected void finalize() throws Throwable {

            // TODO use ReferenceQueue/PhantomReferences instead of finalize()
            Support.notifyFinalize(mObjectId);

            super.finalize();
        }

    } //TrackedJavaObject

    static Object sTrackObjectLock = null;

    static int sNextJavaObjectId = 0;

    public static Object trackNewJavaObject() {

        if (sTrackObjectLock == null) sTrackObjectLock = new Object();

        synchronized (sTrackObjectLock) {
            return new TrackedJavaObject(++sNextJavaObjectId);
        }

    } //trackNewJavaObject

    static void notifyFinalize(final int objectId) {

        runInNativeThread(new Runnable() {
            public void run() {
                javaObjectDidFinalize(objectId);
            }
        });

    } //notifyFinalize

    static native void javaObjectDidFinalize(int objectId);

/// Converters

    public static String toJSONString(Object value) {

        if (value == null) return null;
        return toJSONValue(value).toString();

    } //toJSONString

    public static Object toJSONValue(Object value) {

        if (value == null) return null;
        if (value instanceof List) {
            return toJSONArray((List<Object>)value).toString();
        }
        else if (value instanceof Map) {
            return toJSONObject((Map<String,Object>)value).toString();
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

    public static void runInNativeThread(Runnable r) {

        if (sGLSurfaceView != null) {
            sGLSurfaceView.queueEvent(r);
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

    public static void runInUIThread(Runnable r) {

        if (!isUIThread()) {
            sUIThreadHandler.post(r);
        }
        else {
            r.run();
        }

    } //runInUIThread

    /**
     * If provided, calls to JNI will be done on this GLSurfaceView's renderer thread.
     */
    static GLSurfaceView sGLSurfaceView = null;

    public static GLSurfaceView getGLSurfaceView() {
        return sGLSurfaceView;
    }

    public static void setGLSurfaceView(GLSurfaceView surfaceView) {
        sGLSurfaceView = surfaceView;
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
        return Looper.getMainLooper().getThread() != Thread.currentThread();
    }

} //Support
