//
//  CHFNotificationBarObject.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/15/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHFNotificationBarObject : NSObject

- (instancetype)initWithNotification:(NSString *)message
              wantsToBeDisplayedNext:(BOOL)wantsNext
                   andIsProgressType:(BOOL)type;

@property (nonatomic, strong, readonly) NSString *messageText;
@property (nonatomic, readonly) BOOL wantsToBeDisplayedNext;
@property (nonatomic, readonly) BOOL isProgressType;

@end
