//
//  VARMenuDataSource.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARMenuDataSource.h"
#import "FMDatabase.h"

@interface VARMenuDataSource ()
{
    BOOL databaseOpened;
    FMDatabase *_database;
}

@property (nonatomic, readonly) FMDatabase *database;

@end

@implementation VARMenuDataSource

//Cache Key
static NSString *VARDataSourceCacheKeyChineseCategories = @"VARDataSourceCacheKey.Cache.Categories.Chinese";
static NSString *VARDataSourceCacheKeyEnglishCategories = @"VARDataSourceCacheKey.Cache.Categories.English";
static NSString *VARDataSourceCacheKeyFoodInCategory = @"VARDataSourceCacheKey.%@.Categories.Food";

NSString * const VARsDataSourceDictKeyChineseCategories = @"Category_CHN";
NSString * const VARsDataSourceDictKeyEnglishCategories = @"Category_ENG";
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

- (id) init{
    if(self = [super init])
    {
        // Create database
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [documentDir stringByAppendingPathComponent:@"foodMenu.sqlite"];
        _database = [FMDatabase databaseWithPath:path];
        if (![_database open])
        {
            self = nil;
            return self;
        }
        databaseOpened = YES;
        
//        [_database executeUpdate: @"DROP TABLE comments"];
//        [_database executeUpdate: @"DROP TABLE ratings"];
//        [_database executeUpdate: @"DROP TABLE images"];
//        [_database executeUpdate: @"DROP TABLE food_items"];
//        
//        //create table to store food information (name, introduction, ingredients)
//        [_database executeUpdate:
//         @"CREATE TABLE IF NOT EXISTS food_items (id integer NOT NULL PRIMARY KEY AUTOINCREMENT, name text NOT NULL UNIQUE, chinese_name text NOT NULL, english_category text NOT NULL, chinese_category text NOT NULL, introduction text NOT NULL, ingredients text NOT NULL)"];
//        
//        //create table to store images (image name, and id of the food it refers to)
//        [_database executeUpdate:
//         @"CREATE TABLE IF NOT EXISTS images (image_name text NOT NULL, food_id integer NOT NULL, FOREIGN KEY(food_id) REFERENCES food_items(id))"];
//        
//        //create table to store comments (comment text and id of food)
//        [_database executeUpdate:
//         @"CREATE TABLE IF NOT EXISTS comments (comment text NOT NULL, food_id integer NOT NULL, FOREIGN KEY(food_id) REFERENCES food_items(id))"];
//        
//        //create table to store ratings (rating score (1-5?) and id of food)
//        [_database executeUpdate:
//         @"CREATE TABLE IF NOT EXISTS ratings (rating integer NOT NULL, food_id integer NOT NULL, FOREIGN KEY(food_id) REFERENCES food_items(id))"];
//        
//        [self.database executeUpdate:
//         @"INSERT INTO food_items (name, chinese_name, english_category, chinese_category, introduction, ingredients) VALUES (?,?,?,?,?,?)", @"Minced pork rice", @"滷肉飯", @"rice", @"飯", @"This is a famous Taiwanese dish of minced pork (typically pork belly) stewed in a sweet soy sauce mixture for hours, served on a bowl of steamed rice.", @"Rice, pork, soy sauce, sugar, (garlic, shallots)"];
//        
//        [self.database executeUpdate:
//         @"INSERT INTO food_items (name, chinese_name, english_category, chinese_category, introduction, ingredients) VALUES (?,?,?,?,?,?)", @"Oyster vermecilli", @"蚵仔麵線", @"noodles", @"麵", @"This is a famous Taiwanese dish of thin noodles (mian xian/mi sua) in a thick soup, topped with oysters. Cilantro is typically added as a garnish.", @"Thin noodles, oysters, (cilantro)"];
//        
//        [self.database executeUpdate:
//         @"INSERT INTO images (image_name, food_id) VALUES(?, ?)", @"image2_1.jpg", @1];
//        
//        [self.database executeUpdate:
//         @"INSERT INTO images (image_name, food_id) VALUES(?, ?)", @"image2_2.jpg", @1];
        
        // Create cache
        cache = [[NSCache alloc] init];
    }
    return self;

}

- (void)dealloc
{
    [self.database close];
}

