//
//  CHFMasterContainerViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

// Imported to become the minimalizationDelegate
#import "CHFAbstractModel.h"

@class CHFAppBar;

#define AppContainer \
((CHFAppContainerViewController *)[UIApplication sharedApplication].delegate.window.rootViewController)

@interface CHFAppContainerViewController : UIViewController <CHFModelMinimalizationDelegate>

@property (nonatomic, getter = isFullScreen) BOOL fullScreen;
@property (nonatomic, readonly, strong) CHFAppBar *topAppBar;

// Helper methods for the ChatStack
- (void)userInteraction:(BOOL)interaction; // stops all touches inside the container
- (UIImage *)snapshotImage; // Returns an image of all views in the container

@end
