//
//  CHFChatStackItemBase.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

@protocol CHFChatStackItemBaseDataSource;


@interface CHFChatStackItemBase : UIView

@property (nonatomic, weak) id <CHFChatStackItemBaseDataSource> dataSource;

@property (nonatomic) CHFChatStackItem *item;

- (void)spawnItemAnimated:(BOOL)animated;

- (void)showItem:(CHFChatStackItem *)item animated:(BOOL)animated;
- (void)hideItem:(CHFChatStackItem *)item animated:(BOOL)animated;

@end


#pragma mark - CHFChatStackItemBaseDataSource

@protocol CHFChatStackItemBaseDataSource <NSObject>

- (CHFChatStackItem *)itemBaseWantsChatStackItem:(CHFChatStackItemBase *)base;

@end