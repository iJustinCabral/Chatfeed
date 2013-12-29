//
//  CHFTriangleLayer.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/7/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//typedef NS_ENUM(NSInteger, TriangleStyle)
//{
//    TriangleStyle
//};

typedef NS_ENUM(NSInteger, Edge)
{
    EdgeTop = 0,
    EdgeRight,
    EdgeBottom,
    EdgeLeft
};

@interface CHFTriangleLayer : CAShapeLayer

+ (instancetype)triangleOnEdge:(Edge)edge
                  atEdgeOffset:(CGFloat)offset
                       inFrame:(CGRect)frame
                     withDepth:(CGFloat)depth;

@end
