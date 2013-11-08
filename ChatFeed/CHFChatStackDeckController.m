//
//  CHFChatStackDeckController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFChatStackDeckController.h"
#import "CHFStackViewController.h"

@interface CHFChatStackDeckController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation CHFChatStackDeckController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    CHFStackViewController *viewController = [self viewControllerAtIndex:0];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.pageViewController setViewControllers:@[navigationController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PageViewController Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.dataSource indexForUserID:[(CHFStackViewController *)viewController userID]];
    
    if (index == 0) return nil;
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = 0;
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        index = [self.dataSource indexForUserID:[self viewControllerUserIDFromNavigationController:(UINavigationController *)viewController]];
    }
    else
    {
        
    }
    
   
    
    if (index == [self.dataSource numberOfIndexes]) return nil;
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - Helpers

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    NSLog(@"the count o fuseridarray = %u, index ===== %i", [self.dataSource numberOfIndexes], index);
    viewController.view.tag = [self.dataSource userIDForItemAtIndex:index];
    
    return viewController;
}

- (NSString *)viewControllerUserIDFromNavigationController:(UINavigationController *)navigationBarController
{
    CHFStackViewController *viewController = (CHFStackViewController *)navigationBarController.topViewController;
    
    return viewController.userID;
}

@end
