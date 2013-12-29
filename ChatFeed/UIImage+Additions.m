//
//  UIImage+Additions.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/11/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)imageNamedWithoutCaching:(NSString *)name
{
    NSString *pathName = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], name];
    
    return [self imageWithContentsOfFile:pathName];
}

@end
