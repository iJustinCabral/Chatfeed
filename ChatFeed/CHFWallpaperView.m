//
//  CHFWallpaperView.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/26/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFWallpaperView.h"
#import "UIImage+AverageColor.h"

#define kTransitionInterval 10
#define kTransitionDuration 0.4
#define kBlurViewFadeDuration 0.3

@interface CHFWallpaperView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray *imageURLArray;
@property (nonatomic, strong) NSTimer *transitionTimer;
@property (nonatomic, strong) CHFBlurView *blurView;

@property (nonatomic, readwrite) NSInteger currentIndex;

@end

@implementation CHFWallpaperView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.blurWallpaper = YES;
        
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andBlurWallpaper:(BOOL)blur
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.blurWallpaper = blur;
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // Setup the image array
    self.imageURLArray = @[@"backgroundImage1.jpg", @"backgroundImage2.jpg", @"backgroundImage3.jpg", @"backgroundImage4.jpg", @"backgroundImage5.png"];
    
    // Set the default image index
    self.currentIndex = 0;
    
    // Setup the image view
    [self configureImageView];
    
    // Setup the blur view
    [self showBlur:self.blurWallpaper];
    
    // Start the timer which will change the wallpaper every n seconds
    [self startTransitionTimer];
}

#pragma mark - Properties

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    // Don't let the index get out of the image arrays range
    if (currentIndex < 0) currentIndex = 0;
    if (currentIndex >= self.imageURLArray.count) currentIndex = self.imageURLArray.count - 1;
    
    _currentIndex = currentIndex;
}

- (void)setBlurWallpaper:(BOOL)blurWallpaper
{
    _blurWallpaper = blurWallpaper;
    
    [self showBlur:blurWallpaper];
}

#pragma mark - Helpers

- (UIColor *)averageColor
{
    return self.imageView.image.averageColor;
}

- (UIImage *)imageAtIndex:(NSInteger)index
{
    return [UIImage imageNamed:self.imageURLArray[index]];
}

#pragma mark - TransitionTimer

- (void)startTransitionTimer
{
    [self configureTransitionTimer];
}

- (void)configureTransitionTimer
{
    if (!self.transitionTimer)
    {
        //FIXME: Busy main thread delays transition timer
        
        __block UIBackgroundTaskIdentifier backgroundTask;
        
        UIApplication *application = [UIApplication sharedApplication];
        
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:backgroundTask];
        }];
        
        self.transitionTimer = [NSTimer scheduledTimerWithTimeInterval:kTransitionInterval
                                                                target:self
                                                              selector:@selector(transitionToNextImage)
                                                              userInfo:nil
                                                               repeats:YES];
    }
}

- (void)restartTimer
{
    [self.transitionTimer invalidate];
    self.transitionTimer = nil;
}

#pragma mark - ImageView

- (void)configureImageView
{
    if (!self.imageView)
    {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageURLArray[self.currentIndex]]];
        self.imageView.frame = self.frame;
        
        [self addSubview:self.imageView];
        [self sendSubviewToBack:self.imageView];
    }
}

- (void)transitionToNextImage
{
    // If incrementing the the next index goes past the imageURLArrays range set it back to the first image
    if (self.currentIndex + 1 >= self.imageURLArray.count)
    {
        self.currentIndex = 0;
    }
    else
    {
        self.currentIndex++;
    }
    
    [self transitionToImage:[self imageAtIndex:self.currentIndex]];
}

- (void)transitionToPreviousImage
{
    // If decrementing the the lower index goes past the imageURLArrays range set it to the last image
    if (self.currentIndex - 1 <= -1)
    {
        self.currentIndex = self.imageURLArray.count - 1;
    }
    else
    {
        self.currentIndex--;
    }
    
    [self transitionToImage:[self imageAtIndex:self.currentIndex]];
}

- (void)transitionToImageAtIndex:(NSInteger)index
{
    self.currentIndex = index;
    
    [self transitionToImage:[self imageAtIndex:self.currentIndex]];
}

- (void)transitionToImage:(UIImage *)image
{
    [UIView transitionWithView:self.imageView
                      duration:kTransitionDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self updateImage:image];
                        
                        if ([self.delegate respondsToSelector:@selector(didUpdateToColor:)])
                        {
                            [self.delegate didUpdateToColor:[self averageColor]];
                        }
                    }
                    completion:^(BOOL finished) {
                    }];
}

- (void)updateImage:(UIImage *)image
{
    self.imageView.image = image;
    
    if ([self.delegate respondsToSelector:@selector(didUpdateToImage:)])
    {
        [self.delegate didUpdateToImage:image];
    }
}

#pragma mark - Blur

- (void)configureBlurView
{
    if (!self.blurView)
    {
        CGFloat pointsOffscreen = 10;
        CGSize size = self.bounds.size;
        
        CGRect frame;
        frame.origin = CGPointMake(-pointsOffscreen, -pointsOffscreen);
        frame.size = CGSizeMake(size.width + pointsOffscreen, size.height + pointsOffscreen);
        
        self.blurView = [[CHFBlurView alloc] initWithFrame:frame
                                                  blurType:BlurTypeDark
                                             withAnimation:NO];
        
        self.blurView.layer.opacity = 0.0;
        
        [self addSubview:self.blurView];
        [self bringSubviewToFront:self.blurView];
    }
}

- (void)showBlur:(BOOL)show
{
    [self configureBlurView];
    
    [UIView animateWithDuration:kBlurViewFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.blurView.layer.opacity = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) [self.blurView removeFromSuperview];
                     }];
}

@end
