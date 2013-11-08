//
//  BlackholeView.h
//  BlackholeView
//
//  Created by Larry Ryan on 10/26/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFNonInteractiveView.h"

@interface BlackholeView : CHFNonInteractiveView

- (instancetype)initWithFrame:(CGRect)frame andParticleColor:(UIColor *)color;

@property (nonatomic, strong) UIColor *particleColor;

@end