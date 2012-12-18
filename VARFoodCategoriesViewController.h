//
//  VARFoodCategoriesViewController.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/1.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "VARFoodCategoriesCell.h"
#import "VARFoodListViewController.h"
#import "VARAddFoodViewController.h"
#import "VARSearchBarView.h"

@interface VARFoodCategoriesViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>
- (IBAction)addingFood:(id)sender;

@end

NSMutableDictionary * englishToChineseCategory;
