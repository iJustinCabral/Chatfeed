//
//  CHFAppBar.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppBar.h"
#import "CHFNotificationBar.h"

static CGFloat const kDragActionReload = 0.34; // Percentage limit to trigger the reload action
static CGFloat const kDragActionBackToTop = 0.50; // Percentage limit to trigger the btt action
static CGFloat const kDragActionFullscreen = -0.12; // Percentage limit to trigger the fullscreeen action
static CGFloat const kDragActionFadeThreshold = 0.10; // Threshold for fade in/out
static CGFloat const kDragActionViewHeight = 240.0; // Threshold for fade in/out
static CGFloat const kNotificationBarHeight = 26.0;
static CGFloat const kAnimationDuration = 0.6;

@interface CHFAppBar () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *actionView;
@property (nonatomic, strong) CAShapeLayer *actionViewShape;

@end


@implementation CHFAppBar

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = frame.size.height;
        [self initializer];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.height = 44;
        [self initializer];
    }
    return self;
}

- (instancetype)initWithHeight:(CGFloat)height
{
    self = [super init];
    if (self) {
        self.height = height;
        [self initializer];
    }
    return self;
}

- (void)initializer
{
    self.shouldDrag = YES;
    
    // Add a pan gesture to the app bar
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedAppBar:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Adjust the frame to show the correct height
    CGRect frame = self.superview.frame;
    CGFloat offset = frame.size.height - self.height;
    frame.origin.y -= offset;
    
    self.frame = frame;
    
    // Configurations
    [self configureNotificationBar];
    [self configureActionView];
}

#pragma mark - Helpers

- (CGRect)appBarHiddenOffset
{
    CGRect frame = [self appBarFrame];
    frame.origin.y = -self.frame.size.height;
    
    return frame;
}

- (CGFloat)appBarVisibleOffset
{
    CGFloat appBarVisibleHeight = self.height;
    
    if (self.isShowingNotificationBar) appBarVisibleHeight += kNotificationBarHeight;
    
    return -(CGRectGetHeight(self.superview.bounds) - appBarVisibleHeight);
}

- (CGRect)appBarFrame
{
    return CGRectMake(0, [self appBarVisibleOffset], CGRectGetWidth(self.superview.bounds), CGRectGetHeight(self.superview.bounds));
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToHeight:(CGFloat)height
{
    CGFloat percentage = offset / height;
    NSLog(@"the percentage = %f",percentage);
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (CGFloat)barButtonOffset
{
    // The default nav height is 44, with its items automatically positioned. For every point we change in height we need to calculate how many points the items have to be offset.
    CGFloat defaultHeight = 44;
    
    return -(self.height - defaultHeight) / 2;
}

#pragma mark - Methods

- (void)snapBackAppBarToOriginWithVelocity:(CGPoint)velocity
{
    NSLog(@"the velocity = %@", NSStringFromCGPoint(velocity));
    
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = [self appBarFrame];
                     }
                     completion:^(BOOL finished) {
                         [self appBarDidReturnToOrigin];
                     }];
}

- (void)appBarDidReturnToOrigin
{
    [self configureActionView];
}

#pragma mark - Transition

