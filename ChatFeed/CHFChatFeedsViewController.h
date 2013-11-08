//
//  CHFChatFeedsViewController.h
//  ChatFeed
//
//  Created by Justin Cabral on 9/7/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

@import UIKit;

typedef void(^FetchPostsCompletionHandler)(BOOL success, NSError *error);

@interface CHFChatFeedsViewController : UIViewController

-(void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler;


@end
