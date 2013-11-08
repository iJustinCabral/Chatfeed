//
//  CHFHomeCell.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFClientStreamCell.h"

#import "CHFWebViewController.h"
#import "CHFClientManager.h"

#import <ANKUser.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "CHFBlurView.h"

#define kCornerRadius 8.0

@interface CHFClientStreamCell () <UITextViewDelegate>

@property (nonatomic, strong) ANKPost *post;
@property (nonatomic, strong) CHFChatStackItem *item;

@property (nonatomic, strong) UIView *backView; // Holds the controls
@property (nonatomic, strong) UIView *frontView; // Hold the content

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *postTextView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation CHFClientStreamCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = kCornerRadius;
        self.layer.masksToBounds = YES;
        
        // Setup the front view
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
/*
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    // Circle Cutout
    // There are 4 points to this circle, TL, BL, BR, TR
    CGFloat offsetX = 5;
    CGFloat offsetY = 5;
    
    [bezierPath moveToPoint: CGPointMake(10.25 + offsetX, 10.25 + offsetY)]; // Starts top left
    [bezierPath addCurveToPoint: CGPointMake(10.25 + offsetX, 59.75 + offsetY) controlPoint1: CGPointMake(-3.42 + offsetX, 23.92 + offsetY) controlPoint2: CGPointMake(-3.42 + offsetX, 46.08 + offsetY)];
    [bezierPath addCurveToPoint: CGPointMake(59.75 + offsetX, 59.75 + offsetY) controlPoint1: CGPointMake(23.92 + offsetX, 73.42 + offsetY) controlPoint2: CGPointMake(46.08 + offsetX, 73.42 + offsetY)];
    [bezierPath addCurveToPoint: CGPointMake(59.75 + offsetX, 10.25 + offsetY) controlPoint1: CGPointMake(73.42 + offsetX, 46.08 + offsetY) controlPoint2: CGPointMake(73.42 + offsetX, 23.92 + offsetY)];
    [bezierPath addCurveToPoint: CGPointMake(10.25 + offsetX, 10.25 + offsetY) controlPoint1: CGPointMake(46.08 + offsetX, -3.42 + offsetY) controlPoint2: CGPointMake(23.92 + offsetX, -3.42 + offsetY)];
    [bezierPath closePath];
    
    // Rectangle (frame)
    CGRect frame = self.frontView.frame;
    
    CGPoint topLeft = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
    CGPoint topRight = CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame));
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame));
    
    [bezierPath moveToPoint:bottomRight]; // Starts bottom right
    [bezierPath addLineToPoint:bottomLeft]; // Bottom left
    [bezierPath addLineToPoint:topLeft]; // Top left
    [bezierPath addLineToPoint:topRight]; // Top right
    [bezierPath addLineToPoint:bottomRight]; // Bottom right
    [bezierPath closePath];
    
    // Set the background color
    [[UIColor whiteColor] setFill];
    
    [bezierPath fill];
}
*/
- (void)prepareForReuse
{
    NSLog(@"9999999999999 prepare for reuse");
    
    self.nameLabel.text = @"";
    
    self.item.center = [self pointForAvatar];
    self.item.originalParentView = nil;
    self.item.avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    self.item.username = @"";
    self.item.userID = @"";
    
    [self.postTextView removeFromSuperview];
    self.postTextView = nil;
    
    [self configureFrontView];
    
    [self.backView removeFromSuperview];
    self.backView = nil;
    
    // Redraw the background cutout
    [self setNeedsDisplay];
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

#pragma mark - Methods

- (void)setPost:(ANKPost *)post withPostTextView:(UITextView *)textView
{
    self.post = post;
    
    // Username
    self.nameLabel.text = post.user.username;
    
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
    self.item.username = self.post.user.username;
    self.item.userID = self.post.user.userID;
    
    if ([self.item.userID isEqualToString:[ClientManager currentClient].authenticatedUser.userID])
    {
        [self.item showFrontFacingCamera];
    }
    else
    {
        [self.item.avatarImageView setImageWithURL:post.user.avatarImage.URL
                                  placeholderImage:[UIImage imageNamed:@"avatarPlaceholder.png"]];
    }
    
    // Post
    self.postTextView = textView;
    self.postTextView.backgroundColor = [UIColor whiteColor];
    self.postTextView.delegate = self;
    
    [self.frontView addSubview:self.postTextView];
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
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        CHFWebViewController *webViewController = [board instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        [AppContainer presentViewController:webViewController animated:YES completion:^{
            [webViewController.webView loadRequest:[NSURLRequest requestWithURL:URL]];
        }];
        
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
