//
//  CHFPrivateMessagesModel.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPrivateMessagesModel.h"

#import <ANKChannel.h>
#import <ANKClient+ANKChannel.h>

#import <ANKMessage.h>
#import <ANKClient+ANKMessage.h>

@implementation CHFPrivateMessagesModel

- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion
{
    [[ClientManager currentClient] fetchCurrentUserPrivateMessageChannelsWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
         if (responseObject)
         {
             [self fetchMessagesFromChannels:responseObject
                              withCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
                                  completion(responseObject, meta, nil);
                              }];
         }
         else
         {
             completion(nil, meta, error);
         }
     }];
}

- (void)fetchMessagesFromChannels:(NSArray *)channels
                   withCompletion:(FetchResponseObjectCompletionHandler)completion
{
    NSMutableArray *array = [NSMutableArray array];
    
    [channels enumerateObjectsUsingBlock:^(ANKChannel *channel, NSUInteger index, BOOL *stop)
     {
         [[ClientManager currentClient] fetchMessageWithID:channel.latestMessageID
                                                 inChannel:channel
                                                completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
          {
              if (responseObject)
              {
                  [array addObject:responseObject];
                  
                  // If we are in the last index return the array
                  if (index == channels.count - 1)
                  {
                      completion(array, meta, nil);
                  }
              }
          }];
     }];
}

- (void)configureCell:(CHFAbstractCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
   withResponseObject:(id)responseObject
          andTextView:(UITextView *)textView
{
    ANKMessage *message = responseObject;
    
    [cell setUsername:message.user.username
               userID:message.user.userID
            avatarURL:message.user.avatarImage.URL
            createdAt:message.createdAt
              content:message.text
          annotations:message.annotations
          andTextView:textView];
}

@end
