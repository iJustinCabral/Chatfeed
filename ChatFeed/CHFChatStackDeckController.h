//
//  CHFChatStackDeckController.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

@protocol StackDeckControllerDelegate;

@interface CHFChatStackDeckController : UIViewController

- (instancetype)initWithUserIDs:(NSArray *)userIDs;

@property (nonatomic, strong) id <StackDeckControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *userIDArray;

@end

@protocol StackDeckControllerDelegate <NSObject>



@end
