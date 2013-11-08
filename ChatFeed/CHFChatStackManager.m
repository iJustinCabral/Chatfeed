//
//  CHFChatStackManager.m
//  DynamicsCatalog
//
//  Created by Larry Ryan on 6/18/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "CHFChatStackManager.h"

#import "CHFChatStackDeckController.h"

#import "CHFHoverMenuViewController.h"
#import "CHFItemsCollectionViewController.h"
#import "CHFHoverMenuCell.h"

#import "UIImage+ImageEffects.h"

#import "CHFBlurView.h"

#import "BlackholeView.h"

@import QuartzCore;

#define kMotionEffectEnabled NO
#define kStackItemAllowsRotation NO // when set to NO, the item will also have more of a damping effect
#define kStackInset 20
#define kSnapBackInset 10
#define kReboundElasticity 100
#define kChatItemOffset 4
#define kMaxChatStackItems 4
#define kChatStackInset 156
#define kKickZoneSize 148
#define kKickOutDuration 1.0 // TODO: set property for const
#define kStackItemSize 60

// TODO: set all following property for const
#define kZIndexBackground 100
#define kZIndexViews 200
#define kZIndexStackItem 300



typedef NS_ENUM (NSUInteger, ProgressBarState)
{
    ProgressBarStateBeginning = 0,
    ProgressBarStateEnd = 1
};

@interface CHFChatStackManager () <CHFChatStackItemDelegate, UIDynamicAnimatorDelegate, StackDeckControllerDelegate, ItemsCollectionViewControllerDataSource, ItemsCollectionViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;


@property (nonatomic) CGPoint pendingBoundsPoint;



@property (nonatomic, strong, readwrite) NSMutableArray *itemArray;
@property (nonatomic, strong, readwrite) NSMutableArray *pendingItemArray;
@property (nonatomic, strong, readwrite) NSMutableArray *replyItemArray;
@property (nonatomic, strong, readwrite) NSMutableArray *oldItemArray;

// Behaviors
@property (nonatomic, strong) UIGravityBehavior *universeGravity;
@property (nonatomic, getter = isDragging) BOOL dragging;

// This is the background blur view for the stack window
@property (nonatomic, strong) CHFBlurView *blurView;

// Displays options on a hud for what ever context they're in
@property (nonatomic, strong) CHFHoverMenuViewController *hoverMenuController;


@property (nonatomic, strong) CHFChatStackDeckController *chatStackDeckController;

// This is the collection view for replying to users not in the chatstack
@property (nonatomic, strong) CHFItemsCollectionViewController *replyItemsCollectionViewController;
@property (nonatomic) BOOL replyItemsCollectionViewIsHidden;

// This collection view has all of the recent users you have messages with in the chatstack
@property (nonatomic, strong) CHFItemsCollectionViewController *messageItemsCollectionViewController;
@property (nonatomic) BOOL messageItemsCollectionViewIsHidden;

// Blackhole
@property (nonatomic, strong) BlackholeView *blackholeView;

// KickingZone
@property (nonatomic, strong) UIView *kickZoneView;
//@property (nonatomic, strong) CAShapeLayer *loadingBarLayer; // TODO: Remove old loading bar
@property (nonatomic, strong) NSTimer *displayLink;
@property (nonatomic) BOOL wantsToShowKickZone; // Helps out with presenting kick zone delay
@property (nonatomic) BOOL wantsToExpand;

// Enum Types
@property (nonatomic, readwrite) ItemLayout layout;

// Settings
@property (nonatomic, readwrite) BOOL motionEffectEnabled;
@property (nonatomic, readwrite) BOOL stackItemAllowsRotation;
@property (nonatomic, readwrite) CGFloat stackInset;
@property (nonatomic, readwrite) CGFloat snapBackInset;
@property (nonatomic, readwrite) CGFloat reboundElasticity;
@property (nonatomic, readwrite) CGFloat chatItemOffset;
@property (nonatomic, readwrite) CGFloat maxChatStackItems;
@property (nonatomic, readwrite) CGFloat chatStackInset;
@property (nonatomic, readwrite) CGFloat kickZoneSize;
@property (nonatomic, readwrite) CGFloat stackItemSize;
@end


@implementation CHFChatStackManager

#pragma mark - Lifecycle

+ (instancetype)sharedChatStackManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self configureDefaultSettings];
    }
    
    return self;
}

- (void)configureDefaultSettings
{
    self.layout = ItemLayoutStack;
    self.window = AppDelegate.window;
    
    self.motionEffectEnabled = kMotionEffectEnabled;
    self.stackItemAllowsRotation = kStackItemAllowsRotation;
    self.stackInset = kStackInset;
    self.snapBackInset = kSnapBackInset;
    self.reboundElasticity = kReboundElasticity;
    self.chatItemOffset = kChatItemOffset;
    self.maxChatStackItems = kMaxChatStackItems;
    self.chatStackInset = kChatStackInset;
    self.kickZoneSize = kKickZoneSize;
    self.stackItemSize = kStackItemSize;
}

#pragma mark - Properites

- (void)setLayout:(ItemLayout)layout
{
    ItemLayout oldLayout = self.layout;
    
    
    
    _layout = layout;
    
    
    
    [self didChangeLayoutFrom:oldLayout toLayout:layout];
}

- (void)didChangeLayoutFrom:(ItemLayout)fromLayout toLayout:(ItemLayout)toLayout
{
    NSLog(@"from layout == %i, to layout == %i", fromLayout, toLayout);
    
    if (fromLayout == ItemLayoutStack && toLayout == ItemLayoutMessage)
    {
    }
    
    if (fromLayout == ItemLayoutStack && toLayout == ItemLayoutReply)
    {
    }
}

- (void)setDragging:(BOOL)dragging
{
    _dragging = dragging;
    
    [AppContainer userInteraction:dragging ? NO: YES];
}

#pragma mark - Boundaries

- (CGRect)snapBackBounds
{
    CGFloat padding = 10;
    
    CGRect appFrame = self.window.frame;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect screenSizeWithoutStatusBar = CGRectMake(0, statusBarHeight + padding, appFrame.size.width, appFrame.size.height - (statusBarHeight + padding));
    CGRect insetRect = CGRectInset(screenSizeWithoutStatusBar, kStackInset, kStackInset);
    
    return insetRect;
}

- (CGRect)kickZoneArea
{
    float kickZoneSize = kKickZoneSize;
    float margin = (CGRectGetWidth(ChatStackManager.window.frame) - kickZoneSize) / 2;
    
    return CGRectMake(margin, CGRectGetHeight(ChatStackManager.window.frame) - (kickZoneSize + 10), kickZoneSize, kickZoneSize);
}

- (CGRect)replyCollectionViewArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide(ChatStackManager.window.frame, &slice, &remainder, kStackItemSize + (margin * 2), CGRectMinYEdge);
    
    return slice;
}

