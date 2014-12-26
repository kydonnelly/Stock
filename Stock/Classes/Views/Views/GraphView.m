//
//  GraphView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/6/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "GraphView.h"

#import "ClassUtils.h"

static const int kLabelTextSize = 12;

@interface GraphView ()

@property (nonatomic) CGFloat axisValue;
@property (nonatomic) stepInfo xDrawingInfo;
@property (nonatomic) stepInfo yDrawingInfo;

@property (nonatomic, assign) id<GraphDatasource> datasource;

@end

@implementation GraphView

#pragma mark - Lifecycle

- (void)dealloc {
    _datasource = nil;
    
    [super dealloc];
}

- (void)resetView {
    [self.superview layoutSubviews];
}

#pragma mark - Setup

- (stepInfo)drawingInfoForStepInfo:(stepInfo)displayInfo
                     originalStart:(float)start
                      contextScale:(CGFloat)contextScale {
    stepInfo drawingInfo;
    drawingInfo.step = displayInfo.step * contextScale;
    drawingInfo.stepStart = (displayInfo.stepStart - start) * contextScale;
    drawingInfo.numSteps = displayInfo.numSteps;
    
    return drawingInfo;
}

- (void)refresh {
    CGSize size = self.frame.size;
    CGFloat xScale = size.width / (self.datasource.maxX - self.datasource.minX);
    CGFloat yScale = size.height / (self.datasource.maxY - self.datasource.minY);
    
    self.xDrawingInfo = [self drawingInfoForStepInfo:self.datasource.domainInfo
                                       originalStart:self.datasource.minX
                                        contextScale:xScale];
    
    self.yDrawingInfo = [self drawingInfoForStepInfo:self.datasource.rangeInfo
                                       originalStart:self.datasource.minY
                                        contextScale:yScale];
    
    [self setNeedsDisplay];
}

- (void)addAxisAtY:(float)axisY {
    float minY = self.datasource.minY;
    float maxY = self.datasource.maxY;
    
    self.axisValue = (maxY - axisY) / (maxY - minY) * self.frame.size.height;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 0.3f);
    [self drawVerticalLines:context];
    [self drawHorizontalLines:context];
    
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetLineWidth(context, 0.2f);
	[self drawAxis:context];
    
    [self addVerticalLabels:context];
    [self addHorizontalLabels:context];
    
    [self drawFunctions:context];
    
	UIGraphicsPopContext();
}

#pragma mark - Grid Lines

- (void)drawAxis:(CGContextRef)context {
    CGContextBeginPath(context);
    
	CGContextMoveToPoint(context, 0, self.axisValue);
	CGContextAddLineToPoint(context, self.frame.size.width, self.axisValue);
    
	CGContextStrokePath(context);
}

- (void)drawVerticalLines:(CGContextRef)context {
    CGContextBeginPath(context);
    
    CGFloat xPos = self.xDrawingInfo.stepStart;
    CGFloat height = self.frame.size.height;
    for (int i = 0; i < self.xDrawingInfo.numSteps; i++) {
        CGContextMoveToPoint(context, xPos, 0);
        CGContextAddLineToPoint(context, xPos, height);
        
        xPos += self.xDrawingInfo.step;
    }
    
    CGContextStrokePath(context);
}

- (void)drawHorizontalLines:(CGContextRef)context {
    CGContextBeginPath(context);
    
    CGFloat yPos = self.frame.size.height - self.yDrawingInfo.stepStart;
    CGFloat width = self.frame.size.width;
    for (int i = 0; i < self.yDrawingInfo.numSteps; i++) {
        CGContextMoveToPoint(context, 0, yPos);
        CGContextAddLineToPoint(context, width, yPos);
        
        yPos -= self.yDrawingInfo.step;
    }
    
    CGContextStrokePath(context);
}

#pragma mark - Grid Labels

- (void)drawText:(NSString *)text x:(CGFloat)x y:(CGFloat)y {
    CGRect textRect;
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:kLabelTextSize] forKey:NSFontAttributeName];
    
    textRect.size = [text sizeWithAttributes:fontAttributes];
    textRect.origin.x = x;
    textRect.origin.y = y - textRect.size.height;
    
    [text drawInRect:textRect withAttributes:fontAttributes];
}

- (void)addVerticalLabels:(CGContextRef)context {
    CGFloat xPosition = self.xDrawingInfo.stepStart;
    CGFloat height = self.frame.size.height;
    
    for (int i = 0; i < self.xDrawingInfo.numSteps; i++) {
        NSString *text = [self.datasource labelForX:xPosition];
        [self drawText:text x:xPosition y:height];
        
        xPosition += self.xDrawingInfo.step;
    }
}

- (void)addHorizontalLabels:(CGContextRef)context {
    CGFloat yPosition = self.frame.size.height - self.yDrawingInfo.stepStart;
    
    for (int i = 0; i < self.yDrawingInfo.numSteps; i++) {
        NSString *text = [self.datasource labelForY:yPosition];
        [self drawText:text x:0 y:yPosition];
        
        yPosition -= self.yDrawingInfo.step;
    }
}

#pragma mark - Graphing Functions

- (void)drawFunctions:(CGContextRef)context {
    NSArray *graphObjects = [self.datasource graphObjects];
    float minY = self.datasource.minY;
    float maxY = self.datasource.maxY;
    
    for (id<GraphObject> model in graphObjects) {
        CGContextSetStrokeColorWithColor(context, [model displayColor].CGColor);
        CGContextSetLineWidth(context, [model lineWidth]);
        
        NSArray *yValues = [model yValues];
        
        CGFloat xStep = self.frame.size.width / [yValues count];
        CGFloat frameHeight = self.frame.size.height;
        CGFloat yScale = frameHeight / (maxY - minY);
        
        CGFloat x = 0;
        CGFloat y = frameHeight - ([[yValues firstObject] floatValue] - minY) * yScale;
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, y);
        
        for (NSNumber *yNumber in yValues) {
            y = frameHeight - ([yNumber floatValue] - minY) * yScale;
            
            CGContextAddLineToPoint(context, x, y);
            CGContextMoveToPoint(context, x, y);
            
            x += xStep;
        }
        
        CGContextStrokePath(context);
    }
}

@end
