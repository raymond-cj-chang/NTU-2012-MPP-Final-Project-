//
//  VARFoodDetailViewController.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARFoodDetailViewController.h"
#import "VARFoodPhotoViewController.h"

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
    UINavigationController * navController = [UINavigationController alloc];
    navController.navigationBar.tintColor = [UIColor colorWithRed:117/255.0f green:4/255.0f blue:32/255.0f alpha:1];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30,60,260,175)];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	self.scrollView.scrollEnabled = YES;
	self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.tag = 1;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageControl = NO;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleTap];
    //check data
    if(_food!=Nil)
    {
        //set food data
        _foodEnglishName.text = _food[VARsDataSourceDictKeyEnglishName];
        _foodChineseName.text = _food[VARsDataSourceDictKeyChineseName];
        //_foodIntroduction.text = _food[VARsDataSourceDictKeyFoodIntroduction];
        //_foodIngredient.text = _food[VARsDataSourceDictKeyFoodIngredient];
//        
        //image array
        NSArray* imageArray = _food[VARsDataSourceDictKeyFoodImage];
        //NSLog(@"images%@",imageArray);
        //check bound
        //UIImage* foodImage;
        if([imageArray count]!=0)
        {
            //add images to scrollView
            for(int i=0; i<[imageArray count]; ++i){
                CGRect frame;
                frame.origin.x = self.scrollView.frame.size.width*i;
                //frame.origin.y = self.imageScrollView.frame.origin.y;
                frame.origin.y = self.scrollView.frame.origin.y;
                frame.size = self.scrollView.frame.size;
                NSString* filename = [imageArray objectAtIndex:i];
                UIImage* addedImage = [UIImage imageNamed:filename];
                //self.foodImage.image = addedImage;
                
                //check image in docs or not
                if(addedImage==nil)
                {
                    //doc path
                    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",docDir,filename];
                    //image
                    addedImage = [UIImage imageWithContentsOfFile:imagePath];
                    
                }
                //CGRect imageViewFrame = self.foodImage.frame;
                CGFloat imageWidth = self.scrollView.frame.size.width;
                CGFloat imageHeight = self.scrollView.frame.size.height;
                //UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth*i,50 , imageWidth, imageHeight)];
                UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth*i, 0, imageWidth, imageHeight)];
                tempImageView.image = addedImage;
                [self.scrollView addSubview:tempImageView];
            }
            [self.view addSubview:self.scrollView];
            //foodImage = [UIImage imageNamed:[imageArray objectAtIndex:0]];
            
            //set scrollView
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*[imageArray count], self.scrollView.frame.size.height);
            //self.pageControl.currentPage = 0;
            //self.pageControl.numberOfPages = [imageArray count];
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(30, 235, 260, 20)];
            [self.pageControl setBackgroundColor:[UIColor blackColor]];
            [self.pageControl setNumberOfPages:[imageArray count]];
            [self.pageControl setCurrentPage:0];
            [self.view addSubview:self.pageControl];
        }
        
    }
    self.textView.text = self.food[VARsDataSourceDictKeyFoodIntroduction];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    if(!pageControlBeingUsed){
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeingDragging:(UIScrollView *)scrollView{
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageControlBeingUsed = NO;
}

- (IBAction)imagePageChange:(id)sender {
    //NSLog(@"here");
    // Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width*self.pageControl.currentPage;
    frame.origin.y = self.scrollView.frame.origin.y;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeingUsed = YES;
    //get page number
    //UIPageControl* pageController = (UIPageControl*) sender;
    //NSInteger currentPageNumber = pageController.currentPage;
    
    //set image
    //image array
    //NSArray* imageArray = _food[VARsDataSourceDictKeyFoodImage];
    //self.foodImage.image = [UIImage imageNamed:[imageArray objectAtIndex:currentPageNumber]];
    
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

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:self.scrollView];
    NSInteger index = touchPoint.x/320;
    //shopDetailView = [[ShopDetailViewController alloc] init];
    //[self.navigationController pushViewController:shopDetailView animated:YES];
    NSArray* imageArray = _food[VARsDataSourceDictKeyFoodImage];
    self.currentImage = [imageArray objectAtIndex:self.pageControl.currentPage];
    [self performSegueWithIdentifier:@"ShowDetail" sender:self.scrollView];
    //[shopDetailView release];
    //NSLog(@"gesture");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        //NSLog(@"segue");
        // Get data
        VARFoodPhotoViewController *dest = (VARFoodPhotoViewController *)[[segue destinationViewController] topViewController];
        dest.imageName = self.currentImage;
        //dest.ChineseName = self.foodChineseName.text;
    }
    if ([segue.identifier isEqualToString:@"addPhoto"]){
        VARAddPhotoViewController *dest = (VARAddPhotoViewController *)[[segue destinationViewController] topViewController];
        //send food dict
        dest.food = self.food;
    }
    //    if ([segue.identifier isEqualToString:@"addPhoto"]){
