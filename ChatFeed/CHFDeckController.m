//
//  CHFDeckController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c)2013 Thinkr LLC. All rights reserved.
//

#import "CHFDeckController.h"
#import "CHFNonInteractiveView.h"

// Layout properties
#define kDefaultMinimizedScalingFactor 1     //Amount to shrink each card from the previous one
#define kDefaultMaximizedScalingFactor 1.00     //Maximum a card can be scaled to
#define kDefaultNavigationBarOverlap 0.90       //Defines vertical overlap of each navigation toolbar. Slight hack that prevents rounding errors from showing the whitespace between navigation toolbars. Can be customized if require more/less packing of navigation toolbars

// Animation properties
#define kDefaultAnimationDuration 0.3           //Amount of time for the animations to occur
#define kDefaultDynamicAnimationDuration 1.0    // Max amount of time for the dynamic duration to occur
#define kDefaultReloadHideAnimationDuration 0.4
#define kDefaultReloadShowAnimationDuration 0.6

// Position for the stack of navigation controllers to originate at
#define kDefaultVerticalOrigin 0              //Vertical origin of the controller card stack. Making this value larger/smaller will make the card shift down/up.

// Corner radius properties
#define kDefaultCornerRadius 8.0

// Shadow Properties - Note : Disabling shadows greatly improves performance and fluidity of animations
#define kDefaultShadowEnabled NO
#define kDefaultShadowColor [UIColor blackColor]
#define kDefaultShadowOffset CGSizeMake(0, 0)
#define kDefaultShadowRadius kDefaultCornerRadius
#define kDefaultShadowOpacity 0.50

// Gesture properties
#define kDefaultNumberOfTapsRequired 2

// Distance to top of screen that must be passed in order to toggle full screen state transition
#define kTravelPointThresholdUp 44.0
#define kTravelPointThresholdDown 122.0
#define kAllowsInteractionInDefaultState NO
#define kMoveFullscreenCardToFront YES

// Deck properties
#define kInitialDeckPage 0
#define kEmbedViewControllersInNavigationController YES

// UIDynamic properties
#define kSpringsEnabled NO

// UIMotion Effect
#define kMotionEffectEnabled NO

typedef NS_ENUM (NSUInteger, PageSide)
{
    PageSideLeft = 0,
    PageSideMiddle,
    PageSideRight
};

@interface CHFDeckController ()

// Contains an array for each deck, which contains the view controllers
@property (nonatomic, strong) NSArray *hierarchyArray;

@property (nonatomic, strong) NSMutableArray *sectionContainerArray;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;

// UIDynamic Properties
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) CGFloat oldScrollBounds;

// UIScrollView Helpers
@property (nonatomic) CGFloat lastPercentageScrolled;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger destinationPage;

@property (nonatomic, strong) NSIndexPath *sourceIndexPath;
@property (nonatomic, strong) NSIndexPath *destinationIndexPath;


@end

@implementation CHFDeckController

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (!self)
    {
        return nil;
    }
    
    [self configureDefaultSettings];
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (!self)
    {
        return nil;
    }
    
    [self configureDefaultSettings];
    
    return self;
}

- (void)configureDefaultSettings
{
    self.pagingStyle = ScrollViewPagingStyleSwoopDown;
    
    self.allowsInteractionInDefaultState = kAllowsInteractionInDefaultState;
    self.cardNavigationBarClass = [UINavigationBar class];
    
    self.cardMinimizedScalingFactor = kDefaultMinimizedScalingFactor;
    self.cardMaximizedScalingFactor = kDefaultMaximizedScalingFactor;
    self.cardNavigationBarOverlap = kDefaultNavigationBarOverlap;
    
    self.cardAnimationDuration = kDefaultAnimationDuration;
    self.dynamicAnimationDuration = kDefaultDynamicAnimationDuration;
    self.cardReloadHideAnimationDuration = kDefaultReloadHideAnimationDuration;
    self.cardReloadShowAnimationDuration = kDefaultReloadShowAnimationDuration;
    
    self.cardVerticalOrigin = kDefaultVerticalOrigin;
    
    self.cardCornerRadius = kDefaultCornerRadius;
    
    self.cardShadowEnabled = kDefaultShadowEnabled;
    self.cardShadowColor = kDefaultShadowColor;
    self.cardShadowOffset = kDefaultShadowOffset;
    self.cardShadowRadius = kDefaultShadowRadius;
    self.cardShadowOpacity = kDefaultShadowOpacity;
    
    self.cardGestureOptions = CardGestureOptionAll;
    //    self.cardEnablePressGesture = YES;
    self.cardMinimumTapsRequired = kDefaultNumberOfTapsRequired;
    
    self.cardAutoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |
                                 UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleWidth);
    
    self.travelPointThresholdUp = kTravelPointThresholdUp;
    self.travelPointThresholdDown = kTravelPointThresholdDown;
    
    self.allowsInteractionInDefaultState = kAllowsInteractionInDefaultState;
    
    self.initialDeckPage = kInitialDeckPage;
    self.embedViewControllersInNavigationController = kEmbedViewControllersInNavigationController;
    
    self.springsEnabled = kSpringsEnabled;
}

