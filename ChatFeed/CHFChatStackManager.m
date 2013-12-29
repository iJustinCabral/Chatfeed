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
#import "UIView+Hierarchy.h"

#import "CHFBlurView.h"

#import "BlackholeView.h"

#import "CHFChatStackItemBase.h"

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

NSString * NSStringFromItemLayout(ItemLayout layout)
{
    switch (layout)
    {
        case ItemLayoutStack:
            return @"ItemLayout Stack";
            break;
        case ItemLayoutMessage:
            return @"ItemLayout Message";
            break;
        case ItemLayoutReply:
            return @"ItemLayout Reply";
            break;
        default:
            return nil;
            break;
    }
}

@interface CHFChatStackManager () <UIDynamicAnimatorDelegate, StackDeckControllerDelegate, StackDeckControllerDataSource, ItemsCollectionViewControllerDataSource, ItemsCollectionViewControllerDelegate>

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
    
    NSLog(@"making chatstack manager");
    
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

- (CGRect)windowFrame
{
    CGRect frame = self.window.frame;
    
    if (!AppDelegate.statusBarIsHidden)
    {
        frame.origin.y += AppDelegate.statusBarRect.size.height;
        frame.size.height -= AppDelegate.statusBarRect.size.height;
    }
    
    return frame;
}

- (CGRect)snapBackBounds
{
    CGFloat padding = 10;
    
    CGRect appFrame = [self windowFrame];
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect screenSizeWithoutStatusBar = CGRectMake(0, statusBarHeight + padding, appFrame.size.width, appFrame.size.height - (statusBarHeight + padding));
    CGRect insetRect = CGRectInset(screenSizeWithoutStatusBar, kStackInset, kStackInset);
    
    return insetRect;
}

- (CGRect)kickZoneArea
{
    float kickZoneSize = kKickZoneSize;
    float margin = (CGRectGetWidth(self.window.frame) - kickZoneSize) / 2;
    
    return CGRectMake(margin, CGRectGetHeight(self.window.frame) - (kickZoneSize + 10), kickZoneSize, kickZoneSize);
}

- (CGRect)replyCollectionViewArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide([self windowFrame], &slice, &remainder, kStackItemSize + (margin * 2), CGRectMinYEdge);
    
    return slice;
}

- (CGRect)messageCollectionViewArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide([self windowFrame], &slice, &remainder, kStackItemSize + (margin * 2), CGRectMaxYEdge);
    
    return slice;
}

- (CGRect)deckControllerArea
{
    CGRect slice;
    CGRect remainder;
    CGFloat margin = 10.0;
    
    CGRectDivide([self windowFrame], &slice, &remainder, kStackItemSize + (margin * 2), self.layout == ItemLayoutMessage ? CGRectMaxYEdge : CGRectMinYEdge);
    
    return remainder;
}

#pragma mark - BlackHole

- (void)configureBlackHole
{
    if (!self.blackholeView)
    {
        self.blackholeView = [[BlackholeView alloc] initWithFrame:self.window.frame andParticleColor:[UIColor appColor]];
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
            
            self.kickZoneView.backgroundColor = [UIColor purpleColor];
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

- (void)addItemToStack:(CHFChatStackItem *)item
{
    [self addItemToStack:item fromView:nil];
}

// Add a new item to the stack array, and shift trailing items to there right center point
- (void)addItemToStack:(CHFChatStackItem *)item fromView:(UIView *)view
{
    item.itemtype = ItemTypeStack;
    
    // If the item has a base then tell the base to make a new item for itself with the same characteristics
    if (item.base) [item.base spawnItemAnimated:YES];
    
    // Make us the delegate of the object
    if (!item.delegate) item.delegate = self;
    
    // If the DynamicAnimator doesn't exist we need to make one
    if (!self.animator) self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.window];
    
    // If the itemArray doesn't exist make one
    if (!self.itemArray) self.itemArray = [NSMutableArray array];
    
    // First added object
    if (self.itemArray.count == 0)
    {
        [self.itemArray addObject:item];
        
        self.boundsCrossingPoint = self.snapBackBounds.origin;
        
        [item snapToPoint:self.snapBackBounds.origin
                   inView:self.window];
        
        [self updateMotionEffectForItem:item
                                atIndex:[item index]];
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
                
                [item snapToPoint:spawnPoint ///self.boundsCrossingPoint
                           inView:self.window];
                
                [self updateItemsPointForStackLayout:spawnPoint];
            }
                break;
            case ItemLayoutMessage:
                
                [self.itemArray insertObject:item atIndex:0];
                
                break;
            default:
                break;
        }
    }
}

