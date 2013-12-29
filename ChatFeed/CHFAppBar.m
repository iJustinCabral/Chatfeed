//
//  CHFAppBar.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppBar.h"
#import "CHFNotificationBar.h"
#import "CHFAppBarScrollView.h"

#import "UIView+AutoLayout.h"
#import "UICollectionView+Additions.h"

static CGFloat const kDragActionReload = 0.34; // Percentage limit to trigger the reload action
static CGFloat const kDragActionBackToTop = 0.50; // Percentage limit to trigger the btt action
static CGFloat const kDragActionFullscreen = -0.12; // Percentage limit to trigger the fullscreeen action
static CGFloat const kDragActionFadeThreshold = 0.10; // Threshold for fade in/out
static CGFloat const kDragActionViewHeight = 240.0; // Threshold for fade in/out

static CGFloat const kMinimalizatioMaximumPointsPastMinLock = 200.0; // Maximum number of points//TODO: HARD TO EXPLAIN NEED TO TRY AGAIN
static CGFloat const kMinimalizationInteractionVelocity = 900; // Points per second needed to cause interaction
static BOOL const kMinimalizationUsesInteractionVelocity = NO; // Turns I/O the velocity option and leaves it to the PointsBeforeInteraction
static CGFloat const kMinimalizationAnimationVelocity = 400;

static CGFloat const kAnimationDuration = 0.6;
static NSString * const kCell = @"Cell";


@interface CHFAppBar () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSArray *barViewArray;

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic) UIView *actionView;
@property (nonatomic) UIView *fakeStatusBar;

@property (nonatomic) AppBarViewType currentViewType;
@property (nonatomic) AppBarViewType minimalizationLockViewType;
@property (nonatomic) CGFloat minimalizationPointsPastMinLock; // Once the appBar minimalizes and hits the minLock, we keep track of how many points are scrolled up to the kMinimalizationPointsBeforeInteraction
@property (nonatomic, readwrite, getter = isMinimalized) BOOL minimalized; // The minimalization velocity looks for this to be YES to initiate showing the appbar

@property (nonatomic, readwrite, getter = isHidden) BOOL hidden; // When apps in fullscreen
@property (nonatomic, readwrite, getter = isDragging) BOOL dragging;
@property (nonatomic, readwrite, getter = isStatusBarFaked) BOOL statusBarFaked;

@end


@implementation CHFAppBar

#pragma mark - Lifecycle

- (instancetype)init
{
    return [self initWithBarView:nil];
}

- (instancetype)initWithBarView:(CHFAppBarView *)barView
{
    self = [super init];
    if (self)
    {
        [self initializer];
        
        self.barViewArray = barView ? @[barView] : @[];
    }
    return self;
}

- (void)initializer
{
    self.shouldAnimateWhenAppearing = NO; // Broken
    self.shouldDrag = YES;
    self.currentViewType = AppBarViewTypeNotification;
    self.minimalizationLockViewType = AppBarViewTypeNotification;
}


- (void)loadView
{
    self.view = [[CHFShadowCouplingView alloc] initWithFrame:AppContainer.view.bounds
                                                    blurType:BlurTypeDark
                                               withAnimation:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    if (self.shouldAnimateWhenAppearing)
    {
        [self updateAppBarFrameHidden];
    }
    //    [self drawGradientOnLayer:self.view.layer];
    
    // Add tap gestures to the app bar
    [self configureGestureRecognizers];
    
    // Make the Notification and Action Bar Views. The App container takes care of the NavigationBarView.
    [self printBarArray];
    [self addBarViews:@[[self notificationBarView], [self actionBarView], [self auxiliaryBarView]]];
    [self printBarArray];
    // Setup the collectionView which holds our barViews
    [self configureCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateAppBarFrameMaxLock];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Adjust the contentOffset to show the correct barViewType
    // Comes in late since the collectionview need to appear before we can calculate where to update the content to. Might try to determine by getting all the barView heights and calculating it
    [self updateContentOffset];
    
    if (self.shouldAnimateWhenAppearing)
    {
        [self showAppBar:YES withTransition:AppBarTransitionSlide];
    }
    else
    {
        [self updateAppBarFrameMaxLock];
    }
}

- (void)updateUI
{
    if (self.collectionView)
    {
        [self updateContentOffset];
    }
}

- (void)printBarArray
{
    NSLog(@"---------------------------------");
    NSLog(@" the count = %i", self.barViewArray.count);
    for (CHFAppBarView *barView in self.barViewArray)
    {
        NSLog(@"%@", NSStringFromAppBarViewType(barView.barViewtype));
    }
    NSLog(@"---------------------------------");
}

#pragma mark - Properties

- (void)setHidden:(BOOL)hidden
{
    if (hidden == _hidden) return;
    
    _hidden = hidden;
    
    AppContainer.fullScreen = hidden;
    [AppDelegate hideStatusBar:hidden withAnimation:UIStatusBarAnimationFade];
    
    if (hidden)
    {
        [(CHFShadowCouplingView *)self.view removeShadowAnimated:YES];
        
        // Doesn't work prob wouldnt want anyway
        /*
         UIScreenEdgePanGestureRecognizer *swipeInAppBarGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeFromTop:)];
         swipeInAppBarGesture.edges = UIRectEdgeTop;
         swipeInAppBarGesture.delegate = self;
         
         [self.view addGestureRecognizer:swipeInAppBarGesture];
         //*/
    }
    else
    {
        [(CHFShadowCouplingView *)self.view drawShadowAnimated:YES];
    }
}

#pragma mark - Gradient Drawing

- (void)drawGradientOnLayer:(CALayer *)layer
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.6] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], nil];
    [layer insertSublayer:gradient atIndex:0];
}

