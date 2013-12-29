//
//  CHFTimeStampLabel.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFTimeStampLabel.h"
#import "NSDate+NVTimeAgo.h"

static const NSInteger kMaxCountingSecond = 60;

@interface CHFTimeStampLabel ()

@property (nonatomic, getter = isObserving) BOOL observing;

@end

@implementation CHFTimeStampLabel

- (instancetype)initWithDate:(NSDate *)date frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.date = date;
    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    if ([date secondsSince] < kMaxCountingSecond)
    {
        // Make sure the singleton is initialized
        [TimeAgoTimer sharedTimeAgoTimer];
        
        self.observing = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateText)
                                                     name:@"timeAgoSecondNotification"
                                                   object:nil];
    }
    else
    {
        if (self.isObserving)
        {
            self.observing = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
    
    self.text = [date formattedAsTimeAgo];
}

- (void)updateText
{
    self.text = [self.date formattedAsTimeAgo];
}

@end
