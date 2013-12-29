//
//  CHFAppBar.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFBlurView.h"
#import "CHFAppBarScrollView.h"

typedef NS_ENUM (NSUInteger, AppBarAction)
{
    AppBarActionNormal = 0,
    AppBarActionReloadData,
    AppBarActionBackToTop,
    AppBarActionFullscreen
};

typedef NS_ENUM (NSUInteger, AppBarTransition)
{
    AppBarTransitionSlide = 0,
    AppBarTransitionFade
};

@protocol CHFAppBarDelegate;

#pragma mark - Interface

@interface CHFAppBar : UIViewController <CHFNotificationBarDelegate>

@property (nonatomic, weak) id <CHFAppBarDelegate> delegate;

@property (nonatomic) BOOL shouldAnimateWhenAppearing;
@property (nonatomic) BOOL shouldMinimalize;
@property (nonatomic) BOOL shouldDrag;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isMinimalized) BOOL minimalized;
@property (nonatomic, readonly, getter = isHidden) BOOL hidden; // When apps in fullscreen
@property (nonatomic, getter = isCollectionViewDragging) BOOL collectionViewDragging;

@property (nonatomic) CHFAppBarScrollView *auxiliaryBarScrollView;

- (instancetype)initWithBarView:(CHFAppBarView *)barView;

- (void)showAppBar:(BOOL)show
    withTransition:(AppBarTransition)transition;

- (CGFloat)appBarVisibleHeight;

- (void)addBarView:(CHFAppBarView *)barView;
- (void)addView:(UIView *)view withBarViewType:(AppBarViewType)barViewType;
- (void)clearBarView:(CHFAppBarView *)barView;
- (void)clearBarViewType:(AppBarViewType)barViewType;

- (void)interactiveTransitionToAuxiliaryViewWithPercentage:(CGFloat)percentage;
- (void)interactiveTransitionFromAuxiliaryViewWithPercentage:(CGFloat)percentage;

- (void)interactiveTransitionToMinimalizationInDirection:(PanDirection)direction
                                              withOffset:(CGFloat)offset
                                             andVelocity:(CGPoint)velocity;

- (void)collectionViewModel:(CHFAbstractModel *)model
     didUpdateContentOffset:(CGFloat)contentOffset
           withOffsetChange:(CGFloat)change;

//TODO: Rename to collectionView.. beganindirection.....
- (void)beganDraggingCollectionViewModel:(CHFAbstractModel *)model
                             inDirection:(PanDirection)direction
                            withVelocity:(CGPoint)velocity;

- (void)endedDraggingCollectionViewModel:(CHFAbstractModel *)model
                             inDirection:(PanDirection)direction
                            withVelocity:(CGPoint)velocity;

@end

#pragma mark - Delegate

@protocol CHFAppBarDelegate <NSObject>

- (void)didEndDraggingAppBar:(CHFAppBar *)appBar
             withAppBarAction:(AppBarAction)action;

@optional

- (void)didUpdateAppBar:(CHFAppBar *)appBar
               toHeight:(CGFloat)height;

- (void)didStartDraggingAppBar:(CHFAppBar *)appBar
                   inDirection:(PanDirection)direction;

- (void)didDragAppBar:(CHFAppBar *)appBar
       withPercentage:(CGFloat)percentage
          inDirection:(PanDirection)direction;

- (void)willClearAuxiliaryViewForAppBar:(CHFAppBar *)appBar;
- (void)didClearAuxiliaryViewForAppBar:(CHFAppBar *)appBar;

- (void)didSingleTapAppBar:(CHFAppBar *)appBar;
- (void)didDoubleTapAppBar:(CHFAppBar *)appBar;

@end

#pragma mark - Interface CHFShadowCouplingView

@interface CHFShadowCouplingView : CHFBlurView

- (void)updateShadowFrame;

- (void)drawShadowAnimated:(BOOL)animated;

- (void)removeShadowAnimated:(BOOL)animated;

@end