#pragma mark - AbstactModel CollectionView methods

- (void)collectionViewModel:(CHFAbstractModel *)model
     didUpdateContentOffset:(CGFloat)contentOffset
           withOffsetChange:(CGFloat)change
{
    // The contentOffset is quirky. Stable as of now but was returning pos and neg values at the same time. The contentOffset is also reversed. It's neg when it should be pos
    
    //    NSLog(@"-----------------------------------------");
    NSLog(@"the reg offset = %f", contentOffset);
    
    // currentOffset + maxHiehgt = 0 for contentOffset
    
    if (self.collectionViewDragging)
    {
        if ([self appBarVisibleHeight] >= 74)
        {
            
            NSLog(@"the content offset = %f", fabsf(contentOffset));
            [self updateAppBarFrameForHeight:fabsf(contentOffset)];
            [self updateContentOffsetWithOffset:fabsf(contentOffset)];
        }
    }
    
    //    NSLog(@"-----------------------------------------");
}

- (void)beganDraggingCollectionViewModel:(CHFAbstractModel *)model
                             inDirection:(PanDirection)direction
                            withVelocity:(CGPoint)velocity
{
    self.collectionViewDragging = YES;
}

- (void)endedDraggingCollectionViewModel:(CHFAbstractModel *)model
                             inDirection:(PanDirection)direction
                            withVelocity:(CGPoint)velocity
{
    self.collectionViewDragging = NO;
    
    if (velocity.y > kMinimalizationAnimationVelocity) return;
    
    CGFloat heightForMinLock = Settings.statusBarEnabled ? [self heightForBarViewType:self.minimalizationLockViewType] : 0;
    CGFloat heightForMaxLock = [self heightForVisibleBarViews];
    
    CGFloat heightToBeHidden = heightForMaxLock - heightForMinLock;
    CGFloat currentHeight = [self appBarVisibleHeight] - heightForMinLock;
    
    CGFloat percentage = currentHeight / heightToBeHidden;
    
    if (percentage < 0.5)
    {
        [self transitionToMinLockWithVelocity:velocity];
    }
    else
    {
        [self transitionToMaxLockWithVelocity:velocity];
    }
}

#pragma mark - CollectionView

- (void)configureCollectionView
{
    if (!self.collectionView)
    {
        // Layout
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        // Collection View
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                 collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.scrollEnabled = NO;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[UICollectionViewCell class]
                forCellWithReuseIdentifier:kCell];
        
        [self.view addSubview:self.collectionView];
    }
    
    [self printBarArray];
}

#pragma mark DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.barViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:1.000 alpha:0.210];
    [cell.contentView addSubview:[self barViewForBarViewType:indexPath.row]];
}

#pragma mark FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(AppContainer.view.frame);
    CHFAppBarView *barView = [self barViewForBarViewType:indexPath.row];
    
    return CGSizeMake(width, barView.frame.size.height);
}


#pragma mark - BarView
#pragma mark Management

- (void)addBarView:(CHFAppBarView *)barView
{
    self.barViewArray = [self sortBarViewsForArray:[self.barViewArray arrayByAddingObject:barView]];
}

- (void)addBarViews:(NSArray *)views
{
    self.barViewArray = [self sortBarViewsForArray:[self.barViewArray arrayByAddingObjectsFromArray:views]];
}

- (void)addView:(UIView *)view withBarViewType:(AppBarViewType)barViewType
{
    CHFAppBarView *barView = [[CHFAppBarView alloc] initWithType:barViewType andView:view];
    
    [self addBarView:barView];
}

