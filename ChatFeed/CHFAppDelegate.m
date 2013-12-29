//
//  CHFAppDelegate.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppDelegate.h"

#import "CHFHomeViewController.h"
#import "CHFMessagesViewController.h"
#import "CHFChatFeedsViewController.h"

#import "CHFClientManager.h"
#import "CHFLoginViewController.h"

#import <ANKClient.h>

#import "CHFWallpaperView.h"

#import <ADNLogin.h>
#import "CHFIAPHelper.h"

NSString * NSStringFromAppLayer(AppLayer layer)
{
    switch (layer)
    {
        case AppLayerWallpaper:
            return @"AppLayer Wallpaper";
            break;
        case AppLayerAppContainer:
            return @"AppLayerAppContainer";
            break;
        case AppLayerAppBar:
            return @"AppLayer AppBar";
            break;
        case AppLayerChats:
            return @"AppLayer Chats";
            break;
        case AppLayerHoverMenu:
            return @"AppLayer HoverMenu";
            break;
        case AppLayerChatItems:
            return @"AppLayer ChatItems";
            break;
        default:
            return @"AppLayer Unkown";
            break;
    }
}

NSString * NSStringFromPanDirection(PanDirection direction)
{
    switch (direction)
    {
        case PanDirectionUp:
            return @"PanDirection Up";
            break;
        case PanDirectionRight:
            return @"PanDirection Right";
            break;
        case PanDirectionDown:
            return @"PanDirection Down";
            break;
        case PanDirectionLeft:
            return @"PanDirection Left";
            break;
        default:
            return @"Invalid direction";
            break;
    }
}

PanDirection PanDirectionFromVelocity(CGPoint velocity)
{
    PanDirection direction;
    
    if (fabs(velocity.y) > fabs(velocity.x))
    {
        direction = velocity.y > 0 ? PanDirectionDown : PanDirectionUp;
    }
    else
    {
        direction = velocity.x > 0 ? PanDirectionRight : PanDirectionLeft;
    }
    
    return direction;
}

@interface CHFAppDelegate () <CHFWallpaperDelegate, ADNLoginDelegate, LoginViewControllerDelegate>

@property (nonatomic, strong) CHFWallpaperView *wallpaperView;
@property (nonatomic) NSArray *appLayerContainers;

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
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Manage Authentication
    [self login];
    
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

// This method makes sure that our app stays layered properly. If you need to add something that uses the apps window it should go through this method
- (void)addSubview:(UIView *)view ofAppLayerType:(AppLayer)layer
{
    [self.window insertSubview:view atIndex:layer];
    
//    switch (layer)
//    {
//        case AppLayerWallpaper:
//            return [self.window insertSubview:view atIndex:layer];
//            break;
//        case AppLayerAppContainer:
//            return [self.window.rootViewController.view addSubview:view];
//            break;
//        case AppLayerAppBar:
//            return ;
//            break;
//        case AppLayerChats:
//            return ;
//            break;
//        case AppLayerHoverMenu:
//            return @"AppLayer HoverMenu";
//            break;
//        case AppLayerChatItems:
//            return @"AppLayer ChatItems";
//            break;
//        default:
//            break;
//    }
    
}

- (UIView *)viewForAppLayer:(AppLayer)layer
{
//    switch (layer)
//    {
//        case AppLayerWindow:
//            return self.window;
//            break;
//        case AppLayerWallpaper:
//            return self.wallpaperView;
//            break;
//        case AppLayerAppContainer:
//            return self.window.rootViewController.view;
//            break;
//        case AppLayerAppBar:
//            return ;
//            break;
//        case AppLayerChats:
//            return ;
//            break;
//        case AppLayerHoverMenu:
//            return @"AppLayer HoverMenu";
//            break;
//        case AppLayerChatItems:
//            return @"AppLayer ChatItems";
//            break;
//        default:
//            return nil;
//            break;
//    }
    return nil;

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
    self.wallpaperView = [[CHFWallpaperView alloc] initWithFrame:self.window.bounds
                                                   blurWallpaper:YES
                                                     randomStart:NO
                                                     shouldCycle:NO
                                                  cycleInReverse:NO];
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

#pragma mark - StatusBar Helpers

- (void)hideStatusBar:(BOOL)hide withAnimation:(UIStatusBarAnimation)animation
{
    if (hide && ![self statusBarIsHidden])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:animation];

    }
    else if ([self statusBarIsHidden] && Settings.isStatusBarEnabled && !TopNotificationBar.isShowingNotifications)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:animation];
    }
}

- (BOOL)statusBarIsHidden
{
    return [self statusBarHeight] > 0 ? NO: YES;
}

- (UIImageView *)statusBarSnapshot
{
    // Take a snapshot of the app
    UIView *statusBarSnapView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    
    // Convert the view to an image
    UIGraphicsBeginImageContext([self statusBarRect].size);
    
    [statusBarSnapView.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *statusBarImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Mask the status bar
//    CGFloat colorValueLow = 0;
//    CGFloat colorValueHigh = 255;
//    float colorMaskingLow[6] = {0, colorValueLow, 0, colorValueLow, 0, colorValueLow};
//    float colorMaskingHigh[6] = {colorValueHigh, 255, colorValueHigh, 255, colorValueHigh, 255};
//    CGImageRef imageRef = CGImageCreateWithMaskingColors(statusBarImage.CGImage, colorMaskingLow);
//    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:statusBarImage];
    return statusBarSnapView;
}

- (CGRect)statusBarRect
{
    return [UIApplication sharedApplication].statusBarFrame;
}

- (CGFloat)statusBarHeight
{
    return [self statusBarRect].size.height;
}

#pragma mark - Login Methods

- (void)login
{
    if (([ClientManager currentClient] && [ClientManager currentClientIsAuthenticated])
        || [ANKClient sharedClient]
        )
    {
        self.window.rootViewController = [CHFAppContainerViewController new];
        
        [CHFIAPHelper sharedInstance];
    }
    else
    {
        ADNLogin *adn = [ADNLogin sharedInstance];
        adn.delegate = self;
        adn.scopes = @[@"basic", @"stream", @"write_post", @"follow", @"public_messages", @"messages", @"update_profile", @"files"];
        
        CHFLoginViewController *viewController = [CHFLoginViewController new];
        viewController.delegate = self;
        self.window.rootViewController = viewController;
    }
    
    [self.window makeKeyAndVisible];
}

#pragma mark CHFLogin Delegate

- (void)loginDidSucceedForClient:(ANKClient *)client
{
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = [CHFAppContainerViewController new]; }
                    completion:nil];
}

- (void)loginDidFailWithError:(NSError *)error
{
    
}

#pragma mark ADNLogin Delegate

- (void)adnLoginDidSucceedForUserWithID:(NSString *)userID
                               username:(NSString *)username
                                  token:(NSString *)accessToken
{
    // Stash token in Keychain, make client request with ADNKit, etc.
//    ANKClient *client = [ANKClient new];
    
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[ADNLogin sharedInstance] openURL:url
                            sourceApplication:sourceApplication
                                   annotation:annotation];
}

@end

@implementation CHFLayerContainer

@end