- (void)loadView
{
    self.view = [[CHFNonInteractiveView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad
{
    // Populate the navigation controllers to the controller stack
    [self updateData];
    
    [super viewDidLoad]; // TODO: switch viewdidload and update data
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.layer.allowsEdgeAntialiasing = YES;
    self.view.layer.allowsGroupOpacity = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldShowNavigationBarWhenAuxiliaryBarIsShowing
{
    return YES;
}

#pragma mark - Property Setters

- (void)setPagingStyle:(ScrollViewPagingStyle)pagingStyle
{
    if (pagingStyle == ScrollViewPagingStyleDynamicSprings)
    {
        self.springsEnabled = YES;
        
        if ([self isDynamicsSupported])
        {
            self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.scrollView];
            _pagingStyle = pagingStyle;
        }
        else // If not dynamics are NOT supported
        {
            self.springsEnabled = NO;
            _pagingStyle = ScrollViewPagingStyleNone;
        }
    }
    else
    {
        self.springsEnabled = NO;
        _pagingStyle = pagingStyle;
    }
}

- (void)setCardVerticalOrigin:(CGFloat)cardVerticalOrigin
{
    _cardVerticalOrigin = cardVerticalOrigin;
    
    // Let the scrollview know
    self.scrollView.cardVerticalOrigin = cardVerticalOrigin;
}

//- (void)setDestinationPage:(NSUInteger)destinationPage
//{
//    _destinationPage = destinationPage >= self.hierarchyArray.count ? self.currentPage : destinationPage;
//}

- (void)setDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.section >= self.hierarchyArray.count)
    {
        _destinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentPage];
    }
    else
    {
        _destinationIndexPath = destinationIndexPath;
    }
}

#pragma mark - ControllerCard Delegate

- (void)controllerCard:(CHFControllerCard *)controllerCard didChangeToDisplayState:(ControllerCardState)toState fromDisplayState:(ControllerCardState)fromState
{
    if (fromState == ControllerCardStateDefault && toState == ControllerCardStateFullScreen)
    {
        // For all cards above the current card move them
        for (CHFControllerCard *currentCard in [self controllerCardsAboveCard:controllerCard])
        {
            [currentCard setState:ControllerCardStateHiddenTop animated:YES];
        }
        
        for (CHFControllerCard *currentCard in [self controllerCardsBelowCard:controllerCard])
        {
            [currentCard setState:ControllerCardStateHiddenBottom animated:YES];
        }
    }
    else if (fromState == ControllerCardStateFullScreen && toState == ControllerCardStateDefault)
    {
        // For all cards above the current card move them back to default state
        for (CHFControllerCard *currentCard in [self controllerCardsAboveCard:controllerCard])
        {
            [currentCard setState:ControllerCardStateDefault animated:YES];
        }
        
        // For all cards below the current card move them back to default state
        for (CHFControllerCard *currentCard in [self controllerCardsBelowCard:controllerCard])
        {
            [currentCard setState:ControllerCardStateHiddenBottom animated:NO];
            [currentCard setState:ControllerCardStateDefault animated:YES];
        }
    }
    else if (fromState == ControllerCardStateDefault && toState == ControllerCardStateDefault)
    {
        // If the current state is default and the user does not travel far enough to kick into a new state, then  return all cells back to their default state
        for (CHFControllerCard *cardBelow in [self controllerCardsBelowCard:controllerCard])
        {
            [cardBelow setState:ControllerCardStateDefault animated:YES];
        }
    }
    
    // Let the scrollview know what state
    self.scrollView.cardState = toState;
    
    // Notify the delegate of the change
    [self deckController:self
 didUpdateControllerCard:controllerCard
          toDisplayState:toState
        fromDisplayState:fromState];
}

