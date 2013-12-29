//
//  CHFMasterContainerViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppContainerViewController.h"

#import "UIImage+ImageEffects.h"

#import "CHFChatStackItem+ClientItem.h"
#import "UIView+AutoLayout.h"

#import "CHFBlurView.h"

#import "CHFAppBar.h"

#import "CHFViewController.h"
#import "CHFFrontViewController.h"
#import "CHFBackViewController.h"

typedef NS_ENUM (NSUInteger, ScrollViewControllerIndex)
{
    ScrollViewControllerIndexBack = 0,
    ScrollViewControllerIndexFront
};

@interface CHFAppContainerViewController () <CHFScrollViewControllerDelegate, CHFAppBarDelegate>

//** Deck Controllers
@property (nonatomic) CHFBackViewController *backScrollViewController;
@property (nonatomic) CHFFrontViewController *frontScrollViewController;
@property (nonatomic) ScrollViewControllerIndex currentScrollViewControllerIndex;

//** Top AppBar
@property (nonatomic, readwrite) CHFAppBar *topAppBar;

// - NavigationBar
@property (nonatomic) UIButton *settingsButton;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) UIButton *postButton;

@end

@implementation CHFAppContainerViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Set up the statusBar. The statusBar has to enabled in Settings for this method to show the statusBar
    [AppDelegate hideStatusBar:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Start the chatstack
    ChatStackManager;
    
    self.currentScrollViewControllerIndex = ScrollViewControllerIndexFront;
    
    // Build up views back to front, but don't wipe that way ;)
    [self configureBackScrollViewController];
    [self configureMainScrollViewController];
    [self configureTopAppBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self updateContentInsets];
}

- (void)updateContentInsetsToHeight:(CGFloat)height
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contentInsetNotification"
                                                        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (void)setCurrentScrollViewControllerIndex:(ScrollViewControllerIndex)currentScrollViewControllerIndex
{
    _currentScrollViewControllerIndex = currentScrollViewControllerIndex;
    
    //TODO: get the currentindex from teh current controller and update the segmented control
}

#pragma mark - ChatStack helper methods

- (void)userInteraction:(BOOL)interaction
{
    self.view.userInteractionEnabled = interaction;
}

- (UIImage *)snapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, self.view.window.screen.scale);
    
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

#pragma mark - SegmentControl

- (void)configureSegmentedControlForDeck:(ScrollViewControllerIndex)index
{
    switch (index)
    {
        case ScrollViewControllerIndexBack:
        {
            
        }
        case ScrollViewControllerIndexFront:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)showSegmentedControlAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self showSegmentedControlAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    
    self.segmentedControl.layer.opacity = 1.0;
}

- (void)hideSegmentedControlAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self hideSegmentedControlAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    
    self.segmentedControl.layer.opacity = 0.0;
}

#pragma mark - Action Methods

- (void)toggleSettings:(UIButton *)button
{
    [self switchScrollViewsWithAnimationOptions:UIViewAnimationOptionTransitionCrossDissolve];
    
    /*
    
    if (button.selected == YES)
    {
        button.selected = NO;
        
        [self.backScrollViewController hideWithAnimation:TransitionAnimationScaleFade];
        [self.frontScrollViewController showWithAnimation:TransitionAnimationScaleFade];
    }
    else
    {
        button.selected = YES;
        
        [self.frontScrollViewController hideWithAnimation:TransitionAnimationScaleFade];
        [self.backScrollViewController showWithAnimation:TransitionAnimationScaleFade];
    }
     //*/
}

- (void)showDeck:(UISegmentedControl *)segmentedControl
{
    switch (self.currentScrollViewControllerIndex)
    {
        case ScrollViewControllerIndexBack:
        {
            [self.backScrollViewController moveToIndex:segmentedControl.selectedSegmentIndex animated:YES];
        }
            break;
        case ScrollViewControllerIndexFront:
        {
            [self.frontScrollViewController moveToIndex:segmentedControl.selectedSegmentIndex animated:YES];
        }
            break;
        default:
            break;
    }
    
    self.settingsButton.selected = NO;
}

- (void)showPost:(UIButton *)button
{
    //    CHFChatStackItem *clientItem = [CHFChatStackItem currentClientItem];
    
    //    [ChatStackManager add]
    
    
}

#pragma mark - TopAppBar

