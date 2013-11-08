//
//  CHFChatStackItem.m
//  DynamicsCatalog
//
//  Created by Larry Ryan on 6/18/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "CHFChatStackItem.h"
#import "CHFChatStackManager.h"
#import "CHFKickOutBehavior.h"

#import "UIImage+ImageEffects.h"

#import "CHFBlurView.h"

@import QuartzCore;
@import AVFoundation;


typedef NS_ENUM (NSUInteger, RectEdge)
{
    RectEdgeTop = 0,
    RectEdgeRight = 1,
    RectEdgeBottom = 2,
    RectEdgeLeft = 3
};

@interface CHFChatStackItem ()

@property (nonatomic, strong) CALayer *contentLayer;

@property (nonatomic) NSTimer *frequencyToningTimer;

// Dynamic Properties
@property (nonatomic, strong) UIDynamicItemBehavior *boundsObservingBehavior;
@property (nonatomic, strong, readwrite) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong, readwrite) UIAttachmentBehavior *precedentItemAttachmentBehavior;
@property (nonatomic, strong, readwrite) UIDynamicItemBehavior *flickBehavior;

@property (nonatomic) UIDynamicAnimator *removalAnimator;

@property (nonatomic) CGPoint lastPointInSnapBackBounds;

@property (nonatomic) UIPanGestureRecognizer *panGesture;

// View Controller
@property (nonatomic, strong, readwrite) UINavigationController *navigationController;
@property (nonatomic, strong) CHFBlurView *backgroundView;

@end

@implementation CHFChatStackItem

#pragma mark - Lifecycle

- (instancetype)initWithType:(ItemType)type
{
    self = [super init];
    
    if (self)
    {
        // Set the type
        self.itemtype = type;
        self.delegate = ChatStackManager;
        
        // View
        self.frame = CGRectMake(0, 0, ChatStackManager.stackItemSize, ChatStackManager.stackItemSize);
        self.backgroundColor = [UIColor clearColor];
        
        // Layer
        self.layer.shouldRasterize = YES;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.layer.cornerRadius = ChatStackManager.stackItemSize / 2;
        self.layer.masksToBounds = YES;
        self.layer.allowsEdgeAntialiasing = YES;
        self.layer.allowsGroupOpacity = YES;
//        [self drawShadowOnLayer:self.layer];
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.avatarImageView.center = self.center;
        [self addSubview:self.avatarImageView];
        
        // Apply tap gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedItem:)];
        [self addGestureRecognizer:tap];
        
        // Apply pan gesture
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedItem:)];
        [self addGestureRecognizer:self.panGesture];
    }
    
    return self;
}

+ (instancetype)testItem:(ItemType)type
{
    CHFChatStackItem *item = [[CHFChatStackItem alloc] initWithType:type];
    
    NSArray *usernames = @[@"Jarvis", @"Timmy", @"Bill", @"Bob", @"Molly"];
    item.username = usernames[arc4random() % usernames.count];
    
    NSArray *userIDs = @[@"1", @"2", @"3", @"4", @"5"];
    item.userID = userIDs[arc4random() % userIDs.count];
    
    NSArray *avatarImages = @[@"at1.jpg", @"at2.jpg", @"at3.jpg", @"at4.jpg", @"at5.jpg", @"at6.jpg"];
    NSString *imageName = avatarImages[arc4random() % avatarImages.count];
    item.avatarImageView.image = [UIImage imageNamed:imageName];
    
    return item;
}