- (void)controllerCard:(CHFControllerCard *)controllerCard didUpdatePanPercentage:(CGFloat)percentage
{
    switch (controllerCard.state)
    {
        case ControllerCardStateDefault:
        {
            for (CHFControllerCard *currentCard in [self controllerCardsBelowCard: controllerCard])
            {
                CGFloat deltaDistance = controllerCard.frame.origin.y - controllerCard.origin.y;
                CGFloat yCoordinate = currentCard.origin.y + deltaDistance;
                [currentCard setYCoordinate: yCoordinate];
            }
        }
            break;
        case ControllerCardStateFullScreen:
        {
            for (CHFControllerCard *currentCard in [self controllerCardsAboveCard: controllerCard])
            {
                CGFloat yCoordinate = (CGFloat)currentCard.origin.y * [controllerCard percentageDistanceTravelled];
                [currentCard setYCoordinate: yCoordinate];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Deck Helpers

- (CGFloat)defaultVerticalOriginForControllerCard:(CHFControllerCard *)controllerCard atIndexPath:(NSIndexPath *)indexPath
{
    // Sum up the shrunken size of each of the cards appearing before the current index
    CGFloat originOffset = 0;
    
    for (NSUInteger i = 0; i < indexPath.row; i ++)
    {
        CGFloat scalingFactor = [self scalingFactorForIndexPath:indexPath];
        originOffset += scalingFactor * self.travelPointThresholdUp * self.cardNavigationBarOverlap;
    }
    
    // Position should start at self.cardVerticalOrigin and move down by size of nav toolbar for each additional nav controller
    return roundf(self.cardVerticalOrigin + originOffset);
}

- (CGFloat)scalingFactorForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfCardsInDeck = [self deckController:self numberOfControllerCardsInDeckAtIndex:indexPath.section];
    
    // Items should get progressively smaller based on their index in the navigation controller array
    return  powf(self.cardMinimizedScalingFactor, (numberOfCardsInDeck - indexPath.row));
}

- (UIView *)sectionContainerViewAtIndex:(NSUInteger)index
{
    return [self.sectionContainerArray objectAtIndex:index];
}

// Returns the controller cards above the given card
- (NSArray *)controllerCardsAboveCard:(CHFControllerCard *)card
{
    NSArray *deckArray = [self allCardsFromDeckContainingCard:card];
    
    return [deckArray filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(CHFControllerCard *controllerCard, NSDictionary *bindings)
             {
                 NSIndexPath *cardIndexPath = [self indexPathForCard:card];
                 NSIndexPath *currentCardIndexPath = [self indexPathForCard:controllerCard];
                 
                 //Only return cards with an index less than the one being compared to
                 return cardIndexPath.row > currentCardIndexPath.row;
             }]];
}

// Returns the controller cards below the given card
- (NSArray *)controllerCardsBelowCard:(CHFControllerCard *)card
{
    NSArray *deckArray = [self allCardsFromDeckContainingCard:card];
    
    return [deckArray filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(CHFControllerCard *controllerCard, NSDictionary *bindings)
             {
                 NSIndexPath *cardIndexPath = [self indexPathForCard:card];
                 NSIndexPath *currentCardIndexPath = [self indexPathForCard:controllerCard];
                 
                 // Only return cards with an index less than the one being compared to
                 return cardIndexPath.row < currentCardIndexPath.row;
             }]];
}

- (NSArray *)controllerCardsWithinDeckWithoutCard:(CHFControllerCard *)card
{
    NSArray *deckArray = [self allCardsFromDeckContainingCard:card];
    
    return [deckArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CHFControllerCard *controllerCard, NSDictionary *bindings) {
        // Only return cards that are not equal to the parameter card
        return controllerCard != card;
    }]];
}

- (NSArray *)allCardsFromAllDecksWithoutCard:(CHFControllerCard *)card
{
    NSArray *deckArray = [self allCardsFromAllDecks];
    
    return [deckArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CHFControllerCard *controllerCard, NSDictionary *bindings) {
        // Only return cards that are not equal to the parameter card
        return controllerCard != card;
    }]];
}

- (NSArray *)cardsInDeckAtIndex:(NSUInteger)deckIndex
{
    NSMutableArray *cardArray = [@[] mutableCopy];
    
    for (NSUInteger cardIndex = 0; cardIndex < [self deckController:self numberOfControllerCardsInDeckAtIndex:deckIndex]; cardIndex++)
    {
        [cardArray addObject:[self cardAtIndexPath:[NSIndexPath indexPathForRow:cardIndex inSection:deckIndex]]];
    }
    
    return cardArray;
}

- (NSArray *)allCardsFromDeckContainingCard:(CHFControllerCard *)card
{
    NSIndexPath *cardIndex = [self indexPathForCard:card];
    
    return self.hierarchyArray[cardIndex.section];
}

