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
static NSString * VARDataSourceCacheKeyChineseCategories = @"VARDataSourceCacheKey.Cache.Categories.Chinese";
static NSString * VARDataSourceCacheKeyEnglishCategories = @"VARDataSourceCacheKey.Cache.Categories.English";
static NSString * VARDataSourceCacheKeyFoodInCategory = @"VARDataSourceCacheKey.%@.Categories.Food";
static NSString * VARDataSourceCacheKeyFoodByRating = @"VARDataSourceCacheKey.%@.Food.Rating";
static NSString * VARDataSourceCacheKeyFoodByAlphabeticalOrder = @"VARDataSourceCacheKey.%@.Food.Alphabetical.Order";
//static NSString * VARDataSourceCacheKeyFoodByRating = @"VARDataSourceCacheKey.%@.Food.Rating";

NSString * const VARsDataSourceDictKeyChineseCategories = @"Category_CHN";
NSString * const VARsDataSourceDictKeyEnglishCategories = @"Category_ENG";
NSString * const VARsDataSourceDictKeyEnglishName = @"EnglishName";
NSString * const VARsDataSourceDictKeyChineseName = @"ChineseName";
NSString * const VARsDataSourceDictKeyFoodIntroduction = @"Introduction";
NSString * const VARsDataSourceDictKeyFoodIngredient = @"Ingredient";
NSString * const VARsDataSourceDictKeyRating = @"Rating";
NSString * const VARsDataSourceDictKeyFoodImage = @"Image";
NSString * const VARsDataSourceDictKeyFoodID = @"FID";
NSString * const VARsDataSourceDictKeyComment = @"Comment";
NSString * const VARsDataSourceDictKeyCommentContent = @"Comment_content";
NSString * const VARsDataSourceDictKeyCommentTimestamp = @"Comment_timestamp";
NSString * const VARsDataSourceDictKeyPinyin = @"Pinyin";

//global server url
NSString* const serverURL = @"http://varfinalprojectserver.appspot.com";
                       
//global operation queue
NSOperationQueue* globalOperationQueue;

//global lock
NSCondition* requestLock;

#pragma mark -
#pragma mark Object Lifecycle

//shared menu data
+ (VARMenuDataSource *) sharedMenuDataSource{
    //once flag
    static dispatch_once_t onceFlag;
    
    //share data
    static VARMenuDataSource *sharedMenuDataSource;
    
    //only alloc once
    dispatch_once(&onceFlag,^{
        sharedMenuDataSource = [[self alloc] init];
    });
    
    return sharedMenuDataSource;
}

