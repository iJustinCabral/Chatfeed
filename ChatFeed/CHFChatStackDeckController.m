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

- (instancetype)initWithUserIDs:(NSArray *)userIDs
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
        self.userIDArray = [userIDs copy];
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
    NSUInteger index = [self.userIDArray indexOfObject:[(CHFStackViewController *)viewController userID]];
    
    if (index == 0) return nil;
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.userIDArray indexOfObject:[(CHFStackViewController *)viewController userID]];
    
    if (index == self.userIDArray.count) return nil;
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - Helpers

- (CHFStackViewController *)viewControllerAtIndex:(NSUInteger)index
{
    CHFStackViewController *viewController = [[CHFStackViewController alloc] initWithNibName:nil bundle:nil];
    NSLog(@"the count o fuseridarray = %u, index ===== %i", self.userIDArray.count, index);
    viewController.userID = self.userIDArray[index];
    
    return viewController;
}

@end