- (NSIndexPath *)indexPathForCard:(CHFControllerCard *)card
{
    for (NSUInteger deckIndex = 0; deckIndex < [self numberOfDecksInDeckController:self]; deckIndex++)
    {
        NSArray *deckArray = self.hierarchyArray[deckIndex];
        
        for (NSUInteger cardIndex = 0; cardIndex < deckArray.count; cardIndex++)
        {
            CHFControllerCard *controllerCard = deckArray[cardIndex];
            
            if ([card isEqual:controllerCard])
            {
                return [NSIndexPath indexPathForRow:cardIndex inSection:deckIndex];
            }
        }
    }
    
    return nil;
}

- (CHFControllerCard *)cardAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSUInteger deckIndex = 0; deckIndex < [self numberOfDecksInDeckController:self]; deckIndex++)
    {
        NSArray *deckArray = self.hierarchyArray[deckIndex];
        
        for (NSUInteger cardIndex = 0; cardIndex < deckArray.count; cardIndex++)
        {
            CHFControllerCard *controllerCard = deckArray[cardIndex];
            
            if ([[NSIndexPath indexPathForRow:cardIndex inSection:deckIndex] isEqual:indexPath])
            {
                return controllerCard;
            }
        }
    }
    
    return nil;
}

- (CHFControllerCard *)cardAtIndexPath:(NSIndexPath *)indexPath inDeckAtIndex:(NSUInteger)deckIndex
{
    NSArray *deckArray = self.hierarchyArray[deckIndex];
    
    for (NSUInteger cardIndex = 0; cardIndex < deckArray.count; cardIndex++)
    {
        CHFControllerCard *controllerCard = deckArray[cardIndex];
        
        if ([[NSIndexPath indexPathForRow:cardIndex inSection:deckIndex] isEqual:indexPath])
        {
            return controllerCard;
        }
    }
    
    return nil;
}

- (NSArray *)allCardsFromAllDecks
{
    NSMutableArray *cardsArray = [@[] mutableCopy];
    
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [cardsArray addObject:card];
        }
    }
    
    return cardsArray;
}

- (NSInteger)currentDeck
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger deckPage = ((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    return deckPage;
}

//- (UIViewController *)viewControllerForCurrentCardInCurrentDeck
//{
//    CHFControllerCard *card = [self cardAtIndexPath:0 inDeckAtIndex:[self currentPageInCurrentDeck]];
//
//    return [self ]
//}

//TODO: currentViewController

#pragma mark - Deck Methods

- (void)updateData
{
    // Setup the scrollview
    self.scrollView = nil;
    [self configureScrollView];
    
    // Get the total amount of decks
    NSUInteger totalDecks = [self numberOfDecksInDeckController:self];
    
    // Here we start to build up the hierarchy. This array will hold the decks which hold their cards.
    NSMutableArray *hierarchy = [[NSMutableArray alloc] initWithCapacity:totalDecks];
    
    // Deck loop
    for (NSUInteger deckIndex = 0; deckIndex < [self numberOfDecksInDeckController:self]; deckIndex++)
    {
        // Get the total amount of cards in the deck
        NSUInteger totalCardsInDeck = [self deckController:self numberOfControllerCardsInDeckAtIndex:deckIndex];
        
        // Make an array to hold the cards for this deck
        NSMutableArray *deckArray = [[NSMutableArray alloc] initWithCapacity:totalCardsInDeck];
        
        // Card loop
        for (NSUInteger cardIndex = 0; cardIndex < totalCardsInDeck; cardIndex++)
        {
            UIViewController *viewController = [self deckController:self
                                   viewControllerForDeckAtIndexPath:[NSIndexPath indexPathForRow:cardIndex inSection:deckIndex]];
            
            if ([self deckController:self embedCardInNavigationControllerAtIndexPath:[NSIndexPath indexPathForRow:cardIndex inSection:deckIndex]])
            {
                viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
                NSLog(@"NAVIGATOIN ROOT == %@", viewController);
            }
            
            CHFControllerCard *controllerCard = [[CHFControllerCard alloc] initWithDeckController:self
                                                                                   viewController:viewController
                                                                                        indexPath:[NSIndexPath indexPathForRow:cardIndex
                                                                                                                     inSection:deckIndex]];
            
            [controllerCard setDelegate:self];
            
            [deckArray addObject:controllerCard];
            
            [[self sectionContainerViewAtIndex:deckIndex] addSubview:controllerCard];
            
            // Add the top view controller as a child view controller
            [self addChildViewController:viewController];
            
            // As child controller will call the delegate methods for UIViewController
            [viewController didMoveToParentViewController:self];
            
            [controllerCard setState:ControllerCardStateDefault
                            animated:NO];
            
            
        }
        
        [hierarchy addObject:deckArray];
    }
    
    self.hierarchyArray = [hierarchy copy];
}

- (void)updateDataAnimated:(BOOL)animated
{
    if (animated)
    {
        NSArray *cardsArray = [self allCardsFromAllDecks];
        
        [UIView animateWithDuration:self.cardReloadHideAnimationDuration
                         animations:^{
                             for (CHFControllerCard *card in cardsArray)
                             {
                                 [card setState:ControllerCardStateHiddenBottom animated:NO];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                             [self updateData];
                             [self reloadInputViews];
                             
                             for (CHFControllerCard *card in cardsArray)
                             {
                                 [card setState:ControllerCardStateHiddenBottom animated:NO];
                             }
                             
                             [UIView animateWithDuration:self.cardReloadShowAnimationDuration animations:^{
                                 for (CHFControllerCard *card in cardsArray)
                                 {
                                     [card setState:ControllerCardStateDefault animated:NO];
                                 }
                             }];
                         }];
    }
    else
    {
        [self updateData];
    }
}

- (void)reloadInputViews
{
    [super reloadInputViews];
    
    // First remove all of the navigation controllers from the view to avoid redrawing over top of views
    [self removeControllerCardFromSuperView];
    
    // Add the navigation controllers to the view
    [self.hierarchyArray enumerateObjectsUsingBlock:^(NSArray *deckArray, NSUInteger deckIndex, BOOL *stop)
     {
         for (CHFControllerCard *controllerCard in deckArray)
         {
             [[self sectionContainerViewAtIndex:deckIndex] addSubview:controllerCard];
         }
     }];
}

- (void)moveAllCardsToState:(ControllerCardState)theState animated:(BOOL)animated
{
    // Add the navigation controllers to the view
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [card setState:theState animated:animated];
        }
    }
}

