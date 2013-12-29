//
//  CHFAbstractCell.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

typedef NS_ENUM (NSUInteger, CellLayout)
{
    CellLayoutLeft = 0,
    CellLayoutRight = 1
};

typedef NS_ENUM (NSUInteger, CellState)
{
    CellStateCollapsed = 0,
    CellStateExpanded = 1
};

@interface CHFAbstractCell : UICollectionViewCell

@property (nonatomic) CellLayout layout;
@property (nonatomic) CellState state;

- (void)setUsername:(NSString *)username
             userID:(NSString *)userID
          avatarURL:(NSURL *)avatarURL
          createdAt:(NSDate *)created
            content:(NSString *)content
        annotations:(NSArray *)annotations
        andTextView:(UITextView *)textView;

- (void)showControlBar:(BOOL)show withView:(UIView *)view;

@end