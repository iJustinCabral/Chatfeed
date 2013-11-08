//
//  CHFHomeViewController.m
//  Chatfeed
//
//  Created by Justin Cabral on 4/20/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHomeViewController.h"
#import "CHFSpringyFlowLayout.h"
#import "CHFClientStreamModel.h"

@import QuartzCore;

@interface CHFHomeViewController ()

@property (nonatomic, assign) BOOL initialLoad;

@property (nonatomic, strong) CHFClientStreamModel *collectionViewModel;

@end

@implementation CHFHomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Collection View
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                             collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(AppContainer.toolBarHeight, 0, 0, 0);
    [self.view addSubview:collectionView];
    
    // Model
    self.collectionViewModel = [[CHFClientStreamModel alloc] initWithCollectionView:collectionView];
    [self.collectionViewModel loadInitialData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Background Refresh Methods

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler
{
    [self fetchNewPostsWithCompletionhander:completionHandler];
}

- (void)fetchNewPostsWithCompletionhander:(FetchPostsCompletionHandler)completionHandler
{
    [self.collectionViewModel loadInitialData];
}


@end