- (id) init{
    if(self = [super init])
    {
        // Create database
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *targetPath = [libraryPath stringByAppendingPathComponent:@"foodMenu.sqlite"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            // database doesn't exist in your library path... copy it from the bundle
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"foodMenu" ofType:@"sqlite"];
            NSLog(@"sourcePath = %@", sourcePath);
            NSError *error = nil;
            
            if (![[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:&error]) {
                NSLog(@"Error: %@", error);
            }
        }
        
        NSLog(@"DB path = %@",targetPath);
        _database = [FMDatabase databaseWithPath:targetPath];
        if (![_database open])
        {
            self = nil;
            return self;
        }
        databaseOpened = YES;
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
    //clean cache
    //[cache removeAllObjects];
    
    NSLog(@"Refresh!");
    
    //refresh
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
    NSArray * chineseCategories = [cache objectForKey:VARDataSourceCacheKeyChineseCategories];
    
    if(!chineseCategories)
    {
        NSMutableSet *categorySet = [NSMutableSet set];
        //execute SQL query to get unique categories
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT english_category, chinese_category FROM food_items ORDER BY english_category"];
        
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
        [cache setObject:chineseCategories forKey:VARDataSourceCacheKeyChineseCategories];
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
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT english_category, chinese_category FROM food_items ORDER BY english_category"];
        
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

//gets all foods sorted by rating.
- (NSArray *) arrayOfFoodsByRating
{
    //get from cache
    NSMutableArray* foods = [cache objectForKey:VARDataSourceCacheKeyFoodByRating];
    
    if(!foods)
    {
        //initalize
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients, rating, pinyin FROM food_items ORDER BY rating DESC"];
        while([queryResults next])
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setObject:[queryResults stringForColumn:@"name"] forKey:VARsDataSourceDictKeyEnglishName];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_name"] forKey:VARsDataSourceDictKeyChineseName];
            [tempDict setObject:[queryResults stringForColumn:@"english_category"] forKey:VARsDataSourceDictKeyEnglishCategories];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_category"] forKey:VARsDataSourceDictKeyChineseCategories];
            [tempDict setObject:[queryResults stringForColumn:@"introduction"] forKey:VARsDataSourceDictKeyFoodIntroduction];
            [tempDict setObject:[queryResults stringForColumn:@"ingredients"] forKey:VARsDataSourceDictKeyFoodIngredient];
            [tempDict setObject:[queryResults stringForColumn:@"id"] forKey:VARsDataSourceDictKeyFoodID];
            [tempDict setObject:[queryResults stringForColumn:@"rating"] forKey:VARsDataSourceDictKeyRating];
            [tempDict setObject:[queryResults stringForColumn:@"pinyin"] forKey:VARsDataSourceDictKeyPinyin];
            
            //NSLog(@"%@", [queryResults stringForColumn:@"name"]);
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                [tempImageArray addObject:[imageResults stringForColumn:@"image_name"]];
            }
            
            //add the image array to the temp dict
            [tempDict setObject:tempImageArray forKey:VARsDataSourceDictKeyFoodImage];
            
			//add dictionary of comments
            FMResultSet * commentResults = [self.database executeQuery:@"SELECT * FROM comments WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempCommentArray = [[NSMutableArray alloc]init];
            while([commentResults next])
            {
				NSMutableDictionary * tempCommentDict = [[NSMutableDictionary alloc] init];
                [tempCommentDict setObject:[commentResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[commentResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
				[tempCommentArray addObject: tempCommentDict];
            }
            
            //add the comment dictionary to the temp dict
            [tempDict setObject:tempCommentArray forKey:VARsDataSourceDictKeyComment];
            [foods addObject:tempDict];
        }
        //add in cache
        [cache setObject:foods forKey:VARDataSourceCacheKeyFoodByRating];
    }
    //return
    return [[NSArray alloc] initWithArray:foods];
}

//returns an array of all the foods, arranged in alphabetical order
- (NSArray *) arrayOfFoodsByAlphabeticalOrder
{
    //get from cache
    NSMutableArray* foods = [cache objectForKey:VARDataSourceCacheKeyFoodByAlphabeticalOrder];
    
    if(!foods)
    {
        //initalize
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients, rating, pinyin FROM food_items ORDER BY name"];
        while([queryResults next])
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setObject:[queryResults stringForColumn:@"name"] forKey:VARsDataSourceDictKeyEnglishName];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_name"] forKey:VARsDataSourceDictKeyChineseName];
            [tempDict setObject:[queryResults stringForColumn:@"english_category"] forKey:VARsDataSourceDictKeyEnglishCategories];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_category"] forKey:VARsDataSourceDictKeyChineseCategories];
            [tempDict setObject:[queryResults stringForColumn:@"introduction"] forKey:VARsDataSourceDictKeyFoodIntroduction];
            [tempDict setObject:[queryResults stringForColumn:@"ingredients"] forKey:VARsDataSourceDictKeyFoodIngredient];
            [tempDict setObject:[queryResults stringForColumn:@"id"] forKey:VARsDataSourceDictKeyFoodID];
            [tempDict setObject:[queryResults stringForColumn:@"rating"] forKey:VARsDataSourceDictKeyRating];
            [tempDict setObject:[queryResults stringForColumn:@"pinyin"] forKey:VARsDataSourceDictKeyPinyin];
            
            //NSLog(@"%@", [queryResults stringForColumn:@"name"]);
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                [tempImageArray addObject:[imageResults stringForColumn:@"image_name"]];
            }
            
            //add the image array to the temp dict
            [tempDict setObject:tempImageArray forKey:VARsDataSourceDictKeyFoodImage];
            
			//add dictionary of comments
            FMResultSet * commentResults = [self.database executeQuery:@"SELECT * FROM comments WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempCommentArray = [[NSMutableArray alloc]init];
            while([commentResults next])
            {
				NSMutableDictionary * tempCommentDict = [[NSMutableDictionary alloc] init];
                [tempCommentDict setObject:[commentResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[commentResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
				[tempCommentArray addObject: tempCommentDict];
            }
            
            //add the comment dictionary to the temp dict
            [tempDict setObject:tempCommentArray forKey:VARsDataSourceDictKeyComment];
            [foods addObject:tempDict];
        }
        //add in cache
        [cache setObject:foods forKey:VARDataSourceCacheKeyFoodByAlphabeticalOrder];
    }
    //return
    return [[NSArray alloc] initWithArray:foods];
}


//returns an array of all the foods, arranged in alphabetical order
- (NSDictionary *) getFoodItemByFID:(NSString*)fidStr
{
    //get from cache
    //NSDictionary* food = [cache objectForKey];
    
    NSMutableDictionary* foodItem = [[NSMutableDictionary alloc] init];
    
    //if(!foodItem)
    {
        //sadsa
        //initalize
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients, rating, pinyin FROM food_items WHERE id = ?",fidStr];
        
        if(queryResults!=nil)
        {
            [queryResults next];
            foodItem[VARsDataSourceDictKeyEnglishName] = [queryResults stringForColumn:@"name"];
            foodItem[VARsDataSourceDictKeyChineseName] = [queryResults stringForColumn:@"chinese_name"];
            foodItem[VARsDataSourceDictKeyEnglishCategories] = [queryResults stringForColumn:@"english_category"];
            foodItem[VARsDataSourceDictKeyChineseCategories] = [queryResults stringForColumn:@"chinese_category"];
            foodItem[VARsDataSourceDictKeyFoodIntroduction] = [queryResults stringForColumn:@"introduction"];
            foodItem[VARsDataSourceDictKeyFoodIngredient] = [queryResults stringForColumn:@"ingredients"];
            foodItem[VARsDataSourceDictKeyFoodID] = [queryResults stringForColumn:@"id"];
            foodItem[VARsDataSourceDictKeyRating] = [queryResults stringForColumn:@"rating"];
            foodItem[VARsDataSourceDictKeyPinyin] = [queryResults stringForColumn:@"pinyin"];

            //NSLog(@"%@", [queryResults stringForColumn:@"name"]);
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                [tempImageArray addObject:[imageResults stringForColumn:@"image_name"]];
            }
            
            //add the image array to the temp dict
            foodItem[VARsDataSourceDictKeyFoodImage] = tempImageArray;
            
			//add dictionary of comments
            FMResultSet * commentResults = [self.database executeQuery:@"SELECT * FROM comments WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempCommentArray = [[NSMutableArray alloc]init];
            while([commentResults next])
            {
				NSMutableDictionary * tempCommentDict = [[NSMutableDictionary alloc] init];
                [tempCommentDict setObject:[commentResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[commentResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
				[tempCommentArray addObject: tempCommentDict];
            }
            
            //add the comment dictionary to the temp dict
            foodItem[VARsDataSourceDictKeyComment] = tempCommentArray;
        }
    }
    //return
    return foodItem;
}


//get food from category
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category{
    //get from cache
    NSString *cacheKey = [NSString stringWithFormat:VARDataSourceCacheKeyFoodInCategory, category];
    NSMutableArray* foods = [cache objectForKey:cacheKey];

    if(!foods)
    {
        //init
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients, rating, pinyin FROM food_items WHERE english_category = ?", category];
        while([queryResults next])
        {
            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setObject:[queryResults stringForColumn:@"name"] forKey:VARsDataSourceDictKeyEnglishName];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_name"] forKey:VARsDataSourceDictKeyChineseName];
            [tempDict setObject:[queryResults stringForColumn:@"english_category"] forKey:VARsDataSourceDictKeyEnglishCategories];
            [tempDict setObject:[queryResults stringForColumn:@"chinese_category"] forKey:VARsDataSourceDictKeyChineseCategories];
            [tempDict setObject:[queryResults stringForColumn:@"introduction"] forKey:VARsDataSourceDictKeyFoodIntroduction];
            [tempDict setObject:[queryResults stringForColumn:@"ingredients"] forKey:VARsDataSourceDictKeyFoodIngredient];
            [tempDict setObject:[queryResults stringForColumn:@"id"] forKey:VARsDataSourceDictKeyFoodID];
            [tempDict setObject:[queryResults stringForColumn:@"rating"] forKey:VARsDataSourceDictKeyRating];
            [tempDict setObject:[queryResults stringForColumn:@"pinyin"] forKey:VARsDataSourceDictKeyPinyin];
            
            //NSLog(@"%@", [queryResults stringForColumn:@"name"]);
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempImageArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                [tempImageArray addObject:[imageResults stringForColumn:@"image_name"]];
            }
            
            //add the image array to the temp dict
            [tempDict setObject:tempImageArray forKey:VARsDataSourceDictKeyFoodImage];
            
			//add dictionary of comments
            FMResultSet * commentResults = [self.database executeQuery:@"SELECT * FROM comments WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempCommentArray = [[NSMutableArray alloc]init];
            
            while([commentResults next])
            {
				NSMutableDictionary * tempCommentDict = [[NSMutableDictionary alloc] init];
                [tempCommentDict setObject:[commentResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[commentResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
				[tempCommentArray addObject: tempCommentDict];
            }
            
            //add the comment dictionary to the temp dict
            [tempDict setObject:tempCommentArray forKey:VARsDataSourceDictKeyComment];
            [foods addObject:tempDict];
        }
        //add in cache
        [cache setObject:foods forKey:cacheKey];
    }
    //return
    return [[NSArray alloc] initWithArray:foods];
}

/**
 Adds a comment to the specified food item.
 */

- (void) addCommentToFoodItem:(NSInteger)foodID withContents:(NSString *)contents withDate:(NSString*)dateTimeStr
{
    /*
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString * currentDate = [DateFormatter stringFromDate:[NSDate date]];
     */
    
    //split string
    NSString* splitDateTimeStr = [[dateTimeStr componentsSeparatedByString:@"."] objectAtIndex:0];
    
    
    [self.database executeUpdate:@"INSERT INTO comments (comment, timestamp, food_id) values (?,?,?)",
     contents, splitDateTimeStr, [NSString stringWithFormat:@"%i", foodID]];
}

/**
 Adds an image to the specified food item.
 */

- (void) addImageToFoodItem:(NSInteger)foodID withImageName:(NSString *)imageName
{
    [self.database executeUpdate:@"INSERT INTO images (image_name, food_id) values (?,?)",
     imageName,[NSString stringWithFormat:@"%i", foodID]];
}

//update rating
-(void) updateRatingToFoodItem:(NSString*)fidStr withRating:(NSString*)rating
{
    //update rating
    NSString* sql =[NSString stringWithFormat: @"UPDATE food_items SET rating='%@' WHERE id = '%@'",rating,fidStr];
    [self.database executeUpdate:sql];
}


//Adds a food item to the database table. The item must be added in dictionary form.
//(ask Raymond if need further explanation)
//This dictionary should only contain the basic information and images; nothing else will be added.
- (void) addFoodItemToDB:(NSDictionary *) foodItem
{
    //NSLog(@"Add Food item in DB :%@",foodItem[VARsDataSourceDictKeyEnglishName]);
    
    //grab attributes from NSDictionary
    NSString * name = foodItem[VARsDataSourceDictKeyEnglishName];
    NSString * chineseName = foodItem[VARsDataSourceDictKeyChineseName];
    NSString * englishCategory = foodItem[VARsDataSourceDictKeyEnglishCategories];
    NSString * chineseCategory = foodItem[VARsDataSourceDictKeyChineseCategories];
    NSString * introduction = foodItem[VARsDataSourceDictKeyFoodIntroduction];
    NSString * ingredients = foodItem[VARsDataSourceDictKeyFoodIngredient];
    NSString * food_id = foodItem[VARsDataSourceDictKeyFoodID];
    
    //check
    if(food_id == nil)
    {
        return;
    }
    if(name == nil) name = @"";
    if(chineseName == nil) chineseName = @"";
    if(englishCategory == nil) englishCategory = @"";
    if(chineseCategory == nil) chineseCategory = @"";
    if(introduction == nil) introduction = @"";
    if(ingredients == nil) ingredients = @"";
    
    //query for insert food item
    [self.database executeUpdate:@"INSERT INTO food_items (id, name, chinese_name, english_category, chinese_category, introduction, ingredients,rating) VALUES (?,?,?,?,?,?,?,?)", food_id, name, chineseName, englishCategory, chineseCategory, introduction, ingredients,@"0"];
    
    //add image
    /*
    NSArray * images = foodItem[VARsDataSourceDictKeyFoodImage];
    
    for(NSString * imageName in images)
    {
        [self.database executeUpdate:@"INSERT INTO images (image_name, food_id) values (?,?)",
         imageName, food_id];
    }
    */
}


#pragma mark -
#pragma mark Connect Server Interface
//Connect to Server

//download new food data
- (void)downloadFoodDataFromGAEServer
{
    
    //download new data from server
    
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      
    //get last update time from file
    NSDictionary* dateTimeDictionary = [self getLastTimeUpdateTimeDateFromFile];
    
    
    //**download all update food comment from server
    
    //post to server string with date time
    NSString* serverForCommentTableStr = [NSString stringWithFormat:@"%@/seeCommentTable?year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",serverURL,dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]];
    
    NSURL* serverForCommentTableURL = [NSURL URLWithString:serverForCommentTableStr];
    
    //lock
    //[requestLock lock];
    
    //Request for new food item
    AFJSONRequestOperation *requestCommentTableOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverForCommentTableURL]
                                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            
                                                                                                   
                                                                                                     
                                                                                                   //food dictionary
                                                                                                   NSDictionary *downloadFoodDictionary = (NSDictionary*)JSON;
                                                                                                   
                                                                                                   //JSON decoder
                                                                                                   JSONDecoder* JSONDecoderForFoodDictionary = (JSONDecoder*)JSON;
                                                                                                   JSONDecoder* foodItemDecoder;
                                                                                                   //loop for all food item
                                                                                                   for (NSString *foodItemName in downloadFoodDictionary)
                                                                                                   {
                                                                                                       //JSON food item
                                                                                                       foodItemDecoder = [JSONDecoderForFoodDictionary valueForKey:foodItemName];
                                                                                                       
                                                                                                       NSLog(@"Comment element:%@",foodItemDecoder);
                                                                    //add comments in SQLite
                                                                                                       NSInteger fid = [[foodItemDecoder valueForKey:@"Fid"] intValue];
                                                                    
                                       
                                                                    [[VARMenuDataSource sharedMenuDataSource]addCommentToFoodItem:fid withContents:[foodItemDecoder valueForKey:@"Comment"] withDate:[foodItemDecoder valueForKey:@"UploadTime"]];
                                                                                                   }
                                                                                                   
                                                                                                   //
                                                                    //unlock
                                                                    //[requestLock unlock];
                                                                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                                                    
                                                                                                   //unlock
                                                                                                   //[requestLock unlock];
                                                                                                   NSLog(@"Error : %@",error);
                                                                                               }];
    
    //add in global queue
    [globalOperationQueue addOperation:requestCommentTableOperation];
    
    
    //**download all update food rating from server
    
    //post to server string with date time
    NSString* serverForRatingTableStr = [NSString stringWithFormat:@"%@/seeRatingTable?year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",serverURL,dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]];
    
    NSURL* serverForRatingTableURL = [NSURL URLWithString:serverForRatingTableStr];
    
    //lock
    //[requestLock lock];
    
    //Request for new food item
    AFJSONRequestOperation *requestRatingTableOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverForRatingTableURL]
                                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                               
                                                                                                                                                      //food dictionary
                                                                                                               NSDictionary *downloadFoodDictionary = (NSDictionary*)JSON;
                                                                                                               
                                                                                                               //JSON decoder
                                                                                                               JSONDecoder* JSONDecoderForFoodDictionary = (JSONDecoder*)JSON;
                                                                                                               JSONDecoder* foodItemDecoder;
                                                                                                               //loop for all food item
                                                                                                               for (NSString *foodItemName in downloadFoodDictionary)
                                                                                                               {
                                                                                                                   //JSON food item
                                                                                                                   foodItemDecoder = [JSONDecoderForFoodDictionary valueForKey:foodItemName];
                                                                                                                   
                                                                                                                   NSLog(@"Ratig  element:%@",foodItemDecoder);
                                                                                                                   //add comments in SQLite
                                                                                                                   NSString* fidStr = [foodItemDecoder valueForKey:@"Fid"];
                                                                                                                   
                                                                                                                   NSString* foodRating = [foodItemDecoder valueForKey:@"rating"];
                                                                    //add rating
                                                                                                                   //**add rating in SQLite
                                                                    [[VARMenuDataSource sharedMenuDataSource] updateRatingToFoodItem:fidStr withRating:foodRating];
                                                                                                               }
                                                                                                               
                                                                                                               //unlock
                                                                    //[requestLock unlock];
                                                                                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                                                                                               
                                                                                                               //unlock
                                                                                                               //[requestLock unlock];
                                                                                                               NSLog(@"Error : %@",error);
                                                                                                           }];
    
    //add in global queue
    [globalOperationQueue addOperation:requestRatingTableOperation];
    

    //**download all update food rating from server
    
    //post to server string with date time
    NSString* serverForImageTableStr = [NSString stringWithFormat:@"%@/seeImageTable?year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",serverURL,dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]];
    
    NSURL* serverForImageTableURL = [NSURL URLWithString:serverForImageTableStr];
    
    //Request for new food item
    AFJSONRequestOperation *requestImageTableOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverForImageTableURL]
                                                                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                              
                                                                                                              //food dictionary
                                                                                                              NSDictionary *downloadFoodDictionary = (NSDictionary*)JSON;
                                                                                                              
                                                                                                              //JSON decoder
                                                                                                              JSONDecoder* JSONDecoderForFoodDictionary = (JSONDecoder*)JSON;
                                                                                                              JSONDecoder* foodItemDecoder;
                                                                                                              //loop for all food item
                                                                                                              for (NSString *foodItemName in downloadFoodDictionary)
                                                                                                              {
                                                                                                                  //JSON food item
                                                                                                                  foodItemDecoder = [JSONDecoderForFoodDictionary valueForKey:foodItemName];
                                                                                                                  
                                                                                                                  NSLog(@"Image element:%@",foodItemDecoder);
                                                                                                                  //add comments in SQLite
                                                                                                                  NSString* imageName = [foodItemDecoder valueForKey:@"imageName"];
                                                                                                            
                                                                    NSString* fidStr = [foodItemDecoder valueForKey:@"Fid"];
                                                                                                                  //server URL
                                                                                                                  NSString *serverImageURL = [NSString stringWithFormat:@"%@/downloadImage",serverURL];
                                                                                                                  
                                                                                                                  //download image from server
                                                                                                                  if(imageName!=nil)
                                                                                                                  {
                                                                                                                      //server url
                                                                                                                      NSString *imageURL = [NSString stringWithFormat:@"%@?image_name=%@",serverImageURL,imageName];
                                                                                                                      // Get an image from the URL below
                                                                                                                      UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                                                                                                                      
                                                                                                                      //save to jepg
                                                                                                                      NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
                                                                                                                      NSData *imageJPEGData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                                                                                                                      [imageJPEGData writeToFile:jpegFilePath atomically:YES];
                                                                                                                      
                                                                                                                      NSLog(@"[Client] saving image %@ From %@ ,to %@",imageName,imageURL,docDir);
                                                                                                                      
                                                                                                                      //add image in SQLite DB
                                                                                                                      NSInteger fid = [fidStr intValue];
                                                                                                                      [[VARMenuDataSource sharedMenuDataSource]addImageToFoodItem:fid withImageName:imageName];
                                                                                                                  }

                                                                                                              }
                                                                                                              //
                                                                                                              //unlock
                                                                                                              //[requestLock unlock];
                                                                                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                                                                                              
                                                                                                              //unlock
                                                                                                              //[requestLock unlock];
                                                                                                              NSLog(@"Error : %@",error);
                                                                                                          }];
    
    //add in global queue
    [globalOperationQueue addOperation:requestImageTableOperation];
    
    
    //**download food item from server
    
    //post to server string with date time
    NSString* serverStr = [NSString stringWithFormat:@"%@/?year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",serverURL,dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]];
    
    //server URL
    NSURL* serverURL = [NSURL URLWithString:serverStr];
    
    //lock
    //[requestLock lock];
    
    //Request for new food item
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverURL]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        
                                                        //print
                                                        //NSLog(@"Response for add food:%@",JSON);
                                                   
                                                        //food dictionary
                                                        NSDictionary *downloadFoodDictionary = (NSDictionary*)JSON;
                                                                                                   
                                                        //JSON decoder
                                                        JSONDecoder* JSONDecoderForFoodDictionary = (JSONDecoder*)JSON;
                                                        JSONDecoder* foodItemDecoder;
                                                        //loop for all food item
                                                        for (NSString *foodItemName in downloadFoodDictionary)
                                                        {
                                                                //JSON food item
                                                                foodItemDecoder = [JSONDecoderForFoodDictionary valueForKey:foodItemName];
                                                                                                       
                                                                //print
                                                                /*
                                                                NSLog(@"fid = %@",[foodItemDecoder valueForKey:@"Fid"]);
                                                                NSLog(@"English name = %@",[foodItemDecoder valueForKey:@"EnglishName"]);
                                                                NSLog(@"Chinese name = %@",[foodItemDecoder valueForKey:@"ChineseName"]);
                                                                */
                                                            
                                                                //food item data
                                                                //NSString* fidStr = [foodItemDecoder valueForKey:@"Fid"];
                                                                
                                                                NSMutableDictionary* foodItem = [[NSMutableDictionary alloc] init];
                                                                foodItem[VARsDataSourceDictKeyFoodID]= [foodItemDecoder valueForKey:@"Fid"];
                                                                foodItem[VARsDataSourceDictKeyEnglishName] = [foodItemDecoder valueForKey:@"EnglishName"];
                                                                foodItem[VARsDataSourceDictKeyChineseName] = [foodItemDecoder valueForKey:@"ChineseName"];
                                                                foodItem[VARsDataSourceDictKeyEnglishCategories] = [foodItemDecoder valueForKey:@"EnglishCategory"];;
                                                                foodItem[VARsDataSourceDictKeyChineseCategories] = [foodItemDecoder valueForKey:@"ChineseCategory"];
                                                                foodItem[VARsDataSourceDictKeyFoodIntroduction] = [foodItemDecoder valueForKey:@"Introduction"];
                                                                foodItem[VARsDataSourceDictKeyFoodIngredient] = [foodItemDecoder valueForKey:@"Ingredients"];
                                                            
                                                        
                                                                //add food item in SQLite
                                                                [[VARMenuDataSource sharedMenuDataSource] addFoodItemToDB:foodItem];
                                                            
                                                            }
                                                                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                                   
                                                   NSLog(@"Error : %@",error);
                                               }];
    
    //add in global queue
    [globalOperationQueue addOperation:requestOperation];
    
    //**may wait util all data download
    //wait
    //[globalOperationQueue waitUntilAllOperationsAreFinished];
    
    //add observe for download finish
    [globalOperationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];

}



