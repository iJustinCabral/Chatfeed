//
//  CHFNotificationBarObject.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/15/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFNotificationBarObject.h"

@interface CHFNotificationBarObject ()
@property (nonatomic, strong, readwrite) NSString *messageText;
@property (nonatomic, readwrite) BOOL wantsToBeDisplayedNext;
@property (nonatomic, readwrite) BOOL isProgressType;
@end

@implementation CHFNotificationBarObject

- (instancetype)initWithNotification:(NSString *)message
              wantsToBeDisplayedNext:(BOOL)wantsNext
                   andIsProgressType:(BOOL)type;
{
    self = [super init];
    
    if (self)
    {
        self.messageText = message;
        self.wantsToBeDisplayedNext = wantsNext;
        self.isProgressType = type;
    }
    
    return self;
}


@end
