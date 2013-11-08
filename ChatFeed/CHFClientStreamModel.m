//
//  CHFClientStreamModel.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFClientStreamModel.h"
#import "CHFClientStreamCell.h"
#import "CHFClientManager.h"

#import <ANKClient.h>
#import <ANKUser.h>
#import <ANKPost.h>

#import <ANKClient+ANKPostStreams.h>
#import <ANKAnnotation.h>

#define kCell @"HomeCell"
#define kCellMinHeight 100.0f
#define kCellWidth 320.0
#define kPostLabelMaxWidth 300.0f
#define kPadding 10.0
#define kCollectionFooterHeight 40.0

typedef void(^FetchPostsCompletionHandler)(BOOL success, NSError *error);

@interface CHFClientStreamModel () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) BOOL isLoading;
@property (nonatomic) int elementsCount;

@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) NSArray *postTextArray;
@property (nonatomic, strong) NSMutableArray *sortedTextArray;
@property (nonatomic, strong) NSMutableArray *cellHeightArray;

@end

@implementation CHFClientStreamModel

#pragma mark - Lifecycle

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    
    if (self)
    {
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[CHFClientStreamCell class] forCellWithReuseIdentifier:kCell];
        
        self.collectionViewLayout = self.collectionView.collectionViewLayout;
        
        self.postArray = @[];
        self.postTextArray = @[];
        self.cellHeightArray = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - CollectionView
#pragma mark DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.postArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFClientStreamCell *cell = (CHFClientStreamCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    ANKPost *post = [self.postArray objectAtIndex:indexPath.row];
    
    // The is post is by the current user then we want the cell to stype to the right side
    if ([post.user.userID isEqualToString:[ClientManager currentClient].authenticatedUser.userID])
    {
        cell.layout = CellLayoutRight;
    }
    
    UITextView *textView = [self.postTextArray objectAtIndex:indexPath.row];
    [cell setPost:post withPostTextView:textView];
    
    for (id annotation in post.annotations)
    {
        NSLog(@"annotation = %@", annotation);
    }
    
    return cell;
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFClientStreamCell *cell = (CHFClientStreamCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGFloat currentHeight = [self.cellHeightArray[indexPath.item] floatValue];
    CGFloat collapsedHeight = [self calculatedHeightForItemAtIndexPath:indexPath];
    
    BOOL shouldExpand = currentHeight == collapsedHeight;
    
    CGFloat height = shouldExpand ? currentHeight + 44 : collapsedHeight;
    
    [collectionView performBatchUpdates:^{
        for (NSInteger index = 0; index < self.cellHeightArray.count; index++)
        {
            if (index == indexPath.item)
            {
                self.cellHeightArray[index] = @(height);
                cell.state = shouldExpand ? CellStateExpanded : CellStateCollapsed;
            }
            else if ([self.cellHeightArray[index] floatValue] > [self calculatedHeightForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]])
            {
                self.cellHeightArray[index] = @([self calculatedHeightForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]]);
                cell.state = CellStateCollapsed;
            }
        }
    }
                             completion:^(BOOL finished) {
//                                 if (CGRectIntersectsRect(cell.frame, collectionView.frame))
//                                 {
//                                     [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
//                                 }
                             }];
}


#pragma mark -

- (void)loadInitialData
{
    [self fetchLatestPostsCompletion:^(BOOL success, NSError *error)
     {
         if (success)
         {
             [self updateUI];
         }
         else
         {
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
}

- (void)fetchLatestPostsCompletion:(FetchPostsCompletionHandler)completion
{
    [[ClientManager currentClient] fetchStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
     {
         if (responseObject)
         {
             self.postArray = [self filterDeletedPosts:responseObject];
             [self populateTextViews];
             
             completion(YES, nil);
         }
         else
         {
             completion(YES, error);
         }
     }];
}

- (void) updateUI
{
    [self.collectionView reloadData];
}

- (void)populateTextViews
{
    NSMutableArray *textViews = [NSMutableArray array];
    
    // Loop through the post array, and make textViews to add to the postTextArray
    for (ANKPost *post in self.postArray)
    {
        // Make an attributed string from the post text content
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:post.text];
        [postText addAttributes:@{
                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]}
                          range:NSMakeRange(0, postText.length)];
        
        UITextView *postTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 80, kPostLabelMaxWidth, 44)];
        postTextView.attributedText = postText;
        postTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        postTextView.backgroundColor = [UIColor whiteColor];
        postTextView.editable = NO;
        postTextView.scrollEnabled = NO;
        postTextView.clipsToBounds = NO; // So it doesn't clip the text selector
        
        CGRect textViewBounds = postTextView.bounds;
        textViewBounds.origin = CGPointMake(80, 30);
        textViewBounds.size.width = MAX(textViewBounds.size.width, kPostLabelMaxWidth);
        textViewBounds.size.height = postTextView.contentSize.height;
        
        postTextView.bounds = textViewBounds;
        
        [postTextView sizeToFit]; // Reload the content size
        
        [textViews addObject:postTextView];
        
        [self.cellHeightArray addObject:@([self calculatedHeightForTextView:postTextView])];
    }
    
    self.postTextArray = textViews;
}

#pragma mark - Helper Methods

- (CGFloat)calculatedHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *postTextView = self.postTextArray[indexPath.row];
    
    CGFloat calculatedHeight = postTextView.bounds.size.height + postTextView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (CGFloat)calculatedHeightForTextView:(UITextView *)textView
{
    CGFloat calculatedHeight = textView.bounds.size.height + textView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (NSArray *)filterDeletedPosts:(NSArray *)posts
{
    NSMutableArray *goodPosts = [NSMutableArray array];
    
    for (ANKPost *post in posts)
    {
        if (post.text) [goodPosts addObject:post];
    }
    
    return goodPosts;
}

#pragma mark - CollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = [self.cellHeightArray[indexPath.item] floatValue];
    
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kPadding, 0, kPadding, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

@end
