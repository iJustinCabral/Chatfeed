//
//  CHFSettingsViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Settings \
((CHFSettingsViewController *)[CHFSettingsViewController sharedSettings])

typedef NS_ENUM (NSUInteger, AppTheme)
{
    AppThemeLight = 0,
    AppThemeDark,
    AppThemeCustom
};

@interface CHFSettingsViewController : CHFViewController

// Can keep the statusBar always hidden
@property (nonatomic, readonly, getter = isStatusBarEnabled) BOOL statusBarEnabled;

// App Theme methods
@property (nonatomic, readonly) AppTheme appTheme;
- (UIBarStyle)barStyle;
//
@property (nonatomic, readonly) BOOL remindAboutUnsentMessage;

// UIDynamics
@property (nonatomic, readonly, getter = isDynamicsEnabled) BOOL dynamicsEnabled;

// UIMotion Effects
@property (nonatomic, readonly, getter = isMotionEffectsEnabled) BOOL motionEffectsEnabled;

// AppBar
@property (nonatomic, readonly, getter = isAppBarMinimalizationEnabled) BOOL appBarMinimalizationEnabled;

#pragma mark - Singleton
+ (instancetype)sharedSettings;

@end
