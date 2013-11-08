//
//  CHFNotificationBar.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHFNotificationBarObject;

@interface CHFNotificationBar : UIView

+ (instancetype)sharedNotifcationBar;

- (CHFNotificationBarObject *)dequeueNotification;
- (void)enqueueNotification:(CHFNotificationBarObject *)notification;

- (NSUInteger)countOfNotificationsEnqueued;

- (void)resumeNotificationQueue;
- (void)pauseNotificationQueue;
- (void)stopNotificationQueue;

@end

@protocol CHFNotificationBarDelegate <NSObject>



@end
