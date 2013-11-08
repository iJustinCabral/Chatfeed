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

- (instancetype)initWithFrame:(CGRect)frame
                blurWallpaper:(BOOL)blur
                  randomStart:(BOOL)randomStart
                  shouldCycle:(BOOL)shouldCycle
               cycleInReverse:(BOOL)cycleInReverse;

@property (nonatomic, assign) id <CHFWallpaperDelegate> delegate;

@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic) BOOL blurWallpaper;
@property (nonatomic) BOOL randomStart;
@property (nonatomic) BOOL shouldCycle;
@property (nonatomic) BOOL cycleInReverse;

- (UIColor *)averageColor;

- (void)transitionToImageAtIndex:(NSInteger)index;

@end

