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
    
    // Model
    self.collectionViewModel = [[CHFMentionsModel alloc] initWithCollectionViewLayout:[CHFSpringyFlowLayout new]];
    [self.view addSubview:self.collectionViewModel.collectionView];
}

#pragma mark - Subclassing Hooks

- (BOOL)canFetchData
{
    return YES;
}

- (BOOL)canFetchOlderData
{
    return NO;
}

- (BOOL)canScrollToTop
{
    return YES;
}

- (BOOL)canScrollToBottom
{
    return YES;
}

- (BOOL)hasAuxiliaryView
{
    return NO;
}

- (void)scrollToTop
{
    [self.collectionViewModel scrollToTop];
}

- (void)scrollToBottom
{
    [self.collectionViewModel scrollToBottom];
}

- (void)fetchDataWithCapacity:(NSInteger)capacity
{
    [self.collectionViewModel reloadData];
}

- (void)updateContentInset:(CGFloat)inset
{
    [self.collectionViewModel updateContentInset:inset];
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
