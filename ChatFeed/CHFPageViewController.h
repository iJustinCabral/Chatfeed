//
//  CHFPageViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/11/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, PagingType)
{
    PagingTypeNone = 0,
    PagingTypeSwoopDown = 1,
    PagingTypeHoverOverRight = 2,
    PagingTypeDynamicSprings = 3
};

typedef NS_ENUM (NSUInteger, PagingTransitionAnimation)
{
    PagingTransitionAnimationNone = 0,
    PagingTransitionAnimationScale = 1,
    PagingTransitionAnimationFade = 2,
    PagingTransitionAnimationScaleFade = 3
};

@protocol CHFPageViewControllerDataSource, CHFPageViewControllerDelegate;


@interface CHFPageViewController : CHFViewController

// Delegates
@property (nonatomic, weak) id <CHFPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <CHFPageViewControllerDelegate> delegate;

// iVars
@property (nonatomic) NSUInteger initialPage;
@property (nonatomic, getter = isHidden) BOOL hidden;

// Transition methods
- (void)showWithAnimation:(PagingTransitionAnimation)transitionAnimation;
- (void)hideWithAnimation:(PagingTransitionAnimation)transitionAnimation;

// PageView Controller methods
- (void)goToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (NSUInteger)currentPageIndex;
- (CHFViewController *)currentPageViewController;

@end

#pragma mark - DataSource
@protocol CHFPageViewControllerDataSource <NSObject>

- (NSUInteger)numberOfViewControllersForPageViewController:(CHFPageViewController *)pageViewController;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
                      forPageViewController:(CHFPageViewController *)pageViewController;

@end

#pragma mark - Delegate
@protocol CHFPageViewControllerDelegate <NSObject>

@end