- (void)showCard:(CHFControllerCard *)card withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    [self showView:card withAnimation:transitionAnimation];
}

- (void)hideCard:(CHFControllerCard *)card withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    [self hideView:card withAnimation:transitionAnimation];
}

- (void)showAllCardsWithAnimation:(ViewTransitionAnimation)transitionAnimation
{
    // Add the navigation controllers to the view
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [self showView:card withAnimation:transitionAnimation];
        }
    }
}

- (void)hideAllCardsWithAnimation:(ViewTransitionAnimation)transitionAnimation
{
    // Add the navigation controllers to the view
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [self hideView:card withAnimation:transitionAnimation];
        }
    }
}

- (void)showCards:(NSArray *)cards withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    for (CHFControllerCard *card in cards)
    {
        [self showView:card withAnimation:transitionAnimation];
    }
}

- (void)hideCards:(NSArray *)cards withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    for (CHFControllerCard *card in cards)
    {
        [self hideView:card withAnimation:transitionAnimation];
    }
}

- (void)mimickCard:(CHFControllerCard *)card toState:(ControllerCardState)theState animated:(BOOL)animated
{
    NSArray *cardArray = [self allCardsFromAllDecksWithoutCard:card];
    
    for (CHFControllerCard *mimickCard in cardArray)
    {
        [card setState:theState animated:animated];
    }
}

- (void)moveCards:(NSArray *)cards toState:(ControllerCardState)theState animated:(BOOL)animated
{
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [card setState:theState animated:animated];
        }
    }
}

- (void)removeControllerCardFromSuperView
{
    for (NSArray *deckArray in self.hierarchyArray)
    {
        for (CHFControllerCard *card in deckArray)
        {
            [card.viewController willMoveToParentViewController:nil];
            [card removeFromSuperview];
        }
    }
}

