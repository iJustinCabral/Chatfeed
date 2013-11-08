//
//  CHFClientMentionCell.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/21/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMentionCell.h"
#import "CHFChatStackManager.h"
#import "CHFWebViewController.h"
#import "CHFChatStackItem.h"
#import "CHFBlurView.h"

#import <ANKUser.h>
#import <ANKPost.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface CHFMentionCell () <UITextViewDelegate, CHFChatStackItemDelegate>

@property (nonatomic, strong) ANKPost *post;
@property (nonatomic, strong) CHFChatStackItem *item;
@property (nonatomic, strong) CHFBlurView *blurView;

@property (nonatomic, strong) UIView *avatarImageViewContainer;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *postTextView;

@end

@implementation CHFMentionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // View
        self.contentView.backgroundColor = [UIColor  whiteColor];
        
        // Name Label
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, self.contentView.bounds.size.width - 80 , 20)];
        self.nameLabel.textColor = [UIColor darkTextColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.shadowColor = [UIColor whiteColor];
        self.nameLabel.shadowOffset = CGSizeMake(0, 1);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        [self.contentView addSubview:self.nameLabel];
        
        // Avatar Image
//        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
//        self.avatarImageView.backgroundColor = [UIColor clearColor];
//        self.avatarImageView.contentMode = UIViewContentModeScaleToFill;
//        self.avatarImageView.userInteractionEnabled = YES;
//        [self maskView:self.avatarImageView withCornerRadius:self.frame.size.width / 2];
//        
//        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAvatar:)];
//        avatarTap.numberOfTapsRequired = 1;
//        [self.avatarImageView addGestureRecognizer:avatarTap];
//        
//        [self.contentView addSubview:self.avatarImageView];
        
        
        //        self.postTextView.backgroundColor = [UIColor yellowColor];
        //        [self.contentView addSubview:self.postTextView];
    }
    
    return self;
}

- (void)setPost:(ANKPost *)post withPostTextView:(UITextView *)textView
{
    self.post = post;
    self.nameLabel.text = post.user.username;
    
    if (!self.item)
    {
        self.item = [[CHFChatStackItem alloc] initWithType:ItemTypeStandAlone];
        self.item.center = [self pointForAvatar];
        self.item.delegate = self;
        
        [self.contentView addSubview:self.item];
    }
    
    self.item.originalParentView = self.contentView;
    [self.item.avatarImageView setImageWithURL:post.user.avatarImage.URL
                              placeholderImage:[UIImage imageNamed:@"avatarPlaceholder.png"]];
    self.item.username = self.post.user.username;
    self.item.userID = self.post.user.userID;
    
    
    // Post
    self.postTextView = textView;
    self.postTextView.delegate = self;
    
    [self.contentView addSubview:self.postTextView];
}

- (void)prepareForReuse
{
    self.nameLabel.text = @"";
    
    self.item.center = [self pointForAvatar];
    self.item.originalParentView = nil;
    self.item.avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    self.item.username = @"";
    self.item.userID = @"";
    
    // Post text was not clearing when I set the string to @"" for reusing the cell. This fixed it;
    [self.postTextView removeFromSuperview];
    self.postTextView = nil;
}


- (CGPoint)pointForAvatar
{
    CGFloat padding = 10.0;
    CGRect contentViewFrame = self.contentView.frame;
    CGPoint origin = self.layout == CellLayoutLeft ? contentViewFrame.origin : CGPointMake(CGRectGetMaxX(contentViewFrame), CGRectGetMinY(contentViewFrame));
    CGFloat itemRadius = self.item.frame.size.width / 2;
    
    CGFloat offsetX;
    CGFloat offsetY;
    
    switch (self.layout)
    {
        case CellLayoutLeft:
        {
            offsetX = padding + origin.x + itemRadius;
            offsetY = offsetX;
        }
            break;
        case CellLayoutRight:
        {
            offsetX = origin.x - (padding + itemRadius);
            offsetY = padding + origin.x + itemRadius;
        }
            break;
    }
    
    return CGPointMake(offsetX, offsetX);
}

#pragma mark - Clipping ImageView Helper

- (void)maskView:(UIView *)originalView withCornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:originalView.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = originalView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    originalView.layer.mask = maskLayer;
}

- (void)drawShadowOnLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 0.6f;
    
    UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[layer bounds] cornerRadius:layer.cornerRadius];
    
    [layer setShadowPath:[path CGPath]];
}

#pragma mark - Gesture Methods

- (void)tappedAvatar:(UIGestureRecognizer *)recognizer
{
    
}

- (void)pannedAvatar:(UIGestureRecognizer *)recognizer
{
    if ([recognizer.view isKindOfClass:[CHFChatStackItem class]])
    {
        if (recognizer.state == UIGestureRecognizerStateChanged)
        {
            recognizer.view.center = [recognizer locationInView:ChatStackManager.window];
        }
    }
    else
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            [self hideAvatarAnimated:NO];
            
            //                CHFChatStackItem *item = [[CHFChatStackItem alloc] init];
            //                item.avatarImage = self.avatarImageView.image;
            //                item.username = self.post.user.username;
            //
            //                CGPoint pointInWindow = [self.contentView convertPoint:recognizer.view.center toView:ChatStackManager.chatStackWindow];
            //
            //                item.center = pointInWindow;
            //
            //                [ChatStackManager.chatStackWindow addSubview:item];
            //
            //                [item addGestureRecognizer:self.panGesture];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self showAvatarAnimated:YES];
    }
    
    
    //    [ChatStackManager addItem:item
    //                    fromPoint:pointInWindow
    //                     animated:YES
    //          withCompletionBlock:^(BOOL finished) {
    //
    //          }];
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    //    if ([[URL host] isEqual:@"www.apple.com"]) // TODO: Check if settings want inapp web or go to safari
    {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        CHFWebViewController *webViewController = [board instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        [AppContainer presentViewController:webViewController animated:YES completion:^{
            [webViewController.webView loadRequest:[NSURLRequest requestWithURL:URL]];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - ChatStackItem Delegate

- (void)didTapItem:(CHFChatStackItem *)item withGesture:(UITapGestureRecognizer *)gesture
{
    if ([ChatStackManager itemArrayContainsItemWithUserID:@""])
    {
        
    }
    
    CGPoint pointInWindow = [self.contentView convertPoint:gesture.view.center toView:ChatStackManager.window];
    [ChatStackManager addItem:item
                    fromPoint:pointInWindow
                     animated:YES
          withCompletionBlock:^(BOOL finished) {
              
          }];
}

//- (void)didPanItem:(CHFChatStackItem *)item withGesture:(UIPanGestureRecognizer *)gesture
//{
//    [ChatStackManager addItem:item withPanGesture:gesture andCompletionBlock:^(BOOL Finished) {
//        
//    }];
//}

#pragma mark - Show/Hide Avatar

- (void)showAvatarAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.6
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self showAvatarAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             self.item.hidden = NO;
                         }];
    }
    else
    {
        self.item.layer.transform = CATransform3DIdentity;
        self.item.alpha = 1.0;
        self.item.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
    }
    
}

- (void)hideAvatarAnimated:(BOOL)animated
{
    
    
    
    if (animated)
    {
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self hideAvatarAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             self.item.hidden = YES;
                         }];
    }
    else
    {
        self.item.layer.transform = CATransform3DIdentity;
        self.item.alpha = 0.0;
        self.item.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0f);
    }
    
}@end
