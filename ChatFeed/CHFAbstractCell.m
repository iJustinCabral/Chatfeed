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
#import "ILTranslucentView.h"
#import "CHFTimeStampLabel.h"
#import "CHFChatStackItemBase.h"

#import "UIView+Hierarchy.h"

#import <ANKUser.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kCornerRadius 8.0
#define kPadding 10.0

@interface CHFAbstractCell () <UITextViewDelegate, CHFChatStackItemBaseDataSource>

//@property (nonatomic) CHFChatStackItem *item;
@property (nonatomic) CHFChatStackItemBase *itemBase;

@property (nonatomic) UIView *topView; // Holds Avatar, username, timestamp
@property (nonatomic) UIView *bottomView; // Holds the content
@property (nonatomic) ILTranslucentView *controlView; // Holds the controls if any

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) CHFTimeStampLabel *timeLabel;
@property (nonatomic) UITextView *postTextView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSURL *avatarURL;

@property (nonatomic) BOOL shouldRedrawCutout;

@end

@implementation CHFAbstractCell

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = kCornerRadius;
        self.clipsToBounds = YES;
        
        self.state = CellStateCollapsed;
        
        [self configureTopView];
        [self configureBottomView];
    }
    
    return self;
}

- (void)redrawCutout
{
    self.shouldRedrawCutout = YES;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (!self.shouldRedrawCutout)
    {
        
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
        CGRect frame = [self topViewFrame];
        
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
    self.shouldRedrawCutout = NO;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.text = @"";
    
    [self.postTextView removeFromSuperview];
    self.postTextView = nil;
    
    [self.bottomView setHeightWithAdditive:self.state == CellStateExpanded ? 44 : 0];

    // Redraw the background cutout
    [self setNeedsDisplay];
}

#pragma mark - Properties

- (void)setState:(CellState)state
{
    _state = state;
    
    //    switch (state)
    //    {
    //        case CellStateCollapsed:
    //        {
    //            [self showControlView:NO];
    //        }
    //            break;
    //        case CellStateExpanded:
    //        {
    //            [self showControlView:YES];
    //        }
    //            break;
    //    }
}

#pragma mark - Public Methods

// This is the method given by the model
- (void)setUsername:(NSString *)username
             userID:(NSString *)userID
          avatarURL:(NSURL *)avatarURL
          createdAt:(NSDate *)created
            content:(NSString *)content
        annotations:(NSArray *)annotations
        andTextView:(UITextView *)textView;
{
    // Update the bottomView frame for the new content
    //    self.bottomView.frame = self.contentView.frame;
    
    self.username = username;
    self.userID = userID;
    self.avatarURL = avatarURL;
    
    // Username
    self.nameLabel.text = username;
    
    // Time
    self.timeLabel.date = created;
    
    // Avatar/Chatstack item
    [self configureChatStackBase];
    
    // Post
    self.postTextView = textView;
    self.postTextView.delegate = self;
    [self.bottomView addSubview:self.postTextView];
}


#pragma mark - Item Base

- (void)configureChatStackBase
{
    if (!self.itemBase)
    {
        self.itemBase = [[CHFChatStackItemBase alloc] initWithFrame:CGRectMake(0, 0, ChatStackManager.stackItemSize, ChatStackManager.stackItemSize)];
        self.itemBase.dataSource = self;
        self.itemBase.center = [self pointForAvatar];
        
        [self.topView addSubview:self.itemBase];
    }
    
    [self.itemBase spawnItemAnimated:NO];
}

#pragma mark DataSource

- (CHFChatStackItem *)itemBaseWantsChatStackItem:(CHFChatStackItemBase *)base
{
    if ([self.itemBase isEqual:base])
    {
        CHFChatStackItem *item = [[CHFChatStackItem alloc] initWithType:ItemTypeStandAlone];
        
        item.username = self.username;
        item.userID = self.userID;
        
        if ([self.userID isEqualToString:[ANKClient sharedClient].authenticatedUser.userID])
        {
            [item showFrontFacingCamera];
            self.layout = CellLayoutRight;
        }
        else
        {
            [item.avatarImageView setImageWithURL:self.avatarURL
                                 placeholderImage:[UIImage imageNamed:@"avatarPlaceholder@2x.jpg"]];
        }
        
        return item;
    }
    
    return nil;
}

#pragma mark - TopView

- (void)configureTopView
{
    if (!self.topView)
    {
        self.topView = [[UIView alloc] initWithFrame:[self topViewFrame]];
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.layer.cornerRadius = kCornerRadius;
        
        [self.contentView addSubview:self.topView];
    }
    
    if (!self.nameLabel)
    {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, self.contentView.bounds.size.width - 80, 20)];
        self.nameLabel.textColor = [UIColor darkTextColor];
        self.nameLabel.backgroundColor = [UIColor whiteColor];
        self.nameLabel.shadowColor = [UIColor whiteColor];
        self.nameLabel.shadowOffset = CGSizeMake(0, 1);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        [self.topView addSubview:self.nameLabel];
    }
    
    if (!self.timeLabel)
    {
        self.timeLabel = [[CHFTimeStampLabel alloc] initWithFrame:CGRectMake(80, 35, self.contentView.bounds.size.width - 80, 20)];
        self.timeLabel.textColor = [UIColor darkTextColor];
        self.timeLabel.backgroundColor = [UIColor whiteColor];
        self.timeLabel.shadowColor = [UIColor whiteColor];
        self.timeLabel.shadowOffset = CGSizeMake(0, 1);
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        
        [self.topView addSubview:self.timeLabel];
    }
}

