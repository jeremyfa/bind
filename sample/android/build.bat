@ECHO OFF
cd /d %~dp0

REM Bind Java code to Haxe
bind-java.bat

REM Build Haxe code
haxe build.hxml

REM Compile Android binaries
compile-android.bat