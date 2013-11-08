//
//  CHFControllerCard.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/3/13.
//  Copyright (c)2013 Thinkr LLC. All rights reserved.
//

#import "CHFControllerCard.h"
#import "CHFDeckController.h"

@interface CHFControllerCard () <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat originY;
@property (nonatomic) CGFloat originScale;
@property (nonatomic) CGFloat scalingFactor;
@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation CHFControllerCard

#pragma mark - Lifecyle

- (instancetype)initWithDeckController:(CHFDeckController *)deckController
                        viewController:(UIViewController *)viewController
                             indexPath:(NSIndexPath *)indexPath
{
    if (self = [super init])
    {
        self.deckController = deckController;
        self.viewController = viewController;
        
        CGFloat origin = [deckController defaultVerticalOriginForControllerCard:self atIndexPath:indexPath];
        [self setOriginY:origin andCardIndexPath:indexPath];
        
        self.frame = deckController.view.bounds;
        
        // Initialize the view's properties
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:self.deckController.cardAutoresizingMask];
        
        // Configure navigation controller to have rounded edges while maintaining shadow
        self.viewController.view.frame = self.frame;
        self.viewController.view.layer.cornerRadius = self.deckController.cardCornerRadius;
        self.viewController.view.clipsToBounds = YES;
        
        [self addSubview:viewController.view];
        
        // Gestures
        [self configureGestures];
    }
    
    return self;
}

- (void)configureGestures
{
    // Pan Gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didPerformPanGesture:)];
    self.panGesture.delegate = self;
    
    // Tap Gesture
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didPerformTapGesture:)];
    self.tapGesture.delegate = self;
    self.tapGesture.numberOfTapsRequired = self.deckController.cardMinimumTapsRequired;
    
    // Pinch Gesture
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(didPerformPinchGesture:)];
    self.pinchGesture.delegate = self;
    self.pinchGesture.scale = 2.0f;
    
    // Assign the gestures to the viewcontroller
    if (self.deckController.cardGestureOptions == CardGestureOptionAll)
    {
        if ([self.viewController isKindOfClass:[UINavigationController class]])
        {
            [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.panGesture];
            [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.tapGesture];
            [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.pinchGesture];
        }
        
        // Add Pan Gesturesf
        [self.viewController.view addGestureRecognizer:self.panGesture];
        
        // Add Tap Gestures
        [self.viewController.view addGestureRecognizer:self.tapGesture];
        
        // Add Pinch Gestures
        [self.viewController.view addGestureRecognizer:self.pinchGesture];
    }
    else
    {
        if ([self.viewController isKindOfClass:[UINavigationController class]])
        {
            if (self.deckController.cardGestureOptions & CardGestureOptionNavigationPan)
            {
                [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.panGesture];
            }
            if (self.deckController.cardGestureOptions & CardGestureOptionNavigationPinch)
            {
                [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.pinchGesture];
            }
            if (self.deckController.cardGestureOptions & CardGestureOptionNavigationTap)
            {
                [[(UINavigationController *)self.viewController navigationBar] addGestureRecognizer:self.tapGesture];
            }
        }
        
        if (self.deckController.cardGestureOptions & CardGestureOptionViewPan)
        {
            [self.viewController.view addGestureRecognizer:self.panGesture];
        }
        if (self.deckController.cardGestureOptions & CardGestureOptionViewPinch)
        {
            [self.viewController.view addGestureRecognizer:self.pinchGesture];
        }
        if (self.deckController.cardGestureOptions & CardGestureOptionViewTap)
        {
            [self.viewController.view addGestureRecognizer:self.tapGesture];
        }
    }
}

#pragma mark - Properties