- (CGRect)messageCollectionViewArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide(ChatStackManager.window.frame, &slice, &remainder, kStackItemSize + (margin * 2), CGRectMaxYEdge);
    
    return slice;
}

- (CGRect)deckControllerArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide(ChatStackManager.window.frame, &slice, &remainder, kStackItemSize + (margin * 2), self.layout == ItemLayoutMessage ? CGRectMaxYEdge : CGRectMinYEdge);
    
    return remainder;
}

#pragma mark - BlackHole

- (void)configureBlackHole
{
    if (!self.blackholeView)
    {
        self.blackholeView = [[BlackholeView alloc] initWithFrame:self.window.frame andParticleColor:[AppDelegate appColor]];
//        self.blackholeView.backgroundColor = [UIColor grayColor];
        [self.window addSubview:self.blackholeView];
    }
}

- (CGRect)blackHoleFrame
{
    CGRect frame;
    frame.size.width = CGRectGetWidth(self.window.bounds);
    frame.size.height = 100;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetHeight(self.window.bounds) - frame.size.height;
    
    return frame;
}

#pragma mark - KickZone

- (void)presentKickZoneAnimated:(NSNumber *)animated
{
    if (self.wantsToShowKickZone)
    {
        BOOL animate = [animated boolValue];
        
        if (!self.kickZoneView)
        {
            self.kickZoneView = [[UIView alloc] initWithFrame:[self kickZoneArea]];
            
            self.kickZoneView.backgroundColor = [UIColor blueColor];
            self.kickZoneView.layer.masksToBounds = YES;
            self.kickZoneView.layer.cornerRadius = kKickZoneSize / 2;
            self.kickZoneView.transform = CGAffineTransformMakeScale(0, 0);
            
            //            CALayer *shadowLayer = [[CALayer alloc] init];
            //            shadowLayer.frame = [self kickZoneArea];
            //
            //            [self drawShadowOnLayer:shadowLayer];
            //            [self.kickZoneView.layer addSublayer:shadowLayer];
            
            // Blur image
            UIImage *snapshotImage = [AppContainer snapshotImage];
            snapshotImage = [snapshotImage applyLightEffect];
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:snapshotImage];
            CGPoint offsetImage = CGPointMake(-86, -410);
            CGRect imageFrame;
            imageFrame.size = backgroundImageView.frame.size;
            imageFrame.origin = offsetImage;
            
            backgroundImageView.frame = imageFrame;
            
            [self.kickZoneView addSubview:backgroundImageView];
            
            // Setup Progress bar
            
            
            [self.window insertSubview:self.kickZoneView belowSubview:(CHFChatStackItem *)self.itemArray.lastObject];
        }
        
        if (animate)
        {
            self.kickZoneView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            
            [UIView animateWithDuration:0.3/1.5 animations:^{
                self.kickZoneView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    self.kickZoneView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        self.kickZoneView.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
        else
        {
            self.kickZoneView.transform = CGAffineTransformIdentity;
        }
        
        if (self.motionEffectEnabled)
        {
            float maximumTilt = 15;
            
            UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-maximumTilt];
            xAxis.maximumRelativeValue = [NSNumber numberWithFloat:maximumTilt];
            
            UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-maximumTilt];
            yAxis.maximumRelativeValue = [NSNumber numberWithFloat:maximumTilt];
            
            UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
            group.motionEffects = @[xAxis, yAxis];
            
            [self.kickZoneView addMotionEffect:group];
        }
    }
}

- (void)dismissKickZoneAnimated:(NSNumber *)animated
{
    if (self.kickZoneView)
    {
        BOOL animate = [animated boolValue];
        
        if (animate)
        {
            [UIView animateWithDuration:0.3/1.5 animations:^{
                self.kickZoneView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    self.kickZoneView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
                } completion:^(BOOL finished) {
                    [self.kickZoneView removeFromSuperview];
                    self.kickZoneView = nil;
                }];
            }];
        }
        else
        {
            [self.kickZoneView removeFromSuperview];
            self.kickZoneView = nil;
        }
    }
}

#pragma mark

- (void)startDisplayLink
{
    //    float FPS = 30.0;
    
    if (!self.displayLink)
    {
        //        self.displayLink = [NSTimer timerWithTimeInterval:1.0/FPS
        //                                                   target:self
        //                                                 selector:@selector(updateProgressBar)
        //                                                 userInfo:nil
        //                                                  repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.displayLink forMode:NSRunLoopCommonModes];
    }
    
    //    if (!self.displayLink)
    //    {
    //        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressBar)];
    //        self.displayLink.frameInterval = 2;
    //        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    //    }
}

- (void)stopDisplayLink
{
    if (self.displayLink)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

#pragma mark

- (CGFloat)durationFromProgress:(CGFloat)fromProgress toProgressState:(ProgressBarState)progressState
{
    if (progressState == ProgressBarStateEnd)
    {
        return kKickOutDuration * fromProgress;
    }
    else
    {
        CGFloat flipProgess = 100.0 - fromProgress;
        
        return kKickOutDuration * flipProgess;
    }
}

- (void)startKickLoadingBar
{
    
    
    //Start Progress bar
    //
    //
    //
    //
    //    // Set up the shape of the circle
    //    int strokeWidth = 2;
    //    int radius = (kKickZoneSize / 2) - 1;
    //
    //    CGFloat startAngle = 0;
    //
    //
    //
    //    self.loadingBarLayer = [CAShapeLayer layer];
    //
    //    self.loadingBarLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 1, 2.0 * radius, 2.0 * radius) cornerRadius:radius].CGPath;
    //
    //    self.loadingBarLayer.fillColor = [UIColor clearColor].CGColor;
    //    self.loadingBarLayer.strokeColor = [UIColor colorWithRed:1.0 green:1.0 - self.loadingBarLayer.strokeEnd blue:1.0 - self.loadingBarLayer.strokeEnd alpha:0.5].CGColor;
    //    self.loadingBarLayer.lineWidth = strokeWidth;
    //    self.loadingBarLayer.strokeEnd = startAngle;
    //
    //    [self.kickZoneView.layer addSublayer:self.loadingBarLayer];
    
    //    if (!self.displayLink)
    //    {
    //        [self startDisplayLink];
    //    }
}

- (void)stopKickLoadingBar
{
    //    [self stopDisplayLink];
    
    //remove progressbar
}

/*
- (void)progressLabel:(KAProgressLabel *)label progressChanged:(CGFloat)progress
{
    if (progress >= 100.0)
    {
        [self kickOutAllItems];
        [self stopKickLoadingBar];
    }
    else if (progress < 0.0)
    {
        //        if (self.wantsToExpand)
        //        {
        //            self.progressBar setProgress:<#(CGFloat)#>
        //
        //            self.loadingBarLayer.strokeEnd += 0.0333;
        //            self.loadingBarLayer.strokeColor = [UIColor colorWithRed:1.0 green:1.0 - self.loadingBarLayer.strokeEnd blue:1.0 - self.loadingBarLayer.strokeEnd alpha:0.5].CGColor;
        //        }
        //        else
        //        {
        //            self.loadingBarLayer.strokeEnd -= 0.0333;
        //        }
    }
}
*/

- (void)kickOutAllItems
{
    [self.animator removeAllBehaviors];
    
    NSMutableArray *proxyItemArray = [self.itemArray mutableCopy];
    
    for (CHFChatStackItem *item in proxyItemArray)
    {
        [self.itemArray removeObject:item];
        [item kickOutWithRandomAnimation:YES];
    }
    
    proxyItemArray = nil;
    
    self.dragging = NO;
    [self dismissKickZoneAnimated:@YES];
}

#pragma mark - Item Methods

//
- (void)passPanningItem:(CHFChatStackItem *)item withPanGesture:(UIPanGestureRecognizer *)panGesture andCompletionBlock:(void (^)(BOOL))completion
{
    item.delegate = self;
    
    if (!self.animator) self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.window];
    
    [self pannedView:panGesture];
    
    [self.window addSubview:item];
    [self.window bringSubviewToFront:item];
    
    item.center = [item.originalParentView convertPoint:item.originalPoint toView:self.window];
}

