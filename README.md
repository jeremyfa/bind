# bind

Bind Objective-C and Java (JNI) code to Haxe without writing glue code manually.

Warning: this library is in active development.

## Usage

#### Parse one or more header files and return result as JSON

```
haxelib run bind objc SomeObjcHeader.h [SomeOtherObjcHeader.h ...] --json --parse-only --pretty
```

_That's all you can do for now, but there is more to come (see roadmap below)._

## Roadmap

* [x] Parse Objective-C classes, with methods, properties and comments in header files
* [x] Parse Objective-C blocks as Haxe functions in class methods and properties
* [x] Parse Objective-C typedefs, including block types in typedefs
* [ ] Generate Haxe (C++) to Objective-C bindings from parsed informations (in progress)
* [ ] Parse Java classes, with methods, properties and comments in java files
* [ ] Generate Haxe (C++) to Java (JNI) bindings from parsed informations
* [ ] Generate single Haxe class from Objective-C + Java (JNI) bindings having the same methods and properties
* [ ] Provide a build macro to make all this work at compile time
