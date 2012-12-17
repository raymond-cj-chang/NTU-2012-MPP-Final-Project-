//
//  VARRankingViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARRankingCell.h"
#import "VARMenuDataSource.h"
#import "VARFoodDetailViewController.h"

@interface VARRankingViewController : UITableViewController
@property (strong, nonatomic) NSArray *arrayOfFoodDictionary;

-(void) refresh;

@end
