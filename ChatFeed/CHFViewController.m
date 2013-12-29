//
//  CHFViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFViewController.h"

@interface CHFViewController ()

@end

@implementation CHFViewController

//
- (BOOL)canScrollToTop
{
    return NO;
}

- (void)scrollToTop
{
    
}

//
- (BOOL)canScrollToBottom
{
    return NO;
}

- (void)scrollToBottom
{
}

//
- (BOOL)canFetchData
{
    return NO;
}

- (void)fetchDataWithCapacity:(NSInteger)capacity
{
}

//
- (BOOL)canFetchOlderData
{
    return NO;
}

- (void)fetchOlderDataWithCapacity:(NSInteger)capacity
{
}

//
- (BOOL)hasAuxiliaryView
{
    return NO;
}

- (UIView *)auxiliaryView
{
    return nil;
}

- (void)clearAuxiliaryView
{
}

//
- (void)updateContentInset:(CGFloat)inset
{
}

@end