- (void)moveCardToFront:(CHFControllerCard *)card
{
    NSUInteger deckIndex = [self indexPathForCard:card].section;
    
    // Give the cardsInDeck the card objects to enumerate through as we modify the heirarchy array
    NSMutableArray *cardsInDeck = [[self allCardsFromDeckContainingCard:card] mutableCopy];
    
    // Remove the card object from the array since we will be removing these items from the heirarchy array
    [cardsInDeck removeObject:card];
    
    for (CHFControllerCard *cardObject in cardsInDeck.reverseObjectEnumerator)
    {
        // Remove the objects that was passed to the cardsInDeck
        [(NSMutableArray *)[self cardsInDeckAtIndex:deckIndex] removeObject:cardObject];
        
        // Insert the object in its new index. The card passed in by the parameter has been retained in the controllerCards array. We add the other objects back in before it.
        [(NSMutableArray *)[self cardsInDeckAtIndex:deckIndex] insertObject:cardObject atIndex:0];
    }
    
    // Now that the controllerCards array is in its new order we can update the cards
    for (CHFControllerCard *cardObject in (NSMutableArray *)[self cardsInDeckAtIndex:deckIndex])
    {
        // Update the index
        NSIndexPath *indexPath = [self indexPathForCard:cardObject];
        
        // Update the orgin for we the card need to return to when its in its default state
        CGFloat originY = [self defaultVerticalOriginForControllerCard:cardObject atIndexPath:indexPath];
        
        [cardObject setOriginY:originY andCardIndexPath:indexPath];
        
        // For every card that is NOT the card going fullscreen, we need to scale the size so when we go back to default we dont see them morph into the new size.
        if (![cardObject isEqual:card])
        {
            // Shrink the card without animation
            [cardObject shrinkCardToScaledSize:NO];
        }
        
        // We need to reverse the z index of the stack
        [self.view bringSubviewToFront:cardObject];
    }
    
    // Get rid of the cardsInDeck since its not needed anymore
    cardsInDeck = nil;
    
    // Let the delegate know of the change
    [self deckController:self didMoveCardToFront:card];
}

#pragma mark - DeckController DataSource

// If the controller is subclassed it will allow these values to be grabbed by the subclass. If not sublclassed it will grab from the assigned datasource.
- (NSUInteger) numberOfDecksInDeckController:(CHFDeckController *)deckController
{
    return [self.dataSource numberOfDecksInDeckController:deckController];
}

- (NSInteger) deckController:(CHFDeckController *)deckController numberOfControllerCardsInDeckAtIndex:(NSUInteger)deckIndex
{
    return [self.dataSource deckController:deckController numberOfControllerCardsInDeckAtIndex:deckIndex];
}

- (UIViewController *) deckController:(CHFDeckController *)deckController viewControllerForDeckAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource deckController:deckController viewControllerForDeckAtIndexPath:indexPath];
}

#pragma mark Optional
- (BOOL)deckController:(CHFDeckController *)deckController embedCardInNavigationControllerAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(deckController:embedCardInNavigationControllerAtIndexPath:)])
    {
        return [self.dataSource deckController:deckController embedCardInNavigationControllerAtIndexPath:indexPath];
    }
    
    return self.embedViewControllersInNavigationController;
}

#pragma mark - DeckController Delegate
#pragma mark Optional
- (void)deckController:(CHFDeckController *)deckController
didUpdateControllerCard:(CHFControllerCard *)controllerCard
        toDisplayState:(ControllerCardState)toState
      fromDisplayState:(ControllerCardState)fromState
{
    // Make the other cards take the same action
    //    [self mimickCard:controllerCard toState:toState animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(deckController:didUpdateControllerCard:toDisplayState:fromDisplayState:)])
    {
        [self.delegate deckController:self
              didUpdateControllerCard:controllerCard
                       toDisplayState:toState
                     fromDisplayState:fromState];
    }
}

- (void)deckController:(CHFDeckController *)deckController didMoveToDeckIndex:(NSUInteger)index
{
    self.currentPageInCurrentDeck = index;
    
    if ([self.delegate respondsToSelector:@selector(deckController:didMoveToDeckIndex:)])
    {
        [self.delegate deckController:deckController didMoveToDeckIndex:index];
    }
}

- (void)deckController:(CHFDeckController *)deckController didMoveCardToFront:(CHFControllerCard *)card
{
    if ([self.delegate respondsToSelector:@selector(deckController:didMoveCardToFront:)])
    {
        [self.delegate deckController:deckController didMoveCardToFront:card];
    }
}

#pragma mark -
#pragma mark -
#pragma mark -

- (void)configurePageViewControllerWithItems:(NSArray *)items
{
    if (!self.pageController)
    {
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:@{UIPageViewControllerOptionInterPageSpacingKey : @(10)}];
        self.pageController.dataSource = self;
        self.pageController.delegate = self;
    }
}

#pragma mark -
#pragma mark -
#pragma mark -


#pragma mark - ScrollView Method

