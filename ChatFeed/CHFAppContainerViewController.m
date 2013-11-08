//
//  CHFMasterContainerViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppContainerViewController.h"

#import "CHFBackDeckController.h"
#import "CHFMainDeckController.h"

#import "CHFAppBar.h"

#import "UIImage+ImageEffects.h"

#import "CHFChatStackItem+ClientItem.h"

//current deckcontroller

typedef NS_ENUM (NSUInteger, DeckControllerIndex)
{
    DeckControllerIndexBack = 0,
    DeckControllerIndexMain,
    DeckControllerIndexHover
};

#define kToolBarHeight 60

@interface CHFAppContainerViewController () <DeckControllerDelegate, CHFAppBarDelegate>

@property (nonatomic, strong) UIView *deckContainer; // Holds the decks.

@property (nonatomic, strong, readwrite) CHFBackDeckController *backDeckController;
@property (nonatomic, strong, readwrite) CHFMainDeckController *mainDeckController;

@property (nonatomic) DeckControllerIndex currentDeckControllerIndex;
@property (nonatomic) NSMutableArray *deckControllers;

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UISegmentedControl *deckSegmentedControl;
@property (nonatomic, strong) UIButton *postButton;

@property (nonatomic, strong) CHFBlurView *toolBarContainer;
@property (nonatomic, strong) CHFAppBar *topAppBar;

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
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    self.toolBarHeight = kToolBarHeight;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Start the chatstack
    ChatStackManager;
    
    [self configureBackDeckController];
    [self configureMainDeckController];
    [self configureTopAppBar];
    
    self.currentDeckControllerIndex = DeckControllerIndexMain;
    self.deckSegmentedControl.selectedSegmentIndex = [self deckControllerForIndex:self.currentDeckControllerIndex].initialDeckPage;
}

