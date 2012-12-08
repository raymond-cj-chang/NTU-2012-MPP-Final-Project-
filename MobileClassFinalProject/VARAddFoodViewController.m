//
//  VARAddFoodViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARAddFoodViewController.h"

@interface VARAddFoodViewController ()

@end

@implementation VARAddFoodViewController{
    BOOL viewIsDisappearForTakingPhoto;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.foodName.delegate = self;
    self.ingredientInput.delegate = self;
    self.comment.delegate = self;
    
    //Initialize
    self.ingredientLabel.text = @"";
    self.ingredient = [[NSMutableString alloc] init];

    self.pickerView.showsSelectionIndicator = TRUE;
    NSArray *tempArr = [[NSArray alloc] initWithArray:[[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories]];

    self.categoryArray = [[NSMutableArray alloc] init];
    if (self.currentCategory != nil) {
        [self.categoryArray addObject:self.currentCategory];
        for(NSString *category in tempArr){
            if (category != self.currentCategory && [category isEqualToString:@"other"] == NO) {
                [self.categoryArray addObject:category];
            }
        }
    }
    else{ 
        for(NSString *category in tempArr){ 
            if([category isEqualToString: @"other"] == NO){
                [self.categoryArray addObject:category];
            }
        }
    }
    
    [self.categoryArray addObject:@"other"];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //NSLog(@"here");
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.categoryArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.categoryArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.currentCategory = [self.categoryArray objectAtIndex:row];
    //NSLog(@"category:%@",self.currentCategory);
}


- (IBAction)cancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addButton:(id)sender {
    if(self.ingredientInput.text != @""){
        if ([self.ingredient isEqualToString:@""] == NO) {
            [self.ingredient appendString:@","];
        }
      [self.ingredient appendString:self.ingredientInput.text];
      self.ingredientLabel.text = self.ingredient;
    }
    self.ingredientInput.text = @"";
}
- (IBAction)takePhotoButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a source"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [actionSheet addButtonWithTitle:@"Camera"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [actionSheet addButtonWithTitle:@"Photo Library"];
    
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIImagePickerControllerSourceType sourceType;
    if ([buttonTitle isEqualToString:@"Camera"]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([buttonTitle isEqualToString:@"Photo Library"]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    viewIsDisappearForTakingPhoto = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        viewIsDisappearForTakingPhoto = NO;
    }];
    
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
}

//add food item on GAE DB
- (void) uploadFoodItemOnGAEDB
{
    //upload food item on server
    
    //server path
    NSString* uploadServerPath = @"http://varfinalprojectserver.appspot.com/addFoodInDB";
    
    //server url
    NSURL *url = [NSURL URLWithString:@"http://localhost"];
    
    //client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    //upload data
    NSString *foodFid = @"101";
    NSString *foodEnglishName = self.foodName.text;
    NSString *foodChineseName = @"測試";
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            foodFid, @"fid",
                            foodEnglishName, @"EnglishName",
                            foodChineseName,@"ChineseName",
                            nil];
    
    //request to server
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:uploadServerPath parameters:params];
    
      
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //set class
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //operation
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [operation responseString];
        NSLog(@"response for POST: [%@]",response);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [operation start];

}

@end

