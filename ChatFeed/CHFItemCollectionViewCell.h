//
//  CHFItemCollectionViewCell.h
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHFChatStackItem;

@interface CHFItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) CHFChatStackItem *item;

@end