//check operation queue empty
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == globalOperationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([globalOperationQueue.operations count] == 0) {
            // Do something here when your queue has completed
            //get current date time
            [self getCurrentTimeFromGAEServer];
            
            //refresh
            [[VARMenuDataSource sharedMenuDataSource] cleanCache];
            [[VARMenuDataSource sharedMenuDataSource] refresh];
            
            //print information
            NSLog(@"[Client]Download food data finish.");
            
            //remove observer
            [globalOperationQueue removeObserver:self forKeyPath:@"operations"];
            
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}


- (void) downloadImageFromGAEServer:(NSString*)fidStr
{
    //download food image from server
    
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    //download image table for this food fid
    
    //image name array
    NSMutableArray* imageNameArray = [[NSMutableArray alloc] init];
    
    //server image table path
    NSString *serverDownloadImageTablePath = [NSString stringWithFormat:@"%@/seeImageTable?fid=%@",serverURL,fidStr];
    //
    //add last update time from file
    NSDictionary* dateTimeDictionary = [self getLastTimeUpdateTimeDateFromFile];
    
    serverDownloadImageTablePath = [serverDownloadImageTablePath  stringByAppendingString:[NSString stringWithFormat:@"&year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]]];
    //
    
    NSURL* serverDownloadImageTableURL = [NSURL URLWithString:serverDownloadImageTablePath];
    
    //Request for food image table
    AFJSONRequestOperation *operations = [AFJSONRequestOperation
                                          JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverDownloadImageTableURL]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                              
                                              //convert to NSDictionary
                                              NSDictionary *downloadFoodImageTableDictionary = (NSDictionary*)JSON;
                                              //JSON decoder
                                              JSONDecoder* JSONDecoderForFoodImageNameDictionary = (JSONDecoder*)JSON;
                                              JSONDecoder* foodImageTableDecoder;
                                              
                                              //loop for all food item
                                              for (NSString *foodImageName in downloadFoodImageTableDictionary)
                                              {
                                                  //JSON food item
                                                  foodImageTableDecoder = [JSONDecoderForFoodImageNameDictionary valueForKey:foodImageName];
                                                  
                                                  //print
                                                  NSLog(@"Image Name = %@",[foodImageTableDecoder valueForKey:@"imageName"]);
                                                  
                                                  //image name
                                                  NSString* imageName = [foodImageTableDecoder valueForKey:@"imageName"];
                                                  
                                                  //server URL
                                                  NSString *serverImageURL = [NSString stringWithFormat:@"%@/downloadImage",serverURL];
                                                  
                                                  //download image from server
                                                  if(imageName!=nil)
                                                  {
                                                      //server url
                                                      NSString *imageURL = [NSString stringWithFormat:@"%@?image_name=%@",serverImageURL,imageName];
                                                      // Get an image from the URL below
                                                      UIImage* image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                                                      
                                                      //save to jepg
                                                      NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
                                                      NSData *imageJPEGData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                                                      [imageJPEGData writeToFile:jpegFilePath atomically:YES];
                                                      
                                                      NSLog(@"[Client] saving image %@ From %@ ,to %@",imageName,imageURL,docDir);
                                                      
                                                      //add image in SQLite DB
                                                      NSInteger fid = [fidStr intValue];
                                                      [[VARMenuDataSource sharedMenuDataSource]addImageToFoodItem:fid withImageName:imageName];
                                                  }
                                                  
                                                  //add image name in array
                                                  if(imageName!=nil) [imageNameArray addObject:imageName];
                                                  
                                              }
                                              
                                              //[self.activityIndicator stopAnimating];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                              NSLog(@"Error : %@",error);
                                          }];
    
    //add in global queue
    [globalOperationQueue addOperation:operations];
}


