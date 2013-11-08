 //
//  CHFNotificationBar.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFNotificationBar.h"
#import "CHFNotificationBarObject.h"

#import <QuartzCore/QuartzCore.h>


@interface CHFNotificationBar ()

@property (nonatomic, strong) NSMutableArray *notificationQueue;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *notificationLabel;

@property (nonatomic) BOOL isPaused;

@end

@implementation CHFNotificationBar

#pragma mark - Lifecycle

+ (instancetype)sharedNotifcationBar
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.frame = CGRectMake(0, 0, AppDelegate.window.frame.size.width, 20);
        
        [self initializer];
    }
    return self;
}

- (void)initializer
{
    if (!self.notificationQueue)
    {
        self.notificationQueue = [[NSMutableArray alloc] init];
    }
    
    if (!self.activityIndicator)
    {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [self.activityIndicator startAnimating];
        self.activityIndicator.layer.opacity = 0.0;
        self.activityIndicator.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
        [self addSubview:self.activityIndicator];
    }
    
    if (!self.notificationLabel)
    {
        self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        self.notificationLabel.center = self.center;
        self.notificationLabel.backgroundColor = [UIColor clearColor];
        self.notificationLabel.textColor = [UIColor lightGrayColor];
        self.notificationLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.notificationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.notificationLabel.numberOfLines = 1;
        self.notificationLabel.textAlignment = NSTextAlignmentCenter;
        self.notificationLabel.layer.opacity = 0.0;
        
        [self addSubview:self.notificationLabel];
    }
}


#pragma mark - Queue Methods

- (CHFNotificationBarObject *)dequeueNotification
{
    CHFNotificationBarObject *notification = self.notificationQueue[0];
    
    [self.notificationQueue removeObjectAtIndex:0];
    
    return notification;
}

- (void)enqueueNotification:(CHFNotificationBarObject *)notification
{
    if (notification.wantsToBeDisplayedNext)
    {
        [self.notificationQueue insertObject:notification atIndex:0];
    }
    else
    {
        [self.notificationQueue insertObject:notification atIndex:self.notificationQueue.count];
    }
    
    if (self.notificationQueue.count > 0) //  && self.statusBarIsHidden == NO
    {
        [self displayNextNotificationObject];
    }
}


- (void)displayNextNotificationObject
{
    if (!self.isPaused)
    {
//        if (!self.statusBarIsHidden)
//        {
//            [self hideStatusBar];
//        }
        
        [self displayNotification:[self dequeueNotification]];
    }
}

- (void)displayNotification:(CHFNotificationBarObject *)notification
{
//    [self updateFrameWidthForNotification:notification.notificationText];
    
    [UIView animateWithDuration:.68
                          delay:0.1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.notificationLabel.layer.opacity = 1.0;
                         
                         if (notification.isProgressType)
                         {
                             self.activityIndicator.layer.opacity = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         [self performSelector:@selector(notificationWillEnd:) withObject:notification afterDelay:3];
                     }];
}

- (void)notificationWillEnd:(CHFNotificationBarObject *)notification
{
    if (self.notificationQueue.count > 0)
    {
        CHFNotificationBarObject *notificationObject = self.notificationQueue[0];
        
        if (!notificationObject.isProgressType)
        {
            self.activityIndicator.layer.opacity = 0.0;
        }
        
        [self displayNextNotificationObject];
    }
    else
    {
        
        [UIView animateWithDuration:.68
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.notificationLabel.layer.opacity = 0.0;
                             self.activityIndicator.layer.opacity = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [self showStatusBar];
                             
                         }];
    }
}

#pragma mark - Statusbar Methods

- (void)showStatusBar
{
//    self.statusBarIsHidden = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:.48
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    // This is the last method called once a notification is finished. We need to check once more that there are no notifications to be displayed
    if (self.notificationQueue.count > 0 && !self.isPaused)
    {
        [self displayNextNotificationObject];
    }
}

- (void)hideStatusBar
{
//    self.statusBarIsHidden = YES;
    
    [UIView animateWithDuration:.48
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                     }];
}

#pragma mark - Controls

- (void)resumenotificationQueue
{
    if (self.notificationQueue.count > 0)
    {
        self.isPaused = NO;
        
        [self showStatusBar];
//        self.statusBarIsHidden = YES;
        
        [self displayNextNotificationObject];
    }
}

- (void)pausenotificationQueue
{
    self.isPaused = YES;
    
    [self hideStatusBar];
//    self.statusBarIsHidden = NO;
}

- (void)stopnotificationQueue
{
    [self hideStatusBar];
    [self.notificationQueue removeAllObjects];
}

#pragma mark - Helpers

- (NSUInteger)countOfNotificationsEnqueued
{
    return self.notificationQueue.count;
}

@end
