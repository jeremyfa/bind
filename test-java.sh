#!/bin/bash
cd "${0%/*}"

haxe run.hxml
haxelib run bind java sample/android/project.android/app/src/main/java/yourcompany/androidsample/AppAndroidInterface.java --json --pretty --parse-only
