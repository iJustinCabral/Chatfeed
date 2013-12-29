//
//  CHFViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHFViewControllerDelegate <NSObject>

@end

@interface CHFViewController : UIViewController

// This index is used when the VC is a subview of a scrollView
@property (nonatomic) NSUInteger index;

- (BOOL)canScrollToTop;
- (void)scrollToTop;

- (BOOL)canScrollToBottom;
- (void)scrollToBottom;

- (BOOL)canFetchData;
- (void)fetchDataWithCapacity:(NSInteger)capacity;

- (BOOL)canFetchOlderData;
- (void)fetchOlderDataWithCapacity:(NSInteger)capacity;

- (BOOL)hasAuxiliaryView;
- (UIView *)auxiliaryView;
- (void)clearAuxiliaryView;

- (void)updateContentInset:(CGFloat)inset;

@end
