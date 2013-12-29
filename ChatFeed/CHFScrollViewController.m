//
//  CHFScrollViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/12/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFScrollViewController.h"
#import "CHFNonInteractiveView.h"

#define kInitialIndex 0
#define kMargin 0

// UIDynamic properties
#define kScrollResistanceCoefficient 1 / 2000.0f


@interface CHFScrollViewController () <CHFScrollViewDelegate>

@property (nonatomic) NSMutableArray *sectionContainerArray;

// UIDynamic Properties
@property (nonatomic) UIDynamicAnimator *animator;

// UIScrollView Properties
@property (nonatomic) CGFloat lastScrollDelta;
@property (nonatomic) CGFloat lastPercentageScrolled;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (nonatomic) NSUInteger destinationIndex;
@property (nonatomic, getter = isDragging, readwrite) BOOL dragging;

@end


@implementation CHFScrollViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.pagingStyle = PagingStyleSwoopDown;
    self.springsEnabled = self.pagingStyle == PagingStyleDynamicSprings;
    
    self.initialIndex = kInitialIndex;
    self.margin = kMargin;
}

- (void)loadView
{
    self.view = [[CHFNonInteractiveView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad
{
    [self configureScrollView];
    
    [super viewDidLoad];
    
    self.currentIndex = self.initialIndex;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.layer.allowsEdgeAntialiasing = YES;
    self.view.layer.allowsGroupOpacity = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Property Setters

- (void)setPagingStyle:(PagingStyle)pagingStyle
{
    if (pagingStyle == PagingStyleDynamicSprings)
    {
        self.springsEnabled = YES;
        
        if (Settings.isDynamicsEnabled)
        {
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.scrollView];
            _pagingStyle = pagingStyle;
        }
        else // If not dynamics are NOT supported
        {
            self.springsEnabled = NO;
            _pagingStyle = PagingStyleNone;
        }
    }
    else
    {
        self.springsEnabled = NO;
        _pagingStyle = pagingStyle;
    }
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    // Update the currentViewController to match the currentIndex
    CHFViewController *viewController = (CHFViewController *)[self.datasource viewControllerAtIndex:currentIndex forScrollViewController:self];
    self.currentViewController = viewController;
    
    // TODO: Find better place for method
    // Let the delegate know we did move to new index
    if ([self.delegate respondsToSelector:@selector(scrollViewController:didMoveToIndex:)])
    {
        [self.delegate scrollViewController:self didMoveToIndex:currentIndex];
    }
}

#pragma mark - Memory Management

- (void)removeViewControllersAtRange:(NSRange)range
{
    
}

- (void)removeViewControllersAtRanges:(NSArray *)ranges
{
    
}

- (void)restoreViewControllersAtRange:(NSRange)range
{
    
}

- (void)restoreViewControllersAtRanges:(NSArray *)ranges
{
    
}


#pragma mark - UIScrollView

- (void)configureScrollView
{
    if (!self.scrollView)
    {
        NSUInteger numberOfIndexs = [self.datasource numberOfViewControllersForScrollViewController:self];
        CGRect frame = self.view.bounds;
        CGFloat marginMass = (numberOfIndexs - 1) * self.margin;
        
        self.scrollView = [[CHFScrollView alloc] initWithFrame:frame];
        self.scrollView.delegate = self;
        self.scrollView.scrollViewDelegate = self;
        self.scrollView.pagingEnabled = self.margin == 0;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width * numberOfIndexs) + marginMass, self.scrollView.frame.size.height);
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        // Section Containers
        self.sectionContainerArray = [[NSMutableArray alloc] initWithCapacity:numberOfIndexs];
        
        for (NSUInteger index = 0; index < numberOfIndexs; index++)
        {
            CGFloat marginMass = index * self.margin;
            CGPoint offsetOrigin = CGPointMake((frame.size.width * index) + marginMass, frame.origin.y);
            frame.origin = offsetOrigin;
            
            CHFNonInteractiveView *sectionContainerView = [[CHFNonInteractiveView alloc] initWithFrame:frame];
            sectionContainerView.layer.cornerRadius = 8.0;
            sectionContainerView.layer.masksToBounds = YES;
            
            [self.sectionContainerArray addObject:sectionContainerView];
            
            CHFViewController *viewController = (CHFViewController *)[self.datasource viewControllerAtIndex:index forScrollViewController:self];
            [sectionContainerView addSubview:viewController.view];
            [self.scrollView addSubview:sectionContainerView];
            
//            if (index == self.initialIndex)
//            {
//                self.currentViewController = viewController;
//            }
            
            if (self.pagingStyle == PagingStyleDynamicSprings)
            {
                [self addSpringToView:sectionContainerView];
            }
        }
        
        [self.view addSubview:self.scrollView];
        
        [self moveToIndex:self.initialIndex animated:NO];
    }
}

- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated
{
    // Update the scroll view to the appropriate page
    CGFloat marginMass = index * self.margin;
    
    CGRect frame;
    frame.origin = CGPointMake((self.scrollView.frame.size.width * index) + marginMass, 0);
    frame.size = self.scrollView.frame.size;
    
    [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (PanDirection)panningDirectionFromVelocity:(CGPoint)velocity
{
    return 0 < velocity.x ? PanDirectionRight : PanDirectionLeft;
}

- (CGFloat)percentageToEdgeOfScrollView:(UIScrollView *)scrollView
{
    //    CGFloat width = scrollView.frame.size.width;
    //    CGFloat contentOffset = scrollView.contentOffset.x;
    //    CGFloat endOfContent = scrollView.contentSize.width;
    //    NSInteger numberOfPages = endOfContent / width;
    //    CGFloat offset = contentOffset / width;
    //
    
    
    return 0;
}

- (CGFloat)offsetForPageAtIndex:(NSUInteger)index
{
    CGFloat pageWidth = 320;
    CGFloat marginMass = index * self.margin;
    CGFloat pageMass = index * pageWidth;
    
    return marginMass + pageMass;
}

#pragma mark Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:self.scrollView]) return;
    
    NSLog(@"scrolling in CHFscrollview");
    
    NSUInteger oldDestinationIndex = self.destinationIndex;
    
    CGFloat width = scrollView.frame.size.width;
    CGFloat contentOffset = scrollView.contentOffset.x;
    //    CGFloat endOfContent = scrollView.contentSize.width;
    CGFloat offset = contentOffset / width;
    //    NSInteger numberOfPages = endOfContent / width;
//    NSUInteger currentIndexFromCenter = floor((offset - width / 2) / width) + 1;
    CGFloat currentIndexFromOrigin;
    CGFloat percentage;
    
    percentage = modff(offset, &currentIndexFromOrigin);
    
    // Direction of scrolling
    PanDirection direction = percentage < self.lastPercentageScrolled ? PanDirectionRight: PanDirectionLeft;
    
    // Set the current page once the page is at its content offset
    if ((int)contentOffset % (int)width == 0)
    {
        int page = contentOffset / width;
        
        if (self.currentIndex != page)
        {
            self.currentIndex = page;
        }
    }
    
    // Get which side of the current page you are on. ### Would be real cool if there was an "Unless" operator
    PageSide nearestDestinationSide;
    
    if (offset == (float)self.currentIndex)
    {
        nearestDestinationSide = PageSideMiddle;
    }
    else
    {
        if (offset < (float)self.currentIndex)
        {
            nearestDestinationSide = PageSideLeft;
        }
        else
        {
            nearestDestinationSide = PageSideRight;
        }
    }
    
    switch (nearestDestinationSide)
    {
        case PageSideMiddle:
        {
            if (self.destinationIndex != self.currentIndex)
            {
                self.destinationIndex = self.currentIndex;
            }
        }
            break;
            
        case PageSideLeft:
        {
            percentage = 1 - percentage;
            
            if (self.currentIndex == 0)
            {
                self.destinationIndex = self.currentIndex;
            }
            else if (self.destinationIndex != self.currentIndex - 1)
            {
                self.destinationIndex = self.currentIndex - 1;
            }
        }
            break;
            
        case PageSideRight:
        {
            if (self.currentIndex == [self.datasource numberOfViewControllersForScrollViewController:self] - 1)
            {
                self.destinationIndex = self.currentIndex;
            }
            else if (self.destinationIndex != self.currentIndex + 1)
            {
                self.destinationIndex = self.currentIndex + 1;
            }
        }
            break;
    }
    
    if (self.destinationIndex != self.currentIndex)
    {
        // Let the delegate know the scrollview scrolled
        if ([self.delegate respondsToSelector:@selector(scrollViewController:didScrollWithPercentage:inDirection:toViewController:)])
        {
            [self.delegate scrollViewController:self
                        didScrollWithPercentage:percentage
                                    inDirection:direction
                               toViewController:[self.datasource viewControllerAtIndex:self.destinationIndex
                                                               forScrollViewController:self]];
        }
        
        //
        if (self.destinationIndex != oldDestinationIndex)
        {
            
            UIViewController *destinationViewController = [self.datasource viewControllerAtIndex:self.destinationIndex forScrollViewController:self];
            
            if ([self.delegate respondsToSelector:@selector(scrollViewController:didBeginScrollingWithPercentage:inDirection:towardsViewController:fromViewController:)])
            {
                UIViewController *sourceViewController = [self.datasource viewControllerAtIndex:self.currentIndex
                                                                        forScrollViewController:self];
                
                [self.delegate scrollViewController:self
                    didBeginScrollingWithPercentage:percentage
                                        inDirection:direction
                              towardsViewController:destinationViewController
                                 fromViewController:sourceViewController];
            }
        }
    }
    
//    NSLog(@"Current Page = %i, directin = %i, Percentage = %f, destination page = %i, nearest side = %i, current page form origin = %f, offset = %f", self.currentIndex, direction, percentage, self.destinationIndex, nearestDestinationSide, currentIndexFromOrigin, offset);
    
//    NSLog(@"destination index path = %i", self.destinationIndex);
    
    // Update the last percentage scrolled, which is used to calculate scrolling direction
    self.lastPercentageScrolled = percentage;
    
    // Apply the paging trasitions
    switch (self.pagingStyle)
    {
        case PagingStyleNone:
            break;
        case PagingStyleSwoopDown:
            [self pagingStyleSwoopDown];
            break;
        case PagingStyleHoverOverRight:
            [self pagingStyleHoverOverRight];
            break;
        case PagingStyleDynamicSprings:
            if (self.isDragging) [self updateSprings];
            break;
        default:
            break;
    }
}

///*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.margin == 0) return;
    
    CGFloat offset;
    NSLog(@"velocity = %@", NSStringFromCGPoint(velocity));
    CGFloat velocityThreshold = 1;
    
    if (velocity.x > velocityThreshold || velocity.x < -velocityThreshold)
    {
        CGFloat pageWidth = 320.0;
        NSUInteger currentIndexFromCenter = floor((targetContentOffset->x - pageWidth / 2) / pageWidth) + 1;
        NSUInteger numberOfIndexes = [self.datasource numberOfViewControllersForScrollViewController:self];
        
        if (velocity.x > velocityThreshold) // Going towards right index
        {
            if (currentIndexFromCenter == numberOfIndexes - 1)
            {
                offset = [self offsetForPageAtIndex:currentIndexFromCenter];
            }
            else
            {
                offset = [self offsetForPageAtIndex:currentIndexFromCenter + 1];
            }
        }
        else // Going towards left index
        {
            if (currentIndexFromCenter == 0)
            {
                offset = [self offsetForPageAtIndex:currentIndexFromCenter];
            }
            else
            {
                offset = [self offsetForPageAtIndex:currentIndexFromCenter - 1];
            }
        }
    }
    else
    {
        if (self.lastPercentageScrolled < 0.5)
        {
            offset = [self offsetForPageAtIndex:self.currentIndex];
        }
        else
        {
            offset = [self offsetForPageAtIndex:self.destinationIndex];
        }
    }
    
    targetContentOffset->x = offset;
}
//*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didEndScrollingScrollViewController:withDestinationViewController:)])
    {
        [self.delegate didEndScrollingScrollViewController:self
                             withDestinationViewController:[self.datasource viewControllerAtIndex:self.destinationIndex
                                                                          forScrollViewController:self]];
    }
}

