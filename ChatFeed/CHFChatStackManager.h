//
//  CHFChatStackManager.h
//  DynamicsCatalog
//
//  Created by Larry Ryan on 6/18/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHFChatStackManager.h"
#import "CHFChatStackItem.h"

typedef NS_ENUM (NSUInteger, ItemLayout)
{
    ItemLayoutStack = 0,
    ItemLayoutMessage = 1,
    ItemLayoutReply = 2,
//    ItemLayoutHover = 3
};

#define ChatStackManager \
((CHFChatStackManager *)[CHFChatStackManager sharedChatStackManager])


@protocol CHFChatStackManagerDelegate;


@interface CHFChatStackManager : NSObject <CHFChatStackItemDelegate>

@property (nonatomic, assign) id <CHFChatStackManagerDelegate> delegate;

@property (nonatomic, strong, readonly) UIWindow *window;

@property (nonatomic, strong) CHFChatStackItem *currentChosenItem;
@property (nonatomic) CGPoint boundsCrossingPoint;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong, readonly) NSMutableArray *itemArray;
@property (nonatomic, strong, readonly) NSMutableArray *pendingItemArray;
@property (nonatomic, strong, readonly) NSMutableArray *replyItemArray;
@property (nonatomic, strong, readonly) NSMutableArray *oldItemArray;

@property (nonatomic, readonly) ItemLayout layout;
@property (nonatomic, readonly) BOOL motionEffectEnabled;
@property (nonatomic, readonly) BOOL stackItemAllowsRotation;
@property (nonatomic, readonly) CGFloat stackInset;
@property (nonatomic, readonly) CGFloat snapBackInset;
@property (nonatomic, readonly) CGFloat reboundElasticity;
@property (nonatomic, readonly) CGFloat chatItemOffset;
@property (nonatomic, readonly) CGFloat maxChatStackItems;
@property (nonatomic, readonly) CGFloat chatStackInset;
@property (nonatomic, readonly) CGFloat kickZoneSize;
@property (nonatomic, readonly) CGFloat stackItemSize;

#pragma mark - Singleton
+ (instancetype)sharedChatStackManager;

#pragma mark - Helper Methods
// Stack Layout
- (CHFChatStackItem *)headStackItem;
- (BOOL)itemArrayContainsItemWithUserID:(NSString *)userID;

// Geometry
- (CGRect)snapBackBounds;

#pragma mark - Item Methods
// If the user pans either a "standAlone" we hand over the item to the Managers window along with the pan gesture. Once the panning is done or an action occurs with the item, the item will return to its original view.
- (void)passPanningItem:(CHFChatStackItem *)item withPanGesture:(UIPanGestureRecognizer *)panGesture andCompletionBlock:(void (^)(BOOL finished))completion;

// If the user taps ANY kind of item, we will add the item to the Manager. The manager will determine what to do with the item by the "itemType" property of the item.
- (void)addItem:(CHFChatStackItem *)item fromPoint:(CGPoint)fromPoint animated:(BOOL)animated withCompletionBlock:(void (^)(BOOL finished))completion;

- (void)removeItem:(CHFChatStackItem *)item animated:(BOOL)animated randomAnimation:(BOOL)random withCompletionBlock:(void (^)(BOOL finished))completion;

// Methods to send the item view to view or back to the original view
- (void)snapItemBackToOrigin:(CHFChatStackItem *)item
                  completion:(void (^)(void))completion;

- (void)snapItem:(CHFChatStackItem *)item
         toPoint:(CGPoint)toPoint
          inView:(UIView *)toView
      completion:(void (^)(void))completion;

@end


#pragma mark - Delegate

@protocol CHFChatStackManagerDelegate <NSObject>


@end