//
//  AppNativeInterface.m
//  IosSample
//
//  Created by Jeremy FAIVRE on 23/01/2018.
//  Copyright © 2018 Your Company. All rights reserved.
//

#import "AppNativeInterface.h"

@implementation AppNativeInterface

+ (instancetype)sharedInterface {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
    
} //sharedInterface

- (void)hello:(NSString *)name {
    
    NSString *sentence = [NSString stringWithFormat:@"Hello %@", name];
    
    if (_lastName) {
        sentence = [NSString stringWithFormat:@"%@ %@", sentence, _lastName];
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Native iOS"
                                message:sentence
                                preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action) {
                          // Pressed `OK`
                      }]];
    
    UIViewController *viewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    [viewController presentViewController:alert animated:YES completion:nil];
    
} //hello

@end
