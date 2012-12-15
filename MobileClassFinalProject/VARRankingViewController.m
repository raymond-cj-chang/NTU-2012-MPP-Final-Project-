//
//  VARRankingViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/3.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARRankingViewController.h"

@interface VARRankingViewController ()

@end

@implementation VARRankingViewController

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
    self.arrayOfFoodDictionary = [[VARMenuDataSource sharedMenuDataSource] arrayOfFoodsByRating];
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
    return [self.arrayOfFoodDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"row:%u",indexPath.row);
    VARRankingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    //[cell.crownImage initWithImage:[UIImage imageNamed:@"Crown-icon.png"]];
    cell.rankingNumber.text = @"test";
    NSDictionary *dictionary = [self.arrayOfFoodDictionary objectAtIndex:indexPath.row];
    cell.EnglishName.text = dictionary[VARsDataSourceDictKeyEnglishName];
    cell.ChineseName.text = dictionary[VARsDataSourceDictKeyChineseName];
    NSString* imageName = [[NSString alloc] initWithFormat:@"image%@_1.jpg",dictionary[VARsDataSourceDictKeyFoodID]];
    NSLog(@"imageName:%@",imageName);
    //[cell.imageView setImage:[UIImage imageNamed:imageName]];
    //cell.imageView.image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(70, 10, 76, 57);
    [cell addSubview:imageView];
    cell.rankingNumber.text = @"1";
    
    return cell;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    if([segue.identifier isEqualToString:@"showFoodDetailView"]){
        VARFoodDetailViewController *detailViewController = segue.destinationViewController;
        //set data
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        detailViewController.food = [self.arrayOfFoodDictionary objectAtIndex:indexPath.row];
        
        //hide tab bar
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
