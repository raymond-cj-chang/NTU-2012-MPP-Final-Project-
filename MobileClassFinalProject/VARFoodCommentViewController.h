//
//  VARFoodCommentViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/2.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"

@interface VARFoodCommentViewController : UITableViewController
{
    NSMutableArray* commentArray;
}
- (IBAction)done:(id)sender;

@end
