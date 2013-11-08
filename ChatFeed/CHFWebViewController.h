//
//  CHFWebViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/12/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHFWebViewController : UIViewController <UIWebViewDelegate, UIToolbarDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *backBarButtonItem;

- (IBAction)dismissWebViewController:(id)sender;

@end