// Add a new item to the stack array, and shift trailing items to there right center point
- (void)addItem:(CHFChatStackItem *)item fromPoint:(CGPoint)fromPoint animated:(BOOL)animated withCompletionBlock:(void (^)(BOOL))completion
{
    // Make us the delegate of the object
    item.delegate = self;
    
    if (!self.animator) self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.window];
    
    switch (item.itemtype)
    {
        case ItemTypeStack:
        {
            // If the itemArray doesn't exist make one
            if (!self.itemArray) self.itemArray = [NSMutableArray array];
            
            // First added object
            if (self.itemArray.count == 0)
            {
                [self.itemArray addObject:item];
                
                item.center = self.snapBackBounds.origin;

                self.boundsCrossingPoint = item.center;
                
                [self presentItem:item
                        fromPoint:fromPoint
                          toPoint:self.snapBackBounds.origin
                    withAnimation:animated];
                
                [self updateMotionEffectForItem:item atIndex:[item index]];
            }
            else // If there is already an object in the itemarray then there is a possibility that a message object can be added while in the default layout or the message layout.
            {
                switch (self.layout)
                {
                    case ItemLayoutStack:
                    {
                        CGPoint spawnPoint = self.headStackItem.center;
                        
                        // Get where the current headChatStackItem is and put our new item there.
                        item.center = spawnPoint;
                        
                        // Insert the item at the beginning of the array which will make it the head item
                        [self.itemArray insertObject:item atIndex:0];
                        
                        [self presentItem:item
                                fromPoint:fromPoint
                                  toPoint:self.boundsCrossingPoint
                            withAnimation:animated];
                        
                        [self updateItemsPointForStackLayout:spawnPoint];
                    }
                        break;
                    case ItemLayoutMessage:
                        
                        [self.itemArray insertObject:item atIndex:0];
                        
                        item.center = [item pointForMessageLayout];
                        
                        //                [self presentItem:item fromPoint:fromPoint toPoint:toPoint withAnimation:animated];
                        
                        // Update the positions
                        [self snapItemsToMessageLayoutWithTappedItem:item];
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case ItemTypePending:
        {
            if (!self.pendingItemArray)
            {
                self.pendingItemArray = [@[item] mutableCopy];
            }
            else
            {
                [self.pendingItemArray addObject:item];
            }
            
            [self presentPendingItem:item withAnimation:YES];
        }
            break;
        case ItemTypeStandAlone:
        {
            NSLog(@"Added ItemTypeStandAlone");
        }
            break;
    }
    
    completion(YES);
}

// This will cause the oldest stack item to be dropped out of the view to make room for a new stack item. Once the stack item goes out of the bounds, we remove it from the stack array and let the "addItem" method know to go ahead and add the new item.
- (void)removeItem:(CHFChatStackItem *)item animated:(BOOL)animated randomAnimation:(BOOL)random withCompletionBlock:(void (^)(BOOL finished))completion
{
    // Might need to check if item is not dragging, attached to a behavior ect
    if (!self.oldItemArray) self.oldItemArray = [@[] mutableCopy];
    
    [self.oldItemArray addObject:item];
    [self.itemArray removeObject:item];
    
    if (animated)
    {
        [item kickOutWithRandomAnimation:random];
    }
    else
    {
        [item removeFromSuperview];
    }
}

// After Adding a new item to the stack array, this is called to add the item to the view and will animate if wanted.
- (void)presentItem:(CHFChatStackItem *)item fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint withAnimation:(BOOL)animation
{
    if (animation)
    {
        [self.window addSubview:item];
        [self.window bringSubviewToFront:item];
        
        item.center = fromPoint;
        
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             item.center = toPoint;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        //        [item applyEffect:ItemEffectAddZoomIn];
    }
    else
    {
        [self.window addSubview:item];
        [self.window bringSubviewToFront:item];
    }
}

#pragma mark

- (void)updateMotionEffectsForAllItems
{
    if (self.motionEffectEnabled)
    {
        for (CHFChatStackItem *item in self.itemArray)
        {
            [self updateMotionEffectForItem:item atIndex:[item index]];
        }
    }
}

- (void)updateMotionEffectForItem:(CHFChatStackItem *)item atIndex:(NSUInteger)index
{
    // TODO: Make shadows lighter when they are closer to overlapping
    
    if (self.motionEffectEnabled)
    {
        // Make sure the items doesn't already have a motion effect
        for (UIMotionEffectGroup *effect in item.motionEffects)
        {
            [item removeMotionEffect:effect];
        }
        
        float maximumTilt = self.layout == ItemLayoutStack ? 15 + (index * 5) : 15;
        
        UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:maximumTilt];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:-maximumTilt];
        
        UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = [NSNumber numberWithFloat:maximumTilt];
        yAxis.maximumRelativeValue = [NSNumber numberWithFloat:-maximumTilt];
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[xAxis, yAxis];
        
        [item addMotionEffect:group];
    }
}

- (void)updateItemsPointForStackLayout:(CGPoint)point
{
    [self updateZIndexForItems];
    
    for (CHFChatStackItem *trailingItem in self.itemArray)
    {
        if (![trailingItem isEqual:[self headStackItem]])
        {
            float offsetValue = (trailingItem.index * self.chatItemOffset);
            float offsetDirection = point.x < CGRectGetWidth(ChatStackManager.window.frame) / 2 ? offsetValue: -offsetValue;
            
            CGPoint offsetPoint = CGPointMake(point.x + offsetDirection, point.y);
            
            [trailingItem snapToPoint:offsetPoint withCompletion:^{
                
            }];
        }
    }
}

