//
//  VARMenuDataSource.h
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VARsDataSourceDictKeyChineseName;
extern NSString * const VARsDataSourceDictKeyEnglishName;
extern NSString * const VARsDataSourceDictKeyCategories;
extern NSString * const VARsDataSourceDictKeyFoodIngredient;
extern NSString * const VARsDataSourceDictKeyFoodIntroduction;
extern NSString * const VARsDataSourceDictKeyFoodImage;
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
- (NSArray *) arrayOfCategories;
- (NSArray *) arrayOfFoodsInCategories:(NSString*) category;

@end