#pragma mark - View Controller
/*
- (void)presentNavigationControllerAnimated:(BOOL)animated
{
    if (!self.navigationController)
    {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        
        UIViewController *viewController = [board instantiateViewControllerWithIdentifier:@"HoverCardViewController"];
        
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.navigationController.view.layer.cornerRadius = 8.0f;
        self.navigationController.view.layer.masksToBounds = YES;
        self.navigationController.view.frame = [self frameForNavigationController];
        self.navigationController.view.tintColor = [UIColor redColor];
    }
    
    
    self.navigationController.view.transform = CGAffineTransformMakeScale(0, 0);
    
    
    CHFChatStackItem *lastStackItem = [ChatStackManager.itemArray lastObject];
    
    [ChatStackManager.window insertSubview:self.navigationController.view
                                       belowSubview:lastStackItem];
    
    // Background View
    CGFloat padding = 10.0;
    CGRect frameRect = AppDelegate.window.screen.bounds;
    frameRect.origin = CGPointMake(-padding, -padding);
    frameRect.size = CGSizeMake(frameRect.size.width + (padding * 2), frameRect.size.height + (padding * 2));
    
    self.backgroundView = [[CHFBlurView alloc] initWithFrame:frameRect blurType:BlurTypeDark withAnimation:YES];
    
    //    [[self backgroundView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    //    self.backgroundView.blurType = BlurTypeDark;
    self.backgroundView.alpha = 0.0f;
    
    // Get the snapshot of the container view and apply a blur effect to it
    //    UIImage *appContainerSnapshotImage = AppContainer.snapshotImage;
    //    appContainerSnapshotImage = [appContainerSnapshotImage applyBlurWithRadius:30
    //                                                                     tintColor:[UIColor colorWithWhite:1.0
    //                                                                                                 alpha:0.1]
    //                                                         saturationDeltaFactor:2.8
    //                                                                     maskImage:nil];
    //
    //    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:appContainerSnapshotImage];
    //    backgroundImageView.frame = self.backgroundView.frame;
    //    [self.backgroundView addSubview:backgroundImageView];
    
    [ChatStackManager.window insertSubview:self.backgroundView
                                       belowSubview:self.navigationController.view];
    
    if (animated)
    {
        [self showNavigationControllerAnimated:animated
                                withCompletion:^{
                                    
                                }];
    }
    else
    {
        self.navigationController.view.transform = CGAffineTransformIdentity;
        self.backgroundView.alpha = 1.0f;
    }
    
    if (ChatStackManager.motionEffectEnabled)
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
        
        [self.navigationController.view addMotionEffect:group];
    }
}

- (void)dismissNavigationControllerAnimated:(BOOL)animated
{
    if (self.navigationController)
    {
        if (animated)
        {
            [self hideNavigationControllerAnimated:animated
                                    withCompletion:^{
                                        [self.navigationController.view removeFromSuperview];
                                        self.navigationController = nil;
                                        
                                        [self.backgroundView removeFromSuperview];
                                        self.backgroundView = nil;
                                    }];
        }
        else
        {
            [self.navigationController.view removeFromSuperview];
            self.navigationController = nil;
            
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
        }
    }
}

- (CGRect)frameForNavigationController
{
    return CGRectInset(ChatStackManager.deckControllerArea, 10, 10);
}

- (void)showNavigationControllerAnimated:(BOOL)animated withCompletion:(void (^)(void))completion
{
    self.navigationControllerIsHidden = NO;
    
    self.navigationController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.backgroundView.alpha = 1.0;
                     }];
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.4
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationController.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
    
}

- (void)hideNavigationControllerAnimated:(BOOL)animated withCompletion:(void (^)(void))completion
{
    self.navigationControllerIsHidden = YES;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.backgroundView.alpha = 0.0;
                     }];
    
    [UIView animateWithDuration:0.3/1.5
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3/2
                                               delay:0.0
                                             options: UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              self.navigationController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
                                          }
                                          completion:^(BOOL finished) {
                                              completion();
                                          }];
                     }];
}
 */

#pragma mark - Camera

- (void)showFrontFacingCamera
{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *backFacingCamera = nil;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront)
        {
            backFacingCamera = device;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backFacingCamera
                                                                        error:&error];
    
    if (!input)
    {
        NSLog(@"Couldn't create video capture device");
    }
    
    [session addInput:input];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        
        CALayer *viewLayer = [view layer];
        
        newCaptureVideoPreviewLayer.frame = view.bounds;
        
        [viewLayer addSublayer:newCaptureVideoPreviewLayer];
        
//        AVCaptureVideoPreviewLayer *previewLayer = newCaptureVideoPreviewLayer;
        
        [self addSubview:view];
        
        [session startRunning];
    });
}


 
#pragma mark - Dynamic Behaviors