- (void)configureScrollView
{
    if (!self.scrollView)
    {
        NSUInteger numberOfDecks = [self numberOfDecksInDeckController:self];
        
        CGRect frame = self.view.bounds;
        
        self.scrollView = [[CHFDeckScrollView alloc] initWithFrame:frame];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.directionalLockEnabled = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfDecks, self.scrollView.frame.size.height);
        self.scrollView.cardState = ControllerCardStateDefault;
        self.scrollView.cardVerticalOrigin = self.cardVerticalOrigin;
        
        // Section Containers
        NSMutableArray *sectionContainers = [[NSMutableArray alloc] initWithCapacity:numberOfDecks];
        
        for (NSUInteger index = 0; index < numberOfDecks; index++)
        {
            CGPoint offsetOrigin = CGPointMake(frame.size.width * index, frame.origin.y);
            frame.origin = offsetOrigin;
            
            CHFNonInteractiveView *sectionContainerView = [[CHFNonInteractiveView alloc] initWithFrame:frame];
            
            [sectionContainers addObject:sectionContainerView];
            
            [self.scrollView addSubview:sectionContainerView];
            
            if (self.pagingStyle == ScrollViewPagingStyleDynamicSprings)
            {
                [self addSpringToView:sectionContainerView];
            }
        }
        
        self.sectionContainerArray = [sectionContainers copy];
        
        [self moveToDeckIndex:self.initialDeckPage animated:NO];
        
        [self.view addSubview:self.scrollView];
    }
}

- (void)moveToDeckIndex:(NSUInteger)deckIndex animated:(BOOL)animated
{
    // Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * deckIndex;
    frame.origin.y = 0;
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

#pragma mark Delegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.frame.size.width;
    CGFloat contentOffset = scrollView.contentOffset.x;
    //    CGFloat endOfContent = scrollView.contentSize.width;
    CGFloat offset = contentOffset / width;
    //    NSInteger numberOfPages = endOfContent / width;
//    NSUInteger currentPageFromCenter = floor((offset - width / 2) / width) + 1;
    CGFloat currentPageFromOrigin;
    CGFloat percentage;
    
    percentage = modff(offset, &currentPageFromOrigin);
    
    // Direction of scrolling
    PanDirection direction = percentage < self.lastPercentageScrolled ? PanDirectionRight: PanDirectionLeft;
    
    // Set the current page once the page is at its content offset
    if ((int)contentOffset % (int)width == 0)
    {
        int page = contentOffset / width;
        
        if (self.currentPage != page)
        {
            self.currentPage = page;
        }
    }
    
    // Let the delegate know we did move to new deck index
    if ([self.delegate respondsToSelector:@selector(deckController:didMoveToDeckIndex:)])
    {
        [self deckController:self didMoveToDeckIndex:self.currentPage];
    }
    
    // Get which side of the current page you are on. ### Would be real cool if there was an "Unless" operator
    PageSide nearestDestinationSide;
    
    if (offset == (float)self.currentPage)
    {
        nearestDestinationSide = PageSideMiddle;
    }
    else
    {
        if (offset < (float)self.currentPage)
        {
            nearestDestinationSide = PageSideLeft;
        }
        else
        {
            nearestDestinationSide = PageSideRight;
        }
    }
    
    NSLog(@"the heirarcy count = %i", self.hierarchyArray.count);
    
    switch (nearestDestinationSide)
    {
        case PageSideMiddle:
        {
            if (self.destinationPage != self.currentPage)
            {
                self.destinationPage = self.currentPage;
            }
        }
            break;
            
        case PageSideLeft:
        {
            percentage = 1 - percentage;
            
            NSLog(@"in case left");
            
            if (self.currentPage == 0)
            {
                NSLog(@"on the left side of first page");
                self.destinationPage = self.currentPage;
            }
            else if (self.destinationPage != self.currentPage - 1)
            {
                NSLog(@"in else if left");
                self.destinationPage = self.currentPage - 1;
            }
        }
            break;
            
        case PageSideRight:
        {
            NSLog(@"in case right");
            if (self.currentPage == self.hierarchyArray.count - 1)
            {
                NSLog(@"on the right side of last page");
                self.destinationPage = self.currentPage;
            }
            else if (self.destinationPage != self.currentPage + 1)
            {
                NSLog(@"in else if");
                self.destinationPage = self.currentPage + 1;
            }
        }
            break;
    }
    
    // Set the destinationIndexPath if needed.
    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentPage];
    NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.destinationPage];
    
    // If the destinationIndexPath is not already the destination, update
    if (self.destinationPage != self.currentPage)
    {
        // Let the delegate know the scrollview scrolled
        if ([self.delegate respondsToSelector:@selector(deckController:didScrollWithPercentage:inDirection:toViewController:)])
        {
            [self.delegate deckController:self
                  didScrollWithPercentage:percentage
                              inDirection:direction
                         toViewController:[self deckController:self viewControllerForDeckAtIndexPath:destinationIndexPath]];
        }
        
        //
        if (![self.destinationIndexPath isEqual:destinationIndexPath])
        {
            self.destinationIndexPath = destinationIndexPath;
            NSLog(@"self.destinationIndexPath = %@", self.destinationIndexPath);
            UIViewController *destinationViewController = [self deckController:self viewControllerForDeckAtIndexPath:destinationIndexPath];
            
            // Tell the delegate that the DestinationViewController has changed
            if ([self.delegate respondsToSelector:@selector(deckController:didChangeToDestinationViewController:)])
            {
                [self.delegate deckController:self didChangeToDestinationViewController:destinationViewController];
            }
            
            
            if ([self.delegate respondsToSelector:@selector(deckController:didStartDraggingTowardsViewController:fromViewController:withPercentage:)])
            {
                UIViewController *sourceViewController = [self deckController:self viewControllerForDeckAtIndexPath:sourceIndexPath];
                
                [self.delegate deckController:self
        didStartDraggingTowardsViewController:destinationViewController
                           fromViewController:sourceViewController
                               withPercentage:percentage];
            }
        }
    }
    
    
    
    
    
    
    
