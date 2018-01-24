#!/bin/bash
cd "${0%/*}"
cd bin

# Build an iOS debug binary on required architectures (may take a while the first time)
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Diphoneos -DHXCPP_ARMV7 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Diphoneos -DHXCPP_ARM64 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Diphonesim -Dsimulator -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Diphonesim -Dsimulator -DHXCPP_M64 -Ddebug

# Combine architectures
xcrun -sdk iphoneos lipo -output libMain.a -create libMain-debug.iphoneos-v7.a libMain-debug.iphoneos-64.a libMain-debug.iphonesim.a libMain-debug.iphonesim-64.a

cd ..