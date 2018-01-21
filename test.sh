#!/bin/bash

#haxe nodejs.hxml
#haxelib run bind-dev objc test/CIAudioSequencer.h --nodejs --json --pretty --parse-only

haxe run.hxml
haxelib run bind-dev objc test/CIAudioSequencer.h --json --pretty --parse-only
