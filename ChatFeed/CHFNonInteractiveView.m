//
//  CHFNonInteractiveView.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFNonInteractiveView.h"

@implementation CHFNonInteractiveView

// Set the point to only effect subviews, and allow other touches to pass through
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews)
    {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

@end