- (void)snapToPoint:(CGPoint)point withCompletion:(void (^)(void))completion
{
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:point];
    
    snapBehavior.damping = 0.5;
    
    if (!ChatStackManager.stackItemAllowsRotation)
    {
        UIDynamicItemBehavior *properties = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        properties.angularResistance = NO;
        
        [ChatStackManager.animator addBehavior:properties];
    }
    
    
//    __weak UISnapBehavior *snap = snapBehavior;
    
    __block CGPoint observingPoint = CGPointZero;
    
    snapBehavior.action = ^{
        
        if (CGPointEqualToPoint(self.center, observingPoint) && !CGPointEqualToPoint(self.center, point))
        {
            
//            [ChatStackManager.animator removeBehavior:snap];
            
            completion();
        }
        else
        {
            observingPoint = self.center;
        }
        
    };
    
    [ChatStackManager.animator addBehavior:snapBehavior];
    
}

#pragma mark

- (void)kickOutWithRandomAnimation:(BOOL)random
{
    [CHFKickOutBehavior kickOutItem:self withRandomDirection:random];
}

#pragma mark

- (void)attachToPrecedentItem
{
    if (!self.precedentItemAttachmentBehavior)
    {
        self.precedentItemAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToItem:[self precedentItem]];
    }
    
    self.precedentItemAttachmentBehavior.length = 0;
    self.precedentItemAttachmentBehavior.frequency = 0.0;
    self.precedentItemAttachmentBehavior.damping = 0.5;
    
    [ChatStackManager.animator addBehavior:self.precedentItemAttachmentBehavior];
}

- (void)detachFromPrecedentItem
{
    if ([ChatStackManager.animator.behaviors containsObject:self.precedentItemAttachmentBehavior])
    {
        [ChatStackManager.animator removeBehavior:self.precedentItemAttachmentBehavior];
    }
}

- (void)updatePrecedentItemAttachmentLengthForVelocity:(CGPoint)velocity
{
    int maxLength = 54;
    
    float multiplier = 0.001;
    
    float velocitySum = (velocity.x * velocity.y) * multiplier;
    
    if (velocitySum > maxLength) velocitySum = maxLength;
    
    self.precedentItemAttachmentBehavior.length = velocitySum;
}

#pragma mark

- (void)applyGravity
{
    NSLog(@"in apply gracvity");
    
    if (!self.gravityBehavior)
    {
        self.gravityBehavior = [[UIGravityBehavior alloc] init];
    }
    
    if (![self.gravityBehavior.items containsObject:self])
    {
        [self.gravityBehavior addItem:self];
    }
    
    [self updateGravityDirection];
    
    if (![ChatStackManager.animator.behaviors containsObject:self.gravityBehavior])
    {
        [ChatStackManager.animator addBehavior:self.gravityBehavior];
    }
}

- (void)removeGravity
{
    if ([ChatStackManager.animator.behaviors containsObject:self.gravityBehavior])
    {
        [ChatStackManager.animator removeBehavior:self.gravityBehavior];
    }
    
    if ([self.gravityBehavior.items containsObject:self])
    {
        [self.gravityBehavior removeItem:self];
    }
}

