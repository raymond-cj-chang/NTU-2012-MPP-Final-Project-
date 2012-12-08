//
//  VARSearchFoodViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARSearchCell.h"
#import "VARMenuDataSource.h"

@interface VARSearchFoodViewController : UITableViewController<UISearchDisplayDelegate,UISearchBarDelegate>

@property (strong, nonatomic) NSArray *allFood;
@property (nonatomic, retain) NSArray *searchResults;


@end
