//
//  AppNativeInterface.h
//  IosSample
//
//  Created by Jeremy FAIVRE on 23/01/2018.
//  Copyright © 2018 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Example of Objective-C interface exposed to Haxe */
@interface AppNativeInterface : NSObject

/** Last name. If provided, will be used when saying hello. */
@property (nonatomic, strong) NSString *lastName;

/** Get shared instance */
+ (instancetype)sharedInterface;

/** Say hello to `name` with a native iOS dialog. Add a last name if any is known. */
- (void)hello:(NSString *)name;

@end