//        VARAddPhotoViewController *dest = (VARAddCommentViewController *)[[segue destinationViewController] topViewController];
//    }
    if ([segue.identifier isEqualToString:@"showComment"]){
        VARFoodCommentViewController *dest = (VARFoodCommentViewController *)[[segue destinationViewController] topViewController];
        dest.arrayWithCommentAndTimestamp = self.food[VARsDataSourceDictKeyComment];
    }
}


- (IBAction)segmentedControlIndexChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger index = [segmentedControl selectedSegmentIndex];
    switch (index) {
        case 0:
            //self.content.text = @"This is introduction for food";
            self.textView.text = self.food[VARsDataSourceDictKeyFoodIntroduction];
            break;
        case 1:
            //self.content.text = @"This is ingredient for food";
            self.textView.text = self.food[VARsDataSourceDictKeyFoodIngredient];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showComment" sender:self.segmentedControl];
            break;
        default:
            break;
    }
}


- (IBAction)showActionSheet:(id)sender {
    
    UIActionSheet *action  =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Vote", @"Add Photo",@"Add Comment", nil];
    UIWindow *mainWindow = [[UIApplication sharedApplication] windows][0];
    [action showInView:mainWindow];
    //[action dismissWithClickedButtonIndex:2 animated:YES];
    //[action showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"index%i",buttonIndex);
    switch (buttonIndex) {
        case 0:{
            //NSLog(@"Vote");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Voting"
                                                            message:@"Are you voting for this food?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
            break;
        case 1:
            [self performSegueWithIdentifier:@"addPhoto" sender:actionSheet];
            break;
        case 2:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Comment"
                                                            message:@"Add your comment for this food"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Send", nil];
            UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
            [myTextField setBackgroundColor:[UIColor whiteColor]];
            [alert addSubview:myTextField];
            [alert show];
        }
            break;
        default:
            break;
    }

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Send"]) {
        for (UIView* view in alertView.subviews)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                UITextField* textField = (UITextField*)view;
                //[data addObject:textField.text == nil ? @"" : textField.text];
                self.comment = textField.text;
                //NSLog(@"comment:%@",self.comment);
                //NSLog(@"text:[%@]", textField.text);
                
                //add comment to server
                NSString* fid = _food[VARsDataSourceDictKeyFoodID];
                [VARMenuDataSource uploadCommentToGAEServer:fid withComment:self.comment ];

                
                break;
            }
        }
    }
    
    if ([buttonTitle isEqualToString:@"OK"])
        [self updateNewVote];
}


#pragma - new Vote

- (void) updateNewVote{

    //TODO
    //add food rating to server
    [VARMenuDataSource uploadFoodRatingToGAEServer:_food[VARsDataSourceDictKeyFoodID]];
    
    NSLog(@"updated successfully");
}


@end