- (NSArray *)sortBarViewsForArray:(NSArray *)array
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortKey"
                                                 ascending:NO];
    return [array sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)clearBarViewType:(AppBarViewType)barViewType
{
    for (CHFAppBarView *barView in self.barViewArray)
    {
        if (barView.barViewtype == barViewType && [barView isKindOfClass:[CHFAppBarView class]])
        {
            [self clearBarView:barView];
        }
    }
}

- (void)clearBarView:(CHFAppBarView *)barView
{
    if ([self.delegate respondsToSelector:@selector(willClearAuxiliaryViewForAppBar:)])
    {
        [self.delegate willClearAuxiliaryViewForAppBar:self];
    }
    
    if ([barView isKindOfClass:[CHFAppBarScrollView class]])
    {
        [(CHFAppBarScrollView *)barView clearBarViews];
    }
    else
    {
        for (UIView *view in barView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didClearAuxiliaryViewForAppBar:)])
    {
        [self.delegate didClearAuxiliaryViewForAppBar:self];
    }
}

#pragma mark Transitions

- (void)showAppBar:(BOOL)show
    withTransition:(AppBarTransition)transition
{
    switch (transition)
    {
        case AppBarTransitionFade:
        {
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.view.layer.opacity = show ? 1.0: 0.0;
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
                                 show ? [self updateAppBarFrameMaxLock] : [self updateAppBarFrameHidden];
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
            break;
    }
    
    self.hidden = show ? NO : YES;
}

- (void)transitionToMinLockWithVelocity:(CGPoint)velocity
{
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAppBarFrameMinLock];
                         [self updateContentOffset];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)transitionToMaxLockWithVelocity:(CGPoint)velocity
{
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAppBarFrameMaxLock];
                         [self updateContentOffset];
                     }
                     completion:^(BOOL finished) {
                         
                         [self removeFakeStatusBarAnimated:NO];
                     }];
}


- (void)transitionToFullScreenWithVelocity:(CGPoint)velocity
{
    if (self.isDragging) return;
    
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAppBarFrameHidden];
                         [self updateContentOffset];
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
}

- (void)transitionToBarViewType:(AppBarViewType)barViewType
{
    if (self.isDragging) return;
    
    self.currentViewType = barViewType;
    
    switch (barViewType)
    {
        case AppBarViewTypeAction:
        {
            //            self.currentViewType = AppBarViewTypeAction;
        }
            break;
        case AppBarViewTypeNotification:
        {
            
        }
            break;
        case AppBarViewTypeNavigation:
        {
            
        }
            break;
        case AppBarViewTypeAuxiliary:
        {
            
        }
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self updateAppBarFrameMaxLock];
                         [self updateContentOffset];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)transitionToNotificationBar
{
    if (self.isDragging) return;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self updateAppBarFrameMaxLock];
                         [self updateContentOffset];
                     }];
}

- (void)transitionFromNotificationbar
{
    if (self.isDragging) return;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self updateAppBarFrameMaxLock];
                         [self updateContentOffset];
                     }];
}

- (void)interactiveTransitionToAuxiliaryViewWithPercentage:(CGFloat)percentage
{
    if (self.isDragging) return;
    
    CHFAppBarView *barView = [self barViewForBarViewType:AppBarViewTypeAuxiliary];
    
    if (!barView) return;
    
    CGFloat auxiliaryHeight = barView.frame.size.height;
    
    CGFloat offset = auxiliaryHeight * percentage;
    
    [self updateAppBarFrameWithInteractionOffset:offset];
}

- (void)interactiveTransitionFromAuxiliaryViewWithPercentage:(CGFloat)percentage
{
    if (self.isDragging) return;
    
    CHFAppBarView *barView = [self barViewForBarViewType:AppBarViewTypeAuxiliary];
    
    if (!barView) return;
    
    CGFloat auxiliaryHeight = barView.frame.size.height;
    
    percentage = 1 - percentage;
    
    CGFloat offset = auxiliaryHeight * percentage;
    
    [self updateAppBarFrameWithInteractionOffset:offset];
}

