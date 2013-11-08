//
//  CHFAppDelegate.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppDelegate.h"
#import "CHFIAPHelper.h"

#import "CHFHomeViewController.h"
#import "CHFMessagesViewController.h"
#import "CHFChatFeedsViewController.h"

#import "CHFClientManager.h"
#import "CHFLoginViewController.h"

#import <ANKClient.h>

#import "CHFWallpaperView.h"

@interface CHFAppDelegate () <CHFWallpaperDelegate>

@property (nonatomic, strong) CHFWallpaperView *wallpaperView;

@end

@implementation CHFAppDelegate

#pragma mark - Future Store options

- (BOOL)chatStackIsPurchased
{
    return YES;
}

- (BOOL)customizationIsPurchased
{
    return YES;
}

- (BOOL)stickersIsPurchased
{
    return YES;
}

- (BOOL)drawingIsPurchased
{
    return YES;
}

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup background fetching
//    [[UIApplicatio/\n sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //In-App Purchase Helper
    [CHFIAPHelper sharedInstance];
    
    // Manage Authentication
//    [self login];
    
    // Wallpaper
    [self configureWallpaper];
    
    [self updateApplicationColorToColor:[self appColor]];
    
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

#pragma mark - TintColor Methods

- (UIColor *)appColor
{
    return [self customizationIsPurchased] ? [self.wallpaperView averageColor] : [UIColor chatFeedGreen];
}

- (void)updateApplicationColorToColor:(UIColor *)color
{
    self.window.tintColor = color;
}

#pragma mark - WallpaperView

- (void)configureWallpaper
{
    self.wallpaperView = [[CHFWallpaperView alloc] initWithFrame:self.window.frame
                                                andBlurWallpaper:YES];
    self.wallpaperView.delegate = self;
    [self.window addSubview:self.wallpaperView];
    [self.window sendSubviewToBack:self.wallpaperView];
}

#pragma mark Delegate
- (void)didUpdateToColor:(UIColor *)color
{
    // This method is being looped from an animation
    [self updateApplicationColorToColor:color];
}

#pragma mark - Login Methods

- (void)login
{
    if ([ClientManager currentClient] && [ClientManager currentClient].isAuthenticated)
    {
        CHFAppContainerViewController *viewController = [CHFAppContainerViewController new];
        self.window.rootViewController = viewController;
    }
    else
    {
        CHFLoginViewController *viewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        self.window.rootViewController = viewController;
    }
    
    [self.window makeKeyAndVisible];
}

#pragma mark Delegate

- (void)adnLoginDidSucceedForUserWithID:(NSString *)userID username:(NSString *)username token:(NSString *)accessToken
{
    // Stash token in Keychain, make client request with ADNKit, etc.
}

- (void)adnLoginDidFailWithError:(NSError *)error
{
    
}

#pragma mark - Fetch Delegate Callback

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.homeViewControllerForRefresh refreshWithCompletionHandler:^(BOOL success, NSError *error)
     {
        if (success)
        {
            completionHandler(UIBackgroundFetchResultNewData);
        }
        else
        {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
    
    [self.mentionViewControllerForRefresh refreshWithCompletionHandler:^(BOOL success, NSError *error)
     {
         if (success)
         {
             completionHandler(UIBackgroundFetchResultNewData);
         }
         else
         {
             completionHandler(UIBackgroundFetchResultNoData);
         }
     }];
    
    [self.chatfeedsViewControllerForRefresh refreshWithCompletionHandler:^(BOOL success, NSError *error)
     {
         if (success)
         {
             completionHandler(UIBackgroundFetchResultNewData);
         }
         else
         {
             completionHandler(UIBackgroundFetchResultNoData);
         }
     }];
    
}


@end
