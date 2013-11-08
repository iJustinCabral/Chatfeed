//
//  CHFChatStackHoverCell.h
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHFHoverMenuViewController.h"

@interface CHFHoverMenuCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *optionLabel; // TODO: Change to use images, maybe a load bar too
@property (nonatomic) HoverMenuOptions menuOption;
@property (nonatomic, strong) NSString *userID;

@end
