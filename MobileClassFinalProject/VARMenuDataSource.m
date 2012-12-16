//
//  VARMenuDataSource.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARMenuDataSource.h"

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
static NSString * VARDataSourceCacheKeyFoodByRating = @"VARDataSrouceCacheKey.%@.Food.Rating";

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

//gets all foods sorted by rating.
- (NSArray *) arrayOfFoodsByRating
{
    //get from cache
    NSMutableArray* foods = [cache objectForKey:VARDataSourceCacheKeyFoodByRating];
    
    if(!foods)
    {
        //initalize
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients , rating FROM food_items ORDER BY rating"];
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
                [tempCommentDict setObject:[imageResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[imageResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
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

//get food from category
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category{
    //get from cache
    NSString *cacheKey = [NSString stringWithFormat:VARDataSourceCacheKeyFoodInCategory, category];
    NSMutableArray* foods = [cache objectForKey:cacheKey];

    if(!foods)
    {
        //init
        foods =  [[NSMutableArray alloc] init];
        FMResultSet * queryResults = [self.database executeQuery:@"SELECT id, name, chinese_name, english_category, chinese_category, introduction, ingredients, rating FROM food_items WHERE english_category = ?", category];
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
                [tempCommentDict setObject:[imageResults stringForColumn:@"comment"] forKey:VARsDataSourceDictKeyCommentContent];
                [tempCommentDict setObject:[imageResults stringForColumn:@"timestamp"] forKey:VARsDataSourceDictKeyCommentTimestamp];
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

/**
 Adds a comment to the specified food item.
 */

- (void) addCommentToFoodItem:(NSInteger)foodID withContents:(NSString *)contents
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString * currentDate = [DateFormatter stringFromDate:[NSDate date]];
    [self.database executeUpdate:@"INSERT INTO comments (comment, timestamp, food_id) values (?,?,?)",
     contents, currentDate, [NSString stringWithFormat:@"%i", foodID]];
}

/**
 Adds an image to the specified food item.
 */

- (void) addImageToFoodItem:(NSInteger)foodID withImageName:(NSString *)imageName
{
    [self.database executeUpdate:@"INSERT INTO images (image_name, food_id) values (?,?)",
     imageName,[NSString stringWithFormat:@"%i", foodID]];
}

//Adds a food item to the database table. The item must be added in dictionary form.
//(ask Raymond if need further explanation)
//This dictionary should only contain the basic information and images; nothing else will be added.
- (void) addFoodItemToDB:(NSDictionary *) foodItem
{
    //grab attributes from NSDictionary
    NSString * name = foodItem[VARsDataSourceDictKeyEnglishName];
    NSString * chineseName = foodItem[VARsDataSourceDictKeyChineseName];
    NSString * englishCategory = foodItem[VARsDataSourceDictKeyEnglishCategories];
    NSString * chineseCategory = foodItem[VARsDataSourceDictKeyChineseCategories];
    NSString * introduction = foodItem[VARsDataSourceDictKeyFoodIntroduction];
    NSString * ingredients = foodItem[VARsDataSourceDictKeyFoodIngredient];
    NSString * food_id = foodItem[VARsDataSourceDictKeyFoodID];
    
    [self.database executeUpdate:@"INSERT INTO food_items (id, name, chineseName, english_category, chinese_category, introduction, ingredients VALUES (?,?,?,?,?,?,?)", food_id, name, chineseName, englishCategory, chineseCategory, introduction, ingredients];
    NSArray * images = foodItem[VARsDataSourceDictKeyFoodImage];
    
    for(NSString * imageName in images)
    {
        [self.database executeUpdate:@"INSERT INTO images (image_name, food_id) values (?,?)",
         imageName, food_id];
    }
    
}


#pragma mark -
#pragma mark Connect Server Interface
//Connect to Server

//download new food data
+ (void)downloadFoodDataFromGAEServer
{
    //download new food item from server
    //server path
    NSURL* serverURL = [NSURL URLWithString:@"http://varfinalprojectserver.appspot.com"];
    
    //Request
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:serverURL]
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                         //convert to NSDictionary
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
                                                             NSLog(@"fid = %@",[foodItemDecoder valueForKey:@"Fid"]);
                                                             NSLog(@"English name = %@",[foodItemDecoder valueForKey:@"EnglishName"]);
                                                             NSLog(@"Chinese name = %@",[foodItemDecoder valueForKey:@"ChineseName"]);
                                                             
                                                         }
                                                         //[self.activityIndicator stopAnimating];
                                                     } failure:nil] start];
    
    
    //**** download image and comment for every food item
    //download food comments from Server
    //NSString* fidStr = @"2";
    //comment Array
    //commentArray = [VARMenuDataSource downloadCommentFromGAEServer:fidStr];
    
    
    //download food image from server
    // Get an image from the URL below
	UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://localhost:8081/images/image1_1.jpg"]]];
    
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"Doc Path = %@",docDir);
    
    //save to png
	//NSLog(@"saving png");
	//NSString *pngFilePath = [NSString stringWithFormat:@"%@/test.png",docDir];
	//NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	//[data1 writeToFile:pngFilePath atomically:YES];
    
    //save to jepg
	NSLog(@"saving jpeg");
	NSString *jpegFilePath = [NSString stringWithFormat:@"%@/test.jpeg",docDir];
	NSData *imageJPEGData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
	[imageJPEGData writeToFile:jpegFilePath atomically:YES];
    
    //done
	NSLog(@"saving image done");
    
}



