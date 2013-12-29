//
//  CHFFrontViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/12/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFFrontViewController.h"

#import "CHFMessagesViewController.h"
#import "CHFHomeViewController.h"
#import "CHFExploreViewController.h"

typedef NS_ENUM (NSUInteger, Page)
{
    PageMessages = 0,
    PageHome = 1,
    PageExplore = 2
};

@interface CHFFrontViewController () <CHFScrollViewControllerDelegate, CHFScrollViewControllerDataSource>

@property (nonatomic) CHFMessagesViewController *messagesViewController;
@property (nonatomic) CHFHomeViewController *homeViewController;
@property (nonatomic) CHFExploreViewController *exploreViewController;

@end

@implementation CHFFrontViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.datasource = self;
    self.delegate = self;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.initialIndex = PageHome;
        self.pagingStyle = PagingStyleSwoopDown;
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

#pragma mark - CHFScrollViewController DataSource

- (NSUInteger)numberOfViewControllersForScrollViewController:(CHFScrollViewController *)scrollViewController
{
    return 3;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
                    forScrollViewController:(CHFScrollViewController *)scrollViewController
{
    switch (index)
    {
        case PageMessages:
        {
            if (!self.messagesViewController)
            {
                self.messagesViewController = [CHFMessagesViewController new];
            }
            
            return self.messagesViewController;
        }
            break;
        case PageHome:
        {
            if (!self.homeViewController)
            {
                self.homeViewController = [CHFHomeViewController new];
            }
            
            return self.homeViewController;
        }
            break;
        case PageExplore:
        {
            if (!self.exploreViewController)
            {
                self.exploreViewController = [CHFExploreViewController new];
            }
            
            return self.exploreViewController;
        }
            break;
        default:
            return nil;
            break;
    }
}

@end
