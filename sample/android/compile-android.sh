#!/bin/bash
cd "${0%/*}"
cd bin

# Build an Android debug binary on required architectures (may take a while the first time)
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARMV7 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARM64 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARMV5 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_X86 -Ddebug

cd ..

# Copy Android binaries to the correct location
jni_dir="project.android/app/src/main/jniLibs"
if [ ! -d "$jni_dir/armeabi" ]; then mkdir -p "$jni_dir/armeabi"; fi
cp -f bin/libMain-debug.so "$jni_dir/armeabi/libMain.so"
if [ ! -d "$jni_dir/armeabi-v7a" ]; then mkdir -p "$jni_dir/armeabi-v7a"; fi
cp -f bin/libMain-debug-v7.so "$jni_dir/armeabi-v7a/libMain.so"
if [ ! -d "$jni_dir/arm64-v8a" ]; then mkdir -p "$jni_dir/arm64-v8a"; fi
cp -f bin/libMain-debug-64.so "$jni_dir/arm64-v8a/libMain.so"
if [ ! -d "$jni_dir/x86" ]; then mkdir -p "$jni_dir/x86"; fi
cp -f bin/libMain-debug-x86.so "$jni_dir/x86/libMain.so"
