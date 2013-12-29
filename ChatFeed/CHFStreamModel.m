//
//  CHFStreamModel.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/3/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFStreamModel.h"

#import <ANKPost.h>
#import <ANKClient+ANKPostStreams.h>

@implementation CHFStreamModel

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self.dataSource = self;
    self.delegate = self;
    
    return [super initWithCollectionViewLayout:layout];
}

#pragma mark - Model Delegate

- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion
{
    [[ClientManager currentClient] fetchStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
     {
         completion(responseObject, meta, error);
     }];
}

- (void)configureCell:(CHFAbstractCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
   withResponseObject:(id)responseObject
          andTextView:(UITextView *)textView
{
    ANKPost *post = responseObject;
    
    [cell setUsername:post.user.username
               userID:post.user.userID
            avatarURL:post.user.avatarImage.URL
            createdAt:post.createdAt
              content:post.text
          annotations:post.annotations
          andTextView:textView];
}

#pragma mark - Model DataSource

- (BOOL)showControlBarForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UIView *)controlBarViewForIndexPath:(NSIndexPath *)indexPath
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.tintColor = [UIColor appColor];
    toolbar.translucent = YES;
    toolbar.backgroundColor = [UIColor clearColor];
    [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(reply:)];
    UIBarButtonItem *repostButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(repost:)];
    UIBarButtonItem *starButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(star:)];
    
    toolbar.items = @[replyButton, flexibleItem, repostButton, flexibleItem, starButton];
    
    return toolbar;
}

#pragma mark - Toolbar Actions

- (void)reply:(UIBarButtonItem *)sender
{
    
}

- (void)repost:(UIBarButtonItem *)sender
{
    
}

- (void)star:(UIBarButtonItem *)sender
{
    
}

@end
