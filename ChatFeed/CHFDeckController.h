//
//  CHFDeckController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c)2013 Thinkr LLC. All rights reserved.
//

@import UIKit;
@import QuartzCore;

#import "CHFControllerCard.h"

typedef NS_ENUM (NSUInteger, ScrollViewPagingStyle)
{
    ScrollViewPagingStyleNone = 0,
    ScrollViewPagingStyleSwoopDown = 1,
    ScrollViewPagingStyleHoverOverRight = 2,
    ScrollViewPagingStyleDynamicSprings = 3
};

typedef NS_ENUM (NSUInteger, ViewTransitionAnimation)
{
    ViewTransitionAnimationNone = 0,
    ViewTransitionAnimationScale = 1,
    ViewTransitionAnimationFade = 2,
    ViewTransitionAnimationScaleFade = 3
};

//typedef NS_ENUM (NSUInteger, ControllerCardGestureScope)
//{
//    ControllerCardGestureScopePanNavigationBar,     // Pan the navigationbar to go to state fullscreen or state default
//    ControllerCardGestureScopePanView,              // Pan card to go to state fullscreen or state default
//    ControllerCardGestureScopePinchView             // Pinch card to go to state fullscreen or state default
//};


typedef NS_OPTIONS (NSUInteger, CardGestureOption)
{
    CardGestureOptionAll = 0,
    CardGestureOptionNavigationPan = (1 << 0),
    CardGestureOptionNavigationTap = (1 << 1),
    CardGestureOptionNavigationPinch = (1 << 2),
    CardGestureOptionViewPan = (1 << 3),
    CardGestureOptionViewTap = (1 << 4),
    CardGestureOptionViewPinch = (1 << 5)
};

typedef void (^transitionStateBlock)(UIViewController *viewController, ControllerCardState fromState, ControllerCardState);

@class CHFDeckScrollView;

@protocol DeckControllerDelegate, DeckControllerDataSource;


#pragma mark - CHFDeckController Interface
@interface CHFDeckController : UIViewController <UIScrollViewDelegate, ControllerCardDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

#pragma mark - Properties
@property (nonatomic, copy) transitionStateBlock stateTransitionBlock;
@property (nonatomic, assign) id <DeckControllerDataSource> dataSource;
@property (nonatomic, assign) id <DeckControllerDelegate> delegate;

// Navigation bar properties
@property (nonatomic, strong) Class cardNavigationBarClass; //Use a custom class for the card navigation bar

// Layout properties
@property (nonatomic) CGFloat cardMinimizedScalingFactor;   //Amount to shrink each card from the previous one
@property (nonatomic) CGFloat cardMaximizedScalingFactor;   //Maximum a card can be scaled to
@property (nonatomic) CGFloat cardNavigationBarOverlap;     //Defines vertical overlap of each navigation toolbar. Slight hack that prevents rounding errors from showing the whitespace between navigation toolbars. Can be customized if require more/less packing of navigation toolbars

// Animation properties
@property (nonatomic) NSTimeInterval cardAnimationDuration;             // Amount of time for the animations to occur
@property (nonatomic) NSTimeInterval dynamicAnimationDuration;          // Max amount of time for the dynamic animation duration to occur
@property (nonatomic) NSTimeInterval cardReloadHideAnimationDuration;
@property (nonatomic) NSTimeInterval cardReloadShowAnimationDuration;

// Position for the stack of navigation controllers to originate at
@property (nonatomic) CGFloat cardVerticalOrigin;           //Vertical origin of the controller card stack. Making this value larger/smaller will make the card shift down/up.

// Corner radius properties
@property (nonatomic) CGFloat cardCornerRadius;

// Shadow Properties - Deck : Disabling shadows greatly improves performance and fluidity of animations
@property (nonatomic) BOOL cardShadowEnabled;
@property (nonatomic) UIColor *cardShadowColor;
@property (nonatomic) CGSize cardShadowOffset;
@property (nonatomic) CGFloat cardShadowRadius;
@property (nonatomic) CGFloat cardShadowOpacity;

// Gesture properties
@property (nonatomic) CardGestureOption cardGestureOptions;
@property (nonatomic) NSInteger cardMinimumTapsRequired;

// Autoresizing mask used for the card controller
@property (nonatomic) UIViewAutoresizing cardAutoresizingMask;

// Distance to top of screen that must be passed in order to toggle full screen state transition
@property (nonatomic) CGFloat travelPointThresholdUp;
@property (nonatomic) CGFloat travelPointThresholdDown;

// UIScrollView Subview in Controller
@property (nonatomic) BOOL allowsInteractionInDefaultState;

// Deck properties
@property (nonatomic) NSUInteger initialDeckPage;
@property (nonatomic) NSInteger currentDeckPage;
@property (nonatomic) BOOL embedViewControllersInNavigationController;

//** ScrollView

@property (nonatomic, strong) UIPageViewController *pageController;

@property (nonatomic, strong) CHFDeckScrollView *scrollView;
// Show/Hide properties
@property (nonatomic) BOOL scrollViewHidden;
// Animation Properties
@property (nonatomic) ScrollViewPagingStyle pagingStyle;
@property (nonatomic) ViewTransitionAnimation transitionAnimation;
// Dynamic Properties
@property (nonatomic, getter = isSpringsEnabled)BOOL springsEnabled;