- (void)updateItemsPointForReplyLayout
{
    
}

- (void)updateZIndexForItems
{
    for (CHFChatStackItem *item in self.itemArray.reverseObjectEnumerator)
    {
        [self.window bringSubviewToFront:item];
        
        // Update the motion effect
        [self updateMotionEffectForItem:item atIndex:[item index]];
    }
}

- (void)updateItemAttachmentLengthsForVelocity:(CGPoint)velocity
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item updatePrecedentItemAttachmentLengthForVelocity:velocity];
    }
}



// Update a items position to the head of the stack. May be animated;
- (void)moveStackItemToHeadItem:(CHFChatStackItem *)item withAnimation:(BOOL)animation
{
    [self.itemArray exchangeObjectAtIndex:[item index] withObjectAtIndex:0];
    
    [self updateZIndexForItems];
}

// For snapping the item we always need to to animate on the chatstacks window, not the destination or the source view.
- (void)snapItemBackToOrigin:(CHFChatStackItem *)item completion:(void (^)(void))completion
{
    // Get the current view and point in that view for the item
    UIView *fromView = item.superview;
    CGPoint fromPoint = item.center;
    
    // If the item is not already in the window we need to find the point and convert it to the window
    if (![fromView isEqual:self.window])
    {
        // Convert the items original point from its original view, to the window so we can animate the item.
        CGPoint windowFromPoint = [fromView convertPoint:fromPoint toView:self.window];
        
        item.center = windowFromPoint;
        [self.window addSubview:item];
        [self.window bringSubviewToFront:item];
    }
    
    // Get the point in the window which to animate to
    CGPoint toPoint = [item.originalParentView convertPoint:item.originalPoint toView:self.window];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         item.center = toPoint;
                     }
                     completion:^(BOOL finished) {
                         // Now that the item is is the same coordinate as its origin, we can give the origin view the item
                         item.center = item.originalPoint;
                         [item.originalParentView addSubview:item];
                         [item.originalParentView bringSubviewToFront:item];
                         
                         completion();
                     }];
}

- (void)snapItem:(CHFChatStackItem *)item toPoint:(CGPoint)toPoint inView:(UIView *)toView completion:(void (^)(void))completion
{
    // Get the current view and point in that view for the item
    UIView *fromView = item.superview;
    CGPoint fromPoint = item.center;
    
    // If the item is not already in the window we need to find the point and convert it to the window
    if (![fromView isEqual:self.window])
    {
        // Convert the items original point from its original view, to the window so we can animate the item.
        CGPoint windowFromPoint = [fromView convertPoint:fromPoint toView:self.window];
        
        item.center = windowFromPoint;
        [self.window addSubview:item];
        [self.window bringSubviewToFront:item];
    }
    
    // Get the point in the window which to animate to
    CGPoint windowToPoint = [toView convertPoint:toPoint toView:self.window];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         item.center = windowToPoint;
                     }
                     completion:^(BOOL finished) {
                         // Now that the item is is the same coordinate as its origin, we can give the origin view the item
                         item.center = toPoint;
                         [toView addSubview:item];
                         [toView bringSubviewToFront:item];
                         
                         completion();
                     }];
}

#pragma mark - Pending Item Methods

// Pending

//- (CGPoint)pointForPendingItem
//{
//
//}

- (void)presentPendingItem:(CHFChatStackItem *)item withAnimation:(BOOL)animation
{
    CGPoint spawnPoint;
    CGPoint boundsPoint;
    
    if (self.pendingItemArray.count > 1)
    {
        CGFloat margin = 10.0f;
        CGFloat radius = self.stackItemSize / 2;
        
        NSUInteger itemIndex = [self.pendingItemArray indexOfObject:item];
        
        CHFChatStackItem *precendentItem = [self.pendingItemArray objectAtIndex:itemIndex - 1];
        CGPoint precendentPoint = precendentItem.center;
        
        boundsPoint = CGPointMake(precendentPoint.x, precendentPoint.y + margin + (radius * 2));
        //TODO : need to check if there is a stack from another array where it wants to spawn. If so boot it across from collision
        if (boundsPoint.x < CGRectGetMidX(self.window.frame))
        {
            spawnPoint = CGPointMake(boundsPoint.x - (self.stackInset + radius), boundsPoint.y);
        }
        else
        {
            spawnPoint = CGPointMake(boundsPoint.x + (self.stackInset + radius), boundsPoint.y);
        }
    }
    else // First Pending Item
    {
        if ([self stackOnLeftSide])
        {
            boundsPoint = CGPointMake(CGRectGetMaxX([self snapBackBounds]), CGRectGetMinY([self snapBackBounds]) + 60);
            
            spawnPoint = CGPointMake(boundsPoint.x + (self.stackInset + (self.stackItemSize / 2)), boundsPoint.y);
        }
        else
        {
            boundsPoint = CGPointMake(CGRectGetMinX([self snapBackBounds]), CGRectGetMinY([self snapBackBounds]) + 60);
            
            spawnPoint = CGPointMake(boundsPoint.x - (self.stackInset + (self.stackItemSize / 2)), boundsPoint.y);
        }
    }
    
    if (animation)
    {
        item.center = spawnPoint;
        
        [self.window addSubview:item];
        
        [item snapToPoint:boundsPoint withCompletion:^{
        }];
    }
    else
    {
        item.center = boundsPoint;
    }
    
    // Start Count
    [self performSelector:@selector(removePendingItem:) withObject:item afterDelay:4.0];
}

- (void)updatePendingItemsPoint
{
    
}

- (void)removePendingItem:(CHFChatStackItem *)item
{
    [self.pendingItemArray removeObject:item];
    
    //    CGFloat radius = self.stackItemSize / 2;
    //
    //    CGPoint deathPoint;
    //
    //    if (item.center.x < CGRectGetMidX(self.chatStackWindow.frame))
    //    {
    //        deathPoint = CGPointMake(0 - (self.stackInset + radius), item.center.y);
    //    }
    //    else
    //    {
    //        deathPoint = CGPointMake(CGRectGetMaxX([self snapBackBounds]) + (self.stackInset + radius), item.center.y);
    //    }
    
    [item kickOutWithRandomAnimation:NO];
}

#pragma mark - Item Behavior Methods

#pragma mark

// Determine what item was tapped. If it was the head item, snap it to the center; Else we need to make the newely selected item the head item with "moveStackItemToHeadItem". Then we call the adjustMessageLayoutPositionForItem to detemine where the stack item should snap to.
- (void)snapItemsToMessageLayoutWithTappedItem:(CHFChatStackItem *)tappedItem
{
    [self.animator removeAllBehaviors];
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item snapToPoint:[item pointForMessageLayout] withCompletion:^{
            
        }];
    }
}