- (void)interactiveTransitionToMinimalizationInDirection:(PanDirection)direction
                                              withOffset:(CGFloat)offset
                                             andVelocity:(CGPoint)velocity
{
    if (self.isDragging || !Settings.isAppBarMinimalizationEnabled || self.hidden) return;
    
    //TODO: Check if near top of collectionView and have the appBar expand early
    //TODO: Set and lock content inset
    //TODO: ScreenShot statusbar
    //FIXME: If the user scroll super fast (extreme velocity) the appBar minimizes to far then goes back to the minLock value
    
    // Get the height of the barView of which we minimalize to, and get the total of the height of the active bar views for the max height
    CGFloat heightForMinLock = Settings.statusBarEnabled ? [self heightForBarViewType:self.minimalizationLockViewType] : 0;
    NSLog(@"heightForMinLock %f",heightForMinLock);
    CGFloat heightForMaxLock = [self heightForVisibleBarViews];
    
    if (kMinimalizationUsesInteractionVelocity)
    {
        // Check if the appBar is minimalized and if it is we check if the velocity is fast enough to start to expand.
        if (direction == PanDirectionDown && velocity.y < kMinimalizationInteractionVelocity && self.isMinimalized)
        {
            return;
        }
    }
    else
    {
        // Since kMinimalizationUsesInteractionVelocity is NO, it means we are using the PointsPastMinLock method of hiding the appBar
        if ([self appBarVisibleHeight] <= heightForMinLock && self.isMinimalized)
        {
            self.minimalizationPointsPastMinLock -= offset;
            
            if (self.minimalizationPointsPastMinLock > kMinimalizatioMaximumPointsPastMinLock)
            {
                self.minimalizationPointsPastMinLock = kMinimalizatioMaximumPointsPastMinLock;
            }
            else if (self.minimalizationPointsPastMinLock < 0)
            {
                self.minimalizationPointsPastMinLock = 0;
            }
        }
    }
    
    // Here we check if the height is either the at the minLock or maxLock height. If the height is at the minLock height and the user is scrolling up, we need to return since the height is already where it needs to be. Now if the height is still at the minLock and the user scrolls down, we need to proceed forward and change the height. When it hits the maxLock it is the same situation but opposite.
    if ((direction == PanDirectionUp && [self appBarVisibleHeight] == heightForMinLock) ||
        (direction == PanDirectionDown && [self appBarVisibleHeight] == heightForMaxLock))
    {
        return;
    }
    
    // If the height is less than the minLock we set the height to the minLock
    if ([self appBarVisibleHeight] < heightForMinLock)
    {
        [self updateAppBarFrameForHeight:heightForMinLock];
    }
    // If the height is more than the maxLock we set the height to the maxLock
    else if ([self appBarVisibleHeight] > heightForMaxLock)
    {
        [self updateAppBarFrameForHeight:heightForMaxLock];
    }
    // Here we are in between the minLock and maxLock locking thresholds so we can change the height freely
    else
    {
        if (self.minimalizationPointsPastMinLock == 0 || kMinimalizationUsesInteractionVelocity)
        {
            [self updateAppBarFrameWithInteractionAdditive:offset];
        }
    }
    
    // Check to see if the the height is at the the minLock point, if it is, set the minimalized lock to YES.
    if ([self appBarVisibleHeight] == heightForMinLock)
    {
        if (!self.isMinimalized)
        {
            self.minimalized = YES;
        }
    }
    else
    {
        if (self.isMinimalized)
        {
            self.minimalized = NO;
        }
    }
}

#pragma mark Helpers

- (CHFAppBarView *)barViewForBarViewType:(AppBarViewType)viewType
{
    for (CHFAppBarView *barView in self.barViewArray)
    {
        if (barView.barViewtype == viewType && [barView isKindOfClass:[CHFAppBarView class]])
        {
            if (viewType == AppBarViewTypeAuxiliary)
            {
//                self.auxiliaryBarScrollView
            }
            else
            {
                return barView;
            }
        }
    }
    
    return nil;
}

// Get the height of a specific bar view
- (CGFloat)heightForBarViewType:(AppBarViewType)barViewType
{
    CHFAppBarView *barView = [self barViewForBarViewType:barViewType];
    return CGRectGetHeight(barView.frame);
}

// This returns the height for every active bar view. This is NOT returning the height of the current visible height, thats appBarVisibleHeight
- (CGFloat)heightForVisibleBarViews
{
    if (self.isHidden) return 0;
    
    CGFloat appBarVisibleHeight = 0;
    
    // Notification Bar / Status Bar
    CHFAppBarView *notificationBarView = [self barViewForBarViewType:AppBarViewTypeNotification];
    
    if (notificationBarView)
    {
        // We are either showing the notification bar which takes place of the status bar when displaying, or if the status bar is showiwing
        if (TopNotificationBar.isShowingNotifications)
        {
            appBarVisibleHeight += CGRectGetHeight(TopNotificationBar.frame);
        }
        else if (Settings.statusBarEnabled) //![AppDelegate statusBarIsHidden]
        {
            appBarVisibleHeight += 20;
        }
    }
    
    // Navigation
    CHFAppBarView *navigationBarView = [self barViewForBarViewType:AppBarViewTypeNavigation];
    
    if (navigationBarView)
    {
        appBarVisibleHeight += CGRectGetHeight(navigationBarView.frame);
    }
    
    return appBarVisibleHeight;
}