//upload image to server
- (void)uploadFoodImageToGAEServer:(NSString*)fidStr withImageName:(NSString*)uploadImageName withImage:(UIImage*) image updateFood:(BOOL)update
{
    //upload image
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //server URL
    NSURL *serverUploadImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/uploadImage",serverURL]];
    
    //prepare data
    NSString* uploadImageFidStr = fidStr;
    NSString *imageName = uploadImageName;
    NSString *uploadJPEGFilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
    UIImage *uploadImage;
    
    //from file name
    if(uploadImageName!=nil)
    {
        uploadImage = [UIImage imageWithContentsOfFile:uploadJPEGFilePath];
    }
    //from image
    else
    {
        uploadImage = image;
    }
    
    // create request
    NSMutableURLRequest *uploadImageRequest = [[NSMutableURLRequest alloc] init];
    [uploadImageRequest setURL:serverUploadImageURL];
    [uploadImageRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [uploadImageRequest setHTTPShouldHandleCookies:NO];
    [uploadImageRequest setTimeoutInterval:60];
    [uploadImageRequest setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"----BoundaryForFileField";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [uploadImageRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSData *imageData = UIImageJPEGRepresentation(uploadImage, 1.0);
    // post body
    NSMutableData *body = [NSMutableData data];
    
    //add image content into body
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add fid into body
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"fid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",uploadImageFidStr] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add image name into body
    /*
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"imagename\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[imageName dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    */
    
    //end boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //set body
    [uploadImageRequest setHTTPBody:body];
    
    //connect to server
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *uploadImageOperation = [[AFHTTPRequestOperation alloc] initWithRequest:uploadImageRequest];
    
    [uploadImageOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];
        NSLog(@"response for upload image POST: [%@]",response);
        
        //download food item from server
        if(update)[[VARMenuDataSource sharedMenuDataSource] downloadFoodDataFromGAEServer];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [uploadImageOperation start];
    
}

//add comment to server
- (void)uploadCommentToGAEServer:(NSString*)foodID withComment:(NSString*)foodComment updateFood:(BOOL)update
{
    //check
    if(foodComment==nil) foodComment = @"comment.";
    
    //food id str
    NSString* foodIDStr = foodID;
    //foodIDStr = @"101";
    
    //clent url
    NSURL *clientURL = [NSURL URLWithString:@"http://localhost"];
    NSString *serverAddCommentPath = [NSString stringWithFormat:@"%@/addComment",serverURL];
    
    //client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:clientURL];
    
    //comment parms
    NSDictionary *commentParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   foodIDStr, @"fid",
                                   foodComment, @"comment",
                                   nil];
    //comment request
    NSMutableURLRequest *commentRequest = [httpClient requestWithMethod:@"POST" path:serverAddCommentPath parameters:commentParams];
    
    //connect to server
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *addCommentOperation = [[AFHTTPRequestOperation alloc] initWithRequest:commentRequest];
    
    //success and failure
    [addCommentOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];
        NSLog(@"response for add comment POST: [%@]",response);
        
        //download food item from server
        if(update) [[VARMenuDataSource sharedMenuDataSource] downloadFoodDataFromGAEServer];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [addCommentOperation start];
    
}

//download comment
- (void)downloadCommentFromGAEServer:(NSString*)foodID
{
    //see comments
    //NSLog(@"Download Comment....");
    
    //server path
    NSString *serverDownloadCommentPath = [NSString stringWithFormat:@"%@/seeComment?fid=%@",serverURL,foodID];
    
    //
    //add last update time from file
    NSDictionary* dateTimeDictionary = [self getLastTimeUpdateTimeDateFromFile];
    
    serverDownloadCommentPath = [serverDownloadCommentPath  stringByAppendingString:[NSString stringWithFormat:@"&year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]]];
    //
    
    //server URL
    NSURL* serverDownloadCommentURL = [NSURL URLWithString:serverDownloadCommentPath];
    
    //Request for food comment
    AFJSONRequestOperation *operations = [AFJSONRequestOperation
                                          JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverDownloadCommentURL]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                              
                                              //convert to NSDictionary
                                              NSDictionary *downloadFoodCommentDictionary = (NSDictionary*)JSON;
                                              //JSON decoder
                                              JSONDecoder* JSONDecoderForFoodCommentDictionary = (JSONDecoder*)JSON;
                                              JSONDecoder* foodCommentDecoder;
                                              
                                              //loop for all food item
                                              for (NSString *foodCommentName in downloadFoodCommentDictionary)
                                              {
                                                  //JSON food item
                                                  foodCommentDecoder = [JSONDecoderForFoodCommentDictionary valueForKey:foodCommentName];
                                                  
                                                  //print
                                                  NSLog(@"Comment = %@",[foodCommentDecoder valueForKey:@"Comment"]);
                                                  
                                                //add comments in SQLite
                                                NSInteger fid = [foodID intValue];
                                                [[VARMenuDataSource sharedMenuDataSource]addCommentToFoodItem:fid withContents:[foodCommentDecoder valueForKey:@"Comment"] withDate:[foodCommentDecoder valueForKey:@"UploadTime"]];
                                              }
                                              
                                              //[self.activityIndicator stopAnimating];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                              NSLog(@"Error : %@",error);
                                          }];
    
    //add in global queue
    [globalOperationQueue addOperation:operations];
    
}

//add food rating to GAE server
- (void) uploadFoodRatingToGAEServer:(NSString*)fidStr updateFood:(BOOL)update
{
    //check
    if(fidStr == nil) return;
    
    //food id str
    NSString* foodIDStr = fidStr;
    
    //clent url
    NSURL *clientURL = [NSURL URLWithString:@"http://localhost"];
    //server
    NSString *serverAddRatingPath = [NSString stringWithFormat:@"%@/addRating",serverURL];
    
    //client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:clientURL];
    
    //comment parms
    NSDictionary *ratingParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  foodIDStr, @"fid",
                                  nil];
    
    //comment request
    NSMutableURLRequest *addRatingRequest = [httpClient requestWithMethod:@"POST" path:serverAddRatingPath parameters:ratingParams];
    
    //connect to server
    //Add your request object to an AFHTTPRequestOperation
    AFHTTPRequestOperation *addRatingOperation = [[AFHTTPRequestOperation alloc] initWithRequest:addRatingRequest];
    
    //success and failure
    [addRatingOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [operation responseString];
        NSLog(@"[Client]response for add rating : [%@]",response);
        
        //download food item from server
        if(update)[[VARMenuDataSource sharedMenuDataSource] downloadFoodDataFromGAEServer];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [addRatingOperation start];
}

//download food rating
- (void) downloadFoodRatingFromGAEServer:(NSString*)fidStr
{
    //server URL
    NSString* serverDownloadFoodPath = [NSString stringWithFormat:@"%@/seeRating?fid=%@",serverURL,fidStr];
    
    //
    //add last update time from file
    NSDictionary* dateTimeDictionary = [self getLastTimeUpdateTimeDateFromFile];
    
    serverDownloadFoodPath = [serverDownloadFoodPath  stringByAppendingString:[NSString stringWithFormat:@"&year=%@&month=%@&day=%@&hour=%@&minute=%@&second=%@&msecond=%@",dateTimeDictionary[@"year"],dateTimeDictionary[@"month"],dateTimeDictionary[@"day"],dateTimeDictionary[@"hour"],dateTimeDictionary[@"minute"],dateTimeDictionary[@"second"],dateTimeDictionary[@"msecond"]]];
    //
    
    NSURL* serverDownloadFoodURL = [NSURL URLWithString:serverDownloadFoodPath];
    
    //Request
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverDownloadFoodURL]
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            
                                                            //JSON decoder
                                                            JSONDecoder* JSONDecoderForFoodRating = (JSONDecoder*)JSON;
                                                                                            
                                                            //food rating
                                                            NSString* foodRating = [JSONDecoderForFoodRating valueForKey:@"rating"];
                                                        
                                                            //check null
                                                            if(foodRating == nil)
                                                            {
                                                                    //no rating update
                                                            }
                                                            else
                                                            {
                                                                    //**add rating in SQLite
                                                                    [[VARMenuDataSource sharedMenuDataSource] updateRatingToFoodItem:fidStr withRating:foodRating];
                                                            }
                                                            //print
                                                            //NSLog(@"Food %@ Rating : %@",fidStr,foodRating);
                                                                                            
                                                        } failure:nil];
    
    //add in global queue
    [globalOperationQueue addOperation:operation];
    
}

