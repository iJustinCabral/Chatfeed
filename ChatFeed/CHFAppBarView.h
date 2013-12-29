//
//  CHFAppBarView.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, AppBarViewType)
{
    AppBarViewTypeAction = 0,
    AppBarViewTypeNotification,
    AppBarViewTypeNavigation,
    AppBarViewTypeAuxiliary
};

NSString * NSStringFromAppBarViewType(AppBarViewType type);

@interface CHFAppBarView : UIView

@property (nonatomic) AppBarViewType barViewtype;

- (instancetype)initWithType:(AppBarViewType)barViewType
                     andView:(UIView *)view;

- (NSString *)sortKey;

@end
