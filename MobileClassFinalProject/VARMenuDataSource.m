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
            
            //NSLog(@"%@", [queryResults stringForColumn:@"name"]);
            
            //add array of images
            NSInteger food_id = [queryResults intForColumn:@"id"];
            FMResultSet * imageResults = [self.database executeQuery:@"SELECT * FROM images WHERE food_id = ?", [NSString stringWithFormat:@"%i", food_id]];
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            while([imageResults next])
            {
                //NSLog(@"%@", [imageResults stringForColumn:@"image_name"]);
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



//add comment to server
- (void)uploadFoodImageToGAEServer
{
    //upload image
    //doc path
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSInteger uploadImageFid = 101;
    NSString *imageName = @"uploadTest.jpeg";
    NSURL *serverUploadImageURL = [NSURL URLWithString:@"http://localhost:8081/uploadImage"];
    NSString *uploadJPEGFilePath = [NSString stringWithFormat:@"%@/%@",docDir,imageName];
    //NSURL *uploadImageURL = [NSURL URLWithString:uploadJPEGFilePath];
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

//upload image
- (void)uploadCommentToGAEServer
{
    //add comment
    //clent url
    NSURL *clientURL = [NSURL URLWithString:@"http://localhost"];
    //NSURL *serverURL = [NSURL URLWithString:@"http://localhost:8081/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:clientURL];
    
    //comment parms
    NSDictionary *commentParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"106", @"fid",
                                   @"Comment,Nice food!3", @"comment",
                                   nil];
    //comment request
    NSMutableURLRequest *commentRequest = [httpClient requestWithMethod:@"POST" path:@"http://localhost:8081/addComment" parameters:commentParams];
    
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

@end