- (FMDatabase *)database {
    if (!databaseOpened) {
        [_database open];
        databaseOpened = YES;
    }
    return _database;
}

#pragma mark -
#pragma mark Interface

//clean Cache
- (void) cleanCache{
    [cache removeAllObjects];
}

//refresh food list
- (void) refresh{
    NSMutableSet * foodSet = [NSMutableSet set];
    FMResultSet * queryResults = [self.database executeQuery:@"SELECT name FROM food_items"];
    
    while([queryResults next])
    {
        [foodSet addObject:[queryResults stringForColumn:@"name"]];
    }
    
    foodList = [[foodSet allObjects] sortedArrayUsingComparator:
               ^NSComparisonResult(id obj1, id obj2) {
                   return [obj1 compare:obj2];
               }];
}

- (NSArray *) arrayOfEnglishCategories
{
    return [self arrayOfCategoriesWithCache:YES];
}

- (NSArray *) arrayOfChineseCategories
{
    //get from cache
    NSArray * chineseCategories = [cache objectForKey:VARDataSourceCacheKeyEnglishCategories];
    
    if(!chineseCategories)
    {
        NSMutableSet *categorySet = [NSMutableSet set];
        //execute SQL query to get unique categories
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT chinese_category FROM food_items"];
        
        //add to set
        while([queryResults next])
        {
            [categorySet addObject:[queryResults stringForColumn:@"chinese_category"]];
        }
        
        //Convert set to array and sort the array
        chineseCategories = [[categorySet allObjects] sortedArrayUsingComparator:
                      ^NSComparisonResult(id obj1, id obj2) {
                          return [obj1 compare:obj2];
                      }];
        
        //Add the resulting array to the cache
        [cache setObject:chineseCategories forKey:VARDataSourceCacheKeyEnglishCategories];
    }
    
    return chineseCategories;

}

- (NSArray *)arrayOfCategoriesWithCache:(BOOL)useCache
{
    //get from cache
    NSArray *categories = [cache objectForKey:VARDataSourceCacheKeyEnglishCategories];
    
    if(!categories || !useCache)
    {
        NSMutableSet *categorySet = [NSMutableSet set];
        //execute SQL query to get unique categories
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT english_category FROM food_items"];
        
        //add to set
        while([queryResults next])
        {
            [categorySet addObject:[queryResults stringForColumn:@"english_category"]];
        }
        
        //Convert set to array and sort the array
        categories = [[categorySet allObjects] sortedArrayUsingComparator:
                     ^NSComparisonResult(id obj1, id obj2) {
                         return [obj1 compare:obj2];
                     }];
        
        //Add the resulting array to the cache
        [cache setObject:categories forKey:VARDataSourceCacheKeyEnglishCategories];
    }
    
    return categories;
}

//get food from category
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category{
//TODO: Finish!!!
    //get from cache
    NSString *cacheKey = [NSString stringWithFormat:VARDataSourceCacheKeyFoodInCategory, category];
    NSMutableArray* foods = [cache objectForKey:cacheKey];

    if(!foods)
    {
        //init
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients FROM food_items WHERE english_category = ?", category];
        while([queryResults next])
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setObject:[queryResults stringForColumn:@"name"] forKey:VARsDataSourceDictKeyEnglishName];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_name"] forKey:VARsDataSourceDictKeyChineseName];
            [tempDict setObject:[queryResults stringForColumn:@"english_category"] forKey:VARsDataSourceDictKeyEnglishCategories];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_category"] forKey:VARsDataSourceDictKeyChineseCategories];
            [tempDict setObject:[queryResults stringForColumn:@"introduction"] forKey:VARsDataSourceDictKeyFoodIntroduction];
            [tempDict setObject:[queryResults stringForColumn:@"ingredients"] forKey:VARsDataSourceDictKeyFoodIngredient];
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                [tempArray addObject:[imageResults stringForColumn:@"image_name"]];
            }
            
            //add the image array to the temp dict
            [tempDict setObject:tempArray forKey:VARsDataSourceDictKeyFoodImage];
            [foods addObject:tempDict];
        }
        //add in cache
        [cache setObject:foods forKey:cacheKey];
    }
    //return
    return [[NSArray alloc] initWithArray:foods];
}

@end
