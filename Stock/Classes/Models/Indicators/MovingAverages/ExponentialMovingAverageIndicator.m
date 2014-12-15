//
//  ExponentialMovingAverageIndicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "ExponentialMovingAverageIndicator.h"

#import "IndicatorList.h"
#import "LocalizationHelper.h"
#import "MovingAverageIndicator+Protected.h"

@interface ExponentialMovingAverageIndicator ()

@property (nonatomic) float decay;

@end

@implementation ExponentialMovingAverageIndicator

#pragma mark - Lifecycle

RegisterForOptionsSlider

- (void)setPeriod:(int)period {
    if (period != self.period) {
        [super setPeriod:period];
        _decay = 2.f / (period + 1);
    }
}

#pragma mark - Display Queries

- (NSString *)displayName {
    return [GET(LocalizationHelper) localizedStringForKey:@"EMA"];
}

#pragma mark - Indicator logic

- (float)cacheInitialMovingAverage {
    // updates rely on 'proper' cached value.
    // we don't use the queue anymore.
    self.priceQueue = nil;
    self.cachedMovingAverage *= self.frequency;
    
    return self.cachedMovingAverage;
}

- (float)updateMovingAverage:(float)price {
    self.cachedMovingAverage += (price - self.cachedMovingAverage) * self.decay;
    
    return self.cachedMovingAverage;
}

@end
