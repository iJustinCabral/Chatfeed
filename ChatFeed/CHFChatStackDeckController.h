//
//  CHFChatStackDeckController.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;


@protocol StackDeckControllerDelegate <NSObject>

@end

@protocol StackDeckControllerDataSource <NSObject>
- (NSInteger)numberOfIndexes;
- (NSString *)userIDForItemAtIndex:(NSInteger)index;
- (NSInteger)indexForUserID:(NSString *)userID;
@end


@interface CHFChatStackDeckController : UIViewController

@property (nonatomic, strong) id <StackDeckControllerDelegate> delegate;
@property (nonatomic, strong) id <StackDeckControllerDataSource> dataSource;

@end

