//
//  UIView+Hierarchy.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Hierarchy)

- (NSUInteger)getSubviewIndex;

- (void)sendBelowChatStackItems;
- (void)insertSubviewBelowChatStackItems:(UIView *)view;

- (void)bringToFront;
- (void)sendToBack;

- (void)bringOneLevelUp;
- (void)sendOneLevelDown;

- (BOOL)isInFront;
- (BOOL)isAtBack;

- (void)swapDepthsWithView:(UIView*)swapView;

@end
