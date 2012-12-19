//
//  VARTabBarController.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/12/19.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARTabBarController.h"

@interface VARTabBarController ()

@end

@implementation VARTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    //NSLog(@"supportedInterfaceOrientations is = %d",[self supportedInterfaceOrientations]);
    //return UIInterfaceOrientationMaskPortraitUpsideDown;
}



@end
