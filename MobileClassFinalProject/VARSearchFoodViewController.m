//
//  VARSearchFoodViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/6.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARSearchFoodViewController.h"

@interface VARSearchFoodViewController ()

@end

@implementation VARSearchFoodViewController

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
    self.allFood = [[NSArray alloc] initWithArray:[[VARMenuDataSource sharedMenuDataSource] arrayOfEnglishCategories]];
    self.searchResults = [[NSArray alloc] initWithArray:self.allFood];
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    VARSearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (!cell) { 
        cell = [[VARSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
    }
    
    NSInteger row = indexPath.row;
    cell.EnglishName.text = [self.searchResults objectAtIndex:row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
	self.searchResults = [self.allFood filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{   
    [self filterContentForSearchText:searchString scope:@"All"];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{   
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:@"All"];
    return YES;
}

#pragma mark - Cancel Button Clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"click cancel");
    [self.searchDisplayController setActive:NO animated:NO];
    self.searchResults = self.allFood;
    //NSLog(@"result%@",self.searchResults);
    //[self.navigationController popViewControllerAnimated:YES];
}


@end
