//
//  MovingAverageIndicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "MovingAverageIndicator.h"

#import "ClassUtils.h"
#import "Indicator+Protected.h"

static const int kDefaultPeriod = 20;

@interface MovingAverageIndicator ()

@property (nonatomic) int period;
@property (nonatomic) float frequency;

@property (nonatomic, retain) NSMutableArray *priceQueue;
@property (nonatomic) BOOL isPriceQueueFull;
@property (nonatomic) float cachedMovingAverage;

@end

@implementation MovingAverageIndicator

#pragma mark - Lifecycle

- (id)init {
    if (self = [super init]) {
        self.period = kDefaultPeriod;
    }
    
    return self;
}

- (void)dealloc {
    ReleaseIvar(_priceQueue);
    
    [super dealloc];
}

- (void)setPeriod:(int)period {
    if (period != _period) {
        Assert(period > 0, @"Moving average period must be positive");
        _period = period;
        _frequency = 1.f / period;
    }
}

#pragma mark - Setup

- (void)initializeFromValues:(NSArray *)yValues {
    self.priceQueue = [NSMutableArray array];
    self.isPriceQueueFull = NO;
    self.cachedMovingAverage = 0;
    
    // todo: need to load older prices if possible
    [super initializeFromValues:yValues];
}

#pragma mark - Indicator logic

- (float)indicatorPriceForRawPrice:(float)price {
    [self.priceQueue addObject:@(price)];
    
    if (!self.isPriceQueueFull) {
        int priceQueueSize = [self.priceQueue count];
        self.cachedMovingAverage += price;
        
        if (priceQueueSize >= self.period) {
            AssertWithFormat([self.priceQueue count] == self.period, @"Moving Average Price Queue has more prices stored than its period! Has %d, expected %d", [self.priceQueue count], self.period);
            
            self.isPriceQueueFull = YES;
            return [self cacheInitialMovingAverage];
        } else {
            return self.cachedMovingAverage / priceQueueSize;
        }
    } else {
        return [self updateMovingAverage:price];
    }
}

#pragma mark - Abstract Indicator Logic

- (float)cacheInitialMovingAverage {
    AbstractMethod
    return 0.f;
}

- (float)updateMovingAverage:(float)price {
    AbstractMethod
    return 0.f;
}

@end
