//
//  UIView+Hierarchy.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "UIView+Hierarchy.h"

@implementation UIView (Hierarchy)

- (NSUInteger)getSubviewIndex
{
    return [self.superview.subviews indexOfObject:self];
}

- (void)insertSubviewBelowChatStackItems:(UIView *)view
{
    [self addSubview:view];
    [view sendBelowChatStackItems];
    
//    [self insertSubview:view atIndex:[self lowestChatStackItemIndex] - 1];
}

- (void)sendBelowChatStackItems
{
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex]
                        withSubviewAtIndex:[self lowestChatStackItemIndex] - 1];
}

- (NSUInteger)lowestChatStackItemIndex
{
    // Count from the end of the array, which is also the views closet to the screen.
    NSMutableArray *chatStackItemIndexes = [NSMutableArray array];
    
    for (UIView *subview in self.superview.subviews.reverseObjectEnumerator)
    {
        // As long as the view is not a ChatStackItem add it to that index
        if ([subview isKindOfClass:[CHFChatStackItem class]])
        {
            [chatStackItemIndexes addObject:@([self getSubviewIndex])];
        }
    }
    
    NSNumber *index = [chatStackItemIndexes valueForKeyPath:@"@min.intValue"];
    
    return index.integerValue;
}

- (void)bringToFront
{
    [self.superview bringSubviewToFront:self];
}

- (void)sendToBack
{
    [self.superview sendSubviewToBack:self];
}

- (void)bringOneLevelUp
{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex+1];
}

- (void)sendOneLevelDown
{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex-1];
}

- (BOOL)isInFront
{
    return ([self.superview.subviews lastObject]==self);
}

- (BOOL)isAtBack
{
    return ([self.superview.subviews objectAtIndex:0]==self);
}

- (void)swapDepthsWithView:(UIView*)swapView
{
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex] withSubviewAtIndex:[swapView getSubviewIndex]];
}

@end
