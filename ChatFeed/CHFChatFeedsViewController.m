//
//  CHFChatFeedsViewController.m
//  ChatFeed
//
//  Created by Justin Cabral on 9/7/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFChatFeedsViewController.h"
#import "CHFSpringyFlowLayout.h"
#import "CHFChatFeedsModel.h"

@interface CHFChatFeedsViewController ()

@property (nonatomic,strong) CHFChatFeedsModel *chatfeedsCollectionViewModel;

@end

@implementation CHFChatFeedsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                          collectionViewLayout:[CHFSpringyFlowLayout new]];
    collectionView.backgroundColor = [UIColor clearColor];
    
    // Model
    self.chatfeedsCollectionViewModel = [[CHFChatFeedsModel alloc] initWithCollectionView:collectionView];
    [self.chatfeedsCollectionViewModel loadInitialData];
    
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
    [self.chatfeedsCollectionViewModel loadInitialData];
}

@end
