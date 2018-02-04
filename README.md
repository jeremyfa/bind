# bind

Bind Objective-C/Swift and Java/JNI code to Haxe without writing glue code manually.

🚨 Warning: this library is in active development! 🚨

## Overall idea

Writing Haxe-compatible native extensions that take advantage of iOS or Android API is quite complicated, especially if you start dealing with callbacks etc... This usually implies writing a lot of difficult to grasp _glue code_. This _glue code_ is definitely not what you want to care about in practice. In addition, these intermediate files, that you would write yourself, usually don't integrate well with code editors. Just try to get iOS API code completion in [this file that mixes Objective-C, C++ and HXCPP FFI code to display a UIWebView instance](https://github.com/HaxeExtension/extension-webview/blob/dca79b548fc6f3522f6d4543104a22e7bec1a26e/project/ios/WebViewEx.mm).

The idea of _bind_ is to let you focus exclusively on **Objective-C/Swift** code (that you would edit with full IDE integration on Xcode) when you work on an iOS native extension for Haxe, as well as **Java** code (that you would edit inside Android Studio with full completion support) when your work on an Android native extension for Haxe. These Objective-C/Swift/Java code files could even be used without Haxe first, allowing you to test them separately etc...

Then, _bind_ utility will take your _Objective-C/Swift_ code or _Java_ code as input and **generate all intermediate glue code** to make the same classes, methods and properties usable from a **clean Haxe interface** with types converted automatically.

In other words, **use the best tools for each part**: Xcode to make iOS code, Android Studio to make Android code and VSCode (or your other favourite Haxe editor) to make Haxe code that uses your iOS/Android bound code.

## Usage

#### Generate binding code for iOS (haxe, c++, build.xml)

```
haxelib run bind objc NSSomeObjcHeader.h --namespace some::namespace --package some.haxe.pack --objc-prefix NS
```

#### Generate binding code for Android (haxe, c++, java, build.xml)

```
haxelib run bind java some/package/SomeJavaClassFile.java --namespace some::namespace --package some.haxe.pack
```

#### Parse one or more header files and return result as JSON

You can use _bind_ utility to simply parse an _Objective-C_ header to list its classes, methods and properties and output them as JSON.

```
haxelib run bind objc SomeObjcHeader.h [SomeOtherObjcHeader.h ...] --json --parse-only --pretty
```

#### Parse one or more java files and return result as JSON

This ``--parse-only`` option also work on java files

```
haxelib run bind run bind java some/package/SomeJavaClassFile.java [SomeOtherJavaFile.java ...] --json --parse-only --pretty
```

## Additional notes

This _bind_ library is not a full-featured _Objective-C/Swift or Java to Haxe converter_. Its approach is pragmatic and is intended to be used on a **clean and portable subset of Objective-C header syntax** (iOS) or a **clean an portable subset of Java syntax** (Android) that acts as a public bridge/interface to all your native iOS/Android API.

Nothing is written to disk by default. The output is simply returned by the command. You can add a ``--json`` argument to get output as JSON (file paths and contents), in order to integrate this into your own tool or add ``--export your/export/path`` to let _bind_ save files to this _export_ directory.

## Objective-C/Swift on iOS