- (void)snapItemsToStackLayoutWithTappedItem:(CHFChatStackItem *)tappedItem
{
    [self.animator removeAllBehaviors];
    
    [tappedItem snapToPoint:self.boundsCrossingPoint withCompletion:^{
        
    }];
    
    if (self.itemArray.count > 1)
    {
        [self updateItemsPointForStackLayout:self.boundsCrossingPoint];
    }
}

- (CHFChatStackItem *)assignNewHeadItemFromHeadItem:(CHFChatStackItem *)itemToBeRemoved
{
    return nil;
}

#pragma mark

- (void)attachItemsToHeadItem
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item detachFromPrecedentItem];
        
        if (!item.isHeadStackItem)
        {
            [item attachToPrecedentItem];
        }
    }
}

- (void)detachItemsFromHeadItem
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        if (item.precedentItemAttachmentBehavior.items.count != 0)
        {
            [item detachFromPrecedentItem];
        }
    }
}

#pragma mark

- (void)updateCurrentStateForAllItems
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [self.animator updateItemUsingCurrentState:item];
    }
}

#pragma mark

- (void)beginObservingBoundsCrossingForAllItems
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item beginObservingBoundsCrossing];
    }
}

- (void)stopObservingBoundsCrossingForAllItems
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item stopObservingBoundsCrossing];
    }
}

#pragma mark

- (void)applyUniverseGravity
{
    if (!self.universeGravity)
    {
        self.universeGravity = [[UIGravityBehavior alloc] init];
    }
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        if (![self.universeGravity.items containsObject:item])
        {
            [self.universeGravity addItem:item];
        }
    }
    
    [self updateGravityDirection];
    
    if (![self.animator.behaviors containsObject:self.universeGravity])
    {
        [self.animator addBehavior:self.universeGravity];
    }
}

- (void)removeUniverseGravity
{
    if ([self.animator.behaviors containsObject:self.universeGravity])
    {
        [self.animator removeBehavior:self.universeGravity];
    }
}

- (void)updateGravityDirection
{
    // Update which direction the gravity should force
    CGFloat gravityForce = 5.0;
    
    CGFloat yComponent = 0.0;
    CGFloat xComponent = [self.headStackItem isOnLeftSide] ? -gravityForce : gravityForce;
    
    self.universeGravity.gravityDirection = CGVectorMake(xComponent, yComponent);
}

#pragma mark

- (void)applyFlickBehaviorForAllItemsWithPanGesture:(UIPanGestureRecognizer *)panGesture
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item applyFlickBehaviorWithPanGesture:panGesture];
    }
}

- (void)removeFlickBehaviorFromAllItems
{
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item removeFlickBehavior];
    }
}

#pragma mark - Animator Delegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator
{
    
}

#pragma mark - Helper Methods

- (BOOL)shouldUseReplyLayoutForAllNonPendingItems
{
    return NO;
}

- (BOOL)doesHaveCurrentChatWithUserID:(NSString *)userID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];
    NSString *userIDString;
    
    userIDString = [self.itemArray filteredArrayUsingPredicate:predicate][0];
    
    if (!userID)
    {
        userIDString = [self.replyItemArray filteredArrayUsingPredicate:predicate][0];
    }
    
    return userIDString == nil ? NO : YES;
}

- (BOOL)itemArrayContainsItemWithUserID:(NSString *)userID
{
    NSArray *userIDArray = [self.itemArray valueForKey:@"userID"];
    
    for (NSString *userIdentity in userIDArray)
    {
        return [userID isEqualToString:userIdentity];
    }
    
    return NO;
}

// Check which side of the screen the stack is on
- (BOOL)stackOnLeftSide
{
    return self.headStackItem.location.x < CGRectGetMidX(self.window.frame) ? YES: NO;
}

- (CHFChatStackItem *)headStackItem
{
    return self.itemArray.firstObject;
}

- (CHFChatStackItem *)itemShowingNavigationController
{
    CHFChatStackItem *currentItem;
    
    for (CHFChatStackItem *item in self.itemArray)
    {
//        if (item.navigationController)
//        {
//            currentItem = item;
//            break;
//        }
    }
    
    return currentItem;
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)drawShadowOnLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.6f;
    
    UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[layer bounds] cornerRadius:layer.cornerRadius];
    
    [layer setShadowPath:[path CGPath]];
}

- (NSArray *)userIDsFromItemArray:(NSArray *)itemArray
{
    NSMutableArray *userIDArray = [NSMutableArray array];
    
    for (int index = 0; index < itemArray.count; index++)
    {
        CHFChatStackItem *item = itemArray[index];
        
        [userIDArray addObject:item.userID];
    }
    
    return userIDArray;
}

#pragma mark - ChatStack Item Delegate

- (void)didTapItem:(CHFChatStackItem *)item withGesture:(UITapGestureRecognizer *)gesture
{
    [self tappedView:gesture];
}

- (void)didPanItem:(CHFChatStackItem *)item withGesture:(UIPanGestureRecognizer *)gesture
{
    [self pannedView:gesture];
}

#pragma mark - BlurView

- (void)configureBlurViewWithBlurType:(BlurType)type animated:(BOOL)animated
{
    self.blurView = [[CHFBlurView alloc] initWithFrame:self.window.bounds
                                              blurType:type
                                         withAnimation:animated];
    
    [self.window insertSubview:self.blurView atIndex:kZIndexBackground];
}

- (void)presentBlurViewAnimated:(BOOL)animated
{
    if (!self.blurView)
    {
        [self configureBlurViewWithBlurType:BlurTypeDark animated:animated];
    }
}

- (void)dismissBlurViewAnimated:(BOOL)animated
{
    if (self.blurView)
    {
        [self.blurView hideBlurViewAnimated:YES
                             withCompletion:^{
                                 self.blurView = nil;
                             }];
    }
}

#pragma mark - ChatStack DeckController

- (void)presentStackDeckController:(BOOL)animated withUserIDs:(NSArray *)userIDs
{
    if (!self.chatStackDeckController)
    {
        self.chatStackDeckController = [[CHFChatStackDeckController alloc] initWithUserIDs:userIDs];
        self.chatStackDeckController.view.frame = [self deckControllerArea];
        self.chatStackDeckController.delegate = self;
        
        [self.window insertSubview:self.chatStackDeckController.view atIndex:kZIndexViews];
    }
}

- (void)dismissStackDeckController:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.48
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self dismissStackDeckController:NO];
                         }
                         completion:^(BOOL finished) {
                             [self.chatStackDeckController.view removeFromSuperview];
                             self.chatStackDeckController = nil;
                         }];
    }
    
    self.chatStackDeckController.view.layer.opacity = 0.0;
}

