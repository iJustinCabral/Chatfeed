//
//  CHFMessagesViewController.m
//  Chatfeed
//
//  Created by Larry Ryan on 4/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMessagesViewController.h"

#import "CHFMentionsViewController.h"
#import "CHFPrivateMessagesViewController.h"
#import "CHFChatFeedsViewController.h"


#define kInitialPage PageMentions

typedef NS_ENUM (NSUInteger, Page)
{
    PageMentions = 0,
    PagePrivateMessages = 1,
    PageChatFeeds = 2
};

@interface CHFMessagesViewController () <UITabBarDelegate>

@property (nonatomic) NSUInteger currentPage;

@property (nonatomic) CHFMentionsViewController *mentionsViewController;
@property (nonatomic) CHFPrivateMessagesViewController *privateMessagesViewController;
@property (nonatomic) CHFChatFeedsViewController *chatFeedsViewController;

@end

@implementation CHFMessagesViewController


#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.currentPage = kInitialPage;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mentionsViewController = [CHFMentionsViewController new];
    self.privateMessagesViewController = [CHFPrivateMessagesViewController new];
    self.chatFeedsViewController = [CHFChatFeedsViewController new];
    
    [self configureViewController:[self viewControllerAtIndex:self.currentPage]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Transition Methods

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

- (void)transitionToIndex:(NSUInteger)index
{
    UIViewController *sourceViewController = [self viewControllerAtIndex:self.currentPage];
    UIViewController *destinationViewController = [self viewControllerAtIndex:index];
    
    [self addChildViewController:destinationViewController];
    destinationViewController.view.frame = self.view.frame;
    
    [UIView transitionFromView:sourceViewController.view
                        toView:destinationViewController.view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        [destinationViewController didMoveToParentViewController:self];
                        
                        [sourceViewController willMoveToParentViewController:nil];
                        [sourceViewController removeFromParentViewController];
                    }];
}

#pragma mark - CHFViewController Hooks

// Here we need to relay all the hooks to the CHFViewController subviews

- (BOOL)canScrollToTop
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(canScrollToTop)])
    {
        return [(CHFViewController *)viewController canScrollToTop];
    }
    
    return NO;
}

- (void)scrollToTop
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(scrollToTop)])
    {
        return [(CHFViewController *)viewController scrollToTop];
    }
}

//
- (BOOL)canScrollToBottom
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(canScrollToBottom)])
    {
        return [(CHFViewController *)viewController canScrollToBottom];
    }
    
    return NO;
}

- (void)scrollToBottom
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(scrollToBottom)])
    {
        return [(CHFViewController *)viewController scrollToBottom];
    }
}

//
- (BOOL)canFetchData
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(canFetchData)])
    {
        return [(CHFViewController *)viewController canFetchData];
    }
    
    return NO;
}

- (void)fetchDataWithCapacity:(NSInteger)capacity
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(fetchDataWithCapacity:)])
    {
        return [(CHFViewController *)viewController fetchDataWithCapacity:capacity];
    }
}

//
- (BOOL)canFetchOlderData
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(canFetchOlderData)])
    {
        return [(CHFViewController *)viewController canFetchOlderData];
    }
    
    return NO;
}

- (void)fetchOlderDataWithCapacity:(NSInteger)capacity
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(fetchOlderDataWithCapacity:)])
    {
        return [(CHFViewController *)viewController fetchOlderDataWithCapacity:capacity];
    }
}

//
- (void)updateContentInset:(CGFloat)inset
{
    UIViewController *viewController = [self viewControllerAtIndex:self.currentPage];
    
    if ([viewController respondsToSelector:@selector(updateContentInset:)])
    {
        return [(CHFViewController *)viewController updateContentInset:inset];
    }
}

// For the Auxiliary view we keep for THIS class, we do not pass on. At this time I don't see a need to support another auxiliary view in the app bar for the subviews
- (BOOL)hasAuxiliaryView
{
    return YES;
}

- (UIView *)auxiliaryView
{
    return [self configureTabBar];
}

- (void)clearAuxiliaryView
{
}

#pragma mark Hook Helpers



#pragma mark - UITabBar

- (UIView *)configureTabBar
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    tabBar.delegate = self;
    tabBar.barStyle = UIBarStyleBlack;
    tabBar.backgroundImage = [UIImage new];
    tabBar.shadowImage = [UIImage new];
    tabBar.translucent = YES;
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    
    UITabBarItem *mentionsItem = [[UITabBarItem alloc] initWithTitle:@"Mentions" image:[UIImage new] tag:PageMentions];
    UITabBarItem *privateMessagesItem = [[UITabBarItem alloc] initWithTitle:@"PMs" image:[UIImage new] tag:PagePrivateMessages];
    UITabBarItem *chatFeedsItem = [[UITabBarItem alloc] initWithTitle:@"ChatFeeds" image:[UIImage new] tag:PageChatFeeds];
    
    [tabBarItems addObject:mentionsItem];
    [tabBarItems addObject:privateMessagesItem];
    [tabBarItems addObject:chatFeedsItem];
    
    tabBar.items = tabBarItems;
    tabBar.selectedItem = [tabBarItems objectAtIndex:self.currentPage];
    
    return tabBar;
}

#pragma mark Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == self.currentPage) return;
    
    [self transitionToIndex:item.tag];
    
    // Update the current index
    self.currentPage = item.tag;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    switch (index)
    {
        case PageMentions:
        {
            if (!self.mentionsViewController)
            {
                self.mentionsViewController = [CHFMentionsViewController new];
            }
            
            return self.mentionsViewController;
        }
            break;
        case PagePrivateMessages:
        {
            if (!self.privateMessagesViewController)
            {
                self.privateMessagesViewController = [CHFPrivateMessagesViewController new];
            }
            
            return self.privateMessagesViewController;
        }
            break;
        case PageChatFeeds:
        {
            if (!self.chatFeedsViewController)
            {
                self.chatFeedsViewController = [CHFChatFeedsViewController new];
            }
            
            return self.chatFeedsViewController;
        }
            break;
        default:
            return nil;
            break;
    }
}

@end