- (void)addItemToPending:(CHFChatStackItem *)item
{
    item.itemtype = ItemTypePending;
    
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

- (void)hideStack
{
    // There first items are in the stack
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item applyEffect:ItemEffectFadeOut];
    }
}

- (void)showStack
{
    // There first items are in the stack
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item applyEffect:ItemEffectFadeIn];
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
            float offsetDirection = point.x < CGRectGetWidth(self.window.frame) / 2 ? offsetValue: -offsetValue;
            
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

#pragma mark - ChatStack Item Delegate

- (void)didTapItem:(CHFChatStackItem *)item withGesture:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"_________________________BEGIN________________________________");
    NSLog(@"Tapped %@", NSStringFromItemType(item.itemtype));
    
    switch (item.itemtype)
    {
            // If a stack item is tapped, we open the message itemcollectionview, and give the stack items to it. The item tapped will be the first in the collection view and makes itself the head chat stack item
        case ItemTypeStack:
        {
            if (!item.isHeadStackItem) [self moveStackItemToHeadItem:item withAnimation:NO];
            
            switch (self.layout)
            {
                case ItemLayoutStack:
                {
                    // If enabled update the motion effects for the items in the stack
                    [self updateMotionEffectsForAllItems];
                    
                    // Detach the trailing items from the headStackItem so they can animate to their cells in the message itemcollectionview.
                    [self detachItemsFromHeadItem];
                    
                    // Present the blurred background
                    [self presentBlurViewAnimated:YES];
                    
                    // Present the messages itemviewcontroller with the items that will be passed to the itemcollectionview once it loads
                    [self presentMessageItems:self.itemArray withCollectionViewAnimated:YES];
                }
                    break;
                case ItemLayoutMessage:
                {
                    //
                    self.layout = ItemLayoutStack;
                    
                    [self dismissMessageCollectionViewAnimated:YES];
                    [self dismissStackDeckController:YES];
                    [self dismissBlurViewAnimated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            // A pending item will pop on the opposite side of the screen from the stack. If tapped it will be added to the reply itemcollectionview
        case ItemTypePending:
        {
            if ([self.currentChosenItem isEqual:item])
            {
                // If the chosen item is equal to the pending item, most likely it is in the reply layout. Tapping the item will dismiss the reply controller
                [self dismissReplyItemsCollectionViewAnimated:YES];
                [self dismissStackDeckController:YES];
                [self dismissBlurViewAnimated:YES];
                
            }
            if (![self.currentChosenItem isEqual:item])
            {
                [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
            }
        }
            break;
            // If a stand alone item is tapped, it will open the reply itemcollectionview if there is no history of messages from the user.
        case ItemTypeStandAlone:
        {
            NSLog(@"the chosen item = %@",item);
            
            if (![self.currentChosenItem isEqual:item])
            {
                [self presentBlurViewAnimated:YES];
                NSLog(@"ItemTypeStandAlone presented blure view");
                if ([AppDelegate chatStackIsPurchased])
                {
                    NSLog(@"ItemTypeStandAlone chatStackIsPurchased");
                    // TODO: Maybe have setting to default begin chat uses reply
                    if ([self doesHaveCurrentChatWithUserID:item.userID])
                    {
                        NSLog(@"ItemTypeStandAlone doesHaveCurrentChatWithUserID");
                        [self presentMessageItems:self.itemArray withCollectionViewAnimated:YES];
                        // TODO: scroll to the page with the userID
                    }
                    else
                    {
                        NSLog(@"ItemTypeStandAlone presentReplyItems");
                        // Present the ReplyCollectionView, and then give the item to the collection view cell
                        [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
                    }
                }
                else
                {
                    NSLog(@"ItemTypeStandAlone els eelse presentReplyItems");
                    // Present the ReplyCollectionView, and then give the item to the collection view cell
                    [self presentReplyItems:@[item] withCollectionViewAnimated:YES];
                }
                
                // Show the deck controller which holds all of the VC's for each chat item
                
                //                [self.window bringSubviewToFront:item];
            }
            else // The currentChosenItem IS the same as the chosen item
            {
                NSLog(@"currentChosenItem IS the same");
                self.layout = ItemLayoutStack;
                
                [self dismissBlurViewAnimated:YES];
                
                [self dismissStackDeckController:YES];
                
                [self dismissReplyItemsCollectionViewAnimated:YES];
            }
        }
            break;
    }
    
    if (![self.currentChosenItem isEqual:item])
    {
        self.currentChosenItem = item;
        if (![self.itemArray containsObject:item]) [self.currentChosenItem addShadow:YES animated:YES];
        NSLog(@"Set new chosen item");
        // !!!: Hack to get around conforming files to NSCoding right now
        //        self.currentChosenItem = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:item]];
    }
    else
    {
        NSLog(@"set chosent item to nil");
        [self.currentChosenItem addShadow:NO animated:YES];
//        self.currentChosenItem = nil;
    }
    
    NSLog(@"_________________________END________________________________");
}


- (void)didPanItem:(CHFChatStackItem *)item withGesture:(UIPanGestureRecognizer *)panGesture
{
    switch (item.itemtype)
    {
        case ItemTypeStack:
        {
            switch (self.layout)
            {
                case ItemLayoutStack:
                    if ([item isHeadStackItem])
                    {
                        [self pannedViewFlick:panGesture];
                        //                        [self pannedViewKickZone:panGesture];
                        //                        [self configureBlackHole];
                    }
                    break;
                case ItemLayoutMessage:
                    //                    if (self.messageCollectionViewIsHidden == YES)
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
    NSLog(@"the item superview = %@", item.superview);
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self.window addSubview:item];
            //            item.center = [item.originalParentView convertPoint:item.originalPoint toView:self.window];
            
            item.center = [[(ItemCoordinates *)item.journeyArray[0] view] convertPoint:[(ItemCoordinates *)item.journeyArray[0] point] toView:self.window];
            
            self.dragging = YES;
            // | HoverMenuOptionUserFollowers | HoverMenuOptionMessageRepost | HoverMenuOptionUserMentions | HoverMenuOptionUserInteractions | HoverMenuOptionUserInteractions | HoverMenuOptionMessageStar | HoverMenuOptionMessageShare | HoverMenuOptionMessageReportSpam | HoverMenuOptionManageAddUser | HoverMenuOptionManageKick | HoverMenuOptionChatStackAddUser | HoverMenuOptionChatStackRemoveUser
            [self presentHoverMenuWithMenuOptions:HoverMenuOptionUserProfile | HoverMenuOptionUserFollow | HoverMenuOptionUserMute | HoverMenuOptionUserBlock | HoverMenuOptionChatStackAddUser
                                          forItem:item
                                         animated:YES];
            
            [self.window bringSubviewToFront:item];
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
                case ItemTypePending: // The item will go out of the bounds and be killed muahaha
                {
                    [self dismissHoverMenuAnimated:YES];
                    
                    [item applyGravity];
                    
                    [item applyFlickBehaviorWithPanGesture:panGesture];
                    [item beginObservingBoundsCrossing];
                }
                    break;
                case ItemTypeStandAlone: // The item will snap back to where it was originaly from
                case ItemTypeStack:
                {
                    if (panGesture.state == UIGestureRecognizerStateEnded)
                    {
                        [self.hoverMenuController performActionOnCellAtPoint:item.center
                                                           withChatStackItem:item
                                                               andCompletion:^(BOOL performedAction, BOOL itemShouldReturn) {
                                                                   
                                                                   // If the didn't perform an action, or if it did and the item should go back from where it came from
                                                                   if (!performedAction || itemShouldReturn)
                                                                   {
                                                                       [self dismissHoverMenuAnimated:YES];
                                                                       [item snapToPreviousCoordinates];
                                                                   }
                                                                   else
                                                                   {
                                                                       // The hoverMenuController decides what happens to the item
                                                                       [self dismissHoverMenuAnimated:YES];
                                                                   }
                                                               }];
                    }
                    if (panGesture.state == UIGestureRecognizerStateCancelled)
                    {
                        [self dismissHoverMenuAnimated:YES];
                        [item snapToPreviousCoordinates];
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
    NSLog(@"doesHaveCurrentChatWithUserID = %@", userID);
    
    BOOL doesHaveExistingChat = NO;
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        if ([item.userID isEqualToString:userID])
        {
            doesHaveExistingChat = YES;
            break;
        }
    }
    
    return doesHaveExistingChat;
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

- (void)drawShadowOnLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.6f;
    
    UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[layer bounds] cornerRadius:layer.cornerRadius];
    
    [layer setShadowPath:[path CGPath]];
}

- (void)removeShadowOnLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor clearColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0;
    layer.shadowOpacity = 0.0f;
    layer.shadowPath = nil;
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

#pragma mark - BlurView

- (void)configureBlurViewWithBlurType:(BlurType)type animated:(BOOL)animated
{
    self.blurView = [[CHFBlurView alloc] initWithFrame:self.window.bounds
                                              blurType:type
                                         withAnimation:animated];
    
    [self.window insertSubview:self.blurView atIndex:2];
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

- (void)presentStackDeckController:(BOOL)animated
{
    if (!self.chatStackDeckController)
    {
        self.chatStackDeckController = [[CHFChatStackDeckController alloc] initWithNibName:nil bundle:nil];
        self.chatStackDeckController.view.frame = [self deckControllerArea];
        
        
        [self.window addSubview:self.chatStackDeckController.view];
        [self.chatStackDeckController.view sendBelowChatStackItems];
        
        //        [self.window insertSubview:self.chatStackDeckController.view atIndex:kZIndexViews];
    }
    
    self.chatStackDeckController.delegate = self;
    self.chatStackDeckController.dataSource = self;
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
                             
                             // !!!: App crashed when setting to nil
                             self.chatStackDeckController = nil;
                         }];
    }
    
    self.chatStackDeckController.view.layer.opacity = 0.0;
}

#pragma mark DataSource

- (NSInteger)numberOfIndexes
{
    NSLog(@"numberOfIndexes ==== %i", self.replyItemArray.count);
    
    return 5;
}

- (NSString *)userIDForItemAtIndex:(NSInteger)index
{
    CHFChatStackItem *item = self.replyItemArray[index];
    return item.userID;
}

- (NSInteger)indexForUserID:(NSString *)userID
{
    NSInteger index;
    
    for (CHFChatStackItem *item in self.replyItemArray)
    {
        if ([item.userID isEqualToString:userID])
        {
            index = [self.replyItemArray indexOfObject:item];
            break;
        }
    }
    
    return index;
}


#pragma mark - ItemsCollectionViews
#pragma mark ItemsCollectionViewController DataSource

- (NSArray *)itemsToPassToItemsCollectionViewController:(CHFItemsCollectionViewController *)controller
{
    NSArray *items = @[];
    
    if ([controller isEqual:self.replyItemsCollectionViewController])
    {
        items = self.replyItemArray;
    }
    else if ([controller isEqual:self.messageItemsCollectionViewController])
    {
        items = self.itemArray;
    }
    
    return items;
}


#pragma mark ItemsCollectionViewController Delegate

- (void)passItems:(NSArray *)items toItemsCollectionViewController:(CHFItemsCollectionViewController *)controller
{
    [items enumerateObjectsUsingBlock:^(CHFChatStackItem *item, NSUInteger index, BOOL *stop)
     {
         //         CGPoint point = [controller pointForCellAtIndex:index inSection:0];
         
         CHFItemCollectionViewCell *cell = (CHFItemCollectionViewCell *)[controller.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
         NSLog(@"the POINT OF THE PASS ITEMS == %@ cell ==== %@", NSStringFromCGPoint(cell.center), cell);
         CGPoint point = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
         [item snapToPoint:point inView:cell.contentView];
     }];
}

#pragma mark ReplyCollectionViewController

- (void)presentReplyItems:(NSArray *)items withCollectionViewAnimated:(BOOL)animated
{
    self.layout = ItemLayoutReply;
 
    self.replyItemsCollectionViewIsHidden = NO;
    
    [self hideStack];
    
    if (!self.replyItemArray) self.replyItemArray = [NSMutableArray array];
    [self.replyItemArray addObjectsFromArray:items];
    
    for (CHFChatStackItem *item in self.replyItemArray)
    {
        [item prepareToSnap];
    }

    if (!self.replyItemsCollectionViewController)
    {
        self.replyItemsCollectionViewController = [CHFItemsCollectionViewController new];
        self.replyItemsCollectionViewController.collectionView.frame = [self replyCollectionViewArea];
        self.replyItemsCollectionViewController.dataSource = self;
        self.replyItemsCollectionViewController.delegate = self;
    }
    
    [self.window addSubview:self.replyItemsCollectionViewController.view];
    [self.replyItemsCollectionViewController.view sendBelowChatStackItems];
    
    [self presentStackDeckController:YES];
}

- (void)dismissReplyItemsCollectionViewAnimated:(BOOL)animated
{
    self.replyItemsCollectionViewIsHidden = YES;
    
    [self showStack];
    
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
                     [item snapToOrigin];
                 }
                 default:
                     break;
             }
         }];
        
        // The reply item array shouldn't keep its objects since their temporary messages
        [self.replyItemArray removeAllObjects];
        self.replyItemArray = nil;
    }
}

#pragma mark MessageItemsCollectionViewController

- (void)presentMessageItems:(NSArray *)items withCollectionViewAnimated:(BOOL)animated
{
    self.layout = ItemLayoutMessage;
    
//    if (!self.itemArray) self.itemArray = [NSMutableArray array];
//    [self.itemArray addObjectsFromArray:items];
    
    for (CHFChatStackItem *item in self.itemArray)
    {
        [item prepareToSnap];
    }
    
    self.messageItemsCollectionViewIsHidden = NO;
    
    if (!self.messageItemsCollectionViewController)
    {
        self.messageItemsCollectionViewController = [CHFItemsCollectionViewController new];
        self.messageItemsCollectionViewController.view.frame = [self messageCollectionViewArea];
        self.messageItemsCollectionViewController.dataSource = self;
        self.messageItemsCollectionViewController.delegate = self;
    }
    
    [self.window addSubview:self.messageItemsCollectionViewController.view];
    [self.messageItemsCollectionViewController.view sendBelowChatStackItems];
    
    [self presentStackDeckController:YES];
}

- (void)dismissMessageCollectionViewAnimated:(BOOL)animated
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
        [self.itemArray enumerateObjectsUsingBlock:^(CHFChatStackItem *item, NSUInteger idx, BOOL *stop)
         {
            [item snapToPoint:self.boundsCrossingPoint inView:self.window];
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
        self.hoverMenuController.view.frame = self.window.bounds;
        
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
            return self.window.frame;
        }
            break;
        case ItemLayoutMessage:
        case ItemLayoutReply:
        {
            return CGRectInset(self.deckControllerArea, 10, 10);
        }
            break;
    }
    
    return CGRectInset(self.deckControllerArea, 10, 10);
}

@end
