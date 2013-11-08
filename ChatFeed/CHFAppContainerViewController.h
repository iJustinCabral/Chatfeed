//
//  CHFMasterContainerViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

#import "CHFBlurView.h"

#define AppContainer \
((CHFAppContainerViewController *)[UIApplication sharedApplication].delegate.window.rootViewController)

@interface CHFAppContainerViewController : UIViewController

@property (nonatomic, strong) CHFBlurView *blurView;

@property (nonatomic) CGFloat toolBarHeight;

// Helper methods for the ChatStack
- (void)userInteraction:(BOOL)interaction; // stops all touches inside the container
- (UIImage *)snapshotImage; // Returns an image of all views in the container

@end
