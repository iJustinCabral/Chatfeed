//
//  CHFPrivateMessageCell.h
//  ChatFeed
//
//  Created by Justin Cabral on 8/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANKChannel;

@interface CHFPrivateMessageCell : UICollectionViewCell

- (void)setChannel:(ANKChannel *)channel withPostTextView:(UITextView *)textView;

@end