#pragma mark Delegate


#pragma mark - ItemsCollectionViews
#pragma mark ItemsCollectionViewController DataSource

- (NSArray *)itemsToPassToController:(CHFItemsCollectionViewController *)controller
{
    NSMutableArray *items = [@[] mutableCopy];
    
    if ([controller isEqual:self.replyItemsCollectionViewController])
    {
        items = self.replyItemArray;
    }
    else if ([controller isEqual:self.messageItemsCollectionViewController])
    {
        items = self.itemArray;
    }
    
    return [items copy];
}

#pragma mark ItemsCollectionViewController Delegate

- (void)passItems:(NSArray *)items toController:(CHFItemsCollectionViewController *)controller
{
    [items enumerateObjectsUsingBlock:^(CHFChatStackItem *item, NSUInteger idx, BOOL *stop) {
        
        CGPoint point = [controller pointForCellAtIndex:idx inSection:0];
        
        NSLog(@"point %@", NSStringFromCGPoint(point));
        
        [item snapToPoint:point withCompletion:^{ }];
        [item removeFromSuperview];
        
        CHFItemCollectionViewCell *cell = [controller cellAtIndex:idx inSection:0];
        cell.item = item;
        [cell.contentView addSubview:item];
    }];
}

#pragma mark ReplyCollectionViewController

- (void)presentReplyItems:(NSArray *)items withCollectionViewAnimated:(BOOL)animated
{
    self.layout = ItemLayoutReply;
    
    if (!self.replyItemArray) self.replyItemArray = [NSMutableArray array];
    [self.replyItemArray addObjectsFromArray:items];
    
    self.replyItemsCollectionViewIsHidden = NO;
    
    if (!self.replyItemsCollectionViewController)
    {
        self.replyItemsCollectionViewController = [[CHFItemsCollectionViewController alloc] initWithItems:self.replyItemArray];
        self.replyItemsCollectionViewController.collectionView.frame = [self replyCollectionViewArea];
        self.replyItemsCollectionViewController.dataSource = self;
        self.replyItemsCollectionViewController.delegate = self;
    }
    
    [self.window insertSubview:self.replyItemsCollectionViewController.view atIndex:kZIndexViews];
    
    [self presentStackDeckController:YES withUserIDs:[self userIDsFromItemArray:self.replyItemArray]];
}

- (void)dismissReplyItemsCollectionViewAnimated:(BOOL)animated
{
    self.replyItemsCollectionViewIsHidden = YES;
    
    if (self.replyItemsCollectionViewController)
    {
        [self takeItemsFromReplyItemsCollectionView];
        
        [self.replyItemsCollectionViewController.view removeFromSuperview];
        self.replyItemsCollectionViewController.view = nil;
        
        [self.replyItemsCollectionViewController removeFromParentViewController];
        self.replyItemsCollectionViewController = nil;
    }
}

- (void)takeItemsFromReplyItemsCollectionView
{
    if (self.replyItemsCollectionViewController)
    {
        [self.replyItemArray enumerateObjectsUsingBlock:^(CHFChatStackItem *item, NSUInteger idx, BOOL *stop)
         {
             switch (item.itemtype)
             {
                 case ItemTypePending:
                 {
                     // Animate this item away
                     [item kickOutWithRandomAnimation:YES];
                 }
                     break;
                 case ItemTypeStandAlone:
                 {
                     // Return this item to its original point in its original view
                     CGPoint snappingPoint = [item.originalParentView convertPoint:item.originalPoint toView:self.window];
                     
                     NSLog(@"snapping point = %@", NSStringFromCGPoint(snappingPoint));
                     
                     [item snapToPoint:snappingPoint
                        withCompletion:^{
                            
                        }];
                 }
                 default:
                     break;
             }
         }];
    }
}

#pragma mark MessageItemsCollectionViewController

- (void)presentMessageItems:(NSArray *)items withCollectionViewAnimated:(BOOL)animated
{
    self.layout = ItemLayoutMessage;
    
//    if (!self.itemArray) self.itemArray = [NSMutableArray array];
//    [self.itemArray addObjectsFromArray:items];
    
    self.messageItemsCollectionViewIsHidden = NO;
    
    if (!self.messageItemsCollectionViewController)
    {
        self.messageItemsCollectionViewController = [[CHFItemsCollectionViewController alloc] initWithItems:self.itemArray];
        self.messageItemsCollectionViewController.view.frame = [self messageCollectionViewArea];
        self.messageItemsCollectionViewController.dataSource = self;
        self.messageItemsCollectionViewController.delegate = self;
        self.messageItemsCollectionViewController.view.backgroundColor = [UIColor greenSeaColor];
    }
    
    [self.window insertSubview:self.messageItemsCollectionViewController.view atIndex:kZIndexViews];
    
    [self presentStackDeckController:YES withUserIDs:[self userIDsFromItemArray:self.itemArray]];
}

- (void)dismissFriendCollectionViewAnimated:(BOOL)animated
{
    self.messageItemsCollectionViewIsHidden = YES;
    
    if (self.messageItemsCollectionViewController)
    {
        [self takeItemsFromMessageItemsCollectionView];
        
        [self.messageItemsCollectionViewController.view removeFromSuperview];
        self.messageItemsCollectionViewController.view = nil;
        
        [self.messageItemsCollectionViewController removeFromParentViewController];
        self.messageItemsCollectionViewController = nil;
    }
}

- (void)takeItemsFromMessageItemsCollectionView
{
    if (self.messageItemsCollectionViewController)
    {
        [self.itemArray enumerateObjectsUsingBlock:^(CHFChatStackItem *item, NSUInteger idx, BOOL *stop) {
            
            // Get the point of the item while in cell
            CGPoint pointOfCell = [self.messageItemsCollectionViewController pointForCellAtIndex:idx inSection:0];
            
            // Convert the cell point to the window point
            CGPoint pointOfCellInWindow = [self.messageItemsCollectionViewController.collectionView convertPoint:pointOfCell toView:self.window];
            CHFChatStackItem *itemOfCell = (CHFChatStackItem *)[self.messageItemsCollectionViewController itemForCellAtIndex:idx inSection:0];
            [itemOfCell removeFromSuperview];
            
            itemOfCell.center = pointOfCellInWindow;
            [self.window insertSubview:item atIndex:kZIndexStackItem];
            
            // Snap back to the bounds crossing point
            [itemOfCell snapToPoint:self.boundsCrossingPoint withCompletion:^{
                
            }];
        }];
    }
}

#pragma mark - HoverMenu Controller

