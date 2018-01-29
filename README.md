# bind

Bind Objective-C and Java (JNI) code to Haxe without writing glue code manually.

Warning: this library is in active development.

## Usage

#### Parse one or more header files and return result as JSON

```
haxelib run bind objc SomeObjcHeader.h [SomeOtherObjcHeader.h ...] --json --parse-only --pretty
```

#### Generate binding code (haxe, c++, build.xml)

```
haxelib run bind objc NSSomeObjcHeader.h --namespace some::namespace --package some.haxe.pack --objc-prefix NS
```

Nothing is written to disk by default. The output is simply returned by the command. You can add a ``--json`` argument to get output as JSON (file paths and contents), in order to integrate this into your own tool or add ``--export your/export/path`` to let _bind_ save files to this _export_ directory.

Note that _bind_ library is not a full _Objective-C to Haxe converter_. Its approach is pragmatic and is intended to be used on a **clean and portable subset of Objective-C header syntax** that acts as a public bridge/interface to all your native iOS API.

Check out an example of [bound Objective-C header](https://github.com/jeremyfa/bind/blob/master/sample/ios/project.ios/IosSample/AppNativeInterface.h) that you can use as reference to see which subset of Objective-C can be handled by _bind_. This file can be tested with the provided sample iOS/Objective-C project.

## Sample iOS/Objective-C Project

You can check out [The iOS Sample project](https://github.com/jeremyfa/bind/tree/master/sample/ios) which contains:

 * A _Haxe_ project that can be compiled with ``build.hxml``
 * An Xcode project configured to build haxe files to C++, generate bindings and run the result as an iOS App
 * Scripts (used by Xcode project) to compile C++ to iOS binaries, to generate bindings
 * An example of class written in _Swift Language_ bound to _Haxe_ through an _Objective-C_ compatible dynamic framework

This will obviously only work on a mac, with haxe, bind library and xcode properly installed.

_That's all you can do for now, but there is more to come (see roadmap below)._

## Roadmap

* [x] Parse Objective-C classes, with methods, properties and comments in header files
* [x] Parse Objective-C blocks as Haxe functions in class methods and properties
* [x] Parse Objective-C typedefs, including block types in typedefs
* [x] Generate Haxe (C++) to Objective-C bindings from parsed informations
* [x] Add examples of some Objective-C bindings and a sample Xcode/iOS project
* [x] Add similar tests and examples for Swift (through Objective-C compatible dynamic frameworks)
* [x] Add an option to write generated and support files to disk at a target directory to make them _ready to use_
* [x] Parse Java classes, with methods, properties and comments in java files
* [ ] Generate Haxe (C++) to Java (JNI) bindings from parsed informations
* [ ] Generate single Haxe class from Objective-C + Java (JNI) bindings having the same methods and properties
