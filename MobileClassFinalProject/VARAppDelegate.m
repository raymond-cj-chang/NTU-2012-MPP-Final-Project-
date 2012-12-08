//
//  VARAppDelegate.m
//  MobileClassFinalProject
//
//  Created by Admin on 12/10/26.
//  Copyright (c) 2012年 VAR. All rights reserved.
//

#import "VARAppDelegate.h"

@implementation VARAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //dowload new food data
    self.downloadFoodDataFromGAEServer;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)downloadFoodDataFromGAEServer
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
@end
