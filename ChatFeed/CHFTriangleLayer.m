//
//  CHFTriangleLayer.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/7/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFTriangleLayer.h"

@implementation CHFTriangleLayer

+ (instancetype)triangleOnEdge:(Edge)edge
                  atEdgeOffset:(CGFloat)offset
                       inFrame:(CGRect)frame
                     withDepth:(CGFloat)depth
{
    //TODO: Need to get the angle crossing point of the triangle when partly offscreen
    
    // Determine if arrow is partly offscreen
    
    
    // Get our layer and path going
    CHFTriangleLayer *layer = [[CHFTriangleLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Start From top left, going clockwise...
    CGPathMoveToPoint(path, NULL, 0, 0);
    
    
    
    switch (edge)
    {
        case EdgeTop:
        {
            
        }
            break;
        case EdgeRight:
        {
            
        }
            break;
        case EdgeBottom:
        {
            
            
            CGPathAddLineToPoint(path, NULL, frame.size.width, 0); // Top Right
            CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height); // Bottom Right
            
            CGPathAddLineToPoint(path, NULL, offset + (depth / 2), frame.size.height); // Bottom Right of triangle
            CGPathAddLineToPoint(path, NULL, offset, frame.size.height - depth); // Top of triangle
            CGPathAddLineToPoint(path, NULL, offset - (depth / 2), frame.size.height); // Bottom Left of triangle
            
            CGPathAddLineToPoint(path, NULL, 0, frame.size.height); // Bottom Left
        }
            break;
        case EdgeLeft:
        {
            
        }
            break;
        default:
            NSAssert(edge, @"Invalid Edge given");
            break;
    }
    
    CGPathCloseSubpath(path); // Close off path
    [layer setPath:path];
    CGPathRelease(path);
    
    return layer;
}

@end