// Looks at all of the visible bar view and determines the visible height onscreen
- (CGFloat)appBarMaximumVisibleOffset
{
    CGRect superBounds = self.view.superview.bounds;
    CGFloat superHeight = superBounds.size.height;
    CGFloat difference = superHeight - [self heightForVisibleBarViews];
    CGFloat offset = superBounds.origin.y - difference;
    
    return offset;
}

// Returns the visible height of where ever the current frame is
- (CGFloat)appBarVisibleHeight
{
    return [self visibleHeightForFrame:self.view.frame];
}

- (CGFloat)visibleHeightForFrame:(CGRect)frame
{
    CGFloat height = frame.size.height;
    CGFloat yAxis = frame.origin.y;
    
    CGFloat visibleHeight = fabsf(height) - fabsf(yAxis);
    
    return visibleHeight;
}

// Calculate the collectionView contentOffset needed to have the wanted cell's edge to touch the views edge
- (CGFloat)calculateContentOffsetForBarViewType:(AppBarViewType)barViewType
{
    CGFloat bottomOfView = CGRectGetMinY(self.collectionView.frame);
    CGFloat bottomOfCell = [self.collectionView edgeAxisValueForCellAtIndex:barViewType
                                                                  inSection:0
                                                                    forEdge:CellEdgeTop];
    
    CGFloat offset = -(bottomOfView - bottomOfCell);
    
    return offset;
}

#pragma mark Methods

// Update the appBar visible height by adding to it's existing yAxis
- (void)updateAppBarFrameWithInteractionAdditive:(CGFloat)additive
{
    [self.view setYWithAdditive:additive];
    [self updateAppBarBounds];
}

// Update the appBar visible height by adding an offset to a predefined appBarVisibleHeight
- (void)updateAppBarFrameWithInteractionOffset:(CGFloat)offset
{
    self.view.y = [self appBarMaximumVisibleOffset] + offset;
    [self updateAppBarBounds];
}

// Update the appBar to a defined visible height
- (void)updateAppBarFrameForHeight:(CGFloat)height
{
    CGRect bounds = self.view.superview.bounds;
    CGFloat offset = bounds.size.height - height;
    bounds.origin.y -= offset;
    self.view.frame = bounds;
    
    [self updateAppBarBounds];
}

// Update the appBar visible height by the predefined appBarVisibleHeight (Refresh AppBar)
- (void)updateAppBarFrameMaxLock
{
    self.view.y = [self appBarMaximumVisibleOffset];
    [self updateAppBarBounds];
}

// Gets the current frame and update the bounds
- (void)updateAppBarBounds
{
    // Updating the bounds causes the frame to update. Here we get the frame before the bounds change and then assign it back.
    CGRect frameBeforeBoundsChange = self.view.frame;
    CGRect updatedBounds = frameBeforeBoundsChange;
    updatedBounds.size = AppDelegate.window.frame.size;
    
    self.view.bounds = updatedBounds;
    self.view.frame = frameBeforeBoundsChange;
    
    if ([self.delegate respondsToSelector:@selector(didUpdateAppBar:toHeight:)])
    {
        [self.delegate didUpdateAppBar:self
                              toHeight:[self appBarVisibleHeight]];
    }
}

// Update the appBar to its hidden offscreen frame
- (void)updateAppBarFrameHidden
{
    self.view.y = -self.view.height;
    [self updateAppBarBounds];
}

- (void)updateAppBarFrameMinLock
{
    [self updateAppBarFrameForHeight:Settings.statusBarEnabled ? [self heightForBarViewType:self.minimalizationLockViewType] : 0];
}

// Updates the collectionView Content Offset to the current barViewType
- (void)updateContentOffset
{
    CHFAppBarView *notificationBarView = [self barViewForBarViewType:AppBarViewTypeNotification];
    
    if (notificationBarView)
    {
        // We are either showing the notification bar which takes place of the status bar when displaying, or if the status bar is showiwing
        if (TopNotificationBar.isShowingNotifications)
        {
            self.collectionView.contentOffsetY = [self calculateContentOffsetForBarViewType:AppBarViewTypeNotification];
            
            return;
        }
        
        else if (Settings.statusBarEnabled) //![AppDelegate statusBarIsHidden]
        {
            self.collectionView.contentOffsetY = [self calculateContentOffsetForBarViewType:AppBarViewTypeNotification];
            
            return;
        }
    }
    
    // Navigation
    CHFAppBarView *navigationBarView = [self barViewForBarViewType:AppBarViewTypeNavigation];
    
    if (navigationBarView)
    {
        self.collectionView.contentOffsetY = [self calculateContentOffsetForBarViewType:AppBarViewTypeNavigation];
        
        return;
    }
    
    // Auxiliary
    CHFAppBarView *auxiliaryBarView = [self barViewForBarViewType:AppBarViewTypeAuxiliary];
    
    if (auxiliaryBarView)
    {
        self.collectionView.contentOffsetY = [self calculateContentOffsetForBarViewType:AppBarViewTypeAuxiliary];
        
        return;
    }
}

