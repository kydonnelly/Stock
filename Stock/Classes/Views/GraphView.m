//
//  GraphView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/6/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "GraphView.h"

#import "ClassUtils.h"
#import "Indicator.h"

static const int kVerticalSections = 5;
static const int kHorizontalSections = 4;
static const CGFloat kVerticalBuffer = .05f;
static const int kLabelTextSize = 12;

typedef struct {
    CGFloat step;
    CGFloat stepStart;
} stepInfo;

typedef struct {
    int displayPrecision;
    stepInfo displayStepInfo;
    stepInfo drawingStepInfo;
} axisInfo;

@interface GraphView ()

@property (nonatomic) CGFloat axisValue;
@property (nonatomic) axisInfo xStepInfo;
@property (nonatomic) axisInfo yStepInfo;

@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat maxY;

@property (nonatomic, assign) id<IndicatorDatasource> indicatorDatasource;

@end

@implementation GraphView

#pragma mark - Lifecycle

- (void)dealloc {
    _indicatorDatasource = nil;
    
    [super dealloc];
}

#pragma mark - Setup

- (axisInfo)stepForValuesFrom:(CGFloat)start
                           to:(CGFloat)end
                     numSteps:(int)steps
                 contextScale:(CGFloat)contextScale {
    axisInfo axisInfo;
    stepInfo displayInfo;
    stepInfo drawingInfo;
    
    CGFloat range = end - start;
    CGFloat rawStep = range / steps;
    
    float scale = 1;
    int displayPrecision = 0;
    while (rawStep * scale < 1.f) {
        scale *= 10;
        displayPrecision++;
    }
    while (rawStep * scale > 10.f) {
        scale /= 10;
    }
    
    int scaledStep = rawStep * scale;
    int remainder = range * scale - (scaledStep * (steps - 1));
    
    displayInfo.step = scaledStep / scale;
    displayInfo.stepStart = start + (remainder / 2.f) / scale;
    if (remainder % 2) {
        displayPrecision++;
    }
    
    drawingInfo.step = displayInfo.step * contextScale;
    drawingInfo.stepStart = (displayInfo.stepStart - start) * contextScale;
    
    axisInfo.displayPrecision = displayPrecision;
    axisInfo.displayStepInfo = displayInfo;
    axisInfo.drawingStepInfo = drawingInfo;
    
    return axisInfo;
}

- (void)setMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY axisY:(float)axisY {
    CGFloat yBuffer = (maxY - minY) * kVerticalBuffer;
    maxY += yBuffer;
    minY -= yBuffer;
    
    CGFloat xScale = self.frame.size.width / (maxX - minX);
    CGFloat yScale = self.frame.size.height / (maxY - minY);
    
    self.xStepInfo = [self stepForValuesFrom:minX
                                          to:maxX
                                    numSteps:kHorizontalSections
                                contextScale:xScale];
    self.yStepInfo = [self stepForValuesFrom:minY
                                          to:maxY
                                    numSteps:kVerticalSections
                                contextScale:yScale];
    
    self.minY = minY;
    self.maxY = maxY;
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
    
    [self drawPrimaryIndicators:context];
    
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
    
    CGFloat xPos = self.xStepInfo.drawingStepInfo.stepStart;
    CGFloat height = self.frame.size.height;
    for (int i = 0; i < kHorizontalSections; i++) {
        CGContextMoveToPoint(context, xPos, 0);
        CGContextAddLineToPoint(context, xPos, height);
        
        xPos += self.xStepInfo.drawingStepInfo.step;
    }
    
    CGContextStrokePath(context);
}

- (void)drawHorizontalLines:(CGContextRef)context {
    CGContextBeginPath(context);
    
    CGFloat yPos = self.frame.size.height - self.yStepInfo.drawingStepInfo.stepStart;
    CGFloat width = self.frame.size.width;
    for (int i = 0; i < kVerticalSections; i++) {
        CGContextMoveToPoint(context, 0, yPos);
        CGContextAddLineToPoint(context, width, yPos);
        
        yPos -= self.yStepInfo.drawingStepInfo.step;
    }
    
    CGContextStrokePath(context);
}

#pragma mark - Grid Labels

- (void)drawNumberText:(float)value decimalPrecision:(int)precision x:(CGFloat)x y:(CGFloat)y {
    NSString *format = [@"%" stringByAppendingString:[NSString stringWithFormat:@".%df", precision]];
    NSString *text = [NSString stringWithFormat:format, value];
    
    CGRect textRect;
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:kLabelTextSize] forKey:NSFontAttributeName];
    
    textRect.size = [text sizeWithAttributes:fontAttributes];
    textRect.origin.x = x;
    textRect.origin.y = y - textRect.size.height;
    
    [text drawInRect:textRect withAttributes:fontAttributes];
}

- (void)addVerticalLabels:(CGContextRef)context {
    CGFloat xPos = self.xStepInfo.drawingStepInfo.stepStart;
    float xValue = self.xStepInfo.displayStepInfo.stepStart;
    CGFloat height = self.frame.size.height;
    
    for (int i = 0; i < kHorizontalSections; i++) {
        [self drawNumberText:xValue decimalPrecision:self.xStepInfo.displayPrecision x:xPos y:height];
        
        xPos += self.xStepInfo.drawingStepInfo.step;
        xValue += self.xStepInfo.displayStepInfo.step;
    }
}

- (void)addHorizontalLabels:(CGContextRef)context {
    CGFloat yPosition = self.frame.size.height - self.yStepInfo.drawingStepInfo.stepStart;
    float yValue = self.yStepInfo.displayStepInfo.stepStart;
    
    for (int i = 0; i < kVerticalSections; i++) {
        [self drawNumberText:yValue decimalPrecision:self.yStepInfo.displayPrecision x:0 y:yPosition];
        
        yPosition -= self.yStepInfo.drawingStepInfo.step;
        yValue += self.yStepInfo.displayStepInfo.step;
    }
}

#pragma mark - Price & Indicators

- (void)drawPrimaryIndicators:(CGContextRef)context {
    NSSet *primaryIndicators = [self.indicatorDatasource activeIndicatorsOfType:IndicatorTypePrimary];
    
    for (Indicator *indicator in primaryIndicators) {
        CGContextSetStrokeColorWithColor(context, [indicator displayColor].CGColor);
        CGContextSetLineWidth(context, [indicator lineWidth]);
        
        NSArray *prices = [indicator allPrices];
        
        CGFloat xStep = self.frame.size.width / [prices count];
        CGFloat frameHeight = self.frame.size.height;
        CGFloat yScale = frameHeight / (self.maxY - self.minY);
        
        CGFloat x = 0;
        CGFloat y = frameHeight - ([[prices firstObject] floatValue] - self.minY) * yScale;
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, x, y);
        
        for (NSNumber *yNumber in prices) {
            y = frameHeight - ([yNumber floatValue] - self.minY) * yScale;
            
            CGContextAddLineToPoint(context, x, y);
            CGContextMoveToPoint(context, x, y);
            
            x += xStep;
        }
        
        CGContextStrokePath(context);
    }
}

@end
