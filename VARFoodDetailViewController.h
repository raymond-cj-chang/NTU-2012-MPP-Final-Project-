//
//  VARFoodDetailViewController.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "VARAddPhotoViewController.h"
#import "VARFoodCommentViewController.h"

@interface VARFoodDetailViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate>
{
    BOOL pageControlBeingUsed;
}
@property (strong, nonatomic) IBOutlet UILabel *foodEnglishName;
@property (strong, nonatomic) IBOutlet UILabel *foodChineseName;
@property (strong, nonatomic) NSDictionary* food;
//@property (strong, nonatomic) IBOutlet UIImageView *foodImage;
//@property (strong, nonatomic) IBOutlet UILabel *foodIntroduction;
//@property (strong, nonatomic) IBOutlet UILabel *foodIngredient;
//@property (strong, nonatomic) IBOutlet UIPageControl *imagePageController;
//@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
- (IBAction)imagePageChange:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *foodImage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSString *currentImage;
- (IBAction)segmentedControlIndexChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *content;
- (IBAction)showActionSheet:(id)sender;
@property (strong, nonatomic) NSString *comment;



@end
