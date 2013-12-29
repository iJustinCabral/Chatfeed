//
//  CHFLoginViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANKClient;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginDidSucceedForClient:(ANKClient *)client;
- (void)loginDidFailWithError:(NSError *)error;

@optional
- (void)loginDidBeginRequest;
- (void)loginDidFinishRequest;

@end

@interface CHFLoginViewController : UIViewController

@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;

@end
