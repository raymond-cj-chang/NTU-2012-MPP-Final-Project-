//
//  VARAddFoodViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VARMenuDataSource.h"
#import "AFNetworking.h"

@interface VARAddFoodViewController : UITableViewController<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *foodName;
//@property (strong, nonatomic) IBOutlet UITextField *ingredient;
//@property (strong, nonatomic) IBOutlet UITextField *comment;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)cancelButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *categoryArray;
@property (strong, nonatomic) NSString *currentCategory;
@property (strong, nonatomic) IBOutlet UITextField *ingredientInput;
@property (strong, nonatomic) IBOutlet UILabel *ingredientLabel;
- (IBAction)addButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *comment;
@property (strong, nonatomic) NSMutableString *ingredient;
- (IBAction)takePhotoButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (void) uploadFoodItemOnGAEDB;
@end
