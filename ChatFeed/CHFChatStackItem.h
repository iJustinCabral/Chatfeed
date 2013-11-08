//
//  CHFChatStackItem.h
//  DynamicsCatalog
//
//  Created by Larry Ryan on 6/18/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHFChatStackManager;

typedef NS_ENUM (NSUInteger, ItemType)
{
    ItemTypeStack = 0, // Uses this type when it is a part of the stack
    ItemTypePending = 1, // Uses this type when you get a new message waiting for approval. Once the pending item leaves the windows bounds it will be dismissed.
    ItemTypeStandAlone = 2 // Uses this type when it is just by itself. This could be in a cell, or just a stack item in a view. Once the user lets go it will return to the original point.
};

typedef NS_ENUM (NSUInteger, ItemEffect)
{
    ItemEffectNone = 0,
    ItemEffectAddZoomOut = 1,
    ItemEffectAddZoomIn = 2,
    ItemEffectSwitchZIndexUp = 3,
    ItemEffectSwitchZIndexDown = 4,
    ItemEffectTouchDown = 5
};

@protocol CHFChatStackItemDelegate;


@interface CHFChatStackItem : UIView

@property (nonatomic, assign) id <CHFChatStackItemDelegate> delegate;

// Journey holds the items parentView and point in a dictionary for each time it is passed from one view to another. Once it goes back to its origin we will clear the array. The original view and point is always at index 0.
//@property (nonatomic, strong) NSArray *journeyArray;

@property (nonatomic) CGPoint originalPoint; // Not used. Have keys for dict in journeyArray.
@property (nonatomic, strong) UIView *originalParentView;

#pragma mark - Client Properties
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic) BOOL favorite;
@property (nonatomic, strong) NSDate *lastUsed;
@property (nonatomic) ItemType itemtype;
@property (nonatomic, strong) UIImageView *avatarImageView;

#pragma mark - Dynamic Behaviors Properties
@property (nonatomic, strong, readonly) UIDynamicItemBehavior *flickBehavior;
@property (nonatomic, strong, readonly) UIAttachmentBehavior *precedentItemAttachmentBehavior;

#pragma mark - Init
- (instancetype)initWithType:(ItemType)type;

#pragma mark - Methods
// If the user chooses to, they can have the front camera instead of their profile photo
- (void)showFrontFacingCamera;

#pragma mark - Dynamic Behaviors Methods
- (void)kickOutWithRandomAnimation:(BOOL)random;

- (void)attachToPrecedentItem;
- (void)detachFromPrecedentItem;
- (void)updatePrecedentItemAttachmentLengthForVelocity:(CGPoint)velocity;

- (void)snapToPoint:(CGPoint)point withCompletion:(void (^)(void))completion;

- (void)beginObservingBoundsCrossing;
- (void)stopObservingBoundsCrossing;

- (void)applyGravity;
- (void)removeGravity;

- (void)applyFlickBehaviorWithPanGesture:(UIPanGestureRecognizer *)panGesture;
- (void)removeFlickBehavior;

#pragma mark - Helper Methods
- (NSInteger)index;
- (BOOL)isHeadStackItem;
- (BOOL)isOnLeftSide;
- (CGPoint)location;
- (CGPoint)pointForDefaultLayoutFromSourcePoint:(CGPoint)point;
- (CGPoint)pointForMessageLayout;

#pragma mark - Effects
- (void)applyEffect:(ItemEffect)effect;

@end

#pragma mark - Delegate
@protocol CHFChatStackItemDelegate <NSObject>
@optional
- (void)didTapItem:(CHFChatStackItem *)item withGesture:(UITapGestureRecognizer *)gesture;
- (void)didPanItem:(CHFChatStackItem *)item withGesture:(UIPanGestureRecognizer *)gesture;

- (void)chatStackItemDidLeaveBounds:(CHFChatStackItem *)item;
@end