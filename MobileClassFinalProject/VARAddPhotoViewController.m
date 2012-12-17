//
//  VARAddPhotoViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARAddPhotoViewController.h"

@interface VARAddPhotoViewController ()

@end

@implementation VARAddPhotoViewController{
    BOOL viewIsDisappearForTakingPhoto;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButton:(id)sender {
    //upload image to server
    if(self.imageView.image!=nil) [VARMenuDataSource uploadFoodImageToGAEServer:_food[VARsDataSourceDictKeyFoodID] withImageName:nil withImage:self.imageView.image];
}

- (IBAction)cancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        UIImage *image = info[UIImagePickerControllerOriginalImage];
    //        image = [image imageFixedOrientation];
    //
    //        // Store it
    //        if (picker.sourceType==UIImagePickerControllerSourceTypeCamera)
    //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
    //        document.image = image;
    //
    //        // Get thumb
    //        UIImage *thumbImage = [image imageScaledProportionallyToSize:CGSizeMake(300, 225)];
    //        document.thumbImage = thumbImage;
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            self.imageView.image = thumbImage;
    //        });
    //    });
}

@end
