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

@interface VARMenuDataSource : NSObject
{
    // Cache data pool
    NSCache *cache;
    
    //food plist name 
    NSString* foodListFileName;
    
    //food list
    NSArray *foodList;
}


+ (VARMenuDataSource *) sharedMenuDataSource;

- (void) cleanCache;
- (void) refresh;
- (id) init;
- (NSArray *) arrayOfChineseCategories;
- (NSArray *) arrayOfEnglishCategories;
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category;

//for server
+ (void)downloadFoodDataFromGAEServer;
+ (void)uploadFoodImageToGAEServer;
+ (void)uploadCommentToGAEServer:(NSString*)foodID withComment:(NSString*)foodComment;
+ (NSMutableArray*)downloadCommentFromGAEServer:(NSString*)foodID;

@end
