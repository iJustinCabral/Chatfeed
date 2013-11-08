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

@property (nonatomic,strong) CHFMentionsModel *mentionsCollectionViewModel;

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
    
    // Model
    self.mentionsCollectionViewModel = [[CHFMentionsModel alloc] initWithCollectionView:collectionView];
    [self.mentionsCollectionViewModel loadInitialData];
    
    [self.view addSubview:collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Background Fetch Methods

-(void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler
{
    [self fetchNewPostsWithCompletionhander:completionHandler];
}

-(void)fetchNewPostsWithCompletionhander:(FetchPostsCompletionHandler)completionHandler
{
    [self.mentionsCollectionViewModel loadInitialData];
}

@end
