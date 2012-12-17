//
//  VARMenuDataSource.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JSONKit.h"

extern NSString * const VARsDataSourceDictKeyChineseName;
extern NSString * const VARsDataSourceDictKeyEnglishName;
extern NSString * const VARsDataSourceDictKeyChineseCategories;
extern NSString * const VARsDataSourceDictKeyEnglishCategories;
extern NSString * const VARsDataSourceDictKeyFoodIngredient;
extern NSString * const VARsDataSourceDictKeyFoodIntroduction;
extern NSString * const VARsDataSourceDictKeyFoodImage;
extern NSString * const VARsDataSourceDictKeyFoodID;
extern NSString * const VARsDataSourceDictKeyRating;
extern NSString * const VARsDataSourceDictKeyComment;
extern NSString * const VARsDataSourceDictKeyCommentContent;
extern NSString * const VARsDataSourceDictKeyCommentTimestamp;
extern NSOperationQueue* globalOperationQueue;

@interface VARMenuDataSource : NSObject
{
    // Cache data pool
    NSCache *cache;
    
    //food plist name 
    NSString* foodListFileName;
    
    //food list
    NSArray *foodList;
}

//shared data source
+ (VARMenuDataSource *) sharedMenuDataSource;

- (void) cleanCache;
- (void) refresh;
- (id) init;
- (NSArray *) arrayOfChineseCategories;
- (NSArray *) arrayOfEnglishCategories;
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category;
- (NSArray *) arrayOfFoodsByRating;
- (NSArray *) arrayOfFoodsByAlphabeticalOrder;
- (void) addCommentToFoodItem:(NSInteger) foodID withContents:(NSString *)contents withDate:(NSString*)DateTimeStr;
- (void) addImageToFoodItem:(NSInteger)foodID withImageName:(NSString *)imageName;
- (void) addFoodItemToDB:(NSDictionary *) foodItem;
- (void) updateRatingToFoodItem:(NSString*)fidStr withRating:(NSString*)rating;


//for server
+ (void) downloadFoodDataFromGAEServer;
+ (void) uploadFoodImageToGAEServer:(NSString*)serverName withImageName:(NSString*)uploadImageName withImage:(UIImage*)image;
+ (void) uploadCommentToGAEServer:(NSString*)foodID withComment:(NSString*)foodComment;
+ (void) downloadCommentFromGAEServer:(NSString*)foodID;
+ (void) downloadImageFromGAEServer:(NSString*)fidStr;
+ (void) uploadFoodRatingToGAEServer:(NSString*)fidStr;
+ (void) downloadFoodRatingFromGAEServer:(NSString*)fidStr;
+ (void) getCurrentTimeFromGAEServer;
+ (NSDictionary*) getLastTimeUpdateTimeDateFromFile;

@end
