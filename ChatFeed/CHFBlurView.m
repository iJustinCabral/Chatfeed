//
//  CHFBlurView.m
//  CHFBlur
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFBlurView.h"

@import QuartzCore;

#define kAnimationDuration 0.2

@interface CHFBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

@property (nonatomic, strong) UINavigationBar *navBar;


@end

@implementation CHFBlurView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame blurType:(BlurType)blurtype withAnimation:(BOOL)animated
{
    // Adjust the frame to make sure it fills up the window
    frame = CGRectMake(frame.origin.x - 5, frame.origin.y - 5, frame.size.width + 10, frame.size.height + 10);
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setupWithBlurType:blurtype animated:animated];
    }
    return self;
}

- (void)setupWithBlurType:(BlurType)type animated:(BOOL)animated
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.opacity = 0.0;
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:[self bounds]];
    self.blurType = type;
    self.blurLayer = self.toolbar.layer;
    
    UIView *blurView = [UIView new];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.userInteractionEnabled = NO;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [blurView.layer addSublayer:self.blurLayer];
    
    [self insertSubview:blurView atIndex:0];
    
    [self showBlurViewAnimated:animated withCompletion:^{
        
    }];
}

#pragma mark - Properties

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.blurLayer.frame = self.bounds;
}

- (void)setBlurType:(BlurType)blurType
{
    _blurType = blurType;
    
    switch (blurType)
    {
        case BlurTypeLight:
        {
            [self.toolbar setBarStyle:UIBarStyleDefault];
        }
            break;
        case BlurTypeDark:
        {
            [self.toolbar setBarStyle:UIBarStyleBlack];
        }
            break;
    }
}

#pragma mark - Methods

- (void)showBlurViewAnimated:(BOOL)animated withCompletion:(void (^)(void))completion
{
    if (animated)
    {
        self.layer.opacity = 0.0;
        
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |
                                    UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self showBlurViewAnimated:NO withCompletion:completion];
                         }
                         completion:^(BOOL finished) {
                             
                             completion();
                         }];
    }
    
    self.layer.opacity = 1.0;
}

- (void)hideBlurViewAnimated:(BOOL)animated withCompletion:(void (^)(void))completion
{
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self hideBlurViewAnimated:NO withCompletion:completion];
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             
                             completion();
                         }];
    }
    
    self.layer.opacity = 0.0;
}

@end
