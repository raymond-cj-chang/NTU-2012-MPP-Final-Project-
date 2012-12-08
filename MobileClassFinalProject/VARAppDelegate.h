//
//  VARAppDelegate.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "JSONKit.h"

@interface VARAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)downloadFoodDataFromGAEServer;

@end