- (void)didBeginDraggingScrollView:(CHFScrollView *)scrollView
{
    self.dragging = YES;
}

- (void)didEndDraggingScrollView:(CHFScrollView *)scrollView
{
    self.dragging = NO;
}

#pragma mark Show/Hide Methods

- (void)showWithAnimation:(TransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case TransitionAnimationNone:
        {
            self.scrollView.layer.transform = CATransform3DIdentity;
            self.scrollView.alpha = 0.0;
            self.scrollView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
        }
            break;
        case TransitionAnimationFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
        case TransitionAnimationScale:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            
            break;
        case TransitionAnimationScaleFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.alpha = 1.0;
                                 self.scrollView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
    
    self.hidden = NO;
}

- (void)hideWithAnimation:(TransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case TransitionAnimationNone:
        {
            self.scrollView.layer.transform = CATransform3DIdentity;
            self.scrollView.alpha = 0.0;
            self.scrollView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
        }
            break;
        case TransitionAnimationFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.alpha = 0.0;
                             }
                             completion:^(BOOL finished)
             {
                 
             }];
        }
            break;
        case TransitionAnimationScale:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            
            break;
        case TransitionAnimationScaleFade:
        {
            [UIView animateWithDuration:0.2
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.scrollView.layer.transform = CATransform3DIdentity;
                                 self.scrollView.alpha = 0.0;
                                 self.scrollView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
    
    self.hidden = YES;
}

#pragma mark Transition Animations

- (void)pagingStyleSwoopDown
{
    for (UIView *sectionContainer in self.sectionContainerArray)
    {
        NSUInteger sectionIndex = [self.sectionContainerArray indexOfObject:sectionContainer];
        NSUInteger numberOfSections = self.sectionContainerArray.count;
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
        sectionContainer.layer.transform = CATransform3DMakeScale(scale, scale, 1.0f);
        [CATransaction commit];
    }
}

- (void)pagingStyleHoverOverRight
{
    for (UIView *sectionContainer in self.sectionContainerArray)
    {
        NSUInteger sectionIndex = [self.sectionContainerArray indexOfObject:sectionContainer];
        
        self.view.layer.transform = CATransform3DIdentity;
        
        // Easier reference to these
        CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
        CGFloat offset = self.scrollView.contentOffset.x;
        
        // Do some initial calculations to see how far off it is from being the center card
        CGFloat currentIndex = (offset / scrollViewWidth);
        CGFloat pageDifference = (sectionIndex - currentIndex);
        
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

#pragma mark - UIDynamic Behaviors

- (void)addSpringToView:(UIView *)view
{
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:view
                                                             attachedToAnchor:view.center];
    
    spring.length = 0;
    spring.damping = 0.7;
    spring.frequency = 0.8;
    
    [self.animator addBehavior:spring];
}

- (void)updateSprings
{
    CGPoint touchLocation = [self.scrollView.panGestureRecognizer locationInView:self.scrollView];
    CGFloat scrollDelta = self.scrollView.bounds.origin.x - self.lastScrollDelta;
    
    self.lastScrollDelta = self.scrollView.bounds.origin.x;
    
    for (UIAttachmentBehavior *spring in self.animator.behaviors)
    {
        UIView *container = spring.items.firstObject;
        
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.x - anchorPoint.x);
        CGFloat scrollResistance = distanceFromTouch * kScrollResistanceCoefficient;
        
        CGFloat axisValue = container.center.x;
        
        if (scrollDelta < 0)
        {
            axisValue += MAX(scrollDelta, scrollDelta * scrollResistance);
        }
        else
        {
            axisValue += MIN(scrollDelta, scrollDelta * scrollResistance);
        }
        
        container.center = CGPointMake(axisValue, container.center.y);
        
        [self.animator updateItemUsingCurrentState:container];
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


#pragma mark - CHFScrollView Implementation

@interface CHFScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation CHFScrollView

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Pan
    if (!self.panGesture)
    {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(panned:)];
        [self addGestureRecognizer:self.panGesture];
    }
    
    // Pinch
    if (!self.pinchGesture)
    {
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(pinched:)];
        [self addGestureRecognizer:self.pinchGesture];
    }
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [otherGestureRecognizer isEqual:self.panGesture] ? YES : NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    [self.scrollViewDelegate didBeginDraggingScrollView:self];
    
    return YES;
}


#pragma mark - Gesture Methods

- (void)panned:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self.scrollViewDelegate didEndDraggingScrollView:self];
        }
            break;
        default:
            break;
    }
}

- (void)pinched:(UIPinchGestureRecognizer *)pinchGesture
{
    switch (pinchGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            for (UIView *view in self.subviews)
            {
                view.userInteractionEnabled = NO;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            for (UIView *view in self.subviews)
            {
                view.userInteractionEnabled = YES;
            }
        }
        default:
            break;
    }
}

#pragma mark -

// Set the point to only effect subviews, and allow other touches to pass through
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews)
    {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    
    return NO;
}

@end

