//
//  VARAddPhotoViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"

@interface VARAddPhotoViewController : UIViewController
- (IBAction)sendButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)takePhotoButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDictionary* food;

@end
