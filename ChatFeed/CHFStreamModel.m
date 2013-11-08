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

- (BOOL)showToolBarOnCellTap
{
    return YES;
}

@end