//get current from GAE server
- (void) getCurrentTimeFromGAEServer
{
    //server URL
    NSString* serverSeeDateTimePath = [NSString stringWithFormat:@"%@/seeDateTime",serverURL];
    
    NSURL* serverSeeDateTimeURL = [NSURL URLWithString:serverSeeDateTimePath];
    
    //*****can use
    //wait all operation
    //[globalOperationQueue waitUntilAllOperationsAreFinished];
    
    //get current time from GAE server
    
    //Request
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverSeeDateTimeURL]
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            //JSON decoder
                                                            JSONDecoder* JSONDecoderForDateTime = (JSONDecoder*)JSON;
                                                                                            
                                                            //food rating
                                                            NSString* dateTime = [JSONDecoderForDateTime valueForKey:@"dateTime"];
                                                                                            
                                                            //check null
                                                            if(dateTime == NULL) dateTime=@"0";
                                                                                            
                                                            //write to file
                                                            NSData *lastUpdateDataTimeData = [dateTime dataUsingEncoding:NSUTF8StringEncoding];
                                                            NSArray *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                            NSString *documentsDirectory = [docsPath objectAtIndex:0];
                                                            NSString *saveFileForDateTime = [documentsDirectory stringByAppendingPathComponent:@"LastUpdateDateTime"];
                                                            [lastUpdateDataTimeData writeToFile:saveFileForDateTime atomically:YES];
                                                            //write to file finish
                                                            NSLog(@"Save update time to file.");
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                                                                NSLog(@"Error : %@",error);
                                                    }];
    
    //add in global queue
    [globalOperationQueue addOperation:operation];
    
}

