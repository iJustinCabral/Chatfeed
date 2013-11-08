//
//  CHFLoginViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHFLoginViewController : UIViewController

@property (copy) void (^authRequestDidBegin)(void);
@property (copy) void (^authRequestDidFinish)(void);

@end
