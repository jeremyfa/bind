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

Nothing is written to disk. The output is simply returned by the command. You can add a ``--json`` argument to get output as JSON (file paths and contents), in order to integrate this into your own tool.

The generated code exposes one ore more classes to Haxe from the parsed Objective-C header.
For now, you must define yourself header include paths or copy support files (from bind's `support/` directory) to build it.

An option to generate fully standalone classes that add correct build config flags to hxcpp is planned.

_That's all you can do for now, but there is more to come (see roadmap below)._

## Roadmap

* [x] Parse Objective-C classes, with methods, properties and comments in header files
* [x] Parse Objective-C blocks as Haxe functions in class methods and properties
* [x] Parse Objective-C typedefs, including block types in typedefs
* [x] Generate Haxe (C++) to Objective-C bindings from parsed informations
* [ ] Add tests and examples of some Objective-C bindings
* [ ] Add an option to write generated and support files to disk at a target directory to make them _ready to use_
* [ ] Parse Java classes, with methods, properties and comments in java files
* [ ] Generate Haxe (C++) to Java (JNI) bindings from parsed informations
* [ ] Generate single Haxe class from Objective-C + Java (JNI) bindings having the same methods and properties
* [ ] Provide a build macro to make all this work at compile time
