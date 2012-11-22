//
//  VARFoodDetailViewController.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"

@interface VARFoodDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *foodEnglishName;
@property (strong, nonatomic) IBOutlet UILabel *foodChineseName;
@property (strong, nonatomic) NSDictionary* food;
@property (strong, nonatomic) IBOutlet UIImageView *foodImage;
@property (strong, nonatomic) IBOutlet UILabel *foodIntroduction;
@property (strong, nonatomic) IBOutlet UILabel *foodIngredient;
@property (strong, nonatomic) IBOutlet UIPageControl *imagePageControler;
- (IBAction)imagePageChange:(id)sender;

@end
