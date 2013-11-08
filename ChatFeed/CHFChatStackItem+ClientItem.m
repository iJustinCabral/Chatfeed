//
//  CHFChatStackItem+ClientItem.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/3/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFChatStackItem+ClientItem.h"

#import <ANKUser.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation CHFChatStackItem (ClientItem)

+ (instancetype)currentClientItem
{
    CHFChatStackItem *clientItem = [[CHFChatStackItem alloc] initWithType:ItemTypeStandAlone];
    ANKUser *user = [[ANKClient sharedClient] authenticatedUser];
    
    clientItem.userID = user.userID;
    clientItem.username = user.username;
    [clientItem.avatarImageView setImageWithURL:user.avatarImage.URL
                               placeholderImage:[UIImage imageNamed:@"avatarPlaceholder.png"]];
    
    return clientItem;
}

@end
