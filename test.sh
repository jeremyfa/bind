#!/bin/bash

haxe cli-nodejs.hxml
haxelib run bind-dev objc test/CIAudioSequencer.h --nodejs --json --pretty --parse-only
