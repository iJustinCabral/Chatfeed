//
//  CHFKickOutBehavior.h
//  ChatStack
//
//  Created by Larry Ryan on 7/8/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHFChatStackItem;

@interface CHFKickOutBehavior : UIDynamicBehavior

+ (instancetype)kickOutItem:(CHFChatStackItem *)item withRandomDirection:(BOOL)random;

@end
