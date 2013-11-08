//
//  CHFAbstractCell.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

// AbstractCell should be subclassed. It is to make cells faster.
@interface CHFAbstractCell : UICollectionViewCell

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *frontView;

- (void)drawFrontView:(CGRect)rect;

@end