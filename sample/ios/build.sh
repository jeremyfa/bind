#!/bin/bash
cd "${0%/*}"

# Bind Objective-C code to Haxe
./bind-objc.sh

# Build Haxe code
haxe build.hxml

# Compile iOS binaries
./compile-ios.sh
