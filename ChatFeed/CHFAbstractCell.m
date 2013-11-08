//
//  CHFAbstractCell.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAbstractCell.h"
#import "CHFWebViewController.h"
#import "CHFBlurView.h"

#import <ANKUser.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kCornerRadius 8.0

@interface CHFAbstractCell () <UITextViewDelegate>

@property (nonatomic, strong) CHFChatStackItem *item;

@property (nonatomic, strong) UIView *backView; // Holds the controls
@property (nonatomic, strong) UIView *frontView; // Hold the content

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *postTextView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation CHFAbstractCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self configureFrontView];
    }
    
    return self;
}

- (void)setState:(CellState)state
{
    _state = state;
    
    switch (state)
    {
        case CellStateCollapsed:
        {
            [self showBackView:NO];
        }
            break;
        case CellStateExpanded:
        {
            [self showBackView:YES];
        }
            break;
    }
}

- (void)setUsername:(NSString *)username
             userID:(NSString *)userID
          avatarURL:(NSURL *)avatarURL
          createdAt:(NSDate *)created
            content:(NSString *)content
        annotations:(NSArray *)annotations
        andTextView:(UITextView *)textView;
{
    // Username
    self.nameLabel.text = username;

    // Time
    
    // Avatar/Chatstack item
    if (!self.item)
    {
        self.item = [[CHFChatStackItem alloc] initWithType:ItemTypeStandAlone];
        self.item.center = [self pointForAvatar];
        
        [self.frontView addSubview:self.item];
    }
    
    self.item.originalParentView = self.frontView;
    self.item.originalPoint = self.item.center;
    self.item.username = username;
    self.item.userID = userID;
    
    if ([userID isEqualToString:[ClientManager currentClient].authenticatedUser.userID])
    {
        [self.item showFrontFacingCamera];
        self.layout = CellLayoutRight;
    }
    else
    {
        [self.item.avatarImageView setImageWithURL:avatarURL
                                  placeholderImage:[UIImage imageNamed:@"avatarPlaceholder.png"]];
    }
    
    // Post
    self.postTextView = textView;
    self.postTextView.backgroundColor = [UIColor whiteColor];
    self.postTextView.delegate = self;
    
    [self.frontView addSubview:self.postTextView];
    int numLines = textView.contentSize.height / textView.font.lineHeight;
    NSLog(@"In cell height = %f, lines = %i", self.frame.size.height, numLines);
    
}

- (void)prepareForReuse
{
    self.nameLabel.text = @"";
    
    self.item.center = [self pointForAvatar];
    self.item.originalParentView = nil;
    self.item.avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    self.item.username = @"";
    self.item.userID = @"";
    
//    [self.postTextView removeFromSuperview];
//    self.postTextView = nil;
    
    [self configureFrontView];
    
    [self.backView removeFromSuperview];
    self.backView = nil;
    
    // Redraw the background cutout
//    [self setNeedsDisplay];
}

#pragma mark - BackView

- (void)configureBackView
{
    if (!self.backView)
    {
        CGRect frame;
        frame.origin = CGPointMake(0, self.contentView.frame.size.width - 44);
        frame.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), 44);
        
        self.backView = [[UIView alloc] initWithFrame:frame];
        self.backView.backgroundColor = [UIColor darkGrayColor];
        
        [self.contentView addSubview:self.backView];
        [self.contentView sendSubviewToBack:self.backView];
    }
    
    CGRect frame;
    frame.origin = CGPointMake(0, self.contentView.frame.size.width - 44);
    frame.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), 44);
    self.backView.frame = frame;
}

- (void)showBackView:(BOOL)show
{
    [self configureBackView];
    
    
}

#pragma mark - FrontView

- (void)configureFrontView
{
    if (!self.frontView)
    {
        self.frontView = [[UIView alloc] initWithFrame:self.contentView.frame];
        self.frontView.backgroundColor = [UIColor whiteColor];
        self.frontView.layer.cornerRadius = kCornerRadius;
        
        [self.contentView addSubview:self.frontView];
    }
    
    if (!self.nameLabel)
    {
        // Name Label
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, self.contentView.bounds.size.width - 80, 20)];
        self.nameLabel.textColor = [UIColor darkTextColor];
        self.nameLabel.backgroundColor = [UIColor whiteColor];
        self.nameLabel.shadowColor = [UIColor whiteColor];
        self.nameLabel.shadowOffset = CGSizeMake(0, 1);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        [self.frontView addSubview:self.nameLabel];
    }
    
    
}

#pragma mark - Helpers

- (CGPoint)pointForAvatar
{
    CGFloat padding = 10.0;
    CGRect contentViewFrame = self.frontView.frame;
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
    
    return CGPointMake(offsetX, offsetY);
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

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    //    if ([[URL host] isEqual:@"www.apple.com"]) // TODO: Check if settings want inapp web or go to safari
    {
//        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//        CHFWebViewController *webViewController = [board instantiateViewControllerWithIdentifier:@"WebViewController"];
//        
//        [AppContainer presentViewController:webViewController animated:YES completion:^{
//            [webViewController.webView loadRequest:[NSURLRequest requestWithURL:URL]];
//        }];
        
        return NO;
    }
    
    return YES;
}

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
    
}

@end
