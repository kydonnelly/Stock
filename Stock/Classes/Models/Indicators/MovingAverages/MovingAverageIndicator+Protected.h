//
//  MovingAverageIndicator+Protected.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "MovingAverageIndicator.h"

@interface MovingAverageIndicator (Protected)

@property (nonatomic) int period;
@property (nonatomic, retain) NSMutableArray *priceQueue;
@property (nonatomic) float cachedMovingAverage;

- (float)frequency;

- (float)cacheInitialMovingAverage;
- (float)updateMovingAverage:(float)price;

@end