- (void)showAppBar:(BOOL)show withTransition:(AppBarTransition)transition
{
    switch (transition)
    {
        case AppBarTransitionFade:
        {
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.layer.opacity = show ? 1.0: 0.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
        case AppBarTransitionSlide:
        {
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:0.6
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.layer.frame = show ? [self appBarFrame] : [self appBarHiddenOffset];
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
}


#pragma mark - NotificationBar

- (void)configureNotificationBar
{
    CHFNotificationBar *notificationBar = [[CHFNotificationBar alloc] initWithFrame:[self notificationBarFrame]];
    notificationBar.backgroundColor = [UIColor orangeColor];
    
    [self addSubview:notificationBar];
}

- (CGRect)notificationBarFrame
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = self.frame.size.height - self.height - kNotificationBarHeight;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = kNotificationBarHeight;
    
    return frame;
}

#pragma mark - Drag Action

- (void)configureActionView
{
    if (!self.actionView)
    {
        self.actionView = [[UIView alloc] initWithFrame:[self actionViewFrame]];
        
        [self addSubview:self.actionView];
    }
    
    self.actionView.backgroundColor = [UIColor chatFeedGreen];
    self.actionView.layer.opacity = 0.0;
}

- (CGRect)actionViewFrame
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = self.frame.size.height - self.height - kNotificationBarHeight - kDragActionViewHeight;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = kDragActionViewHeight;
    
    return frame;
}

- (CGPathRef)reloadActionPath
{
    UIBezierPath *rect = [UIBezierPath bezierPath];
    return [rect CGPath];
}

- (CGPathRef)backToTopActionPath
{
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    return [triangle CGPath];
}

- (AppBarState)stateWithPercentage:(CGFloat)percentage
{
    AppBarState state = AppBarStateNormal;
    
    if (percentage >= kDragActionReload)
        state = AppBarStateReloadData;
    
    if (percentage >= kDragActionBackToTop)
        state = AppBarStateBackToTop;
    
    if (percentage <= -kDragActionFullscreen)
        state = AppBarStateFullscreen;
    
    return state;
}

- (void)animateIconWithPercentage:(CGFloat)percentage
{
    CGFloat fadeIncrementValue = (kDragActionReload - kDragActionFadeThreshold) / 10;
    CGFloat changeColorIncrementValue = (kDragActionBackToTop - kDragActionReload) / 10;
//    NSLog(@"the test x = %f, fadein = %f", x, fadeInIncrementValue);
//    CGFloat fadeInIncrementValue = (100 / (kDragActionReload - kDragActionFadeThreshold)) / 100;
    
    NSLog(@"animateIconWithPercentage percentage = %f, %f ", percentage, fadeIncrementValue);
    
    if (percentage >= kDragActionReload - kDragActionFadeThreshold && percentage < kDragActionReload)
    {
        NSLog(@"in the coditiaoinal %f", self.actionView.layer.opacity);
        self.actionView.layer.opacity += fadeIncrementValue;
    }
    if (percentage >= kDragActionReload && percentage < kDragActionBackToTop)
    {
        self.actionView.backgroundColor = [UIColor redColor];
    }
    if (percentage >= kDragActionBackToTop && percentage < kDragActionBackToTop + kDragActionFadeThreshold)
    {
        self.actionView.layer.opacity -= fadeIncrementValue;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        // We notify the delegate that we just started dragging
        if ([self.delegate respondsToSelector:@selector(didStartDraggingAppBar:)])
        {
            [self.delegate didStartDraggingAppBar:self];
        }
        
        return YES;
    }
    return NO;
}


- (void)pannedAppBar:(UIPanGestureRecognizer *)panGesture
{
    if (!self.shouldDrag) return;
    
    CGPoint translation = [panGesture translationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:self.superview];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMaxY(self.frame) relativeToHeight:CGRectGetHeight(self.superview.bounds)];
    NSLog(@"the percentage = %f", percentage);
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            self.dragging = YES;
            
            if (percentage >= 1.0)
            {
                // Since the nav bar is its superview height we just make the centers the same
                self.center = self.superview.center;
            }
            else
            {
                self.center = CGPointMake(self.center.x, self.center.y + translation.y);
                [panGesture setTranslation:CGPointZero inView:self.superview];
            }
            
            [self animateIconWithPercentage:percentage];
            
            if ([self.delegate respondsToSelector:@selector(didDragAppBar:withPercentage:)])
            {
                [self.delegate didDragAppBar:self withPercentage:percentage];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.dragging = NO;
            
            [self.delegate didEndDraggingAppBar:self
                                withAppBarState:[self stateWithPercentage:percentage]];
            
            [self snapBackAppBarToOriginWithVelocity:velocity];
        }
            break;
        default:
            break;
    }
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
