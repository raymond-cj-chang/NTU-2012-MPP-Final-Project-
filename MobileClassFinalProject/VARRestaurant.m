//
//  VARRestaurant.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/19.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARRestaurant.h"

@implementation VARRestaurant
-(id) initWithTitle:(NSString *)theTitle subTitle:(NSString *)theSubTitle andCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    self = [super init];
    if(self){
        self.title = theTitle;
        self.subtitle=theSubTitle;
        self.coordinate = theCoordinate;
     }
    return self;
}

@end
