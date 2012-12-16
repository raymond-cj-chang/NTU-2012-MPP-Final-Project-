//
//  VARFoodPhotoViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/2.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VARFoodPhotoViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapRecognizer;
@property (strong, nonatomic) NSString* imageName;
//@property (strong, nonatomic) NSString* ChineseName;
- (IBAction)done:(id)sender;
//- (IBAction)doubleTap:(id)sender;
//- (IBAction)singleTap:(id)sender;

@end
