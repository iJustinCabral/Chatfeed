//
//  CHFBackViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/17/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFBackViewController.h"

#import "CHFStoreViewController.h"
#import "CHFProfileViewController.h"
#import "CHFSettingsViewController.h"

typedef NS_ENUM (NSUInteger, Page)
{
    PageStore = 0,
    PageProfile = 1,
    PageSettings = 2
};

@interface CHFBackViewController () <CHFScrollViewControllerDelegate, CHFScrollViewControllerDataSource>

@property (nonatomic) CHFStoreViewController *storeViewController;
@property (nonatomic) CHFProfileViewController *profileViewController;
@property (nonatomic) CHFSettingsViewController *settingsViewController;

@end

@implementation CHFBackViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.datasource = self;
    self.delegate = self;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.initialIndex = PageSettings;
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