- (void)updateContentOffsetWithInteractionAdditive:(CGFloat)additive
{
    [self.collectionView setContentOffsetYWithAdditive:additive];
}

// Update the appBar visible height by adding an offset to a predefined appBarVisibleHeight
- (void)updateContentOffsetWithOffset:(CGFloat)offset
{
    [self.collectionView setContentOffsetYWithAdditive:-offset];
}

#pragma mark - NotificationBar

- (void)addNotificationBar
{
    [self addBarView:[self notificationBarView]];
}

- (CHFAppBarView *)notificationBarView
{
    CHFNotificationBar *notificationBar = [CHFNotificationBar sharedTopNotificationBar];
    notificationBar.delegate = self;
    
    return [[CHFAppBarView alloc] initWithType:AppBarViewTypeNotification andView:notificationBar];
}

#pragma mark Delegate

- (void)didBeginShowingNotificationsFromNotificationBar:(CHFNotificationBar *)notificationBar
{
    // The notifications are about to start displaying so we need to hide the fake status bar if we are dragging. If we are Not dragging we need to hide the system status bar
    
    [self transitionToNotificationBar];
    
    if (!Settings.statusBarEnabled) return;
    
    if (self.statusBarFaked)
    {
        [self hideFakeStatusBarAnimated:YES withCompletion:^{
            
        }];
    }
    else
    {
        [AppDelegate hideStatusBar:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)didEndShowingNotificationsFromNotificationBar:(CHFNotificationBar *)notificationBar
{
    // Once the notifications are done displaying, if the status bar is enabled and we are dragging we have to show the fake status bar. If we are NOT dragging we need to show the systems status bar
    [self transitionFromNotificationbar];
    
    if (!Settings.statusBarEnabled) return;
    
    if (self.isStatusBarFaked)
    {
        [self showFakeStatusBarAnimated:YES];
    }
    else
    {
        [AppDelegate hideStatusBar:NO withAnimation:UIStatusBarAnimationFade];
    }
}

#pragma mark - StatusBar

- (void)addFakeStatusBarAnimated:(BOOL)animated
{
    if (self.fakeStatusBar) return;
    
    self.fakeStatusBar = [AppDelegate statusBarSnapshot];
    
    if (!TopNotificationBar.isShowingNotifications)
    {
        [self showFakeStatusBarAnimated:animated];
        
        [AppDelegate hideStatusBar:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    self.statusBarFaked = YES;
}

- (void)removeFakeStatusBarAnimated:(BOOL)animated
{
    [self hideFakeStatusBarAnimated:animated
                     withCompletion:^{
                         self.fakeStatusBar = nil;
                         [AppDelegate hideStatusBar:NO withAnimation:UIStatusBarAnimationNone];
                     }];
    
    self.statusBarFaked = NO;
}

- (void)showFakeStatusBarAnimated:(BOOL)animated
{
    if (!self.fakeStatusBar.superview)
    {
        CHFAppBarView *notificationBarView = [self barViewForBarViewType:AppBarViewTypeNotification];
        
        [notificationBarView addSubview:self.fakeStatusBar];
    }
    
    if (animated)
    {
        self.fakeStatusBar.layer.opacity = 0.0;
        
        [UIView animateWithDuration:.48
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.fakeStatusBar.layer.opacity = 1.0;
                         }
                         completion:nil];
    }
}

- (void)hideFakeStatusBarAnimated:(BOOL)animated withCompletion:(void (^)(void))completion
{
    if (animated)
    {
        [UIView animateWithDuration:.48
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.fakeStatusBar.layer.opacity = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self.fakeStatusBar removeFromSuperview];
                             completion();
                         }];
    }
    else
    {
        [self.fakeStatusBar removeFromSuperview];
        completion();
    }
}

#pragma mark - AuxiliaryBar

- (CHFAppBarScrollView *)auxiliaryBarView
{
    self.auxiliaryBarScrollView = [CHFAppBarScrollView new];
    self.auxiliaryBarScrollView.barViewtype = AppBarViewTypeAuxiliary;
    
    return self.auxiliaryBarScrollView;
}

#pragma mark - ActionBar

- (void)addActionBar
{
    [self addBarView:[self actionBarView]];
}

- (CHFAppBarView *)actionBarView
{
    if (!self.actionView)
    {
        self.actionView = [[UIView alloc] initWithFrame:[self actionViewFrame]];
        
        self.actionView.backgroundColor = [UIColor chatFeedGreen];
        self.actionView.layer.opacity = 0.0;
        
        return [[CHFAppBarView alloc] initWithType:AppBarViewTypeAction andView:self.actionView];
    }
    
    return nil;
}

- (CGRect)actionViewFrame
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = kDragActionViewHeight;
    
    return frame;
}

