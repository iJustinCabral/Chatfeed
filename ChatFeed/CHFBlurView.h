//
//  CHFBlurView.h
//  CHFBlur
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

typedef NS_ENUM (NSUInteger, BlurType)
{
    BlurTypeLight = 0,
    BlurTypeDark = 1
};

#import <UIKit/UIKit.h>

@interface CHFBlurView : UIView

- (instancetype)initWithFrame:(CGRect)frame blurType:(BlurType)blurtype withAnimation:(BOOL)animated;

@property (nonatomic) BlurType blurType;

- (void)showBlurViewAnimated:(BOOL)animated withCompletion:(void (^)(void))completion;
- (void)hideBlurViewAnimated:(BOOL)animated withCompletion:(void (^)(void))completion;

@end
