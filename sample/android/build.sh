#!/bin/bash
cd "${0%/*}"

# Ensure tools from /usr/local/bin are available
export PATH="/usr/local/bin:$PATH"

# Bind Java code to Haxe
./bind-java.sh

# Build Haxe code
haxe build.hxml

# Compile Android binaries
./compile-android.sh