- (CGPathRef)reloadActionPath
{
    UIBezierPath *rect = [UIBezierPath bezierPath];
    return [rect CGPath];
}

//- (CGPathRef)backToTopActionPath
//{
//    UIBezierPath *triangle = [UIBezierPath bezierPath];
//
//    CGRect frame = CGRectMake(0, 0, , <#CGFloat height#>)
//
//    CHFTriangleLayer *layer = [[CHFTriangleLayer alloc] init];
//    CGMutablePathRef path = CGPathCreateMutable();
//
//    // Start From top left, going clockwise...
//    CGPathMoveToPoint(path, NULL, 0, 0);
//
//
//            CGPathAddLineToPoint(path, NULL, frame.size.width, 0); // Top Right
//            CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height); // Bottom Right
//
//            CGPathAddLineToPoint(path, NULL, offset + (depth / 2), frame.size.height); // Bottom Right of triangle
//            CGPathAddLineToPoint(path, NULL, offset, frame.size.height - depth); // Top of triangle
//            CGPathAddLineToPoint(path, NULL, offset - (depth / 2), frame.size.height); // Bottom Left of triangle
//
//            CGPathAddLineToPoint(path, NULL, 0, frame.size.height); // Bottom Left
//
//
//    CGPathCloseSubpath(path); // Close off path
//    [layer setPath:path];
//    CGPathRelease(path);
//
//    return [triangle CGPath];
//}

- (AppBarAction)stateWithPercentage:(CGFloat)percentage
{
    AppBarAction state = AppBarActionNormal;
    
    if (percentage >= kDragActionReload)
        state = AppBarActionReloadData;
    
    if (percentage >= kDragActionBackToTop)
        state = AppBarActionBackToTop;
    
    if (percentage <= -kDragActionFullscreen)
        state = AppBarActionFullscreen;
    
    return state;
}

