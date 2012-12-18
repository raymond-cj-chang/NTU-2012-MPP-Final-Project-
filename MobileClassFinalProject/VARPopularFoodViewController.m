//
//  VARPopularFoodViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/17.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARPopularFoodViewController.h"

@interface VARPopularFoodViewController ()

@end

@implementation VARPopularFoodViewController

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
    self.arrayOfFoodDictionary = [[NSArray alloc] initWithArray:[[VARMenuDataSource sharedMenuDataSource]arrayOfFoodsByRating]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrayOfFoodDictionary count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VARPopularFoodCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    //NSLog(@"dict:%@",self.arrayOfFoodDictionary[row]);
    NSString *foodID = self.arrayOfFoodDictionary[row][VARsDataSourceDictKeyFoodID];
    //NSLog(@"id:%@",self.arrayOfFoodDictionary[row][VARsDataSourceDictKeyFoodID]);
    NSString *imageNmae = [[NSString alloc] initWithFormat:@"image%@_1.jpg",foodID];
    //NSLog(@"imageName:%@",imageNmae);
    cell.imageView.image = [UIImage imageNamed:imageNmae];
    return cell;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
    
    if([segue.identifier isEqualToString:@"showFoodDetailView"]){
        
        VARFoodDetailViewController *detailViewController = segue.destinationViewController;
        //set data
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        detailViewController.food = [self.arrayOfFoodDictionary objectAtIndex:indexPath.row];
        
        //hide tab bar
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
