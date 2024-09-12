#!/bin/bash
cd "${0%/*}"

haxe run.hxml
#haxelib run bind cs sample/cs/AppCsInterface.cs --json --pretty --parse-only
rm -rf gen-cs
haxelib run bind cs sample/cs/AppCsInterface.cs --json --pretty --export gen-cs --namespace myapp::unity
