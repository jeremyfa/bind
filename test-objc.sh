#!/bin/bash
cd "${0%/*}"

haxe run.hxml
haxelib run bind objc sample/ios/project.ios/IosSample/AppNativeInterface.h --json --pretty --parse-only
