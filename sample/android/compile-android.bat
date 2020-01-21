@ECHO OFF
cd /d %~dp0
cd bin

REM Build an Android debug binary on required architectures (may take a while the first time)
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARMV7 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARM64 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_ARMV5 -Ddebug
haxelib run hxcpp Build.xml -DHXCPP_CPP11 -DHXCPP_CLANG -Dandroid -DHXCPP_X86 -Ddebug

cd ..

SET jni_dir=project.android\app\src\main\jniLibs
IF NOT EXIST %jni_dir%\armeabi ( mkdir  %jni_dir%\armeabi)
copy /Y/B bin\libMain-debug.so %jni_dir%\armeabi\libMain.so
IF NOT EXIST %jni_dir%\armeabi-v7a ( mkdir  %jni_dir%\armeabi-v7a)
copy /Y/B bin\libMain-debug-v7.so %jni_dir%\armeabi-v7a\libMain.so
IF NOT EXIST %jni_dir%\arm64-v8a ( mkdir  %jni_dir%\arm64-v8a)
copy /Y/B bin\libMain-debug-64.so %jni_dir%\arm64-v8a\libMain.so
IF NOT EXIST %jni_dir%\x86 ( mkdir  %jni_dir%\x86)
copy /Y/B bin\libMain-debug-x86.so %jni_dir%\x86\libMain.so