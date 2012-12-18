//
//  VARMapViewController.m
//  MobileClassFinalProject
//
//  Created by Vincent on 12/12/18.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARMapViewController.h"

@interface VARMapViewController ()

@end

@implementation VARMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    NSLog(@"user:%f", self.mapView.userLocation.location.coordinate.latitude);
    
//	[self.mapView.userLocation addObserver:self
//                                forKeyPath:@"location"
//                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
//                                   context:NULL];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    if ( !self.initialLocation )
//    {
//        self.initialLocation = userLocation.location;
//        
//        MKCoordinateRegion region;
//        region.center = mapView.userLocation.coordinate;
//        region.span = MKCoordinateSpanMake(0.1, 0.1);
//        
//        region = [mapView regionThatFits:region];
//        [mapView setRegion:region animated:YES];
//    }
//}
//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    MKCoordinateRegion region;
//    region.center = self.mapView.userLocation.coordinate;
//    
//    MKCoordinateSpan span;
//    span.latitudeDelta  = 1; // Change these values to change the zoom
//    span.longitudeDelta = 1;
//    region.span = span;
//    
//    [self.mapView setRegion:region animated:YES];
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
