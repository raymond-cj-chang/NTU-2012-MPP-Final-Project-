//
//  VARPopularFoodViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/17.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "VARPopularFoodCell.h"

@interface VARPopularFoodViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property(strong, nonatomic) NSArray * arrayOfFoodDictionary;
@end
