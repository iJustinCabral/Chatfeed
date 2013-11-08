//
//  CHFWebViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/12/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFWebViewController.h"

@interface CHFWebViewController ()

@end

@implementation CHFWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toolbar.delegate = self;
    self.toolbar.barTintColor = [UIColor whiteColor];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.backBarButtonItem.enabled = webView.canGoBack;
    self.forwardBarButtonItem.enabled = webView.canGoForward;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.backBarButtonItem.enabled = webView.canGoBack;
    self.forwardBarButtonItem.enabled = webView.canGoForward;
}

- (IBAction)dismissWebViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