//    NSLog(@"Current Page = %i, directin = %i, Percentage = %f, destination page = %i, nearest side = %i, current page form origin = %f, offset = %f", self.currentPage, direction, percentage, self.destinationPage, nearestDestinationSide, currentPageFromOrigin, offset);
    
    // Update the last percentage scrolled, which is used to calculate scrolling direction
    self.lastPercentageScrolled = percentage;
    
    // Apply the paging trasitions
    switch (self.pagingStyle)
    {
        case ScrollViewPagingStyleNone:
            break;
        case ScrollViewPagingStyleSwoopDown:
            [self pagingStyleSwoopDown];
            break;
        case ScrollViewPagingStyleHoverOverRight:
            [self pagingStyleHoverOverRight];
            break;
        case ScrollViewPagingStyleDynamicSprings:
            [self updateSprings];
            break;
        default:
            NSAssert(self.pagingStyle, @"pagingStyle not set");
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didEndScrollingDeckController:withDestinationViewController:)])
    {
        NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.destinationPage];
        
        [self.delegate didEndScrollingDeckController:self
                       withDestinationViewController:[self deckController:self
                                         viewControllerForDeckAtIndexPath:destinationIndexPath]];
    }
}

#pragma mark Show/Hide Methods

- (void)showScrollViewWithAnimation:(ViewTransitionAnimation)transitionAnimation
{
    [self showView:self.scrollView withAnimation:transitionAnimation];
}

- (void)hideScrollViewWithAnimation:(ViewTransitionAnimation)transitionAnimation
{
    [self hideView:self.scrollView withAnimation:transitionAnimation];
}

- (void)showView:(UIView *)view withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case ViewTransitionAnimationNone:
        {
            self.scrollView.layer.transform = CATransform3DIdentity;
            self.scrollView.alpha = 0.0;
            self.scrollView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
        }
            break;
        case ViewTransitionAnimationFade:
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
        case ViewTransitionAnimationScale:
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
        case ViewTransitionAnimationScaleFade:
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
    
    self.scrollViewHidden = NO;
}

- (void)hideView:(UIView *)view
   withAnimation:(ViewTransitionAnimation)transitionAnimation
{
    switch (transitionAnimation)
    {
        case ViewTransitionAnimationNone:
        {
            self.scrollView.layer.transform = CATransform3DIdentity;
            self.scrollView.alpha = 0.0;
            self.scrollView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0f);
        }
            break;
        case ViewTransitionAnimationFade:
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
        case ViewTransitionAnimationScale:
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
        case ViewTransitionAnimationScaleFade:
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
    
    self.scrollViewHidden = YES;
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

- (BOOL)isDynamicsSupported
{
    NSString *minVersion = @"7.0";
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    if (([version compare:minVersion options:NSNumericSearch] != NSOrderedAscending) && self.isSpringsEnabled)
    {
        return YES;
    }
    
    return NO;
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

@interface CHFDeckScrollView ()

@end

@implementation CHFDeckScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self removeGestureRecognizer:self.pinchGestureRecognizer];
    
    //    if (!self.pinchRecognizer)
    //    {
    //        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
    //                                                                         action:@selector(pinch:)];
    //        [self addGestureRecognizer:self.pinchRecognizer];
    //    }
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        for (UIView *view in self.subviews)
        {
            view.userInteractionEnabled = NO;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        for (UIView *view in self.subviews)
        {
            view.userInteractionEnabled = NO;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        for (UIView *view in self.subviews)
        {
            view.userInteractionEnabled = YES;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        for (UIView *view in self.subviews)
        {
            view.userInteractionEnabled = YES;
        }
    }
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//
//}

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