- (void)configureTopAppBar
{
    if (!self.topAppBar)
    {
        self.topAppBar = [[CHFAppBar alloc] init];
        self.topAppBar.delegate = self;
        
        [self addChildViewController:self.topAppBar];
        
        // Setup the topAppBar and give it what options it needs for the current card
        [self.topAppBar addView:[self navigationBarView] withBarViewType:AppBarViewTypeNavigation];
        
        [self.view addSubview:self.topAppBar.view];
        [self.view bringSubviewToFront:self.topAppBar.view];
    }
}

- (UINavigationBar *)navigationBarView
{
    // Setup the navgation bar
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
    navBar.barStyle = UIBarStyleBlackTranslucent;
    [navBar setBackgroundImage:[UIImage new]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    navBar.translucent = YES;
    
    // Setup navigation item and its content
    UINavigationItem *navItem = [UINavigationItem new];
    CGFloat barItemOffset = -5;
    CGRect frame;
    UIView *containerView;
    
    // Settings Button
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.frame = CGRectMake(0, barItemOffset, 34, 34);
    [self.settingsButton setImage:[[UIImage imageNamed:@"GearIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                         forState:UIControlStateNormal];
    [self.settingsButton setImage:[UIImage imageNamed:@"bigGearIconHighlighted.png"] forState:UIControlStateSelected];
    [self.settingsButton addTarget:self action:@selector(toggleSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    frame = self.settingsButton.frame;
    frame.origin = CGPointZero;
    
    containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:self.settingsButton];
    
    UIBarButtonItem *settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    navItem.leftBarButtonItem = settingsButtonItem;
    
    // Segmented Control
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"M", @"H", @"E"]];
    self.segmentedControl.frame = CGRectMake(0, barItemOffset, 160, 30);
    self.segmentedControl.selectedSegmentIndex = [self scrollViewControllerAtIndex:self.currentScrollViewControllerIndex].currentIndex;
    [self.segmentedControl addTarget:self
                                  action:@selector(showDeck:)
                        forControlEvents:UIControlEventValueChanged];
    
    frame = self.segmentedControl.frame;
    frame.origin = CGPointZero;
    
    containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:self.segmentedControl];
    
    navItem.titleView = containerView;
    
    // Post Button
    self.postButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.postButton.frame = CGRectMake(0, barItemOffset, 44, 44);
    [self.postButton addTarget:self action:@selector(showPost:) forControlEvents:UIControlEventTouchUpInside];
    
    frame = self.postButton.frame;
    frame.origin = CGPointZero;
    
    containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:self.postButton];
    
    UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    navItem.rightBarButtonItem = postButtonItem;
    
    navBar.items = @[navItem];
    
    return navBar;
}

#pragma mark Delegate

- (void)didUpdateAppBar:(CHFAppBar *)appBar
               toHeight:(CGFloat)height
{
    [self updateContentInsetsToHeight:height];
}

- (void)didStartDraggingAppBar:(CHFAppBar *)appBar
                   inDirection:(PanDirection)direction
{
    
}

- (void)didDragAppBar:(CHFAppBar *)appBar
       withPercentage:(CGFloat)percentage
          inDirection:(PanDirection)direction
{
    
}

- (void)didEndDraggingAppBar:(CHFAppBar *)appBar
            withAppBarAction:(AppBarAction)action
{
    if ([appBar isEqual:self.topAppBar])
    {
        UIViewController *viewController = [self viewControllerInCurrentPageViewController];
        
        switch (action)
        {
            case AppBarActionReloadData:
            {
                if ([viewController respondsToSelector:@selector(fetchDataWithCapacity:)])
                {
                    [(CHFViewController *)viewController fetchDataWithCapacity:20];
                }
            }
                break;
            case AppBarActionBackToTop:
            {
                if ([viewController respondsToSelector:@selector(scrollToTop)])
                {
                    [(CHFViewController *)viewController scrollToTop];
                }
            }
                break;
            case AppBarActionFullscreen:
            {
                
            }
                break;
            default:
                break;
        }
    }
}

- (void)willClearAuxiliaryViewForAppBar:(CHFAppBar *)appBar
{
//    UIViewController *viewController = [self scrollViewControllerAtIndex:self.currentScrollViewControllerIndex].currentViewController;
//    
//    if ([viewController respondsToSelector:@selector(clearAuxiliaryView)])
//    {
//        [(CHFViewController *)viewController clearAuxiliaryView];
//    }
}

- (void)didClearAuxiliaryViewForAppBar:(CHFAppBar *)appBar
{
//    UIViewController *viewController = [self scrollViewControllerAtIndex:self.currentScrollViewControllerIndex].currentViewController;
//    
//    if ([viewController respondsToSelector:@selector(clearAuxiliaryView)])
//    {
//        [(CHFViewController *)viewController clearAuxiliaryView];
//    }
}

- (void)didSingleTapAppBar:(CHFAppBar *)appBar
{
    UIViewController *viewController = [self viewControllerInCurrentPageViewController];
    
    if ([viewController respondsToSelector:@selector(scrollToTop)])
    {
        [(CHFViewController *)viewController scrollToTop];
    }
}

- (void)didDoubleTapAppBar:(CHFAppBar *)appBar
{
    UIViewController *viewController = [self viewControllerInCurrentPageViewController];
    
    if ([viewController respondsToSelector:@selector(scrollToBottom)])
    {
        [(CHFViewController *)viewController scrollToBottom];
    }
}

#pragma mark - ScrollViewControllers

- (void)configureMainScrollViewController
{
    if (!self.frontScrollViewController)
    {
        self.frontScrollViewController = [CHFFrontViewController new];
        self.frontScrollViewController.delegate = self;
        
        if (self.currentScrollViewControllerIndex == ScrollViewControllerIndexFront)
        {
            [self configureViewController:self.frontScrollViewController];
        }
    }
}

- (void)configureBackScrollViewController
{
    if (!self.backScrollViewController)
    {
        self.backScrollViewController = [CHFBackViewController new];
        self.backScrollViewController.delegate = self;
        
        if (self.currentScrollViewControllerIndex == ScrollViewControllerIndexBack)
        {
            [self configureViewController:self.backScrollViewController];
        }
    }
}

- (void)configureViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    
    viewController.view.frame = self.view.frame;
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

- (void)removeViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)switchScrollViewsWithAnimationOptions:(UIViewAnimationOptions)options
{
    UIViewController *sourceViewController = [self scrollViewControllerAtIndex:self.currentScrollViewControllerIndex];
    UIViewController *destinationViewController = nil;
    if ([sourceViewController isEqual:self.frontScrollViewController])
    {
        destinationViewController = self.backScrollViewController;
        self.currentScrollViewControllerIndex = ScrollViewControllerIndexBack;
    }
    else
    {
        destinationViewController = self.frontScrollViewController;
        self.currentScrollViewControllerIndex = ScrollViewControllerIndexFront;
    }
    
    [self addChildViewController:destinationViewController];
    destinationViewController.view.frame = self.view.frame;
    
    [UIView transitionFromView:sourceViewController.view
                        toView:destinationViewController.view
                      duration:0.4
                       options:options
                    completion:^(BOOL finished) {
                        [destinationViewController didMoveToParentViewController:self];
                        
                        [sourceViewController willMoveToParentViewController:nil];
                        [sourceViewController removeFromParentViewController];
                    }];
    
    
}