- (CGRect)topViewFrame
{
    CGRect frame;
    frame.size = CGSizeMake(320, (kPadding * 2) + ChatStackManager.stackItemSize);
    frame.origin = CGPointZero;
    
    return frame;
}

#pragma mark - BottomView

- (void)configureBottomView
{
    if (!self.bottomView)
    {
        // Bottom view is going to live in its own container. This allows us to clip off the top corner radiuses off keeping the bottom ones. I'm doing this to avoid having to draw a mask for every cell.
        CGRect bottomViewFrame = [self bottomViewFrame];
        
        UIView *containerView = [[UIView alloc] initWithFrame:bottomViewFrame];
        containerView.clipsToBounds = YES;
        [self.contentView addSubview:containerView];
        
        CGRect frame;
        frame.origin.x = 0;
        frame.origin.y = -kCornerRadius;
        frame.size.width = containerView.frame.size.width;
        frame.size.height = containerView.frame.size.height + kCornerRadius;
        
        self.bottomView = [[UIView alloc] initWithFrame:frame];
        self.bottomView.backgroundColor = [UIColor whiteColor];
        self.bottomView.layer.cornerRadius = kCornerRadius;
        
        [containerView addSubview:self.bottomView];
    }
}

- (CGRect)bottomViewFrame
{
    CGRect frame;
    CGRect topFrame = [self topViewFrame];
    
    CGFloat height = (self.frame.size.height - topFrame.size.height);
    if (self.state == CellStateExpanded) height -= 44;
    
    frame.size = CGSizeMake(self.frame.size.width, height);
    frame.origin = CGPointMake(0, topFrame.size.height);
    
    return frame;
}


#pragma mark - ControlView

- (void)configureControlViewWithView:(UIView *)view
{
    if (!self.controlView)
    {
        UIView *containerView = [[UIView alloc] initWithFrame:[self controlContainerFrame]];
        containerView.clipsToBounds = YES;
        [self.contentView addSubview:containerView];
        [self.contentView sendSubviewToBack:containerView];
        
        self.controlView = [[ILTranslucentView alloc] initWithFrame:[self controlViewFrame]];
        //        self.controlView.backgroundColor = [UIColor colorWithWhite:0.179 alpha:1.000];
        self.controlView.translucentAlpha = 1;
        self.controlView.translucentStyle = UIBarStyleBlack;
        self.controlView.translucentTintColor = [UIColor clearColor];
        self.controlView.backgroundColor = [UIColor clearColor];
        self.controlView.layer.cornerRadius = kCornerRadius;
        
        [containerView addSubview:self.controlView];
        //        [self.contentView sendSubviewToBack:self.controlView];
        
        [view setYWithAdditive:kCornerRadius * 2];
        
        [self.controlView addSubview:view];
    }
}

- (CGRect)controlContainerFrame
{
    CGFloat offset = kCornerRadius * 2;
    CGFloat height = 44 + offset;
    
    CGRect frame;
    frame.origin = CGPointMake(0, self.contentView.frame.size.height - offset);
    frame.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), height);
    
    return frame;
}

- (CGRect)controlViewFrame
{
    CGRect containerFrame = [self controlContainerFrame];
    
    CGFloat offset = kCornerRadius * 2;
    CGFloat height = 44 + offset;
    
    CGRect frame;
    frame.origin = CGPointMake(0, -height);
    frame.size = CGSizeMake(CGRectGetWidth(containerFrame), height);
    
    return frame;
}

- (void)showControlBar:(BOOL)show withView:(UIView *)view
{
    if (show) [self configureControlViewWithView:view];
    
    if (!self.controlView) return;
    
    if (show)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.controlView setCenterYWithAdditive:60];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.controlView setCenterYWithAdditive:-60];
                         }
                         completion:^(BOOL finished) {
                             
                             UIView *controlViewContainer = self.controlView.superview;
                             
                             [self.controlView removeFromSuperview];
                             self.controlView = nil;
                             
                             [controlViewContainer removeFromSuperview];
                             controlViewContainer = nil;
                             
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)pointForAvatar
{
    CGRect contentViewFrame = self.topView.frame;
    CGPoint origin = self.layout == CellLayoutLeft ? contentViewFrame.origin : CGPointMake(CGRectGetMaxX(contentViewFrame), CGRectGetMinY(contentViewFrame));
    CGFloat itemRadius = ChatStackManager.stackItemSize / 2;
    
    CGFloat offsetX;
    CGFloat offsetY;
    
    switch (self.layout)
    {
        case CellLayoutLeft:
        {
            offsetX =  origin.x + kPadding + itemRadius;
            offsetY = offsetX;
        }
            break;
        case CellLayoutRight:
        {
            offsetX = origin.x - (kPadding + itemRadius);
            offsetY = origin.x + kPadding + itemRadius;
        }
            break;
    }
    
    return CGPointMake(offsetX, offsetY);
}

#pragma mark - View/Layer Methods

- (void)maskView:(UIView *)view withCornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
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

@end
