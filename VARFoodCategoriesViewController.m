//
//  VARFoodCategoriesViewController.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/11/1.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARFoodCategoriesViewController.h"

@interface VARFoodCategoriesViewController ()

@end

@implementation VARFoodCategoriesViewController

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


#pragma mark - UICollectionViewDataSource
/*
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[VARMenuDataSource sharedMenuDataSource] arrayOfCategories] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //cell object
    VARFoodCategoriesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //cell row
    NSInteger row = indexPath.row;
    //set cell data
    cell.foodCategoryName.text = [[VARMenuDataSource sharedMenuDataSource] arrayOfCategories][row];
    
    //set category image
    NSString* categoryImageName = [[NSString alloc] initWithFormat:@"image_%@",cell.foodCategoryName.text];
    cell.foodCategoryImage.image = [UIImage imageNamed:categoryImageName];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //get cell
    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
    
    if ([segue.identifier isEqualToString:@"showFoodsListTableView"]) {
        // Fetch data by index path from data source
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        //get index path
        NSUInteger row = indexPath.row;
        NSString *category = [[VARMenuDataSource sharedMenuDataSource] arrayOfCategories][row];
        
        //set next level category
        VARFoodListViewController *foodListController = segue.destinationViewController;
        //set data
        foodListController.currentCategory = category;
        
    }

}

@end
