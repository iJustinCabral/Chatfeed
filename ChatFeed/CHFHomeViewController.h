//
//  CHFHomeViewController.h
//  Chatfeed
//
//  Created by Justin Cabral on 4/20/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFViewController.h"

typedef void(^FetchPostsCompletionHandler)(BOOL success, NSError *error);

@interface CHFHomeViewController : CHFViewController

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler;

@end
