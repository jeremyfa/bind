#!/bin/bash
cd "${0%/*}"


### Plain Objective-C example

# Generate Haxe inferface from Objective-C header
haxelib run bind objc project.ios/IosSample/AppNativeInterface.h --namespace ios --package ios --export src --cwd $(pwd)



### Swift example

# Build Swift framework
xcodebuild -project project.ios/IosSample.xcodeproj -target IosSampleSwift -configuration Release -sdk iphoneos

# Generate Haxe interface from Objective-C compatible header from Swift framework
haxelib run bind objc project.ios/build/Release-iphoneos/IosSampleSwift.framework/Headers/IosSampleSwift-Swift.h --namespace ios --package ios --export src --cwd $(pwd)