- (void)presentHoverMenuWithMenuOptions:(HoverMenuOptions)menuOptions forItem:(CHFChatStackItem *)item animated:(BOOL)animated
{
    NSLog(@"presentHoverMenuWithMenuOptions = %i", menuOptions);
    
    if (!self.hoverMenuController)
    {
        self.hoverMenuController = [[CHFHoverMenuViewController alloc] initWithMenuOptions:menuOptions forItem:item];
        self.hoverMenuController.view.frame = [self frameForHoverMenu];
        
        [self.window insertSubview:self.hoverMenuController.view
                      aboveSubview:(UIView *)self.window.subviews[self.window.subviews.count - 1]];
    }
    else
    {
        self.hoverMenuController.menuOptions = menuOptions;
    }
    
    [self showHoverMenuAnimated:animated];
}

- (void)showHoverMenuAnimated:(BOOL)animated
{
    if (animated)
    {
        self.hoverMenuController.view.layer.opacity = 0.0;
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self showHoverMenuAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    self.hoverMenuController.view.layer.opacity = 1.0;
}

- (void)dismissHoverMenuAnimated:(BOOL)animated
{
    if (animated)
    {
        self.hoverMenuController.view.layer.opacity = 1.0;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self dismissHoverMenuAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             [self.hoverMenuController.view removeFromSuperview];
                             self.hoverMenuController = nil;
                         }];
    }
    
    self.hoverMenuController.view.layer.opacity = 0.0;
}

- (CGRect)frameForHoverMenu
{
    // When we are in the ItemLayoutStack, the pending and standalone type cards can have the hover card over the whole screen;
    switch (self.layout)
    {
        case ItemLayoutStack:
        {
            return ChatStackManager.window.frame;
        }
            break;
        case ItemLayoutMessage:
        case ItemLayoutReply:
        {
            return CGRectInset(ChatStackManager.deckControllerArea, 10, 10);
        }
            break;
    }
    
    return CGRectInset(ChatStackManager.deckControllerArea, 10, 10);
}

#pragma mark - UIGestureRecognizer Methods
#pragma mark Tap

- (void)tappedView:(UITapGestureRecognizer *)tapGesture
{
    [self tappedItem:(CHFChatStackItem *)tapGesture.view];
}

