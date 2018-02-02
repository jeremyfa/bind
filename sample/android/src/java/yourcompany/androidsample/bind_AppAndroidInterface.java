package yourcompany.androidsample;
// This file was generated with bind library

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;
import android.util.Log;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import bind.Support.*;

/** Java/Android interface */
@SuppressWarnings("unchecked")
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
                    try {
                        _bind_result.value = bind_AppAndroidInterface.sharedInterface();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                    synchronized(_bind_result) {
                        if (_bind_result.status == 1) {
                            _bind_result.status = 2;
                            _bind_result.notify();
                        }
                    }
                }
            });
            synchronized(_bind_result) {
                if (_bind_result.status == 0) {
                    _bind_result.status = 1;
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (AppAndroidInterface) _bind_result.value;
        } else {
            AppAndroidInterface return_java_ = AppAndroidInterface.sharedInterface();
            AppAndroidInterface return_jni_ = (AppAndroidInterface) return_java_;
            return return_jni_;
        }
    }

    /** Constructor */
    public static AppAndroidInterface constructor() {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    try {
                        _bind_result.value = bind_AppAndroidInterface.constructor();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                    synchronized(_bind_result) {
                        if (_bind_result.status == 1) {
                            _bind_result.status = 2;
                            _bind_result.notify();
                        }
                    }
                }
            });
            synchronized(_bind_result) {
                if (_bind_result.status == 0) {
                    _bind_result.status = 1;
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (AppAndroidInterface) _bind_result.value;
        } else {
            AppAndroidInterface return_java_ = new AppAndroidInterface();
            return return_java_;
        }
    }

    /** Say hello to `name` with a native Android dialog. Add a last name if any is known. */
    public static void hello(final AppAndroidInterface _instance, final String name, final Object done) {
        if (!bind.Support.isUIThread()) {
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    bind_AppAndroidInterface.hello(_instance, name, done);
                }
            });
        } else {
            String name_java_ = name;
            Runnable done_java_ = null; // Not implemented yet
            _instance.hello(name_java_, done_java_);
        }
    }

    /** Get Android version string */
    public static String androidVersionString(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    try {
                        _bind_result.value = bind_AppAndroidInterface.androidVersionString(_instance);
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                    synchronized(_bind_result) {
                        if (_bind_result.status == 1) {
                            _bind_result.status = 2;
                            _bind_result.notify();
                        }
                    }
                }
            });
            synchronized(_bind_result) {
                if (_bind_result.status == 0) {
                    _bind_result.status = 1;
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            String return_java_ = _instance.androidVersionString();
            String return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Get Android version number */
    public static int androidVersionNumber(final AppAndroidInterface _instance) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    try {
                        _bind_result.value = bind_AppAndroidInterface.androidVersionNumber(_instance);
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                    synchronized(_bind_result) {
                        if (_bind_result.status == 1) {
                            _bind_result.status = 2;
                            _bind_result.notify();
                        }
                    }
                }
            });
            synchronized(_bind_result) {
                if (_bind_result.status == 0) {
                    _bind_result.status = 1;
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (int) _bind_result.value;
        } else {
            int return_java_ = _instance.androidVersionNumber();
            int return_jni_ = return_java_;
            return return_jni_;
        }
    }

    /** Dummy method to get Haxe types converted to Java types that then get returned back as an array. */
    public static String testTypes(final AppAndroidInterface _instance, final int aBool, final int anInt, final float aFloat, final String aList, final String aMap) {
        if (!bind.Support.isUIThread()) {
            final BindResult _bind_result = new BindResult();
            bind.Support.getUIThreadHandler().post(new Runnable() {
                public void run() {
                    try {
                        _bind_result.value = bind_AppAndroidInterface.testTypes(_instance, aBool, anInt, aFloat, aList, aMap);
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                    synchronized(_bind_result) {
                        if (_bind_result.status == 1) {
                            _bind_result.status = 2;
                            _bind_result.notify();
                        }
                    }
                }
            });
            synchronized(_bind_result) {
                if (_bind_result.status == 0) {
                    _bind_result.status = 1;
                    try {
                        _bind_result.wait();
                    } catch (Throwable e) {
                        e.printStackTrace();
                    }
                }
            }
            return (String) _bind_result.value;
        } else {
            boolean aBool_java_ = aBool != 0;
            int anInt_java_ = anInt;
            float aFloat_java_ = aFloat;
            List<Object> aList_java_ = (List<Object>) bind.Support.fromJSONString(aList);
            Map<String,Object> aMap_java_ = (Map<String,Object>) bind.Support.fromJSONString(aMap);
            List<Object> return_java_ = _instance.testTypes(aBool_java_, anInt_java_, aFloat_java_, aList_java_, aMap_java_);
            String return_jni_ = bind.Support.toJSONString(return_java_);
            return return_jni_;
        }
    }

}

