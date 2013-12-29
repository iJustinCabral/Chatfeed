//
//  CHFScrollViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/12/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFViewController.h"

typedef NS_ENUM (NSUInteger, PagingStyle)
{
    PagingStyleNone = 0,
    PagingStyleSwoopDown,
    PagingStyleHoverOverRight,
    PagingStyleDynamicSprings
};

typedef NS_ENUM (NSUInteger, PageSide)
{
    PageSideLeft = 0,
    PageSideMiddle,
    PageSideRight
};

typedef NS_ENUM (NSUInteger, TransitionAnimation)
{
    TransitionAnimationNone = 0,
    TransitionAnimationScale,
    TransitionAnimationFade,
    TransitionAnimationScaleFade
};


@class CHFScrollView;

@protocol CHFScrollViewControllerDelegate, CHFScrollViewControllerDataSource;

#pragma mark - CHFScrollViewController Interface
@interface CHFScrollViewController : CHFViewController

// Delegates
@property (nonatomic, weak) id <CHFScrollViewControllerDelegate> delegate;
@property (nonatomic, weak) id <CHFScrollViewControllerDataSource> datasource;

// Transition Properties
@property (nonatomic) PagingStyle pagingStyle;
@property (nonatomic) TransitionAnimation transitionAnimation;

// Dynamics Properties - only used when the PagingStyle is PagingStyleDynamicSprings
@property (nonatomic, getter = isSpringsEnabled) BOOL springsEnabled;

// ScrollView Properties
@property (nonatomic) CHFScrollView *scrollView;

@property (nonatomic, getter = isHidden) BOOL hidden;
@property (nonatomic, getter = isDragging, readonly) BOOL dragging;

// If the margin is 0 then the scrollView's PagingEnabled is set to YES. If the margin is > 0 then we have to resort to the targetedContentOffset method
@property (nonatomic) CGFloat margin;

@property (nonatomic) NSUInteger initialIndex;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, weak) CHFViewController *currentViewController;

// Transition methods
- (void)showWithAnimation:(TransitionAnimation)transitionAnimation;
- (void)hideWithAnimation:(TransitionAnimation)transitionAnimation;

- (void)moveToIndex:(NSUInteger)index
           animated:(BOOL)animated;

// Memory Management
- (void)removeViewControllersAtRange:(NSRange)range;
- (void)removeViewControllersAtRanges:(NSArray *)ranges; // Store each range in a NSValue to give to array
- (void)restoreViewControllersAtRange:(NSRange)range;
- (void)restoreViewControllersAtRanges:(NSArray *)ranges; // Store each range in a NSValue to give to array

@end

#pragma mark Delegate
@protocol CHFScrollViewControllerDelegate <NSObject>

@optional;
- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
didBeginScrollingWithPercentage:(CGFloat)percentage
                 inDirection:(PanDirection)direction
       towardsViewController:(UIViewController *)destinationViewController
          fromViewController:(UIViewController *)sourceViewController;

- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
     didScrollWithPercentage:(CGFloat)percentage
                 inDirection:(PanDirection)direction
            toViewController:(UIViewController *)viewController;

- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
didHitCenterOfDeckViewController:(UIViewController *)viewController;

- (void)didEndScrollingScrollViewController:(CHFScrollViewController *)scrollViewController
              withDestinationViewController:(UIViewController *)destinationViewController;

- (void)scrollViewController:(CHFScrollViewController*)scrollViewController
              didMoveToIndex:(NSUInteger)index;

@end

#pragma mark DataSource
@protocol CHFScrollViewControllerDataSource <NSObject>

- (NSUInteger)numberOfViewControllersForScrollViewController:(CHFScrollViewController *)scrollViewController;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
                    forScrollViewController:(CHFScrollViewController *)scrollViewController;

@end


#pragma mark - CHFScrollView Interface

@protocol CHFScrollViewDelegate;

@interface CHFScrollView : UIScrollView

@property (nonatomic, weak) id <CHFScrollViewDelegate> scrollViewDelegate;

@end

#pragma mark Delegate

@protocol CHFScrollViewDelegate <UIScrollViewDelegate>

- (void)didBeginDraggingScrollView:(CHFScrollView *)scrollView;
- (void)didEndDraggingScrollView:(CHFScrollView *)scrollView;

@end