- (void)updateActionBarIconWithPercentage:(CGFloat)percentage
{
    CGFloat fadeIncrementValue = (kDragActionReload - kDragActionFadeThreshold) / 10;
    //    CGFloat changeColorIncrementValue = (kDragActionBackToTop - kDragActionReload) / 10;
    //    NSLog(@"the test x = %f, fadein = %f", x, fadeInIncrementValue);
    //    CGFloat fadeInIncrementValue = (100 / (kDragActionReload - kDragActionFadeThreshold)) / 100;
    
    if (percentage >= kDragActionReload - kDragActionFadeThreshold && percentage < kDragActionReload)
    {
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

- (CGFloat)percentageWithOffset:(CGFloat)offset
               relativeToHeight:(CGFloat)height
{
    CGFloat percentage = offset / height;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

#pragma mark - UIGestureRecognizers

- (void)configureGestureRecognizers
{
    //TODO: This has a slow single tap response when double tap is enabled. Need to use touchesBegan.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAppBarWithSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    /*
     UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAppBarWithDoubleTap:)];
     doubleTap.numberOfTapsRequired = 2;
     [self.view addGestureRecognizer:doubleTap];
     
     
     [singleTap requireGestureRecognizerToFail:doubleTap];
     */
    
    // Add a pan gesture to the app bar
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedAppBar:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

#pragma mark Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.shouldDrag) return NO;
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        // We notify the delegate that we just started dragging
        if ([self.delegate respondsToSelector:@selector(didStartDraggingAppBar:inDirection:)])
        {
            CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view];
            
            [self.delegate didStartDraggingAppBar:self
                                      inDirection:PanDirectionFromVelocity(velocity)];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)tappedAppBarWithSingleTap:(UITapGestureRecognizer *)panGesture
{
    if ([self.delegate respondsToSelector:@selector(didSingleTapAppBar:)])
    {
        [self.delegate didSingleTapAppBar:self];
    }
}

- (void)tappedAppBarWithDoubleTap:(UITapGestureRecognizer *)panGesture
{
    if ([self.delegate respondsToSelector:@selector(didDoubleTapAppBar:)])
    {
        [self.delegate didDoubleTapAppBar:self];
    }
}

- (void)pannedAppBar:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:panGesture.view];
    
    [panGesture setTranslation:CGPointZero inView:panGesture.view.superview];
    
    CGPoint updatedTranslation = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + translation.y);
    
    CGFloat radiusY = panGesture.view.frame.size.height / 2;
    
    CGRect updatedFrame = panGesture.view.frame;
    updatedFrame.origin.y = updatedTranslation.y - radiusY;
    
    CGRect updatedBounds = updatedFrame;
    updatedBounds.size = panGesture.view.superview.frame.size;
    
    CGPoint velocity = [panGesture velocityInView:panGesture.view.superview];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMaxY(panGesture.view.frame)
                                   relativeToHeight:CGRectGetHeight(panGesture.view.superview.bounds)];
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            self.dragging = YES;
            
            panGesture.view.bounds = updatedBounds;
            panGesture.view.frame = updatedFrame;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.dragging = NO;
        }
            break;
        default:
            break;
    }
    
    if ([self visibleHeightForFrame:updatedFrame] < [self heightForVisibleBarViews])
    {
        switch (panGesture.state)
        {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
            {
                //!!!:Breaks minimalization
                if ([self.delegate respondsToSelector:@selector(didUpdateAppBar:toHeight:)])
                {
                    [self.delegate didUpdateAppBar:self
                                          toHeight:[self appBarVisibleHeight]];
                }
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                CGFloat percentage = [self appBarVisibleHeight] / [self heightForVisibleBarViews];
                
                if (percentage < 0.7)
                {
                    [self transitionToFullScreenWithVelocity:velocity];
                }
                else
                {
                    [self transitionToMaxLockWithVelocity:velocity];
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {
        switch (panGesture.state)
        {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
            {
                panGesture.view.bounds = updatedBounds;
                panGesture.view.frame = updatedFrame;
                
                [self addFakeStatusBarAnimated:NO];
                
                // Update the collection view's content offset
                [self updateContentOffsetWithInteractionAdditive:-translation.y];
                
                [self updateActionBarIconWithPercentage:percentage];
                
                if ([self.delegate respondsToSelector:@selector(didDragAppBar:withPercentage:inDirection:)])
                {
                    CGPoint velocity = [panGesture velocityInView:self.view];
                    
                    [self.delegate didDragAppBar:self
                                  withPercentage:percentage
                                     inDirection:PanDirectionFromVelocity(velocity)];
                }
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                [self.delegate didEndDraggingAppBar:self
                                   withAppBarAction:[self stateWithPercentage:percentage]];
                
                [self transitionToMaxLockWithVelocity:velocity];
            }
                break;
            default:
                break;
        }
    }
}

- (void)didSwipeFromTop:(UIScreenEdgePanGestureRecognizer *)panGesture
{
    [self updateAppBarFrameMaxLock];
}

@end


#pragma mark - Implemenation CHFShadowCouplingView

#define kShadowOpacity 0.7

@interface CHFShadowCouplingView ()

@property (nonatomic) UIView *shadowView;

@end

@implementation CHFShadowCouplingView

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [self configureShadowView];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self updateShadowFrame];
}

- (void)updateShadowFrame
{
    self.shadowView.frame = self.frame;
}

- (void)configureShadowView
{
    if (!self.shadowView)
    {
        self.shadowView = [[UIView alloc] initWithFrame:self.bounds];
        [self drawShadowAnimated:NO];
        [self.superview insertSubview:self.shadowView belowSubview:self];
    }
}

- (void)drawShadowAnimated:(BOOL)animated
{
    CALayer *layer = self.shadowView.layer;
    
    if (layer.shadowOpacity == kShadowOpacity) return;
    
    // Set to NO so it doesn't clip off the shadow
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 4;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:layer.bounds
                                                  cornerRadius:layer.cornerRadius].CGPath;
    layer.shadowOpacity = 0.0;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             layer.shadowOpacity = kShadowOpacity;
                         }];
    }
    else
    {
        layer.shadowOpacity = kShadowOpacity;
    }
}

- (void)removeShadowAnimated:(BOOL)animated
{
    CALayer *layer = self.shadowView.layer;
    
    if (layer.shadowOpacity == 0) return;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             layer.shadowOpacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             layer.shadowColor = [UIColor clearColor].CGColor;
                             layer.shadowOffset = CGSizeMake(0, 0);
                             layer.shadowRadius = 0;
                             layer.shadowOpacity = 0.0f;
                             layer.shadowPath = nil;
                         }];
    }
    else
    {
        layer.shadowOpacity = 0.0f;
        layer.shadowColor = [UIColor clearColor].CGColor;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0;
        layer.shadowOpacity = 0.0f;
        layer.shadowPath = nil;
    }
}

@end

