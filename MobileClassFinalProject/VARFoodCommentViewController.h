//
//  VARFoodCommentViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/2.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "VARCommentCell.h"

@interface VARFoodCommentViewController : UITableViewController

- (IBAction)done:(id)sender;
@property(strong, nonatomic) NSDictionary *dictionaryWithCommentAndTimestamp;
@end
