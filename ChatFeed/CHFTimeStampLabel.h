//
//  CHFTimeStampLabel.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHFTimeStampLabel : UILabel

@property (nonatomic) NSDate *date;

- (instancetype)initWithDate:(NSDate *)date frame:(CGRect)frame;

@end
