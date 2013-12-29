//
//  CHFItemsCollectionViewCell.m
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFItemCollectionViewCell.h"

@implementation CHFItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
