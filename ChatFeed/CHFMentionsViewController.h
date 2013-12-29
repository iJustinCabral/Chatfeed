//
//  CHFMentionsViewController.h
//  ChatFeed
//
//  Created by Justin Cabral on 8/29/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFViewController.h"

typedef void(^FetchPostsCompletionHandler)(BOOL success, NSError *error);

@interface CHFMentionsViewController : CHFViewController

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler;

@end
