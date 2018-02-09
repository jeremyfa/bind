#!/bin/sh
$ANDROID_HOME/platform-tools/adb logcat | $ANDROID_NDK_HOME/ndk-stack -sym project.android/app/src/main/jniLibs/armeabi-v7a
        