- (void)setYCoordinate:(CGFloat)yValue
{
    self.frame = CGRectMake(self.frame.origin.x, yValue, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    [self redrawShadow];
}

- (void)setOriginY:(CGFloat)originY andCardIndexPath:(NSIndexPath *)cardIndexPath
{
    self.originY = originY;
    self.indexPath = cardIndexPath;
}

#pragma mark - UIGestureRecognizer action handlers
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didPerformPanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.deckController.view];
    CGPoint translation = [recognizer translationInView:self];
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // Begin animation
            if (self.state == ControllerCardStateFullScreen)
            {
                // Shrink to regular size
                [self shrinkCardToScaledSize:YES];
            }
            // Save the offet to add to the height
            self.panOriginOffset = [recognizer locationInView:self].y;
            
            if ([self.delegate respondsToSelector:@selector(didBeginPanningControllerCard:)])
            {
                [self.delegate didBeginPanningControllerCard:self];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // Check if panning downwards and move other cards
            if (translation.y > 0)
            {
                // Panning downwards from Full screen state
                if (self.state == ControllerCardStateFullScreen && self.frame.origin.y < self.originY)
                {
                    //Notify delegate so it can update the coordinates of the other cards unless user has travelled past the origin y coordinate
                    if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)])
                    {
                        [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                    }
                }
                
                // Panning downwards from default state
                else if (self.state == ControllerCardStateDefault && self.frame.origin.y > self.originY)
                {
                    // Implements behavior such that when originating at the default position and scrolling down, all other cards below the scrolling card move down at the same rate
                    if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)])
                    {
                        [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                    }
                    
                    // If the card is the top card, tell the delegate we panned;
                    if ([self isEqual:[[self.deckController allCardsFromDeckContainingCard:self] objectAtIndex:0]])
                    {
                        if ([self.delegate respondsToSelector:@selector(topControllerCard:didUpdatePanPercentage:)])
                        {
                            [self.delegate topControllerCard:self didUpdatePanPercentage:[self percentageDistanceTravelled]];
                        }
                        
                    }
                }
            }
            else // Upwards
            {
                if ([self.delegate respondsToSelector:@selector(topControllerCard:didStopPanningWithReturnState:)])
                {
                    [self.delegate topControllerCard:self didStopPanningWithReturnState:ControllerCardStateDefault];
                }
                //            for (KLControllerCard *card in self.noteViewController.controllerCards)
                //            {
                //                if (card != self)
                //                {
                //                    if (0 != card.origin.y) {
                //                        [card setState:KLControllerCardStateDefault animated:YES];
                //                    }
                //
                //                }
                //            }
            }
            
            
            // Track the movement of the users finger during the swipe gesture
            [self setYCoordinate: location.y - self.panOriginOffset];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // Check if it should return to the origin location
            if ([self shouldReturnToState: self.state fromPoint: [recognizer translationInView:self]])
            {
                [self setState: self.state animated:YES];
                
                // Let the delegate know we stopped panning the top card
                if ([self.delegate respondsToSelector:@selector(topControllerCard:didStopPanningWithReturnState:)])
                {
                    [self.delegate topControllerCard:self didStopPanningWithReturnState:self.state];
                }
            }
            else // Should not return to original state
            {
                // Get where the touch point is currently
                CGPoint point = [recognizer translationInView:self];
                
                if (self.state == ControllerCardStateFullScreen)
                {
                    [self setState:ControllerCardStateDefault animated:YES];
                }
                
                else if (self.state == ControllerCardStateDefault && point.y < -self.deckController.travelPointThresholdUp)
                {
                    [self setState:ControllerCardStateFullScreen animated:YES];
                }
                
                else if (self.state == ControllerCardStateDefault && point.y > self.deckController.travelPointThresholdDown)
                {
                    if ([self isEqual:[[self.deckController allCardsFromDeckContainingCard:self] objectAtIndex:0]])
                    {
                        // Hide every card at the bottom
                        for (CHFControllerCard *card in [self.deckController allCardsFromDeckContainingCard:self])
                        {
                            [card setState:ControllerCardStateHiddenBottom animated:YES];
                        }
                        
                        // Tell the delegate
                        if ([self.delegate respondsToSelector:@selector(topControllerCard:didStopPanningWithReturnState:)])
                        {
                            [self.delegate topControllerCard:self didStopPanningWithReturnState:ControllerCardStateHiddenBottom];
                        }
                    }
                    else
                    {
                        [self setAboveCardToState:ControllerCardStateFullScreen];
                    }
                }
                
            }
            
            if ([self.delegate respondsToSelector:@selector(didStopPanningControllerCard:)])
            {
                [self.delegate didStopPanningControllerCard:self];
            }
            // Toggle state between full screen and default if it doesnt return to the current state
            //                [self setState: self.state == ControllerCardStateFullScreen ? ControllerCardStateDefault : ControllerCardStateFullScreen
            //                      animated:YES];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self setState: self.state animated:YES];
            
            // Let the delegate know we stopped panning the top card
            if ([self.delegate respondsToSelector:@selector(topControllerCard:didStopPanningWithReturnState:)])
            {
                [self.delegate topControllerCard:self didStopPanningWithReturnState:self.state];
            }
        }
            break;
        default:
            break;
    }
}

- (void) didPerformTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Toggle State
        [self toggleStateAnimated:YES];
    }
}

