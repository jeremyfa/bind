@ECHO OFF
cd /d %~dp0

REM Generate Haxe inferface from Java file
haxelib run bind java project.android/app/src/main/java/yourcompany/androidsample/AppAndroidInterface.java --namespace android --package android --export src --cwd %cd%