//
//  CHFMainDeckViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMainDeckController.h"

#import "CHFMessagesViewController.h"
#import "CHFHomeViewController.h"
#import "CHFExploreViewController.h"

typedef NS_ENUM (NSUInteger, Page)
{
    PageMessages = 0,
    PageHome = 1,
    PageExplore = 2
};

@interface CHFMainDeckController () <CHFPageViewControllerDataSource, CHFPageViewControllerDelegate>

@property (nonatomic) CHFMessagesViewController *messagesViewController;
@property (nonatomic) CHFHomeViewController *homeViewController;
@property (nonatomic) CHFExploreViewController *exploreViewController;

@end

@implementation CHFMainDeckController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        
        self.initialPage = PageHome;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CHFPageViewController DataSource

- (NSUInteger)numberOfViewControllersForPageViewController:(CHFPageViewController *)pageViewController
{
    return 3;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
                      forPageViewController:(CHFPageViewController *)pageViewController
{
    id viewController;
    
    switch (index)
    {
        case PageMessages:
        {
            viewController = self.messagesViewController ? self.messagesViewController : [CHFMessagesViewController new];
        }
            break;
        case PageHome:
        {
            viewController = self.homeViewController ? self.homeViewController : [CHFHomeViewController new];
        }
            break;
        case PageExplore:
        {
            viewController = self.exploreViewController ? self.exploreViewController : [CHFExploreViewController new];
        }
            break;
        default:
            break;
    }
    
    return viewController;
}

@end