//upload image to server
+ (void)uploadFoodImageToGAEServer
{
    //upload image
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //server URL
    NSURL *serverUploadImageURL = [NSURL URLWithString:@"http://varfinalprojectserver.appspot.com/uploadImage"];
    
    //prepare data
    NSInteger uploadImageFid = 101;
    NSString *imageName = @"uploadTest.jpeg";
    NSString *uploadJPEGFilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
    UIImage *uploadImage = [UIImage imageWithContentsOfFile:uploadJPEGFilePath];
    
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
    [body appendData:[[NSString stringWithFormat:@"%d",uploadImageFid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add image name into body
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"imagename\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[imageName dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [uploadImageOperation start];
    
}

//add comment to server
+ (void)uploadCommentToGAEServer:(NSString*)foodID withComment:(NSString*)foodComment
{
    //add comment
    
    //check
    if(foodComment==nil) foodComment = @"comment.";
    
    //food id str
    NSString* foodIDStr = foodID;
    
    //clent url
    NSURL *clientURL = [NSURL URLWithString:@"http://localhost"];
    NSString *serverAddCommentPath = @"http://varfinalprojectserver.appspot.com/addComment";
    
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [operation error]);
    }];
    
    //call start on your request operation
    [addCommentOperation start];
    
}

//download comment
+ (NSMutableArray*)downloadCommentFromGAEServer:(NSString*)foodID
{
    //save comments
    NSMutableArray* commentsArray = [[NSMutableArray alloc] init];
    
    //see comments
    NSLog(@"Download Comment....");
    
    //server path
    NSString *serverDownloadCommentPath = [NSString stringWithFormat:@"http://varfinalprojectserver.appspot.com/seeComment?fid=%@",foodID];
    
    NSURL* serverDownloadCommentURL = [NSURL URLWithString:serverDownloadCommentPath];
    //[serverDownloadCommentURL URLByAppendingPathComponent:@"?fid=2"]
    //[serverDownloadCommentURL parameterString:[NSString stringWithFormat:@"fid=2"]];
    //NSLog(@"test : %@",serverDownloadCommentURL);
    
    //************** Need Syn ,wait success then return
    
    
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
                                    
                                    //add comment in array
                                    [commentsArray addObject:[foodCommentDecoder valueForKey:@"Comment"]];
                                }
                            
                                //[self.activityIndicator stopAnimating];
                }
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError* error, id JSON) {
                    NSLog(@"Error : %@",error);
                }];
    
    //start and wait
    [operations start];
    [operations waitUntilFinished];
    
    //return
    return commentsArray;
    
}


@end
