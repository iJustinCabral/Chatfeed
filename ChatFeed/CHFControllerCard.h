//
//  CHFControllerCard.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/3/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@class CHFDeckController;

typedef NS_ENUM (NSUInteger, ControllerCardState)
{
    ControllerCardStateHiddenBottom,    // Card is hidden off screen (Below bottom of visible area)
    ControllerCardStateHiddenTop,       // Card is hidden off screen (At top of visible area)
    ControllerCardStateDefault,         // Default location for the card
    ControllerCardStateFullScreen       // Highlighted location for the card
};

@protocol ControllerCardDelegate;

@interface CHFControllerCard : UIView

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, weak) CHFDeckController *deckController;
@property (nonatomic, weak) id <ControllerCardDelegate> delegate;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat panOriginOffset;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat scaleOriginOffset;

@property (nonatomic) ControllerCardState state;

- (instancetype)initWithDeckController:(CHFDeckController *)deckController
        viewController:(UIViewController *)viewController
                   indexPath:(NSIndexPath *)indexPath;

- (void)toggleStateAnimated:(BOOL)animated;
- (void)setState:(ControllerCardState)state animated:(BOOL)animated;
- (void)mimickState:(ControllerCardState)state animated:(BOOL)animated;
- (void)setAllCardsToState:(ControllerCardState)state animated:(BOOL)animated;

- (void)setYCoordinate:(CGFloat)yValue;
- (CGFloat)percentageDistanceTravelled;

- (void)setOriginY:(CGFloat)originY andCardIndexPath:(NSIndexPath *)cardIndexPath;

- (void)shrinkCardToScaledSize:(BOOL)animated;

@end

@protocol ControllerCardDelegate <NSObject>

@optional
//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from ControllerCardStateDefault to ControllerCardStateDefault)
- (void)controllerCard:(CHFControllerCard *)controllerCard didChangeToDisplayState:(ControllerCardState)toState fromDisplayState:(ControllerCardState)fromState;

//Called when user is panning and a the card has travelled X percent of the distance to the top - Used to redraw other cards during panning fanout
- (void) controllerCard:(CHFControllerCard *)controllerCard didUpdatePanPercentage:(CGFloat)percentage;
- (void) controllerCard:(CHFControllerCard *)controllerCard willBeginPanningGesture:(UIPanGestureRecognizer *) gesture;
- (void) controllerCard:(CHFControllerCard *)controllerCard didEndPanningGesture:(UIPanGestureRecognizer *) gesture;

// Called when the user pans the top card. It is used to interact with a view in the delegate
- (void) topControllerCard:(CHFControllerCard *)controllerCard didUpdatePanPercentage:(CGFloat)percentage;
- (void) topControllerCard:(CHFControllerCard *)controllerCard didStopPanningWithReturnState:(ControllerCardState)returnState;

- (void) didBeginPanningControllerCard:(CHFControllerCard *)controllerCard;
- (void) didStopPanningControllerCard:(CHFControllerCard *)controllerCard;

@end
