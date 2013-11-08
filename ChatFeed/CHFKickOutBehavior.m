//
//  CHFKickOutBehavior.m
//  ChatStack
//
//  Created by Larry Ryan on 7/8/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFKickOutBehavior.h"
#import "CHFChatStackItem.h"
#import "CHFChatStackManager.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define kNudgeForce 3.2
#define kRotationVelocity 12.0
#define kGravityForce 3.0

@interface CHFKickOutBehavior ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) CHFChatStackItem *item;

@end

@implementation CHFKickOutBehavior

+ (instancetype)kickOutItem:(CHFChatStackItem *)item withRandomDirection:(BOOL)random
{
    static id instance;
    instance = [[self alloc] initWithItem:item withRandomDirection:random];
    
    return instance;
}

- (instancetype)initWithItem:(CHFChatStackItem *)item withRandomDirection:(BOOL)random
{
    self = [super init];
    
    if (self)
    {
        self.item = item;
        self.item.userInteractionEnabled = NO;
        
        // Effects
        [self addUpwardNudgeWithRandomAngle:random];
        [self addRotationWithRandomAngle:YES];
        [self addGravityWithRandomForce:random];
        [self addBoundsObserver];
        
        // Animator
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:ChatStackManager.window];
        [self.animator addBehavior:self];
    }
    
    return self;
}

- (void)addUpwardNudgeWithRandomAngle:(BOOL)random
{
    UIPushBehavior *upwardNudge = [[UIPushBehavior alloc] initWithItems:@[self.item] mode:UIPushBehaviorModeInstantaneous];
    
    float min = 225.0;
    float max = 315.0;
    float minMaxDif = max - min;
    
    float nudgeAngle;
    
    if (random)
    {
        float randomMultiplier = arc4random() % 11 * 0.1;
        
        float interpolatingValue = minMaxDif * randomMultiplier;
        
        nudgeAngle = min + interpolatingValue;
    }
    else
    {
        float screenWidth = ChatStackManager.window.frame.size.width;
        
        float pointsPerAngle = minMaxDif / screenWidth;
        
        nudgeAngle = max - (pointsPerAngle * self.item.center.x);
    }
    
    [upwardNudge setAngle:DEGREES_TO_RADIANS(nudgeAngle) magnitude:kNudgeForce];
    
    [self addChildBehavior:upwardNudge];
}

- (void)addRotationWithRandomAngle:(BOOL)random
{
    UIDynamicItemBehavior *rotation = [[UIDynamicItemBehavior alloc] initWithItems:@[self.item]];
    
    if (random)
    {
        float randomMultiplier = arc4random() % 11 * 0.1;
        
        float rotationValue = 15.0 * randomMultiplier;
        
        [rotation addAngularVelocity:rotationValue forItem:self.item];
    }
    else
    {
        [rotation addAngularVelocity:kRotationVelocity forItem:self.item];
    }
    
    [self addChildBehavior:rotation];
}

- (void)addGravityWithRandomForce:(BOOL)random
{
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.item]];
    CGFloat xComponent = 0.0;
    CGFloat yComponent = 0.0;
    
    if (random)
    {
        float min = 3.0;
        float max = 5.0;
        float minMaxDif = max - min;
        
        float randomMultiplier = arc4random() % 11 * 0.1;
        
        float interpolatingValue = minMaxDif * randomMultiplier;
        
        float randomForce = min * interpolatingValue;
        
        yComponent = randomForce;
    }
    else
    {
        yComponent = kGravityForce;
    }
    
    gravity.gravityDirection = CGVectorMake(xComponent, yComponent);
    
    [self addChildBehavior:gravity];
}

- (void)addBoundsObserver
{
    UIDynamicItemBehavior *observer = [[UIDynamicItemBehavior alloc] initWithItems:@[self.item]];
    
    observer.action = ^{
        // If the item doesn't intersect rect anymore and has left out one of the sides
        if (!CGRectIntersectsRect(ChatStackManager.window.frame, [self.item frame]) && (self.item.center.x < 0 || self.item.center.x > [UIApplication sharedApplication].delegate.window.frame.size.width))
        {
            [self.animator removeBehavior:self];
            self.animator = nil;
            
            [self.item removeFromSuperview];
        }
    };
    
    [self addChildBehavior:observer];
}

@end
