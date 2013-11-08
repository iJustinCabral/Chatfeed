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

@interface CHFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CHFHomeViewController *homeViewControllerForRefresh;
@property (nonatomic, strong) CHFMentionsViewController *mentionViewControllerForRefresh;
@property (nonatomic, strong) CHFChatFeedsViewController *chatfeedsViewControllerForRefresh;

- (UIColor *)appColor;

- (void)updateApplicationColorToColor:(UIColor *)color;

// Future store unlock
- (BOOL)chatStackIsPurchased;
- (BOOL)customizationIsPurchased;
- (BOOL)stickersIsPurchased;
- (BOOL)drawingIsPurchased;

@end
