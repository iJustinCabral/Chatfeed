//
//  CHFNotificationBar.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHFNotificationBarObject.h"

#define TopNotificationBar \
((CHFNotificationBar *)[CHFNotificationBar sharedTopNotificationBar])

#define BottomNotificationBar \
((CHFNotificationBar *)[CHFNotificationBar sharedBottomNotifcationBar])

@protocol CHFNotificationBarDelegate;

@interface CHFNotificationBar : UIView

+ (instancetype)sharedTopNotificationBar;
+ (instancetype)sharedBottomNotifcationBar;

@property (nonatomic, weak) id <CHFNotificationBarDelegate> delegate;

@property (nonatomic, readonly, getter = isPaused) BOOL paused;
@property (nonatomic, readonly, getter = isShowingNotifications) BOOL showingNotifications;

- (void)addNotification:(CHFNotificationBarObject *)notification;

- (NSUInteger)countOfEnqueuedNotifications;

- (void)resume;
- (void)pause;
- (void)stop;

@end

@protocol CHFNotificationBarDelegate <NSObject>

- (void)didBeginShowingNotificationsFromNotificationBar:(CHFNotificationBar *)notificationBar;
- (void)didEndShowingNotificationsFromNotificationBar:(CHFNotificationBar *)notificationBar;

@optional
- (void)didBeginShowingNotification:(CHFNotificationBarObject *)notification
                fromNotificationBar:(CHFNotificationBar *)notificationBar;
- (void)didEndShowingNotification:(CHFNotificationBarObject *)notification
              fromNotificationBar:(CHFNotificationBar *)notificationBar;

@end
