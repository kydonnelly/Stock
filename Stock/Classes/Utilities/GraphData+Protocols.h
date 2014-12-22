//
//  GraphData+Protocols.h
//  Stock
//
//  Created by Kyle Donnelly on 12/21/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat step;
    CGFloat stepStart;
    int numSteps;
} stepInfo;

@protocol GraphDatasource

- (NSArray *)graphObjects;

- (NSString *)labelForX:(CGFloat)x;
- (NSString *)labelForY:(CGFloat)y;

- (float)minX;
- (float)maxX;
- (float)minY;
- (float)maxY;

- (stepInfo)rangeInfo;
- (stepInfo)domainInfo;

@end

@protocol GraphObject

- (void)initializeFromValues:(NSArray *)yValues;

- (NSArray *)yValues;
- (UIColor *)displayColor;
- (CGFloat)lineWidth;

@end