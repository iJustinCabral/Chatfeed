//
//  CHFClientMentionCell.h
//  ChatFeed
//
//  Created by Justin Cabral on 8/21/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHFAbstractCell.h"

@class ANKPost;

typedef NS_ENUM(NSUInteger, CellLayout)
{
    CellLayoutLeft = 0,
    CellLayoutRight = 1
};

@interface CHFMentionCell : UICollectionViewCell

@property (nonatomic) CellLayout layout;

- (void)setPost:(ANKPost *)post withPostTextView:(UITextView *)textView;

@end