Check out an example of [bound Objective-C header](https://github.com/jeremyfa/bind/blob/master/sample/ios/project.ios/IosSample/AppNativeInterface.h) that you can use as reference to see which subset of Objective-C can be handled by _bind_. This file can be tested with the provided sample iOS/Objective-C project.

#### Supported Objective-C types

These are the Objective-C types that _bind_ utility can understand and convert to a corresponding Haxe type.

Objective-C Type | Haxe Type
-----------------|----------
NSString*        | String
CGFloat/float    | Float
NSInteger/int    | Int
BOOL/bool        | Bool
NSArray          | Array
NSDictionary     | Dynamic (anonymous structure)
typed ObjC Block | typed Haxe function

#### Sample Xcode Project

You can check out [The iOS Sample project](https://github.com/jeremyfa/bind/tree/master/sample/ios) which contains:

 * A _Haxe_ project that can be compiled with ``build.hxml``
 * An Xcode project configured to build haxe files to C++, generate bindings and run the result as an iOS App
 * Scripts (used by Xcode project) to compile C++ to iOS binaries, to generate bindings
 * An example of class written in _Objective-C Language_ bound to _Haxe_
 * An example of class written in _Swift Language_ bound to _Haxe_ through an _Objective-C_ compatible dynamic framework

This will obviously only work on a mac, with haxe, bind library and xcode properly installed.

## Java/JNI on Android

Check out an example of [bound Java class file](https://github.com/jeremyfa/bind/blob/master/sample/android/project.android/app/src/main/java/yourcompany/androidsample/AppAndroidInterface.javah) that you can use as reference to see which subset of Java can be handled by _bind_. This file can be tested with the provided sample Java/Android project.

#### Supported Java types

These are the Java types that _bind_ utility can understand and convert to a corresponding Haxe type.

Java Type            | Haxe Type
---------------------|----------
String               | String
Float/float          | Float
Int/int              | Int
Boolean/boolean      | Bool
List                 | Array
Map                  | Dynamic (anonymous structure)
Runnable/Func0<Void> | Void->Void function
FuncN<A1,A2...,T>    | A1->A2...->T function

#### Threads in Android

While it is totally possible (and showcased in the sample project) to run Haxe/C++ in the same thread as Android's main UI thread, it is common to run it in a separate thread. For instance, this does happen when running an OpenGL ES app on Android: Haxe code is executed on Android's GLSurfaceView thread, which is not the same as the main UI thread.

The bindings generated by _bind_ utility can take care of switching to the correct thread as needed when passing values between Haxe and Java. To do so, an instance of `android.os.Handler` or `android.opengl.GLSurfaceView` used to execute Haxe/C++ must be provided to `bind.Support` (see `bind.Support.setNativeThreadHandler()` and `bind.Support.setGLSurfaceView()`). This can be tested in the sample project by setting `MainActivity.HAXE_IN_BACKGROUND` to `true` or `false`. As all this thread handling is managed by the generated glue code, you should not have to care much about it. Just keep in mind that if Haxe is executed in a background thread, its thread need to wait for Android's UI thread everytime you are doing a synchronous call from Haxe to Java that has a non-void return value.

In general, you should anyway minimise the number of calls between Haxe and Java as this is an expensive operation.

#### Sample Android Studio Project

You can check out [The Android Sample project](https://github.com/jeremyfa/bind/tree/master/sample/android) which contains:

 * A _Haxe_ project that can be compiled with ``build.hxml``
 * An Android Studio project configured to build haxe files to C++, generate bindings and run the result as an Android App
 * Scripts (used by Android Studio project) to compile C++ to Android binaries, to generate bindings
 * An example of class written in _Java Language_ bound to _Haxe_ through JNI

This currently only works on Unix-based systems (Mac/Linux), with haxe, bind library and Android SDK properly installed.
Project will also work on Windows in the future.

## Roadmap

* [x] Parse Objective-C classes, with methods, properties and comments in header files
* [x] Parse Objective-C blocks as Haxe functions in class methods and properties
* [x] Parse Objective-C typedefs, including block types in typedefs
* [x] Generate Haxe (C++) to Objective-C bindings from parsed informations
* [x] Add examples of some Objective-C bindings and a sample Xcode/iOS project
* [x] Add similar tests and examples for Swift (through Objective-C compatible dynamic frameworks)
* [x] Add an option to write generated and support files to disk at a target directory to make them _ready to use_
* [x] Parse Java classes, with methods, properties and comments in java files
* [x] Generate Haxe (C++) to Java (JNI) bindings from parsed informations
* [ ] Make Android Studio project sample work on Windows machines (only works on Mac/Linux for now)
* [ ] Generate single Haxe class from Objective-C + Java (JNI) bindings having the same methods and properties