- (void)didPerformPinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            // Reset the last scale, necessary if there are multiple objects with different scales
            self.scale = recognizer.scale;
            
            // Still working on this
            //
            //        CGFloat currentScale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
            //
            //        // Constants to adjust the max/min values of zoom
            //        const CGFloat kMaxScale = 1.05;
            //        const CGFloat kMinScale = self.deckController.cardMaximizedScalingFactor;
            //
            //        CGFloat newScale = 1 -  (self.scale - [recognizer scale]);
            //        newScale = MIN(newScale, kMaxScale / currentScale);
            //        newScale = MAX(newScale, kMinScale / currentScale);
            //        CGAffineTransform transform = CGAffineTransformScale([[recognizer view] transform], newScale, newScale);
            //        [recognizer view].transform = transform;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.scale > 1.5)
            {
                [self setState:ControllerCardStateFullScreen animated:YES];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
            else
            {
                [self setState:ControllerCardStateDefault animated:YES];
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self setState:self.state animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Handle resizing of card

- (void)shortenCard:(BOOL)animated
{
}

- (void)heightenCard:(BOOL)animated
{
}

- (void)shrinkCardToScaledSize:(BOOL)animated
{
    // Set the scaling factor if not already set
    if (!self.scalingFactor)
    {
        self.scalingFactor =  [self.deckController scalingFactorForIndexPath:self.indexPath];
    }
    
    // If animated then animate the shrinking else no animation
    if (animated)
    {
        [UIView animateWithDuration:self.deckController.cardAnimationDuration
                         animations:^{
                             // Slightly recursive to reduce duplicate code
                             [self shrinkCardToScaledSize:NO];
                         }];
    }
    else
    {
        [self setTransform: CGAffineTransformMakeScale(self.scalingFactor, self.scalingFactor)];
    }
}

- (void)expandCardToFullSize:(BOOL)animated
{
    // Set the scaling factor if not already set
    if (!self.scalingFactor)
    {
        self.scalingFactor =  [self.deckController scalingFactorForIndexPath:self.indexPath];
    }
    // If animated then animate the shrinking else no animation
    if (animated)
    {
        [UIView animateWithDuration:self.deckController.cardAnimationDuration
                         animations:^{
                             //Slightly recursive to reduce duplicate code
                             [self expandCardToFullSize:NO];
                         }];
    }
    else
    {
        [self setTransform: CGAffineTransformMakeScale(self.deckController.cardMaximizedScalingFactor, self.deckController.cardMaximizedScalingFactor)];
    }
}

#pragma mark - Handle state changes for card

- (void)setAboveCardToState:(ControllerCardState)state
{
    if ([self.deckController controllerCardsAboveCard:self].count != 0)
    {
        // Grab the last object of the array returned of the cars above this card
        CHFControllerCard *cardAbove = [(NSArray *)[self.deckController controllerCardsAboveCard:self] lastObject];
        
        [UIView animateWithDuration:self.deckController.cardAnimationDuration
                         animations:^{
                             [cardAbove setState:state animated:YES];
                         }];
        return;
    }
}

- (void)setState:(ControllerCardState)state animated:(BOOL)animated
{
    if (animated)
    {
        switch (state)
        {
            case ControllerCardStateDefault:
            {
                [UIView animateWithDuration:self.deckController.dynamicAnimationDuration
                                      delay:0.0
                     usingSpringWithDamping:0.5
                      initialSpringVelocity:0.1
                                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     [self setState:state animated:NO];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
                break;
            default:
            {
                [UIView animateWithDuration:self.deckController.cardAnimationDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [self setState:state animated:NO];
                                 } completion:^(BOOL finished) {
                                     //                                     if (state == ControllerCardStateFullScreen)
                                     //                                     {
                                     //                                         // Fix scaling bug when expand to full size
                                     //                                         CGRect frame = self.deckController.scrollView.frame;
                                     //                                         frame.origin.x = frame.size.width * self.indexPath.section;
                                     //                                         frame.origin.y = self.originY;
                                     //
                                     //                                         self.frame = frame;
                                     //                                         self.viewController.view.frame = self.frame;
                                     //                                         self.viewController.view.layer.cornerRadius = self.deckController.cardCornerRadius;
                                     //                                     }
                                 }];
                
            }
                
                break;
        }
        
        return;
    }
    
    // Set corner radius
    [self.viewController.view.layer setCornerRadius:self.deckController.cardCornerRadius];
    
    switch (state)
    {
        case ControllerCardStateDefault:
        {
            //        if (self.deckController.controllerCards.count != 1)
            {
                [self shrinkCardToScaledSize: animated];
            }
            
            [self setYCoordinate: self.originY];
        }
            break;
        case ControllerCardStateFullScreen:
        {
            //        if (self.deckController.controllerCards.count != 1)
            {
                [self expandCardToFullSize: animated];
            }
            
            [self setYCoordinate: 0];
        }
            break;
        case ControllerCardStateHiddenBottom:
        {
            // Move it off screen and far enough down that the shadow does not appear on screen
            [self setYCoordinate: self.deckController.view.frame.size.height + abs(self.deckController.cardShadowOffset.height) * 3];
        }
            break;
        case ControllerCardStateHiddenTop:
        {
            [self setYCoordinate: 0];
        }
            break;
        default:
            break;
    }
    
    // Notify the delegate of the state change (even if state changed to self)
    ControllerCardState lastState = self.state;
    
    // Update to the new state
    self.state = state;
    
    // Notify the delegate
    if ([self.delegate respondsToSelector:@selector(controllerCard:didChangeToDisplayState:fromDisplayState:)])
    {
        [self.delegate controllerCard:self
              didChangeToDisplayState:state fromDisplayState: lastState];
    }
}

- (void)mimickState:(ControllerCardState)state animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:self.deckController.cardAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self mimickState:state animated:NO];
                         } completion:^(BOOL finished) {
                             if (state == ControllerCardStateFullScreen)
                             {
                                 // Fix scaling bug when expand to full size
                                 CGRect frame = self.deckController.scrollView.frame;
                                 frame.origin.x = frame.size.width * self.indexPath.section;
                                 frame.origin.y = self.originY;
                                 
                                 self.frame = frame;
                                 self.viewController.view.frame = self.frame;
                                 self.viewController.view.layer.cornerRadius = self.deckController.cardCornerRadius;
                             }
                         }];
        return;
    }
    
    // Set corner radius
    [self.viewController.view.layer setCornerRadius:self.deckController.cardCornerRadius];
    
    // Full Screen State
    if (state == ControllerCardStateFullScreen)
    {
        //        if (self.deckController.controllerCards.count != 1)
        {
            [self expandCardToFullSize: animated];
        }
        [self setYCoordinate: 0];
    }
    // Default State
    else if (state == ControllerCardStateDefault)
    {
        //        if (self.deckController.controllerCards.count != 1)
        {
            [self shrinkCardToScaledSize: animated];
        }
        
        [self setYCoordinate: self.originY];
    }
    // Hidden State - Bottom
    else if (state == ControllerCardStateHiddenBottom)
    {
        //Move it off screen and far enough down that the shadow does not appear on screen
        [self setYCoordinate: self.deckController.view.frame.size.height + abs(self.deckController.cardShadowOffset.height)*3];
    }
    // Hidden State - Top
    else if (state == ControllerCardStateHiddenTop)
    {
        [self setYCoordinate: 0];
    }
    
    // Update to the new state
    self.state = state;
}