#pragma mark Helpers
                         
- (CHFScrollViewController *)scrollViewControllerAtIndex:(ScrollViewControllerIndex)index
{
    switch (index)
    {
        case ScrollViewControllerIndexBack:
        {
            return self.backScrollViewController;
        }
        case ScrollViewControllerIndexFront:
        {
            return self.frontScrollViewController;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (CHFViewController *)viewControllerInCurrentPageViewController
{
    return [self scrollViewControllerAtIndex:self.currentScrollViewControllerIndex].currentViewController;
}

//- (UIViewController *)previousViewController
//{
//    CHFScrollViewController *deckController = [self deckControllerAtIndex:self.currentScrollViewControllerIndex];
//
//    return [self viewControllerAtIndex:--deckController.currentPageInCurrentDeck
//               inScrollViewControllerAtIndex:self.currentScrollViewControllerIndex];
//}
//
//- (UIViewController *)nextViewController
//{
//    CHFScrollViewController *deckController = [self deckControllerAtIndex:self.currentScrollViewControllerIndex];
//
//    return [self viewControllerAtIndex:++deckController.currentPageInCurrentDeck
//               inScrollViewControllerAtIndex:self.currentScrollViewControllerIndex];
//}


#pragma mark Delegate

///*
- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
didBeginScrollingWithPercentage:(CGFloat)percentage
                 inDirection:(PanDirection)direction
       towardsViewController:(UIViewController *)destinationViewController
          fromViewController:(UIViewController *)sourceViewController
{
    if (![scrollViewController isEqual:self.frontScrollViewController]) return;
    
    NSLog(@"didStartDraggingTowardsViewController = %@", destinationViewController);
    
    if (destinationViewController == nil) return;
    
    if ([destinationViewController isKindOfClass:[CHFViewController class]])
    {
        if ([(CHFViewController *)destinationViewController hasAuxiliaryView])
        {
            // Clear the current auxiliaryview
            [self.topAppBar.auxiliaryBarScrollView clearBarViews];
            
            UIView *auxiliaryView = [(CHFViewController *)destinationViewController auxiliaryView];
            CHFAppBarView *barView = [[CHFAppBarView alloc] initWithType:AppBarViewTypeAuxiliary
                                                                             andView:auxiliaryView];
            
            DestinationSide side = direction == PanDirectionLeft ? DestinationSideRight : DestinationSideLeft;
            
            [self.topAppBar.auxiliaryBarScrollView addBarView:barView onPageSide:side];
            
        }
    }
}

- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
     didScrollWithPercentage:(CGFloat)percentage
                 inDirection:(PanDirection)direction
            toViewController:(UIViewController *)viewController
{
//    return;
    if (![scrollViewController isEqual:self.frontScrollViewController]) return;
    
    NSLog(@"didScrollWithPercentage = %@", viewController);
    
    if ([viewController isKindOfClass:[CHFViewController class]])
    {
        if ([(CHFViewController *)viewController canScrollToTop])
        {
            
        }
        else
        {
            
        }
        
        if ([(CHFViewController *)viewController canFetchData])
        {
            
        }
        else
        {
            
        }
        
        if ([(CHFViewController *)viewController canScrollToBottom])
        {
            
        }
        else
        {
            
        }
        
        if ([(CHFViewController *)viewController canFetchOlderData])
        {
            
        }
        else
        {
            
        }
        
        if ([(CHFViewController *)viewController hasAuxiliaryView])
        {
            NSLog(@"going to");
            [self.topAppBar interactiveTransitionToAuxiliaryViewWithPercentage:percentage];
        }
        else
        {
            NSLog(@"going from");
            [self.topAppBar interactiveTransitionFromAuxiliaryViewWithPercentage:percentage];
        }
    }
    else
    {
        
    }
}

- (void)didEndScrollingScrollViewController:(CHFScrollViewController *)scrollViewController
              withDestinationViewController:(UIViewController *)destinationViewController;
{
    if (![scrollViewController isEqual:self.frontScrollViewController]) return;
    NSLog(@"didEndScrollingScrollViewController = %@", destinationViewController);
    if (destinationViewController == nil) return;
    
    if ([destinationViewController isKindOfClass:[CHFViewController class]])
    {
        if (![(CHFViewController *)destinationViewController hasAuxiliaryView])
        {
            
        }
    }
    else
    {
        [self.topAppBar.auxiliaryBarScrollView clearBarViews];
    }
}

- (void)scrollViewController:(CHFScrollViewController *)scrollViewController
              didMoveToIndex:(NSUInteger)index
{
    if (![scrollViewController isEqual:self.frontScrollViewController]) return;
    NSLog(@"scrollViewController = %@", scrollViewController);
    self.segmentedControl.selectedSegmentIndex = index;
}
//*/


#pragma mark - ModelMinimalization Delegate

// This is called from the collectionViews scrollViewDidScroll
- (void)didScrollForCollectionViewModel:(CHFAbstractModel *)model
                            inDirection:(PanDirection)direction
                             withOffset:(CGFloat)offset
                            andVelocity:(CGPoint)velocity
{
    [self.topAppBar interactiveTransitionToMinimalizationInDirection:direction
                                                          withOffset:offset
                                                         andVelocity:velocity];
    
//    [self.topAppBar collectionViewModel:model
//                 didUpdateContentOffset:model.collectionView.contentOffset.y
//                       withOffsetChange:offset];
}


// These are called from an added pan gesture on the collectionView
- (void)didBeginDraggingCollectionViewModel:(CHFAbstractModel *)model
                                inDirection:(PanDirection)direction
                               withVelocity:(CGPoint)velocity
{
    [self.topAppBar beganDraggingCollectionViewModel:model inDirection:direction withVelocity:velocity];
}

- (void)didEndDraggingCollectionViewModel:(CHFAbstractModel *)model
                              inDirection:(PanDirection)direction
                             withVelocity:(CGPoint)velocity
{
    [self.topAppBar endedDraggingCollectionViewModel:model inDirection:direction withVelocity:velocity];
}

@end
