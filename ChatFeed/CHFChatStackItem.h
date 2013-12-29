//
//  CHFChatStackItem.h
//  DynamicsCatalog
//
//  Created by Larry Ryan on 6/18/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHFChatStackManager;
@class ItemCoordinates;
@class CHFChatStackItemBase;

typedef NS_ENUM (NSUInteger, ItemType)
{
    ItemTypeStack = 0, // Uses this type when it is a part of the stack
    ItemTypePending = 1, // Uses this type when you get a new message waiting for approval. Once the pending item leaves the windows bounds it will be dismissed.
    ItemTypeStandAlone = 2 // Uses this type when it is just by itself. This could be in a cell, or just a stack item in a view. Once the user lets go it will return to the original point.
};

NSString * NSStringFromItemType(ItemType type);

// Different effects to use on the item. Doesn't work while the item is affected by UIDynamics. Might try to make a container view on the item which the dynamics control and that might let the item be effected by UIView animations.
typedef NS_ENUM (NSUInteger, ItemEffect)
{
    ItemEffectNone = 0,
    ItemEffectAddZoomOut = 1,
    ItemEffectAddZoomIn = 2,
    ItemEffectSwitchZIndexUp = 3,
    ItemEffectSwitchZIndexDown = 4,
    ItemEffectTouchDown = 5,
    ItemEffectFadeIn = 6,
    ItemEffectFadeOut = 7
};

// Completion handler for the hover menu. Check weather it performed an action, if it does should the item return to its origin point/view
typedef void(^HoverActionCompletionHandler)(BOOL performedAction, BOOL itemShouldReturn);

@protocol CHFChatStackItemDelegate;


@interface CHFChatStackItem : UIView

@property (nonatomic, weak) id <CHFChatStackItemDelegate> delegate;

@property (nonatomic, weak) CHFChatStackItemBase *base;

@property (nonatomic) ItemType itemtype;

#pragma mark - Client Properties
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *userID;
@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) NSDate *lastUsed;
@property (nonatomic) BOOL favorite;

#pragma mark - Dynamic Behaviors Properties
@property (nonatomic, readonly) UIDynamicItemBehavior *flickBehavior;
@property (nonatomic, readonly) UIAttachmentBehavior *precedentItemAttachmentBehavior;

#pragma mark - Init
- (instancetype)initWithType:(ItemType)type;
+ (instancetype)testItem:(ItemType)type;
// There is currentClientItemWithItemType availiable as a category.

#pragma mark - Item Snapping Methods
// Going from point A to point B is SLOWER than going (From (Point A) to window(Point A) to window(Point B) then converting to (Point B))

// This keeps a log of where the item has travelled. The array gets made the first time the item travels and is set to nil when back to original  ItemCoordinates(point/view). index 0 will be the original point/view where the object was initialized.
@property (nonatomic) NSArray *journeyArray; // Holds ItemCoordinates

// These ivars keep the view of which the item was "born" on. Haven't found a situation where needing to keep track of more point/view ivars
//@property (nonatomic) CGPoint originalPoint;
//@property (nonatomic) UIView *originalParentView;

// Hopefully can get rid of this methods
- (void)addCoordinates:(ItemCoordinates *)coordinates;

// This method calls snapToPoint:inView: giving originalPoint/originalParentView ivars as the arguments
- (void)snapToOrigin;

- (void)snapToPreviousCoordinates;
- (void)snapToItemCoordinatesAtIndex:(NSUInteger)index;
- (void)snapToItemCoordinates:(ItemCoordinates *)coordinates;

// This method is used where some views go over the tapped item when animating the view in for example. It gives the item to the window which will keep the item above all views. (From (Point A) to window(Point A))
- (void)prepareToSnap;

// This method will call prepareItemToSnap first to prep the item to be snapped. This is our window(Point B) to (Point B)).
- (void)snapToPoint:(CGPoint)toPoint
             inView:(UIView *)toView;

#pragma mark - Methods
// If the user chooses to, they can have the front camera instead of their profile photo
- (void)showFrontFacingCamera;

- (void)addShadow:(BOOL)addShadow
         animated:(BOOL)animated;

#pragma mark - Dynamic Behaviors Methods
// Kick out the item in some random upwards direction, and sets item to nil once off the screen
- (void)kickOutWithRandomAnimation:(BOOL)random;

- (void)attachToPrecedentItem;
- (void)detachFromPrecedentItem;
- (void)updatePrecedentItemAttachmentLengthForVelocity:(CGPoint)velocity;

- (void)snapToPoint:(CGPoint)point
     withCompletion:(void (^)(void))completion;

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

#pragma mark - ItemCoordinates Class
@interface ItemCoordinates : NSObject

+ (instancetype)coordinateWithPoint:(CGPoint)point inView:(UIView *)view withScale:(CGFloat)scale;

@property (nonatomic) CGPoint point;
@property (nonatomic) UIView *view;
@property (nonatomic) CGFloat scale;

@end