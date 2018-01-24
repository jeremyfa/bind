#!/bin/bash
cd "${0%/*}"

# Generate Haxe inferface from Objective-C header
haxelib run bind objc project.ios/IosSample/AppNativeInterface.h --namespace ios --package ios --export src --cwd $(pwd)