- (void)updateGravityDirection
{
    switch (self.itemtype)
    {
        case ItemTypeStack:
        {
            // Update which direction the gravity should force
            CGFloat gravityForce = 5.0;
            
            CGFloat xComponent = [self isOnLeftSide] ? -gravityForce : gravityForce;
            CGFloat yComponent = 0.0;
            
            self.gravityBehavior.gravityDirection = CGVectorMake(xComponent,yComponent);
        }
            break;
        case ItemTypePending:
        case ItemTypeStandAlone:
        {
            self.gravityBehavior.gravityDirection = CGVectorMake([self.panGesture velocityInView:self].x, [self.panGesture velocityInView:self].y);
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark

- (void)applyFlickBehaviorWithPanGesture:(UIPanGestureRecognizer *)panGesture
{
    if (![ChatStackManager.animator.behaviors containsObject:self.flickBehavior])
    {
        self.flickBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        
        [ChatStackManager.animator addBehavior:self.flickBehavior];
    }
    
    [self.flickBehavior addLinearVelocity:[panGesture velocityInView:ChatStackManager.window] forItem:self];
}

- (void)removeFlickBehavior
{
    if ([ChatStackManager.animator.behaviors containsObject:self.flickBehavior])
    {
        [ChatStackManager.animator removeBehavior:self.flickBehavior];
    }
}

#pragma mark

- (void)beginObservingBoundsCrossing
{
    if (!self.boundsObservingBehavior)
    {
        self.boundsObservingBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        [ChatStackManager.animator addBehavior:self.boundsObservingBehavior];
    }
    
    if ([self.boundsObservingBehavior.items containsObject:self])
    {
        __weak CHFChatStackItem *myself = self;
        
        [self.boundsObservingBehavior addItem:self];
        
        self.boundsObservingBehavior.action = ^{
            [myself performSelector:@selector(observeBounds) withObject:nil];
        };
    }
}

- (void)stopObservingBoundsCrossing
{
    if ([ChatStackManager.animator.behaviors containsObject:self.flickBehavior])
    {
        [ChatStackManager.animator removeBehavior:self.boundsObservingBehavior];
    }
    
    if (self.boundsObservingBehavior)
    {
        self.boundsObservingBehavior = nil;
    }
}

// This is called from the "boundsObservingBehaviors" action block, which is called consistentely with the runloop. Here we detemine if the item has hit the bounds. If so we remove its behaviors and add a snap behavior to the item to stay on the edge. This can ONLY be called from the headChatStackItem
- (void)observeBounds
{
    [self updateGravityDirection];
    
    switch (self.itemtype)
    {
        case ItemTypeStack:
        {
            if (self.isHeadStackItem)
            {
                if (!(CGRectContainsPoint(ChatStackManager.snapBackBounds, self.center)))
                {
                    // Tell the delegate that the object left bounds
                    if ([self.delegate respondsToSelector:@selector(chatStackItemDidLeaveBounds:)])
                    {
                        [self.delegate chatStackItemDidLeaveBounds:self];
                    }
                    
                    [self stopObservingBoundsCrossing];
                    [self removeGravity];
                    
                    CGPoint outOfBoundsPoint = self.center;
                    CGRect snapBackBounds = [ChatStackManager snapBackBounds];
                    
                    if (outOfBoundsPoint.y < CGRectGetMinY(snapBackBounds)) // Item is too high
                    {
                        if ([self isOnLeftSide])
                        {
                            // Top Left
                            outOfBoundsPoint = CGPointMake(CGRectGetMinX(snapBackBounds), CGRectGetMinY(snapBackBounds));
                        }
                        else
                        {
                            // Top Right
                            outOfBoundsPoint = CGPointMake(CGRectGetMaxX(snapBackBounds), CGRectGetMinY(snapBackBounds));
                        }
                    }
                    else if (outOfBoundsPoint.y >= CGRectGetMaxY(snapBackBounds)) // Item is to low
                    {
                        if ([self isOnLeftSide])
                        {
                            // Bottom Left
                            outOfBoundsPoint = CGPointMake(CGRectGetMinX(snapBackBounds), CGRectGetMaxY(snapBackBounds));
                        }
                        else
                        {
                            // Bottom Right
                            outOfBoundsPoint = CGPointMake(CGRectGetMaxX(snapBackBounds), CGRectGetMaxY(snapBackBounds));
                        }
                    }
                    else // Item is just right ;)
                    {
                        NSArray *edgePoints = [self startAndEndPointForRect:snapBackBounds edge:self.isOnLeftSide ? RectEdgeLeft: RectEdgeRight];
                        
                        // SnapBackBounds Edge
                        CGPoint point1 = [(NSValue *)(edgePoints[0]) CGPointValue];
                        CGPoint point2 = [(NSValue *)(edgePoints[1]) CGPointValue];
                        
                        // Item Travel Path
                        CGPoint point3 = self.lastPointInSnapBackBounds;
                        CGPoint point4 = outOfBoundsPoint;
                        
                        outOfBoundsPoint = [[self intersectionOfLineFrom:point1 to:point2 withLineFrom:point3 to:point4] CGPointValue];
                    }
                    
                    ChatStackManager.boundsCrossingPoint = outOfBoundsPoint;
                    
                    for (CHFChatStackItem *item in ChatStackManager.itemArray)
                    {
                        if (item.precedentItemAttachmentBehavior)
                        {
                            [ChatStackManager.animator removeBehavior:item.precedentItemAttachmentBehavior];
                        }
                        
                        [item snapToPoint:[item pointForDefaultLayoutFromSourcePoint:outOfBoundsPoint]
                           withCompletion:^{
                               [item removeFlickBehavior];
                           }];
                    }
                }
                
                // Update point while the item is still in bounds
                self.lastPointInSnapBackBounds = self.center;
            }
        }
            break;
        case ItemTypePending:
        {
            if (!(CGRectContainsPoint(ChatStackManager.snapBackBounds, self.center)))
            {
                // When the item type is "Pending" we want the item to go offscreen to dimiss and then be removed
                [self stopObservingBoundsCrossing];
                [self removeFlickBehavior];
                [self removeFromSuperview];
            }
        }
            break;
        case ItemTypeStandAlone: // Doesn't rely on observing bounds
            break;
    }
}


#pragma mark - Effects
- (void)applyEffect:(ItemEffect)effect
{
    [self applyEffect:effect toView:self];
}

- (void)applyEffect:(ItemEffect)effect toView:(UIView *)view
{
    switch (effect)
    {
        case ItemEffectAddZoomIn:
        {
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            view.layer.opacity = 0.0;
            
            [UIView animateWithDuration:0.3/1.5 animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                view.layer.opacity = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        view.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
            break;
        case ItemEffectAddZoomOut:
        {
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
            
            [UIView animateWithDuration:0.3/1.5 animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        view.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
            break;
        case ItemEffectSwitchZIndexUp:
        {
            [UIView animateWithDuration:0.3/1.5 animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                view.layer.opacity = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        view.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
            break;
        case ItemEffectSwitchZIndexDown:
        {
            [UIView animateWithDuration:0.3/1.5 animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                view.layer.opacity = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        view.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
            break;
        case ItemEffectTouchDown:
        {
            [UIView animateWithDuration:0.3/1.5 animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                view.layer.opacity = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        view.transform = CGAffineTransformIdentity;
                    }];
                }];
            }];
        }
        default:
            break;
    }
}

#pragma mark - Helper Methods

- (NSInteger)index
{
    return [ChatStackManager.itemArray indexOfObject:self];
}

- (CHFChatStackItem *)precedentItem
{
    return ChatStackManager.itemArray[[self index] - 1];
}

- (CGPoint)location
{
    return [ChatStackManager.window convertPoint:self.center fromView:self];
}

- (BOOL)isHeadStackItem
{
    return [self isEqual:ChatStackManager.headStackItem];
}

- (BOOL)isPending
{
    return ChatStackManager.pendingItemArray && [ChatStackManager.pendingItemArray containsObject:self];
}

- (BOOL)isOnLeftSide
{
    return self.center.x < CGRectGetMidX(ChatStackManager.window.frame) ? YES: NO;
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
    layer.shadowOpacity = 0.5f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:layer.bounds cornerRadius:layer.cornerRadius];
    
    layer.shadowPath = path.CGPath;
}

- (void)removeShadowOnLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor clearColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0;
    layer.shadowOpacity = 0.0f;
    layer.shadowPath = nil;
}

- (CGPoint)pointForDefaultLayoutFromSourcePoint:(CGPoint)point
{
    float offsetValue = ([self index] * 4);
    float offsetDirection = point.x < CGRectGetWidth(ChatStackManager.window.frame) / 2 ? offsetValue: -offsetValue;
    
    CGPoint offsetPoint = CGPointMake(point.x + offsetDirection, point.y);
    
    return offsetPoint;
}

- (CGFloat)distanceFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    CGFloat distance = sqrtf( powf(fromPoint.x - toPoint.x, 2.0) + powf(fromPoint.y - toPoint.y, 2.0) );
    
    return MIN(distance, 200.0);
}

- (BOOL)isPastVelocityThreshold:(CGPoint)velocity
{
    int velocityThreshold = 100;
    
    if ((velocity.x < velocityThreshold && velocity.x > -velocityThreshold) ||
        (velocity.y < velocityThreshold && velocity.y > -velocityThreshold))
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSValue *)intersectionOfLineFrom:(CGPoint)p1 to:(CGPoint)p2 withLineFrom:(CGPoint)p3 to:(CGPoint)p4
{
    CGFloat d = (p2.x - p1.x) * (p4.y - p3.y) - (p2.y - p1.y) * (p4.x - p3.x);
    if (d == 0)
        return nil; // parallel lines
    CGFloat u = ((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d;
    CGFloat v = ((p3.x - p1.x) * (p2.y - p1.y) - (p3.y - p1.y) * (p2.x - p1.x)) / d;
    if (u < 0.0 || u > 1.0)
        return nil; // intersection point not between p1 and p2
    if (v < 0.0 || v > 1.0)
        return nil; // intersection point not between p3 and p4
    CGPoint intersection;
    intersection.x = p1.x + u * (p2.x - p1.x);
    intersection.y = p1.y + u * (p2.y - p1.y);
    
    return [NSValue valueWithCGPoint:intersection];
}

- (NSArray *)startAndEndPointForRect:(CGRect)rect edge:(RectEdge)edge
{
    // Top Points
    NSValue *topLeftPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    NSValue *topRightPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    
    // Bottom Points
    NSValue *bottomLeftPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    NSValue *bottomRightPoint = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    
    switch (edge)
    {
        case RectEdgeTop:
            return @[topLeftPoint, topRightPoint];
            break;
        case RectEdgeRight:
            return @[topRightPoint, bottomRightPoint];
            break;
        case RectEdgeBottom:
            return @[bottomLeftPoint, bottomRightPoint];
            break;
        case RectEdgeLeft:
            return @[topLeftPoint, bottomLeftPoint];
            break;
    }
}

#pragma mark - Gesture Methods
#pragma mark Touch Overides
// Gets called before GestureStateBegin does.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!self.delegate) self.delegate = ChatStackManager;
    
    [ChatStackManager.animator removeAllBehaviors];
    
//    [self applyEffect:ItemEffectTouchDown];
}

#pragma mark Tap
- (void)tappedItem:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(didTapItem:withGesture:)])
    {
        [self.delegate didTapItem:self withGesture:tapGesture];
    }
}

#pragma mark Pan
- (void)pannedItem:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
                [self drawShadowOnLayer:self.layer];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
                [self removeShadowOnLayer:self.layer];
        }
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(didPanItem:withGesture:)])
    {
        [self.delegate didPanItem:self withGesture:panGesture];
    }
}

/*
 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
 {
 if (self.itemtype == ItemTypePending)
 {
 if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
 CGPoint velocity = [recognizer velocityInView:self];
 
 // Make sure we are panning on the x axis
 if (abs(velocity.y) >= abs(velocity.x))
 {
 if ([self isOnLeftSide])
 {
 if (velocity.x < 0) return YES;
 
 return NO;
 }
 else
 {
 if (velocity.x > 0) return YES;
 
 return NO;
 }
 }
 else
 {
 return NO;
 }
 }
 else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 //            UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)gestureRecognizer;
 }
 }
 
 switch (ChatStackManager.layout)
 {
 case StackLayoutDefault:
 {
 if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 //                UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
 //                CGPoint velocity = [recognizer velocityInView:self];
 }
 else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 //                UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)gestureRecognizer;
 }
 }
 break;
 
 case StackLayoutMessage:
 {
 if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
 {
 UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
 CGPoint velocity = [recognizer velocityInView:self];
 
 if (abs(velocity.y) >= abs(velocity.x))
 {
 return YES;
 }
 else
 {
 return NO;
 }
 }
 else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
 {
 //                UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)gestureRecognizer;
 }
 }
 break;
 
 default:
 break;
 }
 
 return YES;
 }
 */

@end
