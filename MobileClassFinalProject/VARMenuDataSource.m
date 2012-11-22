//
//  VARMenuDataSource.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARMenuDataSource.h"

@implementation VARMenuDataSource

//Cache Key
static NSString *VARDataSourceCacheKeyCategories = @"VARDataSourceCacheKey.Cache.Categories";
static NSString *VARDataSourceCacheKeyFoodInCategory = @"VARDataSourceCacheKey.%@.Categories.Food";

NSString * const VARsDataSourceDictKeyCategories = @"Category";
NSString * const VARsDataSourceDictKeyEnglishName = @"EnglishName";
NSString * const VARsDataSourceDictKeyChineseName = @"ChineseName";
NSString * const VARsDataSourceDictKeyFoodIntroduction = @"Introduction";
NSString * const VARsDataSourceDictKeyFoodIngredient = @"Ingredient";
NSString * const VARsDataSourceDictKeyFoodImage = @"Image";
#pragma mark -
#pragma mark Object Lifecycle

//shared menu data
+ (VARMenuDataSource *) sharedMenuDataSource{
    //once flag
    static dispatch_once_t onceFlag;
    //share data
    static VARMenuDataSource *sharedMenuDataSource;
    //only alloc once
    dispatch_once(&onceFlag,^{sharedMenuDataSource = [[self alloc] init];});
    
    return sharedMenuDataSource;
}


//init
- (id) init{
    
    if(self = [super init]){
        
        //plist name
        foodListFileName = [NSString stringWithFormat:@"VARMenuFoodList"];
        
        //get plist file path
        NSString *path = [[NSBundle mainBundle] pathForResource:foodListFileName ofType:@"plist"];
        
        
        //plist to NSArray
        foodList = [NSArray arrayWithContentsOfFile:path];
        
        //test output
        NSLog(@"%@",foodList);
        
        //init cache
        cache = [[NSCache alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark Interface

//clean Cache
- (void) cleanCache{
    [cache removeAllObjects];
}

//refresh food list
- (void) refresh{
    
    //get plist file path
    NSString *path = [[NSBundle mainBundle] pathForResource:foodListFileName ofType:@"plist"];
    
    //plist to NSArray
    foodList = [NSArray arrayWithContentsOfFile:path];
}

- (NSArray *) arrayOfCategories{
    
    //get from cache
    NSArray *categories = [cache objectForKey:VARDataSourceCacheKeyCategories];
    
    //if not in cache
    if(!categories){
        //
        NSMutableSet* categorySet = [NSMutableSet set];
        
        //add in set
        for(NSDictionary *food in foodList){
            [categorySet addObject:food[VARsDataSourceDictKeyCategories]];
        }
        
        // Convert set to array and sort the array.
        categories = [[categorySet allObjects] sortedArrayUsingComparator:
                     ^NSComparisonResult(id obj1, id obj2) {
                         return [obj1 compare:obj2];
                     }];
        //push in cache
        [cache setObject:categories forKey:VARDataSourceCacheKeyCategories];
    }
    
    //return
    return categories;
    
}

//get food from category
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category{
    
    //get from cache
    NSString *cacheKey = [NSString stringWithFormat:VARDataSourceCacheKeyFoodInCategory, category];
    NSMutableArray* foods = [cache objectForKey:cacheKey];
    
    //
    //NSArray *categories = [cache objectForKey:VARDataSourceCacheKeyCategories];
    
    //no in cache
    if(!foods){
        //init
        foods =  [[NSMutableArray alloc] init];
        //add in set
        for(NSDictionary *food in foodList){
            //check category name
            if([food[VARsDataSourceDictKeyCategories] isEqual:category]) [foods addObject:food];
        }
        
        // Convert set to array and sort the array.
        /*  
        foods = [foods sortedArrayUsingComparator:
                      ^NSComparisonResult(id obj1, id obj2) {
                          return [obj1 compare:obj2];
                      }];
        */
        //add in cache
        [cache setObject:foods forKey:cacheKey];
    }
    
    //return
    return [[NSArray alloc] initWithArray:foods];
}

@end
