//
//  VARFoodListViewController.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "VARFoodListCell.h"
#import "VARFoodDetailViewController.h"
#import "VARAddFoodViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface VARFoodListViewController : UITableViewController

@property (nonatomic, strong) NSString *currentCategory;

@end
