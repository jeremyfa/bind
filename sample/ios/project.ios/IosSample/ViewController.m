//
//  ViewController.m
//  IosSample
//
//  Created by Jeremy FAIVRE on 23/01/2018.
//  Copyright © 2018 Your Company. All rights reserved.
//

#import "ViewController.h"
#import "AppNativeInterface.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    AppNativeInterface *native = [AppNativeInterface sharedInterface];
    
    // Call provided block/function if it exists
    if (native.viewDidAppear) {
        native.viewDidAppear();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