- (void)tappedItem:(CHFChatStackItem *)item
{
    NSLog(@"Tapped item type %i", item.itemtype);
    
    switch (item.itemtype)
    {
        case ItemTypeStack:
        {
            if (!item.isHeadStackItem)
            {
                [self moveStackItemToHeadItem:item withAnimation:NO];
            }
            
            switch (self.layout)
            {
                case ItemLayoutStack:
                    
                    self.layout = ItemLayoutMessage;
                    
                    // Snap to the message layout and present the tapped items view
                    //            [self snapItemsToMessageLayoutWithTappedItem:item];
                    [self updateMotionEffectsForAllItems];
                    
                    [self detachItemsFromHeadItem];
                    
                    [self presentBlurViewAnimated:YES];
                    [self presentMessageItems:self.itemArray withCollectionViewAnimated:YES];
                    break;
                case ItemLayoutMessage:
                    
//                    if (item.navigationController)
//                    {
//                        self.layout = ItemLayoutStack;
//                        // If the item is showing its nav controller, it is also the headStackItem. In this case we want to dismiss the
//                        // nav controller and then snap the items back to a stack layout
//                        [item dismissNavigationControllerAnimated:YES];
//                        [self dismissFriendCollectionViewAnimated:YES];
//                        [self snapItemsToStackLayoutWithTappedItem:item];
//                    }
//                    else
//                    {
//                        // Dimiss the current showing navigation controller and present the selected item nav controller
//                        [[self itemShowingNavigationController] dismissNavigationControllerAnimated:YES];
//                        
//                        
//                        [self updateZIndexForItems];
//                    }
                    
                    break;
                default:
                    break;
            }
        }
            break;
        case ItemTypePending:
        {
            if ([self.currentChosenItem isEqual:item])
            {
                
            }
            if (![self.currentChosenItem isEqual:item])
            {
                
            }
            
            [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
        }
            break;
        case ItemTypeStandAlone:
        {
            NSLog(@"the chosen item = %@",item);
            
            if (![self.currentChosenItem isEqual:item])
            {
                [self presentBlurViewAnimated:YES];
                
                if ([AppDelegate chatStackIsPurchased])
                {
                    if ([self doesHaveCurrentChatWithUserID:item.userID])
                    {
                        [self presentMessageItems:self.itemArray withCollectionViewAnimated:YES];
                        // TODO: scroll to the page with the userID
                    }
                    else
                    {
                        // Present the ReplyCollectionView, and then give the item to the collection view cell
                        [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
                    }
                }
                else
                {
                    // Present the ReplyCollectionView, and then give the item to the collection view cell
                    [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
                }
                
                // Show the deck controller which holds all of the VC's for each chat item
                
                //                [self.window bringSubviewToFront:item];
            }
            else
            {
                self.layout = ItemLayoutStack;
                
                [self dismissBlurViewAnimated:YES];
                
                [self dismissStackDeckController:YES];
                
                [self.window insertSubview:item atIndex:kZIndexStackItem];
                CGPoint windowPoint = [item convertPoint:item.center toView:self.window];
                item.center = windowPoint;
                
                NSLog(@"the item superview = %@", item.superview);
                
                
                // Get the point of where the item has to animate to. We will do the animating in the window
                CGPoint animatePoint = [item.originalParentView convertPoint:item.originalPoint toView:self.window];
                
                //                    [item snapToPoint:animatePoint withCompletion:^{
                //                        item.center = item.originalPoint;
                //                        [item.originalParentView addSubview:item];
                //                        [item.originalParentView bringSubviewToFront:item];
                //                    }];
                
                [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.2 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
                    item.center = animatePoint;
                    
                } completion:^(BOOL finished) {
                    item.center = item.originalPoint;
                    [item.originalParentView addSubview:item];
                    [item.originalParentView bringSubviewToFront:item];
                    
                    [self dismissReplyItemsCollectionViewAnimated:NO];
                }];
                
                item.delegate = nil;
            }
            
        }
            break;
    }
    
    if (![self.currentChosenItem isEqual:item])
    {
        self.currentChosenItem = item;
        
        // !!!: Hack to get around conforming files to NSCoding right now
        //        self.currentChosenItem = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:item]];
    }
    else
    {
        self.currentChosenItem = nil;
    }
}

#pragma mark Pan

- (void)pannedView:(UIPanGestureRecognizer *)panGesture
{
    CHFChatStackItem *item = (CHFChatStackItem *)panGesture.view;
    
    switch (item.itemtype)
    {
        case ItemTypeStack:
        {
            switch (self.layout)
            {
                case ItemLayoutStack:
                    if ([(CHFChatStackItem *)panGesture.view isHeadStackItem])
                    {
                        [self pannedViewFlick:panGesture];
//                        [self pannedViewKickZone:panGesture];
                        [self configureBlackHole];
                    }
                    break;
                case ItemLayoutMessage:
                    //                    if (self.friendsCollectionViewIsHidden == YES)
                {
                    [self pannedViewHoverActions:panGesture];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case ItemTypePending:
        {
            [self pannedViewHoverActions:panGesture];
        }
            break;
        case ItemTypeStandAlone:
        {
            [self pannedViewHoverActions:panGesture];
        }
            break;
    }
}

- (void)pannedViewHoverActions:(UIPanGestureRecognizer *)panGesture
{
    CHFChatStackItem *item = (CHFChatStackItem *)panGesture.view;
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.dragging = YES;
            // | HoverMenuOptionUserFollowers | HoverMenuOptionMessageRepost | HoverMenuOptionUserMentions | HoverMenuOptionUserInteractions | HoverMenuOptionUserInteractions | HoverMenuOptionMessageStar | HoverMenuOptionMessageShare | HoverMenuOptionMessageReportSpam | HoverMenuOptionManageAddUser | HoverMenuOptionManageKick | HoverMenuOptionChatStackAddUser | HoverMenuOptionChatStackRemoveUser
            [self presentBlurViewAnimated:YES];
            [self presentHoverMenuWithMenuOptions:HoverMenuOptionUserProfile | HoverMenuOptionUserFollow | HoverMenuOptionUserMute | HoverMenuOptionUserBlock | HoverMenuOptionChatStackAddUser
                                          forItem:item
                                         animated:YES];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            item.center = [panGesture locationInView:self.window];
            [self.hoverMenuController pannedItemPoint:item.center];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            switch (item.itemtype)
            {
                case ItemTypePending: // The item will go out of the bounds and be killed
                {
                    [self dismissHoverMenuAnimated:YES];
                    [self dismissBlurViewAnimated:YES];
                    
                    [item applyGravity];
                    
                    [item applyFlickBehaviorWithPanGesture:panGesture];
                    [item beginObservingBoundsCrossing];
                }
                    break;
                case ItemTypeStandAlone: // The item will snap back to where it was originaly from
                {
                    if (panGesture.state == UIGestureRecognizerStateEnded)
                    {
                        [self.hoverMenuController performActionOnCellAtPoint:item.center
                                                           withChatStackItem:item
                                                               andCompletion:^() {
                                                                   [self dismissHoverMenuAnimated:YES];
                                                                   [self dismissBlurViewAnimated:YES];
                                                                   
                                                                   [self snapItemBackToOrigin:item
                                                                                   completion:^{
                                                                                       item.delegate = nil;
                                                                                   }];
                                                               }];
                    }
                    if (panGesture.state == UIGestureRecognizerStateCancelled)
                    {
                        [self dismissHoverMenuAnimated:YES];
                        [self dismissBlurViewAnimated:YES];
                        
                        [self snapItemBackToOrigin:item
                                        completion:^{
                                            item.delegate = nil;
                                        }];
                    }
                }
                    break;
                default:
                    break;
            }
            
            self.dragging = NO;
        }
            break;
        default:
            break;
    }
}

- (void)pannedViewFlick:(UIPanGestureRecognizer *)panGesture
{
    CHFChatStackItem *item = (CHFChatStackItem *)panGesture.view;
    
    switch (self.layout)
    {
        case ItemLayoutStack:
        {
            if (panGesture.state == UIGestureRecognizerStateBegan)
            {
                self.dragging = YES;
                
                [self removeFlickBehaviorFromAllItems];
                [self.headStackItem stopObservingBoundsCrossing];
                [self removeUniverseGravity];
                
                [self attachItemsToHeadItem];
            }
            else if (panGesture.state == UIGestureRecognizerStateChanged)
            {
                item.center = [panGesture locationInView:self.window];
                
                [self updateCurrentStateForAllItems];
            }
            else if (panGesture.state == UIGestureRecognizerStateEnded)
            {
                [self.animator removeAllBehaviors];
                
                // If the item is let go while inside the snapBackBounds
                if (CGRectContainsPoint([self snapBackBounds], self.headStackItem.center))
                {
                    [self.headStackItem beginObservingBoundsCrossing];
                    [self applyUniverseGravity];
                    [self applyFlickBehaviorForAllItemsWithPanGesture:panGesture];
                }
                else // If the item is let go outside the snapBackBounds, snap to nearest bounds edge
                {
                    // Get nearest edge point
                    CGFloat xCoordinate = [self.headStackItem isOnLeftSide] ? CGRectGetMinX([self snapBackBounds]): CGRectGetMaxX([self snapBackBounds]);
                    
                    CGFloat yCoordinate = self.headStackItem.center.y;
                    
                    for (CHFChatStackItem *item in self.itemArray)
                    {
                        [item snapToPoint:CGPointMake(xCoordinate, yCoordinate)
                           withCompletion:^{
                               
                           }];
                    }
                }
                
                self.dragging = NO;
            }
            else if (panGesture.state == UIGestureRecognizerStateCancelled)
            {
                // Snap back to crossing point
                for (CHFChatStackItem *item in self.itemArray)
                {
                    if (item.precedentItemAttachmentBehavior)
                    {
                        [self.animator removeBehavior:item.precedentItemAttachmentBehavior];
                    }
                    
                    [item snapToPoint:[item pointForDefaultLayoutFromSourcePoint:self.boundsCrossingPoint]
                       withCompletion:^{
                           [item removeFlickBehavior];
                       }];
                }
                
                self.dragging = NO;
            }
        }
            break;
        case ItemLayoutMessage:
        {
            if (panGesture.state == UIGestureRecognizerStateBegan)
            {
                
            }
            else if (panGesture.state == UIGestureRecognizerStateChanged)
            {
                
            }
            else if (panGesture.state == UIGestureRecognizerStateEnded ||
                     panGesture.state == UIGestureRecognizerStateCancelled)
            {
                
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)pannedViewKickZone:(UIPanGestureRecognizer *)panGesture
{
    CHFChatStackItem *item = (CHFChatStackItem *)panGesture.view;
    
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        self.wantsToShowKickZone = YES;
        [self performSelector:@selector(presentKickZoneAnimated:) withObject:@YES afterDelay:0.48];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        // updateItemAttachmentLengthsForVelocity needs work. Dragging is jagged, the legnth works.
        //        [self updateItemAttachmentLengthsForVelocity:[panGesture velocityInView:self.animator.referenceView]];
        
        if (CGRectContainsPoint([self kickZoneArea], item.center))
        {
            self.wantsToExpand = YES;
            [self startKickLoadingBar];
        }
        else
        {
            self.wantsToExpand = NO;
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        self.wantsToShowKickZone = NO;
        
        [self stopKickLoadingBar];
        [self dismissKickZoneAnimated:@YES];
    }
}

@end
