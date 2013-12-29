//
//  CHFBackDeckController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFBackDeckController.h"

#import "CHFStoreViewController.h"
#import "CHFProfileViewController.h"
#import "CHFSettingsViewController.h"

typedef NS_ENUM (NSUInteger, Page)
{
    PageStore = 0,
    PageProfile = 1,
    PageSettings = 2
};

@interface CHFBackDeckController () <CHFPageViewControllerDataSource, CHFPageViewControllerDelegate>

@property (strong, nonatomic) CHFStoreViewController *storeViewController;
@property (strong, nonatomic) CHFProfileViewController *profileViewController;
@property (strong, nonatomic) CHFSettingsViewController *settingsViewController;

@end

@implementation CHFBackDeckController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        
        self.initialPage = PageProfile;
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
    switch (index)
    {
        case PageStore:
        {
            if (!self.storeViewController)
            {
                self.storeViewController = [CHFStoreViewController new];
            }
            
            return self.storeViewController;
        }
            break;
        case PageProfile:
        {
            if (!self.profileViewController)
            {
                self.profileViewController = [CHFProfileViewController new];
            }
            
            return self.profileViewController;
        }
            break;
        case PageSettings:
        {
            if (!self.settingsViewController)
            {
                self.settingsViewController = [CHFSettingsViewController new];
            }
            
            return self.settingsViewController;
        }
            break;
        default:
            return nil;
            break;
    }
}

@end
