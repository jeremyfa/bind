#!/bin/bash

haxe run.hxml
haxelib run bind-dev objc sample/ios/project.ios/IosSample/AppNativeInterface.h --json --pretty --parse-only
