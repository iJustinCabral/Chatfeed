//
//  CHFClientMentionsModel.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/21/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMentionsModel.h"

#import <ANKPost.h>
#import <ANKClient+ANKPostStreams.h>
#import <ANKClient+ANKUser.h>

@implementation CHFMentionsModel

- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion
{
    [[ClientManager currentClient] fetchCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
     {
         if (responseObject)
         {
             [[ClientManager currentClient] fetchPostsMentioningUser:responseObject
                                                          completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
              {
                  completion(responseObject, meta, nil);
              }];
         }
         else
         {
             completion(nil, meta, error);
         }
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

@end
