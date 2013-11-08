//
//  CHFHoverViewController.h
//  ChatStack
//
//  Created by Larry Ryan on 7/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, HoverMenuOptions)
{
    HoverMenuOptionUserProfile          = (1 << 0),
    HoverMenuOptionUserFollow           = (1 << 1),
    HoverMenuOptionUserMute             = (1 << 2),
    HoverMenuOptionUserBlock            = (1 << 3),
    HoverMenuOptionUserFollowers        = (1 << 4),
    HoverMenuOptionUserMentions         = (1 << 5),
    HoverMenuOptionUserInteractions     = (1 << 6),
    
    HoverMenuOptionMessageReply         = (1 << 7),
    HoverMenuOptionMessageRepost        = (1 << 8),
    HoverMenuOptionMessageStar          = (1 << 9),
    HoverMenuOptionMessageShare         = (1 << 10),
    HoverMenuOptionMessageReportSpam    = (1 << 11),
    
    HoverMenuOptionManageAddUser        = (1 << 12),
    HoverMenuOptionManageKick           = (1 << 13),
    HoverMenuOptionManageCanReadwrite   = (1 << 14),
    HoverMenuOptionManageCanReadonly    = (1 << 15),
    
    HoverMenuOptionChatStackAddUser     = (1 << 16),
    HoverMenuOptionChatStackRemoveUser  = (1 << 17),
};

@interface CHFHoverMenuViewController : UIViewController

- (instancetype)initWithMenuOptions:(HoverMenuOptions)menuOptions forItem:(CHFChatStackItem *)item;

@property (nonatomic) HoverMenuOptions menuOptions;

#pragma mark - Methods
- (void)performActionOnCellAtPoint:(CGPoint)point
                 withChatStackItem:(CHFChatStackItem *)item
                     andCompletion:(void (^)(void))completion;

- (void)pannedItemPoint:(CGPoint)point;

- (void)showAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end
