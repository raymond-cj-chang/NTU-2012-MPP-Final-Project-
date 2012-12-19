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

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *subTitle;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
-(id) initWithTitle:(NSString *) theTitle
            subTitle:(NSString *) theAddress
   andCoordinate:(CLLocationCoordinate2D) theCoordinate;
@end
