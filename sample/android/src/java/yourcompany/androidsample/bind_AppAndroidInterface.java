package yourcompany.androidsample;
// This file was generated with bind library

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

/** Java/Android interface */
@SuppressWarnings("all")
class bind_AppAndroidInterface {

    private static class bind_Result {
        Object value = null;
    }

    /** Get shared instance */
    public static AppAndroidInterface sharedInterface() {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.sharedInterface();
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (AppAndroidInterface) _bind_result.value;
        } else {
            final AppAndroidInterface return_java_ = AppAndroidInterface.sharedInterface();
            final AppAndroidInterface return_jni_ = (AppAndroidInterface) return_java_;
            return return_jni_;
        }
    }

    /** Constructor */
    public static AppAndroidInterface constructor() {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.constructor();
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (AppAndroidInterface) _bind_result.value;
        } else {
            final AppAndroidInterface return_java_ = new AppAndroidInterface();
            return return_java_;
        }
    }

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public static void hello(final AppAndroidInterface _instance, final String name, final long done) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.hello(_instance, name, done);
                }
            });
        } else {
            final String name_java_ = name;
            final HaxeObject done_java_hobj_ = done == 0 ? null : new HaxeObject(done);
            final Runnable done_java_ = done == 0 ? null : new Runnable() {
                public void run() {
                    bind.Support.runInNativeThread(new Runnable() {
                        public void run() {
                            callN_Void(done_java_hobj_.address);
                        }
                    });
                }
            };
            _instance.hello(name_java_, done_java_);
        }
    }

    /** hello */
    public static String callbackTest(final AppAndroidInterface _instance, final long callback) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.callbackTest(_instance, callback);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            final HaxeObject callback_java_hobj_ = callback == 0 ? null : new HaxeObject(callback);
            final Func2<List<String>,String,Float> callback_java_ = callback == 0 ? null : new Func2<List<String>,String,Float>() {
                public Float run(final List<String> arg1, final String arg2) {
                    final String arg1_jni_ = bind.Support.toJSONString(arg1);
                    final String arg2_jni_ = arg2;
                    final BindResult return_jni_result_ = new BindResult();
                    bind.Support.runInNativeThreadSync(new Runnable() {
                        public void run() {
                            return_jni_result_.value = callN_ListStringFloat(callback_java_hobj_.address, arg1_jni_, arg2_jni_);
                        }
                    });
                    float return_jni_ = (float) return_jni_result_.value;
                    final Float return_java_ = return_jni_;
                    return return_java_;
                }
            };
            final String return_java_ = _instance.callbackTest(callback_java_);
            final String return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Get Android version string */
    public static String androidVersionString(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.androidVersionString(_instance);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            final String return_java_ = _instance.androidVersionString();
            final String return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Get Android version number */
    public static int androidVersionNumber(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.androidVersionNumber(_instance);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (int) _bind_result.value;
        } else {
            final int return_java_ = _instance.androidVersionNumber();
            final int return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    public static String testTypes(final AppAndroidInterface _instance, final int aBool, final int anInt, final float aFloat, final String aList, final String aMap) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.testTypes(_instance, aBool, anInt, aFloat, aList, aMap);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            final boolean aBool_java_ = aBool != 0;
            final int anInt_java_ = anInt;
            final float aFloat_java_ = aFloat;
            final List<Object> aList_java_ = (List<Object>) bind.Support.fromJSONString(aList);
            final Map<String,Object> aMap_java_ = (Map<String,Object>) bind.Support.fromJSONString(aMap);
            final List<Object> return_java_ = _instance.testTypes(aBool_java_, anInt_java_, aFloat_java_, aList_java_, aMap_java_);
            final String return_jni_ = bind.Support.toJSONString(return_java_);
            return return_jni_;
        }
    }

    /** Android Context */
    public static Object getContext() {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.getContext();
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (Object) _bind_result.value;
        } else {
            final Context return_java_ = AppAndroidInterface.context;
            final Object return_jni_ = (Object) return_java_;
            return return_jni_;
        }
    }

    /** Android Context */
    public static void setContext(final Object context) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.setContext(context);
                }
            });
        } else {
            final Context context_java_ = (Context) context;
            AppAndroidInterface.context = context_java_;
        }
    }

    /** If provided, will be called when main activity is started/resumed */
    public static Object getOnResume(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.getOnResume(_instance);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (Object) _bind_result.value;
        } else {
            final Object return_java_ = _instance.onResume;
            final Object return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** If provided, will be called when main activity is started/resumed */
    public static void setOnResume(final AppAndroidInterface _instance, final long onResume) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.setOnResume(_instance, onResume);
                }
            });
        } else {
            final HaxeObject onResume_java_hobj_ = onResume == 0 ? null : new HaxeObject(onResume);
            final Func1<Boolean,Void> onResume_java_ = onResume == 0 ? null : new Func1<Boolean,Void>() {
                public Void run(final Boolean arg1) {
                    final int arg1_jni_ = arg1 ? 1 : 0;
                    bind.Support.runInNativeThread(new Runnable() {
                        public void run() {
                            callN_BooleanVoid(onResume_java_hobj_.address, arg1_jni_);
                        }
                    });
                    return null;
                }
            };
            _instance.onResume = onResume_java_;
        }
    }

    public static Object getOnDone1(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.getOnDone1(_instance);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (Object) _bind_result.value;
        } else {
            final Object return_java_ = _instance.onDone1;
            final Object return_jni_ = return_java_;
            return return_jni_;
        }
    }

    public static void setOnDone1(final AppAndroidInterface _instance, final long onDone1) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.setOnDone1(_instance, onDone1);
                }
            });
        } else {
            final HaxeObject onDone1_java_hobj_ = onDone1 == 0 ? null : new HaxeObject(onDone1);
            final Runnable onDone1_java_ = onDone1 == 0 ? null : new Runnable() {
                public void run() {
                    bind.Support.runInNativeThread(new Runnable() {
                        public void run() {
                            callN_Void(onDone1_java_hobj_.address);
                        }
                    });
                }
            };
            _instance.onDone1 = onDone1_java_;
        }
    }

    /** Define a last name for hello() */
    public static String getLastName(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    synchronized(_bind_result) {
                        try {
                            _bind_result.value = bind_AppAndroidInterface.getLastName(_instance);
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                        _bind_result.resolved = true;
                        _bind_result.notifyAll();
                    }
                }
            });
            synchronized(_bind_result) {
                if (!_bind_result.resolved) {
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            final String return_java_ = _instance.lastName;
            final String return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Define a last name for hello() */
    public static void setLastName(final AppAndroidInterface _instance, final String lastName) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.setLastName(_instance, lastName);
                }
            });
        } else {
            final String lastName_java_ = lastName;
            _instance.lastName = lastName_java_;
        }
    }

    public static void callJ_BooleanVoid(final Func1<Boolean,Void> _callback, final int arg1) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.callJ_BooleanVoid(_callback, arg1);
                }
            });
        } else {
            final Boolean arg1_java_ = arg1 != 0;
            _callback.run(arg1_java_);
        }
    }

    public static void callJ_Void(final Object _callback) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.callJ_Void(_callback);
                }
            });
        } else {
            Runnable _callback_runnable = null;
            if (_callback instanceof Func0) {
                final Func0<Void> _callback_func0 = (Func0<Void>) _callback;
                _callback_runnable = new Runnable() {
                    public void run() {
                        _callback_func0.run();
                    }
                };
            } else {
                _callback_runnable = (Runnable) _callback;
            }
            _callback_runnable.run();
        }
    }

    static native void callN_Void(long address);

    static native float callN_ListStringFloat(long address, String arg1, String arg2);

    static native void callN_BooleanVoid(long address, int arg1);

}

