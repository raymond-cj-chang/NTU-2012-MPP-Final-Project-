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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //add search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(120, 0.0, 100, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, 220, 44.0)];
    searchBar.delegate = self;
    //title
    CGRect subtitleFrame = CGRectMake(10, 0, 100, 44);
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:subtitleFrame];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = @"Food Menu";
    titleLabel.adjustsFontSizeToFitWidth = YES;
    //add search bar in navigation Item
    [searchBarView addSubview:searchBar];
    [searchBarView addSubview:titleLabel];
    self.navigationItem.titleView = searchBarView;
    [self.navigationItem.titleView sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    
    //return
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
        
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

@end
