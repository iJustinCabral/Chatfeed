//
//  CHFWallpaperView.h
//  ChatFeed
//
//  Created by Larry Ryan on 10/26/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHFWallpaperDelegate <NSObject>

@optional
- (void)didUpdateToImage:(UIImage *)image;
- (void)didUpdateToColor:(UIColor *)color;

@end

@interface CHFWallpaperView : UIView

- (instancetype)initWithFrame:(CGRect)frame andBlurWallpaper:(BOOL)blur;

@property (nonatomic, assign) id <CHFWallpaperDelegate> delegate;

@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic) BOOL blurWallpaper;

- (UIColor *)averageColor;

- (void)transitionToImageAtIndex:(NSInteger)index;

@end