//get date time
- (NSDictionary*) getLastTimeUpdateTimeDateFromFile
{
    //NSMutableDictionary
    NSMutableDictionary* dateTimeDictionary = [[NSMutableDictionary alloc] init];
    
    //read from file
    NSArray *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [docsPath objectAtIndex:0];
    NSString *fileForLastUpdateDateTime = [documentsDirectory stringByAppendingPathComponent:@"LastUpdateDateTime"];
    
    //file content
    NSString* content = [NSString stringWithContentsOfFile:fileForLastUpdateDateTime
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    //print content
    //NSLog(@"File content:%@",content);
    
    //if file not exist
    if(content == nil)
    {
        //default value
        [dateTimeDictionary setValue:@"2011" forKey:@"year"];
        [dateTimeDictionary setValue:@"1" forKey:@"month"];
        [dateTimeDictionary setValue:@"1" forKey:@"day"];
        [dateTimeDictionary setValue:@"0" forKey:@"hour"];
        [dateTimeDictionary setValue:@"0" forKey:@"minute"];
        [dateTimeDictionary setValue:@"0" forKey:@"second"];
        [dateTimeDictionary setValue:@"0" forKey:@"msecond"];
        
        //return
        return dateTimeDictionary;
    }
    
    NSArray *dateTimeStrComponentsTemp = [content componentsSeparatedByString:@"-"];
    
    //parse date time str
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp objectAtIndex:0] forKey:@"year"];
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp objectAtIndex:1] forKey:@"month"];
    
    NSString* tempStr = [dateTimeStrComponentsTemp objectAtIndex:2];
    
    NSArray *dateTimeStrComponentsTemp2 = [tempStr componentsSeparatedByString:@" "];
    
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp2 objectAtIndex:0] forKey:@"day"];
    
    tempStr = [dateTimeStrComponentsTemp2 objectAtIndex:1];
    
    NSArray *dateTimeStrComponentsTemp3 = [tempStr componentsSeparatedByString:@":"];
    
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp3 objectAtIndex:0] forKey:@"hour"];
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp3 objectAtIndex:1] forKey:@"minute"];
    
    tempStr = [dateTimeStrComponentsTemp3 objectAtIndex:2];
    
    NSArray *dateTimeStrComponentsTemp4 = [tempStr componentsSeparatedByString:@"."];
    
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp4 objectAtIndex:0] forKey:@"second"];
    [dateTimeDictionary setValue:[dateTimeStrComponentsTemp4 objectAtIndex:1] forKey:@"msecond"];
    
    //NSLog(@"Dict : %@",dateTimeDictionary);
    return dateTimeDictionary;
}

@end
