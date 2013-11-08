//
//  CHFNavigationBar.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, NavigationBarState)
{
    NavigationBarStateNormal = 0,
    NavigationBarStateReloadData,
    NavigationBarStateBackToTop,
    NavigationBarStateFullscreen
};

typedef NS_ENUM (NSUInteger, NavigationBarTransition)
{
    NavigationBarTransitionSlide = 0,
    NavigationBarTransitionFade
};


@protocol CHFNavigationBarDelegate;

@interface CHFNavigationBar : UINavigationBar

@property (nonatomic, assign) id <CHFNavigationBarDelegate> delegate;

@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) BOOL shouldDrag;
@property (nonatomic, assign, getter = isShowingNotificationBar) BOOL showingNotificationBar;


@property (nonatomic) CGFloat height;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)showNavigationBar:(BOOL)show withTransition:(NavigationBarTransition)transition;

- (CGFloat)barButtonOffset;

@end

@protocol CHFNavigationBarDelegate <NSObject>

- (void)didEndDraggingNavigationBar:(UINavigationBar *)navigationBar withNavigationBarState:(NavigationBarState)state;

@optional

- (void)didStartDraggingNavigationBar:(UINavigationBar *)navigationBar;
- (void)didDragNavigationBar:(UINavigationBar *)navigationBar withPercentage:(CGFloat)percentage;

@end