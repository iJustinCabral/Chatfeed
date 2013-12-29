//
//  CHFAppDelegate.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

#import "CHFHomeViewController.h"
#import "CHFMentionsViewController.h"
#import "CHFChatFeedsViewController.h"

#define AppDelegate \
((CHFAppDelegate *)[UIApplication sharedApplication].delegate)

typedef NS_ENUM (NSUInteger, AppLayer)
{
    AppLayerWallpaper = 0,
    AppLayerAppContainer,
    AppLayerAppBar,
    AppLayerChats,
    AppLayerHoverMenu,
    AppLayerChatItems
};

typedef NS_ENUM (NSUInteger, PanDirection)
{
    PanDirectionUp = 0,
    PanDirectionRight,
    PanDirectionDown,
    PanDirectionLeft
};

NSString * NSStringFromAppLayer(AppLayer layer);
NSString * NSStringFromPanDirection(PanDirection direction);
PanDirection PanDirectionFromVelocity(CGPoint velocity);

@interface CHFAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) CHFHomeViewController *homeViewControllerForRefresh;
@property (nonatomic, strong) CHFMentionsViewController *mentionViewControllerForRefresh;
@property (nonatomic, strong) CHFChatFeedsViewController *chatfeedsViewControllerForRefresh;

- (UIColor *)appColor;

- (void)updateApplicationColorToColor:(UIColor *)color;

- (void)addSubview:(UIView *)view ofAppLayerType:(AppLayer)layer;
- (UIView *)viewForAppLayer:(AppLayer)layer;

// Status Bar
- (void)hideStatusBar:(BOOL)hide withAnimation:(UIStatusBarAnimation)animation;
- (BOOL)statusBarIsHidden;
- (UIView *)statusBarSnapshot;
- (CGRect)statusBarRect;
- (CGFloat)statusBarHeight;

// Future store unlock
- (BOOL)chatStackIsPurchased;
- (BOOL)customizationIsPurchased;
- (BOOL)stickersIsPurchased;
- (BOOL)drawingIsPurchased;

@end

@interface CHFLayerContainer : UIView

@property (nonatomic) AppLayer layer;

@end
