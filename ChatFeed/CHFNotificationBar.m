//
//  CHFNotificationBar.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFNotificationBar.h"

@interface CHFNotificationBar ()

@property (nonatomic, strong) NSMutableArray *notificationQueue;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *notificationLabel;

@property (nonatomic, readwrite, getter = isPaused) BOOL paused;
@property (nonatomic, readwrite, getter = isShowingNotifications) BOOL showingNotifications;

@end

@implementation CHFNotificationBar

#pragma mark - Lifecycle

+ (instancetype)sharedTopNotificationBar
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)sharedBottomNotifcationBar
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
    self.layer.opacity = 0.0;
    
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
        self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        self.notificationLabel.textColor = [UIColor whiteColor];
        self.notificationLabel.font = [UIFont boldSystemFontOfSize:13.0];
        self.notificationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.notificationLabel.numberOfLines = 1;
        self.notificationLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.notificationLabel];
    }
}

#pragma mark - Properties

- (void)setShowingNotifications:(BOOL)showingNotifications
{
    _showingNotifications = showingNotifications;
    
    if (showingNotifications)
    {
        [self.delegate didBeginShowingNotificationsFromNotificationBar:self];
    }
    else
    {
        [self.delegate didEndShowingNotificationsFromNotificationBar:self];
    }
}

#pragma mark - Queue Methods

- (void)addNotification:(CHFNotificationBarObject *)notification
{
    [self enqueueNotification:notification];
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
    
    if (self.notificationQueue.count > 0 && self.isShowingNotifications == NO)
    {
        [self displayNextNotificationObject];
    }
}

- (CHFNotificationBarObject *)dequeueNotification
{
    CHFNotificationBarObject *notification = self.notificationQueue[0];
    
    [self.notificationQueue removeObjectAtIndex:0];
    
    return notification;
}

- (void)displayNextNotificationObject
{
    if (!self.isPaused)
    {
        CHFNotificationBarObject *notification = [self dequeueNotification];
        
        if (self.isShowingNotifications)
        {
            [self hideNotificationAnimated:YES completion:^{
                [self displayNotification:notification
                              shouldDelay:NO];
            }];
        }
        else
        {
            [self displayNotification:notification
                          shouldDelay:YES];
        }
    }
}

- (void)displayNotification:(CHFNotificationBarObject *)notification shouldDelay:(BOOL)delay
{
    self.showingNotifications = YES;
    
    if ([self.delegate respondsToSelector:@selector(didBeginShowingNotification:fromNotificationBar:)])
    {
        [self.delegate didBeginShowingNotification:notification
                               fromNotificationBar:self];
    }
    
    //    [self updateFrameWidthForNotification:notification.notificationText];
    
    self.notificationLabel.text = notification.messageText;
    
    [UIView animateWithDuration:.48
                          delay:delay ? 0.3 : 0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.layer.opacity = 1.0;
                         if (notification.isProgressType)
                         {
                             self.activityIndicator.layer.opacity = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self notification:notification willEndAfter:3];
                     }];
}

- (void)notification:(CHFNotificationBarObject *)notification willEndAfter:(NSTimeInterval)interval // 5
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       
                       if ([self.delegate respondsToSelector:@selector(didEndShowingNotification:fromNotificationBar:)])
                       {
                           [self.delegate didEndShowingNotification:notification
                                                fromNotificationBar:self];
                       }
                       
                       // If the is still notifications in the queue display the next one
                       if (self.notificationQueue.count > 0)
                       {
                           [self displayNextNotificationObject];
                       }
                       else
                       {
                           [self showStatusBar];
                       }
                   });
}

- (void)hideNotificationAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (animated)
    {
        [UIView animateWithDuration:.48
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self hideNotificationAnimated:NO completion:nil];
                         }
                         completion:^(BOOL finished) {
                             completion();
                         }];
    }
    
    self.layer.opacity = 0.0;
}

#pragma mark - Statusbar Methods

- (void)showStatusBar
{
    [self hideNotificationAnimated:YES
                        completion:^{
                            
                            self.showingNotifications = NO;
                        }];
    
    // This is the last method called once a notification is finished. We need to check once more that there are no notifications to be displayed
    if (self.notificationQueue.count > 0 && !self.isPaused)
    {
        [self displayNextNotificationObject];
    }
}

#pragma mark - Controls

- (void)resume
{
    if (self.notificationQueue.count > 0)
    {
        self.paused = NO;
        
        [self showStatusBar];
    }
}

- (void)pause
{
    self.paused = YES;
    
//    [self hideStatusBar];
}

- (void)stop
{
//    [self hideStatusBar];
    [self.notificationQueue removeAllObjects];
}

#pragma mark - Helpers

- (NSUInteger)countOfEnqueuedNotifications
{
    return self.notificationQueue.count;
}

@end
