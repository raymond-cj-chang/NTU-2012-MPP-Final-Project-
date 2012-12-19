//
//  VARMapViewController.h
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/18.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VARRestaurant.h"


@interface VARMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)doneButton:(id)sender;
 

@end
