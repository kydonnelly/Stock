//
//  TriangleView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (void)setTriangleType:(TriangleType)triangleType {
    _triangleType = triangleType;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGPoint startPoint;
    CGPoint midPoint;
    CGPoint endPoint;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    switch (self.triangleType) {
        case TriangleTypeDown:
            startPoint = CGPointMake(0, 0);
            midPoint = CGPointMake(width / 2.f, height);
            endPoint = CGPointMake(width, 0);
            break;
        default:
            startPoint = CGPointMake(0, height);
            midPoint = CGPointMake(width / 2.f, 0);
            endPoint = CGPointMake(width, height);
            break;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, midPoint.x, midPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextClosePath(context);

    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextFillPath(context);
    
	UIGraphicsPopContext();
}

@end
