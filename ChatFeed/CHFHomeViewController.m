//
//  CHFHomeViewController.m
//  Chatfeed
//
//  Created by Justin Cabral on 4/20/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHomeViewController.h"
#import "CHFSpringyFlowLayout.h"
#import "CHFStreamModel.h"

@import QuartzCore;

@interface CHFHomeViewController ()

@property (nonatomic, strong) CHFStreamModel *collectionViewModel;

@end

@implementation CHFHomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Collection View
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[CHFSpringyFlowLayout new]];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(AppContainer.toolBarHeight, 0, 0, 0);
    [self.view addSubview:collectionView];
    
    // Model
    self.collectionViewModel = [[CHFStreamModel alloc] initWithCollectionView:collectionView];
}

#pragma mark - Background Refresh Methods

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler
{
    [self.collectionViewModel reloadData];
}

@end
