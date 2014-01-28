//
//  SWAppDelegate.m
//  Friends
//
//  Created by Simon Westerlund on 23/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWAppDelegate.h"
#import "SWListFriendsViewController.h"
#import "SWFriendsController.h"
#import "SWInfoViewController.h"

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[SWListFriendsViewController new]]];
    [self.window makeKeyAndVisible];
    
    [self setupAppearances];
    
    return YES;
}

- (void)setupAppearances {
    UIColor *sligtlyBlueColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1];
    
    // Navigation bar
    [[UINavigationBar appearance] setBarTintColor:sligtlyBlueColor];
    
    // No access view
    [[UIView appearanceWhenContainedIn:[SWInfoViewController class], nil]
     setBackgroundColor:sligtlyBlueColor];
    
    // Search bar
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    // Title label
    NSDictionary *dictionary = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:dictionary];
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

@end