// Holds the decks in the scrollview
//@property (nonatomic, strong)NSArray *deckArray;
//// CHFControllerCards in an array. Object at index 0 will appear at bottom of the stack, and object at position (size-1)will appear at the top
//@property (nonatomic, strong)NSArray *controllerCardArray;


#pragma mark - Deck Helpers
// Number of deck along the scrollview
- (NSUInteger)numberOfDecksInDeckController:(CHFDeckController *)deckController;
// Number of controller cards for the deck at indexPath
- (NSInteger)deckController:(CHFDeckController *)deckController numberOfControllerCardsInDeckAtIndex:(NSUInteger)deckIndex;
// Called to populate the controllerCards array - Automatically adds to array, and embeds a CHFControllerCard in a UINavigationController if that card should be embeded.
- (UIViewController *)deckController:(CHFDeckController *)deckController viewControllerForDeckAtIndexPath:(NSIndexPath *)indexPath;
// Return yes if you want the card to be embedded in a UINavigationController. Default is NO.
- (BOOL)deckController:(CHFDeckController *)deckController embedCardInNavigationControllerAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Deck Methods
// Repopulates all data for the controllerCards array
- (void)updateData;
- (void)updateDataAnimated:(BOOL)animated;

- (void)moveToDeckIndex:(NSUInteger)deckIndex animated:(BOOL)animated;
- (void)deckController:(CHFDeckController *)deckController didMoveToDeckIndex:(NSUInteger)index;
- (void)showScrollViewWithAnimation:(ViewTransitionAnimation)transitionAnimation;
- (void)hideScrollViewWithAnimation:(ViewTransitionAnimation)transitionAnimation;

#pragma mark - Card Helpers
- (CGFloat)scalingFactorForIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)defaultVerticalOriginForControllerCard:(CHFControllerCard *)controllerCard atIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)allCardsFromDeckContainingCard:(CHFControllerCard *)card;
- (NSArray *)controllerCardsAboveCard:(CHFControllerCard *)card;
- (NSArray *)controllerCardsBelowCard:(CHFControllerCard *)card;

#pragma mark - Card Methods
// State
- (void)deckController:(CHFDeckController *)deckController
didUpdateControllerCard:(CHFControllerCard *)controllerCard
         toDisplayState:(ControllerCardState)toState
       fromDisplayState:(ControllerCardState)fromState;

- (void)mimickCardState:(ControllerCardState)state animated:(BOOL)animated;
- (void)moveAllCardsToState:(ControllerCardState)theState animated:(BOOL)animated;
- (void)moveCards:(NSArray *)cards toState:(ControllerCardState)theState animated:(BOOL)animated;

//
- (void)showCard:(CHFControllerCard *)card withAnimation:(ViewTransitionAnimation)transitionAnimation;
- (void)hideCard:(CHFControllerCard *)card withAnimation:(ViewTransitionAnimation)transitionAnimation;
- (void)showCards:(NSArray *)cards withAnimation:(ViewTransitionAnimation)transitionAnimation;
- (void)hideCards:(NSArray *)cards withAnimation:(ViewTransitionAnimation)transitionAnimation;

//
- (void)moveCardToFront:(CHFControllerCard *)card;
- (void)deckController:(CHFDeckController *)deckController didMoveCardToFront:(CHFControllerCard *)card;

@end

#pragma mark - Deck DataSource
@protocol DeckControllerDataSource <NSObject>

// Number of deck along the scrollview
- (NSUInteger)numberOfDecksInDeckController:(CHFDeckController *)deckController;
// Number of controller cards for the deck at indexPath
- (NSInteger)deckController:(CHFDeckController *)deckController numberOfControllerCardsInDeckAtIndex:(NSUInteger)deckIndex;
// Called to populate the controllerCards array - Automatically adds to array, and embeds a CHFControllerCard in a UINavigationController if that card should be embeded.
- (UIViewController *)deckController:(CHFDeckController *)deckController viewControllerForDeckAtIndexPath:(NSIndexPath *)indexPath;

@optional
// Return yes if you want the card to be embedded in a UINavigationController. Default is NO.
- (BOOL)deckController:(CHFDeckController *)deckController embedCardInNavigationControllerAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Deck Delegate
@protocol DeckControllerDelegate <NSObject>

@optional
// Called on any time a state change has occured - even if a state has changed to itself - (i.e. from ControllerCardStateDefault to ControllerCardStateDefault)
- (void)deckController:(CHFDeckController *)deckController
didUpdateControllerCard:(CHFControllerCard *)controllerCard
        toDisplayState:(ControllerCardState)toState
      fromDisplayState:(ControllerCardState)fromState;

- (void)deckController:(CHFDeckController*)deckController didMoveToDeckIndex:(NSUInteger)index;
- (void)deckController:(CHFDeckController *)deckController didMoveCardToFront:(CHFControllerCard *)card;

@end


#pragma mark - CHFDeckSrollView Interface
@interface CHFDeckScrollView : UIScrollView

@property (nonatomic) ControllerCardState cardState;
@property (nonatomic) CGFloat cardVerticalOrigin;

@end
