//
//  CHFMentionsViewController.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/29/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMentionsViewController.h"
#import "CHFSpringyFlowLayout.h"
#import "CHFMentionsModel.h"

@interface CHFMentionsViewController ()

@property (nonatomic,strong) CHFMentionsModel *collectionViewModel;

@end

@implementation CHFMentionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[CHFSpringyFlowLayout new]];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    // Model
    self.collectionViewModel = [[CHFMentionsModel alloc] initWithCollectionView:collectionView];
}
#pragma mark
#pragma mark - Background Fetch Methods

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler
{
    [self fetchNewPostsWithCompletionhander:completionHandler];
}

- (void)fetchNewPostsWithCompletionhander:(FetchPostsCompletionHandler)completionHandler
{
    [self.collectionViewModel reloadData];
}

@end
