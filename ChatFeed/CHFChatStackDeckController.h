//
//  CHFChatStackDeckController.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;


@protocol StackDeckControllerDelegate, StackDeckControllerDataSource;

@interface CHFChatStackDeckController : UIViewController

@property (nonatomic, weak) id <StackDeckControllerDelegate> delegate;
@property (nonatomic, weak) id <StackDeckControllerDataSource> dataSource;

@end

@protocol StackDeckControllerDelegate <NSObject>

@end

@protocol StackDeckControllerDataSource <NSObject>
- (NSInteger)numberOfIndexes;
- (NSString *)userIDForItemAtIndex:(NSInteger)index;
- (NSInteger)indexForUserID:(NSString *)userID;
@end


