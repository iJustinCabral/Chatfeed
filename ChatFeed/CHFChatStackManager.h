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

NSString * NSStringFromItemLayout(ItemLayout layout);

#define ChatStackManager \
((CHFChatStackManager *)[CHFChatStackManager sharedChatStackManager])


@protocol CHFChatStackManagerDelegate;


@interface CHFChatStackManager : NSObject <CHFChatStackItemDelegate>

@property (nonatomic, weak) id <CHFChatStackManagerDelegate> delegate;

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

- (void)addItemToStack:(CHFChatStackItem *)item;
- (void)addItemToStack:(CHFChatStackItem *)item fromView:(UIView *)view;
- (void)addItemToPending:(CHFChatStackItem *)item;
- (void)removeItem:(CHFChatStackItem *)item animated:(BOOL)animated randomAnimation:(BOOL)random withCompletionBlock:(void (^)(BOOL finished))completion;

@end


#pragma mark - Delegate

@protocol CHFChatStackManagerDelegate <NSObject>


@end