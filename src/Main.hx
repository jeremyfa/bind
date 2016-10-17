package;

import Sys.println;
import sys.io.File;
import haxe.io.Path;

class Main {

    public static function main():Void {

        var objcHeader = File.getContent(Path.join([Sys.getCwd(), 'test/CIAudioSequencer.h']));

        var bindClass = bind.Objc.parseClass(objcHeader);
        trace(bind.Json.stringify(bindClass, true));

        //bind.Objc.parseBlockArg('void (^_Nullable)(NSString *)');

        // bind.Objc.parseProperty('@property (nonatomic, strong) NSTimeInterval loopDuration;');
        // bind.Objc.parseProperty('@property (nonatomic, strong) NSString * loopDuration;');
        // bind.Objc.parseProperty('@property (nonatomic, strong) NSString * loopDuration;');
        // bind.Objc.parseClassName('@interface Bref () <UIWebViewDelegate, AVAudioPlayerDelegate>');
        // bind.Objc.parseClassName('@interface CIAudioSequencer (Youpi) <AVAudioPlayerDelegate>');
        // bind.Objc.parseClassName('@interface MachinTrucBidule : NSObject');
        //
        // trace(bind.Objc.parseMethod('- (bbb)init;'));
        // trace(bind.Objc.parseMethod('- (instancetype)initWithLoopDuration:(NSTimeInterval)loopDuration;'));
        // trace(bind.Objc.parseMethod('+ (NSArray * _Nullable)initWithName:(NSString *)name weight:(NSInteger)weight width:(NSInteger)width;'));
        // trace(bind.Objc.parseMethod('+ (void *(^_Nullable)(NSString *, CGFloat youpi))blockForName:(void(^_Nullable)(NSString *, CGFloat youpi))name;'));
        // trace(bind.Objc.parseMethod('+ (void(^)())blockForName:(void(^)(NSString *, CGFloat youpi))name;'));

        //trace(bind.Objc.parseProperty('@property (nonatomic, strong) NSTimeInterval loopDuration;'));
        //trace(bind.Objc.parseProperty('@property (nonatomic, strong) NSString * loopDuration;'));
        //trace(bind.Objc.parseProperty('@property (nonatomic, copy, nullability) NSString * (^blockName)(NSString *, NSString *argsJson);'));

    } //main

}
