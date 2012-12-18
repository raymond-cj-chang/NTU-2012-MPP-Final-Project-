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
    englishToChineseCategory = [[NSMutableDictionary alloc]init];
    [englishToChineseCategory setObject:@"甜點" forKey:@"dessert"];
    [englishToChineseCategory setObject:@"飲料" forKey:@"drinks"];
    [englishToChineseCategory setObject:@"冰" forKey:@"shaved ice"];
    [englishToChineseCategory setObject:@"餃" forKey:@"dumpling"];
    [englishToChineseCategory setObject:@"湯" forKey:@"soup"];
    [englishToChineseCategory setObject:@"其他" forKey:@"other"];
    [englishToChineseCategory setObject:@"小吃" forKey:@"snack"];
    [englishToChineseCategory setObject:@"飯" forKey:@"rice"];
    [englishToChineseCategory setObject:@"麵" forKey:@"noodle"];
    //UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    //[tempImageView setFrame:self.collectionView.frame];
    //self.collectionView.backgroundView = tempImageView;
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

    return [[[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    //cell object
    VARFoodCategoriesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    //cell row

    NSInteger row = indexPath.row;
    //set cell data
    cell.foodCategoryChineseName.text = englishToChineseCategory[[[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories][row]];
    NSLog(@"%@", englishToChineseCategory);
    NSLog(@"EnglishName:%@",[[VARMenuDataSource sharedMenuDataSource] arrayOfChineseCategories][row]);
    cell.foodCategoryEnglishName.text = [[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories][row];

    
    //set category image
    NSString* categoryImageName = [[NSString alloc] initWithFormat:@"image_%@",cell.foodCategoryEnglishName.text];
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
        NSString *category = [[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories][row];
        
        //set next level category
        VARFoodListViewController *foodListController = segue.destinationViewController;
        //set data
        foodListController.currentCategory = category;
        
    }

}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{   
    VARSearchBarView *header = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader])
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"searchBar"
                                                           forIndexPath:indexPath];
        
        header.label.text = @"Car Image Gallery";
    }
    return header;
}

- (IBAction)addingFood:(id)sender {
    [self performSegueWithIdentifier:@"addingFood" sender:sender];
}

@end
