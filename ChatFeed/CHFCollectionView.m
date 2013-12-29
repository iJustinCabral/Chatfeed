//
//  CHFCollectionView.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFCollectionView.h"

@interface CHFCollectionView ()
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@end

@implementation CHFCollectionView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Pan
    if (!self.panGesture)
    {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(panned:)];
        [self addGestureRecognizer:self.panGesture];
    }
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
    
    [self.collectionViewDelegate collectionView:self
                     didBeginPanningInDirection:PanDirectionFromVelocity(velocity)
                                   withVelocity:velocity];
    
    return YES;
}


#pragma mark - Gesture Methods

- (void)panned:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            
            [self.collectionViewDelegate collectionView:self
                               didEndPanningInDirection:PanDirectionFromVelocity(velocity)
                                           withVelocity:velocity];
        }
            break;
        default:
            break;
    }
}

- (void)pinched:(UIPinchGestureRecognizer *)pinchGesture
{
    switch (pinchGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            for (UIView *view in self.subviews)
            {
                view.userInteractionEnabled = NO;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            for (UIView *view in self.subviews)
            {
                view.userInteractionEnabled = YES;
            }
        }
        default:
            break;
    }
}

@end
