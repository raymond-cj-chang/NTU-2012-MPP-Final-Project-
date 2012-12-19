//
//  VARRestaurant.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/19.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VARRestaurant : NSObject<MKAnnotation>

@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *sbuTitle;
@property(nonatomic, assign) CLLocationCoordinate2D *coordinate;
-(id) initWithTitle:(NSString *) theTitle
            subTitle:(NSString *) theAddress
   andCoordinate:(CLLocationCoordinate2D) theCoordinate;
@end
