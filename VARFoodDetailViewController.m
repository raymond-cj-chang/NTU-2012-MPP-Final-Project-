//
//  VARFoodDetailViewController.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARFoodDetailViewController.h"

@interface VARFoodDetailViewController ()

@end

@implementation VARFoodDetailViewController

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
    
    //check data
    if(_food!=Nil)
    {
        //set food data
        _foodEnglishName.text = _food[VARsDataSourceDictKeyEnglishName];
        _foodChineseName.text = _food[VARsDataSourceDictKeyChineseName];
        _foodIntroduction.text = _food[VARsDataSourceDictKeyFoodIntroduction];
        _foodIngredient.text = _food[VARsDataSourceDictKeyFoodIngredient];
        
        //image array
        NSArray* imageArray = _food[VARsDataSourceDictKeyFoodImage];
        
        //check bound
        UIImage* foodImage;
        if([imageArray count]!=0)
        {
            foodImage = [UIImage imageNamed:[imageArray objectAtIndex:0]];
        }
        //set image
        self.foodImage.image = foodImage;
        
        //set page control
        self.imagePageControler.numberOfPages = [imageArray count];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imagePageChange:(id)sender {
    //get page number
    UIPageControl* pageController = (UIPageControl*) sender;
    NSInteger currentPageNumber = pageController.currentPage;
    
    //set image
    //image array
    NSArray* imageArray = _food[VARsDataSourceDictKeyFoodImage];
    self.foodImage.image = [UIImage imageNamed:[imageArray objectAtIndex:currentPageNumber]];
    
    //image animation
    /*
     [UIView animateWithDuration:0.1 animations:^{
     imgIn.alpha = 1;
     imgOut.alpha = 0;
     } completion:^(BOOL finished) {
     [self performSelectorOnMainThread:@selector(performAnimationOfFrameAtIndex:) withObject:[NSNumber numberWithInt:index+1] waitUntilDone:NO];
     }];
     */
}

@end