- (void)configureToolBar
{
    self.toolBarContainer = [[CHFBlurView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.toolBarHeight)
                                                      blurType:BlurTypeDark
                                                 withAnimation:NO];
    [self.view addSubview:self.toolBarContainer];
    [self.view bringSubviewToFront:self.toolBarContainer];
    
    // Settings Button
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.frame = CGRectMake(0, 0, 34, 34);
    self.settingsButton.center = CGPointMake(37, self.toolBarContainer.frame.size.height / 2);
    UIImage *tintedImage = [[UIImage imageNamed:@"bigGearIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.settingsButton setImage:tintedImage forState:UIControlStateNormal];
    [self.settingsButton setImage:[UIImage imageNamed:@"bigGearIconHighlighted.png"] forState:UIControlStateSelected];
    self.settingsButton.imageView.tintColor = [UIColor chatFeedGreen];
    [self.settingsButton addTarget:self action:@selector(toggleSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBarContainer addSubview:self.settingsButton];
    
    // Segmented Control
    self.deckSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"M", @"H", @"E"]];
    self.deckSegmentedControl.frame = CGRectMake(0, 0, 160, 30);
    self.deckSegmentedControl.center = CGPointMake(self.toolBarContainer.frame.size.width / 2, self.toolBarContainer.frame.size.height / 2);
    self.deckSegmentedControl.tintColor = [UIColor chatFeedGreen];
    self.deckSegmentedControl.selectedSegmentIndex = 0;
    [self.deckSegmentedControl addTarget:self
                                  action:@selector(showDeck:)
                        forControlEvents:UIControlEventValueChanged];
    
    [self.toolBarContainer addSubview:self.deckSegmentedControl];
    
    // Post Button
    self.postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.postButton.frame = CGRectMake(0, 0, 44, 44);
    self.postButton.center = CGPointMake( self.toolBarContainer.frame.size.width - self.postButton.frame.size.width, self.toolBarContainer.frame.size.height / 2);
    [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.postButton setTitleColor: [UIColor chatFeedGreen] forState:UIControlStateNormal];
    
    [self.postButton addTarget:self action:@selector(showPost:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBarContainer addSubview:self.postButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (CHFDeckController *)deckControllerForIndex:(DeckControllerIndex)index
{
    switch (self.currentDeckControllerIndex)
    {
        case DeckControllerIndexBack:
        {
            return self.backDeckController;
        }
        case DeckControllerIndexMain:
        {
            return self.mainDeckController;
        }
            break;
        default:
            return nil;
            break;
    }
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
    
    self.deckSegmentedControl.layer.opacity = 1.0;
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
    
    self.deckSegmentedControl.layer.opacity = 0.0;
}

#pragma mark - Action Methods

- (void)toggleSettings:(UIButton *)button
{
    if (button.selected == YES)
    {
        button.selected = NO;
        
        // Backview
        [self.backDeckController hideScrollViewWithAnimation:ViewTransitionAnimationScaleFade];
        
        // Cards view
        [self.mainDeckController moveAllCardsToState:ControllerCardStateDefault animated:YES];
        
        //        [UIView animateWithDuration:0.3 animations:^{ self.backViewShadowView.layer.opacity = 0.0; }];
    }
    else
    {
        button.selected = YES;
        
        // Backview
        [self.backDeckController showScrollViewWithAnimation:ViewTransitionAnimationScaleFade];
        
        // Cards View
        [self.mainDeckController moveAllCardsToState:ControllerCardStateHiddenBottom animated:YES];
        
        
        //        [UIView animateWithDuration:0.3 animations:^{ self.backViewShadowView.layer.opacity = .8; }];
    }
}

- (void)showDeck:(UISegmentedControl *)segmentedControl
{
    switch (self.currentDeckControllerIndex)
    {
            //        case DeckControllerBack:
            //        {
            //            [self.backDeckController moveToDeckIndex:sender.selectedSegmentIndex animated:YES];
            //        }
            //            break;
        case DeckControllerIndexMain:
        {
            [self.mainDeckController moveToDeckIndex:segmentedControl.selectedSegmentIndex animated:YES];
            [self.mainDeckController moveAllCardsToState:ControllerCardStateDefault animated:YES];
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
        // Setup the navgation bar
        self.topAppBar = [[CHFAppBar alloc] initWithHeight:self.toolBarHeight];
        self.topAppBar.delegate = self;
        NSLog(@"navigation bar configureNavigationBar = %@", NSStringFromCGRect(self.topAppBar.frame));
        
        // Setup navigation item and its content
        UINavigationItem *navItem = [UINavigationItem new];
        CGFloat barItemOffset = self.topAppBar.barButtonOffset;
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
        self.deckSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"M", @"H", @"E"]];
        self.deckSegmentedControl.frame = CGRectMake(0, barItemOffset, 160, 30);
        self.deckSegmentedControl.selectedSegmentIndex = 0;
        [self.deckSegmentedControl addTarget:self
                                      action:@selector(showDeck:)
                            forControlEvents:UIControlEventValueChanged];
        
        frame = self.deckSegmentedControl.frame;
        frame.origin = CGPointZero;
        
        containerView = [[UIView alloc] initWithFrame:frame];
        [containerView addSubview:self.deckSegmentedControl];
        
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
        
        
        
        [self.view addSubview:self.topAppBar];
        [self.view bringSubviewToFront:self.topAppBar];
    }
}

#pragma mark Delegate

- (void)didEndDraggingAppBar:(UINavigationBar *)navigationBar withAppBarState:(AppBarState)state
{
    if ([navigationBar isEqual:self.topAppBar] && self.topAppBar)
    {
        CHFDeckController *controller = [self deckControllerForIndex:self.currentDeckControllerIndex];
        
        switch (state)
        {
            case AppBarStateReloadData:
            {
                
            }
                break;
            case AppBarStateBackToTop:
            {
                
            }
                break;
            case AppBarStateFullscreen:
            {
                
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - DeckControllers

- (void)configureMainDeckController
{
    if (!self.mainDeckController)
    {
        self.mainDeckController = [CHFMainDeckController new];
        self.mainDeckController.delegate = self;
        
        [self addChildViewController:self.mainDeckController];
        
        self.mainDeckController.view.frame = self.view.frame;
        [self.view addSubview:self.mainDeckController.view];
        
        [self.mainDeckController didMoveToParentViewController:self];
    }
}

- (void)configureBackDeckController
{
    if (!self.backDeckController)
    {
        self.backDeckController = [CHFBackDeckController new];
        self.backDeckController.delegate = self;
        
        [self addChildViewController:self.backDeckController];
        
        self.backDeckController.view.frame = self.view.frame;
        [self.view addSubview:self.backDeckController.view];
        
        [self.backDeckController didMoveToParentViewController:self];
        
        [self.backDeckController hideScrollViewWithAnimation:ViewTransitionAnimationNone];
    }
}

#pragma mark Delegate

- (void)deckController:(CHFDeckController *)deckController didUpdateControllerCard:(CHFControllerCard *)controllerCard toDisplayState:(ControllerCardState)toState fromDisplayState:(ControllerCardState)fromState
{
    NSLog(@"in delegate");
    switch (toState)
    {
        case ControllerCardStateDefault:
        {
            NSLog(@"in state default");
            [self.topAppBar showAppBar:YES withTransition:AppBarTransitionSlide];
        }
            break;
        case ControllerCardStateFullScreen:
        {
            NSLog(@"in state fullscreen");
            [self.topAppBar showAppBar:NO withTransition:AppBarTransitionSlide];
            
            //            [self showSegmentedControlAnimated:NO];
        }
            break;
        default:
            break;
    }
}

- (void)deckController:(CHFDeckController *)deckController didMoveToDeckIndex:(NSUInteger)index
{
    self.deckSegmentedControl.selectedSegmentIndex = index;
}

@end
