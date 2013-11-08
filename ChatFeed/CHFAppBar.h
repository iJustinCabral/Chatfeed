//
//  CHFAppBar.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, AppBarState)
{
    AppBarStateNormal = 0,
    AppBarStateReloadData,
    AppBarStateBackToTop,
    AppBarStateFullscreen
};

typedef NS_ENUM (NSUInteger, AppBarTransition)
{
    AppBarTransitionSlide = 0,
    AppBarTransitionFade
};


@protocol CHFAppBarDelegate;

@interface CHFAppBar : UIView

@property (nonatomic, assign) id <CHFAppBarDelegate> delegate;

@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) BOOL shouldDrag;
@property (nonatomic, assign, getter = isShowingNotificationBar) BOOL showingNotificationBar;

@property (nonatomic) CGFloat height;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)showAppBar:(BOOL)show withTransition:(AppBarTransition)transition;

- (CGFloat)barButtonOffset;

@end

@protocol CHFAppBarDelegate <NSObject>

- (void)didEndDraggingAppBar:(CHFAppBar *)appBar withAppBarState:(AppBarState)state;

@optional

- (void)didStartDraggingAppBar:(CHFAppBar *)appBar;
- (void)didDragAppBar:(CHFAppBar *)appBar withPercentage:(CGFloat)percentage;

@end