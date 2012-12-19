//
//  VARFoodListViewController.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARFoodListViewController.h"

@interface VARFoodListViewController ()

@end

@implementation VARFoodListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    VARFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    //cell row
    NSInteger row = indexPath.row;
    
    //set cell data
    cell.foodEnglishName.text = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory][row][VARsDataSourceDictKeyEnglishName];
    cell.foodChineseName.text = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory][row][VARsDataSourceDictKeyChineseName];
    //cell.foodImage = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory][row][VARsDataSourceDictKeyFoodImage];
    NSArray *imageList = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory][row][VARsDataSourceDictKeyFoodImage];
    //NSLog(@"foodList:%@",imageList);
    //NSLog(@"arrayNum:%u",[imageList count]);
    if ([imageList count] > 0) {
        
       //NSLog(@"file%@",imageList[0]);
       NSString* filename = imageList[0];
        UIImage* addedImage = [UIImage imageNamed:filename];
        
        //check image in docs or not
        if(addedImage==nil)
        {
            //doc path
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@",docDir,filename];
            //image
            addedImage = [UIImage imageWithContentsOfFile:imagePath];
            
        }
        
        [cell.foodImage setImage:addedImage];
       //cell.foodImage.image = [UIImage imageWithContentsOfFile:filename];
        //NSLog(@"image:%@",cell.foodImage.image);
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //get cell
    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
    
    if ([segue.identifier isEqualToString:@"showFoodDetailView"]) {
        // Fetch data by index path from data source
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        //get index path
        NSUInteger row = indexPath.row;
        NSDictionary *food = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsInCategories:_currentCategory][row];
        
        //set next level category
        VARFoodDetailViewController *foodListController = segue.destinationViewController;
        //set data
        foodListController.food = food;
        
        //hide tab bar
        foodListController.hidesBottomBarWhenPushed = YES;
        
    }
  
    if( [segue.identifier isEqualToString:@"addingFood"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        VARAddFoodViewController *addFoodViewController = [[navigationController viewControllers] lastObject];
        //NSLog(@"dest:%@",addFoodViewController.currentCategory);
        addFoodViewController.currentCategory = self.currentCategory;
        //NSLog(@"prepare:%@",self.currentCategory);
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)addingFood:(id)sender {
    [self performSegueWithIdentifier:@"addingFood" sender:sender];
}
@end
