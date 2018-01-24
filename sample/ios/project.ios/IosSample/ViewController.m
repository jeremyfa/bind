//
//  ViewController.m
//  IosSample
//
//  Created by Jeremy FAIVRE on 23/01/2018.
//  Copyright © 2018 Your Company. All rights reserved.
//

#import "ViewController.h"

const char *hxRunLibrary(void);
void hxcpp_set_top_of_stack(void);

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Run haxe once the root view controller is visible
    // (Temporary)
    hxcpp_set_top_of_stack();
    
    const char *err = NULL;
    err = hxRunLibrary();
    
    if (err) {
        printf(" Error %s\n", err );
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
