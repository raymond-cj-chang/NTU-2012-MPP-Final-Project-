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

    self.EnglishName.delegate = self;
    self.ChineseName.delegate = self;
    self.introduction.delegate = self;
    self.ingredientInput.delegate = self;
    self.comment.delegate = self;
    
    //Initialize
    self.ingredientLabel.text = @"";
    self.ingredient = [[NSMutableString alloc] init];
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
    
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
- (IBAction)sendButton:(id)sender {
    self.progressView.hidden = NO;
    [self uploadFoodItemOnGAEDB];
}

# pragma - Server Connection

- (void) uploadFoodItemOnGAEDB
{
    //upload food item on server
    
    //server path
    NSString* uploadServerPath = @"http://varfinalprojectserver.appspot.com/addFoodInDB";
    //NSString* uploadServerPath = @"http://localhost:8081/addFoodInDB";
    
    //server url
    NSURL *clientURL = [NSURL URLWithString:@"http://localhost"];
    
    //client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:clientURL];
    
    //upload data
    NSString *foodFid = @"101";
    NSString *foodEnglishName = self.EnglishName.text;
    NSString *foodChineseName = self.ChineseName.text;
    NSString *foodIntroduction = self.introduction.text;
    NSString *foodIngredient = self.ingredientLabel.text;
    NSString *foodEnglishCategory = self.currentCategory;
    NSString *foodChineseCategory = @"中文種類名";
    NSString *foodComment = self.comment.text;
    UIImage *foodImage = self.imageView.image;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            foodFid, @"fid",
                            foodEnglishName, @"EnglishName",
                            foodChineseName,@"ChineseName",
                            foodIntroduction,@"Introduction",
                            foodIngredient,@"Ingredients",
                            foodEnglishCategory,@"EnglishCategory",
                            foodChineseCategory,@"ChineseCategory",
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
        
        //add comment
        NSString* fidStr = response;
        [VARMenuDataSource uploadCommentToGAEServer:fidStr withComment:foodComment];
        
        //*****add image
        [VARMenuDataSource uploadFoodImageToGAEServer:fidStr withImageName:nil withImage:foodImage];
        
        //download from server
        [VARMenuDataSource downloadFoodDataFromGAEServer];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [operation start];
    
    
    //progress view setting
    self.progressView.hidden = NO;
    float theInterval = 1.0/5.0;
    [NSTimer scheduledTimerWithTimeInterval:theInterval target:self selector:@selector(running) userInfo:nil repeats:YES];

}

- (void)running{
    if(self.progressView.progress != 1.0){
        float tempProgress = self.progressView.progress + 0.1;
        self.progressView.progress = tempProgress;
    }
    else{
        self.progressView.progress = 1.0;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

