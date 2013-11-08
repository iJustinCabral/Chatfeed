//
//  CHFSpringyFlowLayout.m
//  NavigationBarPull
//
//  Created by Larry Ryan on 10/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFSpringyFlowLayout.h"

@interface CHFSpringyFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPaths;
@property (nonatomic) CGPoint lastContentOffset;
@property (nonatomic) CGFloat lastScrollDelta;
@property (nonatomic) CGPoint lastTouchLocation;

@end

@implementation CHFSpringyFlowLayout

#define kScrollRefreshThreshold         30.0f
#define kScrollResistanceCoefficient    1 / 4500.0f

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPaths = [NSMutableSet set];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    // only refresh the set of UIAttachmentBehaviours if we've moved more than the scroll threshold since last load
    if (fabsf([self scrollDirectionAxisValueForPoint:contentOffset] - [self scrollDirectionAxisValueForPoint:self.lastContentOffset]) < kScrollRefreshThreshold && self.visibleIndexPaths.count > 0)
    {
        return;
    }
    self.lastContentOffset = contentOffset;
    
    CGFloat padding = 100;
    CGRect currentRect = CGRectMake(0, [self scrollDirectionAxisValueForPoint:contentOffset] - padding, self.collectionView.frame.size.width, self.collectionView.frame.size.height + 2 * padding);
    
    NSArray *itemsInCurrentRect = [super layoutAttributesForElementsInRect:currentRect];
    NSSet *indexPathsInVisibleRect = [NSSet setWithArray:[itemsInCurrentRect valueForKey:@"indexPath"]];
    
    // Remove behaviours that are no longer visible
    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behaviour, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [[behaviour.items firstObject] indexPath];
        
        BOOL isInVisibleIndexPaths = [indexPathsInVisibleRect member:indexPath] != nil;
        
        if (!isInVisibleIndexPaths)
        {
            [self.animator removeBehavior:behaviour];
            [self.visibleIndexPaths removeObject:[[behaviour.items firstObject] indexPath]];
        }
    }];
    
    // Find newly visible indexes
    NSArray *newVisibleItems = [itemsInCurrentRect filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings)
                                                                                {
                                                                                    BOOL isInVisibleIndexPaths = [self.visibleIndexPaths member:item.indexPath] != nil;
                                                                                    return !isInVisibleIndexPaths;
                                                                                }]];
    
    [newVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop)
     {
         UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:attribute.center];
         spring.length = 0;
         spring.frequency = 0.7;
         spring.damping = 0.5;
         
         // If our touchLocation is not (0,0), we need to adjust our item's center
         if (self.lastScrollDelta != 0)
         {
             [self adjustSpring:spring centerForTouchPosition:self.lastTouchLocation scrollDelta:self.lastScrollDelta];
         }
         
         [self.animator addBehavior:spring];
         [self.visibleIndexPaths addObject:attribute.indexPath];
     }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    self.lastScrollDelta = [self scrollDirectionAxisValueForPoint:newBounds.origin] - [self scrollDirectionAxisValueForPoint:scrollView.bounds.origin];
    
    self.lastTouchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *spring, NSUInteger idx, BOOL *stop)
     {
         [self adjustSpring:spring centerForTouchPosition:self.lastTouchLocation scrollDelta:self.lastScrollDelta];
         [self.animator updateItemUsingCurrentState:[spring.items firstObject]];
     }];
    
    
    
    return NO;
}

- (void)adjustSpring:(UIAttachmentBehavior *)spring centerForTouchPosition:(CGPoint)touchLocation scrollDelta:(CGFloat)scrollDelta
{
    CGFloat distanceFromTouch = fabsf([self scrollDirectionAxisValueForPoint:touchLocation] - [self scrollDirectionAxisValueForPoint:spring.anchorPoint]);
    CGFloat scrollResistance = distanceFromTouch * kScrollResistanceCoefficient;
    
    UICollectionViewLayoutAttributes *item = [spring.items firstObject];
    CGPoint center = item.center;
    
    if (self.lastScrollDelta < 0)
    {
        CGFloat axisValue = [self scrollDirectionAxisValueForPoint:center];
        axisValue += MAX(self.lastScrollDelta, self.lastScrollDelta * scrollResistance);
        center = [self navigationBarPointAxisValue:axisValue forPoint:center];
    }
    else
    {
        CGFloat axisValue = [self scrollDirectionAxisValueForPoint:center];
        axisValue += MIN(self.lastScrollDelta, self.lastScrollDelta * scrollResistance);
        center = [self navigationBarPointAxisValue:axisValue forPoint:center];
    }
    
    item.center = center;
}

#pragma mark - Helpers

- (CGFloat)scrollDirectionAxisValueForPoint:(CGPoint)point
{
    return self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? point.x : point.y;
}

- (CGPoint)navigationBarPointAxisValue:(CGFloat)axisValue forPoint:(CGPoint)point
{
    return self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? CGPointMake(axisValue, point.y) : CGPointMake(point.x, axisValue);
}

@end
