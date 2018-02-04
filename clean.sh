#!/bin/bash
cd "${0%/*}"

rm -rf sample/ios/bin
rm -rf sample/ios/project.ios/build
rm -rf sample/ios/project.ios/IosSample.xcodeproj/project.xcworkspace/xcuserdata
rm -rf sample/ios/project.ios/IosSample.xcodeproj/xcuserdata

rm -rf sample/android/bin
rm -rf sample/android/project.android/build
rm -rf sample/android/project.android/.gradle
rm -rf sample/android/project.android/local.properties
rm -rf sample/android/project.android/project.android.iml
rm -rf sample/android/project.android/.idea/workspace.xml
rm -rf sample/android/project.android/.idea/libraries
rm -rf sample/android/project.android/app/build
rm -rf sample/android/project.android/app/src/main/jniLibs