- (void) toggleStateAnimated:(BOOL)animated
{
    ControllerCardState nextState = self.state == ControllerCardStateDefault ? ControllerCardStateFullScreen : ControllerCardStateDefault;
    [self setState: nextState
          animated: animated];
}

#pragma mark - Various data helpers

- (CGPoint)origin
{
    return CGPointMake(0, self.originY);
}

- (CGFloat)percentageDistanceTravelled
{
    return self.frame.origin.y / self.originY;
}

// Boolean for determining if the movement was sufficient to warrent changing states
- (BOOL) shouldReturnToState:(ControllerCardState) state fromPoint:(CGPoint) point
{
    if (state == ControllerCardStateFullScreen)
    {
        return ABS(point.y) < self.deckController.travelPointThresholdUp;
    }
    else if (state == ControllerCardStateDefault && point.y < -self.deckController.travelPointThresholdUp)
    {
        return point.y > -self.deckController.travelPointThresholdUp;
    }
    else if (state == ControllerCardStateDefault && point.y > self.deckController.travelPointThresholdDown)
    {
        return point.y < self.deckController.travelPointThresholdDown;
    }
    else if (state == ControllerCardStateDefault)
    {
        return point.y > -self.deckController.travelPointThresholdUp;
    }
    
    return NO;
}

- (void)redrawShadow
{
    if (self.deckController.cardShadowEnabled)
    {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.deckController.cardCornerRadius];
        
        self.layer.shadowOpacity = self.deckController.cardShadowOpacity;
        self.layer.shadowOffset = self.deckController.cardShadowOffset;
        self.layer.shadowRadius = self.deckController.cardShadowRadius;
        self.layer.shadowColor = self.deckController.cardShadowColor.CGColor;
        self.layer.shadowPath = [path CGPath];
    }
}

@end
