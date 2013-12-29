//
//  CHFPageViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/11/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPageViewController.h"

#define kInitialPage 0

@interface CHFPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, weak) UIScrollView *scrollView;

//
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) CGFloat oldScrollBounds;

@end

@implementation CHFPageViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.initialPage = kInitialPage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configurePageViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView = [self scrollViewFromPageViewController];
    NSLog(@"the scrollview = %@", self.scrollView);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)scrollViewFromPageViewController
{
    for (UIScrollView *scrollView in self.view.subviews)
    {
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            return scrollView;
            break;
        }
    }
    
    return nil;
}

#pragma mark - UIPageViewController

- (void)configurePageViewController
{
    self.pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
    
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [self goToPageAtIndex:self.initialPage
                 animated:NO];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)goToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSArray *array = @[[self viewControllerAtIndex:index]];
    [self.pageViewController setViewControllers:array
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:animated
                                     completion:nil];
}

- (CHFViewController *)viewControllerAtIndex:(NSUInteger)index
{
    CHFViewController *viewController = (CHFViewController *)[self.dataSource viewControllerAtIndex:index
                                                        forPageViewController:self];
    viewController.index = index;
    NSLog(@"teh viewcontroller = %@", viewController);
    return viewController;
}

- (NSUInteger)currentPageIndex
{
    CHFViewController *viewController = [self.pageViewController viewControllers][0];
    return viewController.index;
}

- (CHFViewController *)currentPageViewController
{
    return [self.pageViewController viewControllers][0];
}

#pragma mark DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(CHFViewController *)viewController index];
    
    if (index == 0 || (index == NSNotFound))  return nil;
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(CHFViewController *)viewController index];
    
    if (index == [self.dataSource numberOfViewControllersForPageViewController:self] - 1 || (index == NSNotFound)) return nil;
    
    index++;
    
    return [self viewControllerAtIndex:index];
    
}

#pragma mark Show/Hide Methods

- (void)showWithAnimation:(PagingTransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case PagingTransitionAnimationNone:
        {
            self.view.layer.transform = CATransform3DIdentity;
            self.view.alpha = 0.0;
            self.view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
        }
            break;
        case PagingTransitionAnimationFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
        case PagingTransitionAnimationScale:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            
            break;
        case PagingTransitionAnimationScaleFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.alpha = 1.0;
                                 self.view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
    
    self.hidden = NO;
}

- (void)hideWithAnimation:(PagingTransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case PagingTransitionAnimationNone:
        {
            self.view.layer.transform = CATransform3DIdentity;
            self.view.alpha = 0.0;
            self.view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
        }
            break;
        case PagingTransitionAnimationFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished)
             {
                 
             }];
        }
            break;
        case PagingTransitionAnimationScale:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            
            break;
        case PagingTransitionAnimationScaleFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.view.layer.transform = CATransform3DIdentity;
                                 self.view.alpha = 0.0;
                                 self.view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
    
    self.hidden = YES;
}

#pragma mark Transition Animations
/*
- (void)pagingStyleSwoopDown
{
    for (UIView *view in self.scrollView.subviews)
    {
        NSUInteger sectionIndex = [self.sectionContainerArray indexOfObject:sectionContainer];
        NSUInteger numberOfSections = [self.dataSource numberOfViewControllersForPageViewController:self];
        self.view.layer.transform = CATransform3DIdentity;
        
        // Easier reference to these
        CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
        CGFloat offset = self.scrollView.contentOffset.x;
        
        // Do some initial calculations to see how far off it is from being the center card
        CGFloat nearestToCenterPage = (offset / scrollViewWidth);
        CGFloat pageDifference = (sectionIndex - nearestToCenterPage);
        
        // And the default values
        CGFloat scale = 1.0f;
        
        if (sectionIndex == 0) // First Section
        {
            if (nearestToCenterPage > 0)
            {
                scale = 1 + (pageDifference / 10);
            }
            else
            {
                
            }
        }
        else if (sectionIndex == numberOfSections - 1) // Last Section
        {
            if (nearestToCenterPage > numberOfSections - 1)
            {
                
            }
            else
            {
                scale = 1 - (pageDifference / 10);
            }
        }
        else // Between Cards
        {
            if (nearestToCenterPage > sectionIndex)
            {
                scale = 1 + (pageDifference / 10);
            }
            else
            {
                scale = 1 - (pageDifference / 10);
            }
        }
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        view.layer.transform = CATransform3DMakeScale(scale, scale, 1.0f);
        [CATransaction commit];
    }
}

- (void)pagingStyleHoverOverRight
{
    for (UIView *view in self.scrollView.subviews)
    {
        NSUInteger sectionIndex = [self.sectionContainerArray indexOfObject:sectionContainer];
        
        self.view.layer.transform = CATransform3DIdentity;
        
        // Easier reference to these
        CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
        CGFloat offset = self.scrollView.contentOffset.x;
        
        // Do some initial calculations to see how far off it is from being the center card
        CGFloat currentPage = (offset / scrollViewWidth);
        CGFloat pageDifference = (sectionIndex - currentPage);
        
        // And the default values
        CGFloat scale = 1.0f;
        CGFloat alpha = 1.0f;
        
        // Scale it based on how far it is from being centered
        scale += (pageDifference * 0.2);
        
        // If it's meant to have faded into the screen fade it out
        if (pageDifference > 0.0f)
        {
            alpha = 1 - pageDifference;
        }
        
        // Don't let it get below nothing (like reversed is -1)
        if (scale < 0.0f)
        {
            scale = 0.0f;
        }
        
        // If you can't see it disable userInteraction so as to stop it preventing touches on the one bellow.
        if (alpha <= 0.0f)
        {
            alpha = 0.0f;
            self.view.userInteractionEnabled = NO;
        }
        else
        {
            self.view.userInteractionEnabled = YES;
        }
        
        // Set effects
        self.view.alpha = alpha;
        
        // We could do just self.transform = but it comes by default with an animation.
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        self.view.layer.transform = CATransform3DMakeScale(scale, scale, 1.0f);
        [CATransaction commit];
    }
}
//*/

#pragma mark - UIDynamic Behaviors

- (void)addSpringToView:(UIView *)view
{
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:view
                                                             attachedToAnchor:view.center];
    
    spring.length = 0;
    spring.damping = 0.6;
    spring.frequency = 0.8;
    
    [self.animator addBehavior:spring];
}

- (void)updateSprings
{
    CGPoint touchLocation = [self.scrollView.panGestureRecognizer locationInView:self.scrollView];
    
    CGFloat scrollDelta = self.scrollView.bounds.origin.x - self.oldScrollBounds;
    
    self.oldScrollBounds = self.scrollView.bounds.origin.x;
    
    for (UIAttachmentBehavior *spring in self.animator.behaviors)
    {
        UIView *cardDynamicContainer = spring.items.firstObject;
        
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat touchDistance = fabsf(touchLocation.x - anchorPoint.x);
        CGFloat resistanceFactor = 0.002;
        
        CGPoint center = cardDynamicContainer.center;
        
        CGFloat resistedScroll = scrollDelta * touchDistance * resistanceFactor;
        CGFloat simpleScroll = scrollDelta;
        
        CGFloat actualScroll = MIN(abs(simpleScroll), abs(resistedScroll));
        
        if (simpleScroll < 0)
        {
            actualScroll *= -1;
        }
        
        center.x += actualScroll;
        cardDynamicContainer.center = center;
        
        [self.animator updateItemUsingCurrentState:cardDynamicContainer];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.view.subviews)
    {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self.view convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    
    return NO;
}

@end
