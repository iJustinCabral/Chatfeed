//
//  CHFHomeCell.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ANKPost.h>

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

@interface CHFClientStreamCell : UICollectionViewCell

@property (nonatomic) CellLayout layout;
@property (nonatomic) CellState state;

- (void)setPost:(ANKPost *)post withPostTextView:(UITextView *)textView;

@end
