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

- (void)loadView
{  
    [super loadView];

    CLLocationCoordinate2D location0 = {25.022083,121.541289};
    VARRestaurant *restaurant0 = [[VARRestaurant alloc] initWithTitle:@"大李水餃"
                                                             subTitle:@"和平東路二段118巷54弄"
                                                        andCoordinate:location0];
    CLLocationCoordinate2D location1 = {25.022929,121.542625};
    VARRestaurant *restaurant1 = [[VARRestaurant alloc] initWithTitle:@"小李水餃"
                                                             subTitle:@"台北市大安區復興南路二段340巷8號"
                                                        andCoordinate:location1];
    CLLocationCoordinate2D location2 = {25.016011,121.531061};
    VARRestaurant *restaurant2 = [[VARRestaurant alloc] initWithTitle:@"豪季水餃專賣店"
                                                             subTitle:@"羅斯福路三段74-1號"
                                                        andCoordinate:location2];
    CLLocationCoordinate2D location3 = {25.017494,121.5328};
    VARRestaurant *restaurant3 = [[VARRestaurant alloc] initWithTitle:@"八方雲集"
                                                             subTitle:@"臺北市羅斯福路三段333巷11號"
                                                        andCoordinate:location3];
    CLLocationCoordinate2D location4 = {25.021626,121.542882};
    VARRestaurant *restaurant4 = [[VARRestaurant alloc] initWithTitle:@"阿玉水餃"
                                                             subTitle:@"台北市大安區辛亥路二段217號"
                                                        andCoordinate:location4];


    [self.mapView addAnnotations:[NSArray arrayWithObjects:restaurant0,restaurant1,restaurant2,restaurant3,restaurant4, nil]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    
    //change map type
    [self.mapView setMapType:MKMapTypeStandard];
    
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
