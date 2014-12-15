//
//  SimpleMovingAverageIndicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "SimpleMovingAverageIndicator.h"

#import "IndicatorList.h"
#import "LocalizationHelper.h"
#import "MovingAverageIndicator+Protected.h"

@implementation SimpleMovingAverageIndicator

RegisterForOptionsSlider

#pragma mark - Display Queries

- (NSString *)displayName {
    return [GET(LocalizationHelper) localizedStringForKey:@"SMA"];
}

- (UIColor *)displayColor {
    return [UIColor magentaColor];
}

- (float)lineWidth {
    return 0.5;
}

#pragma mark - Indicator logic

- (float)cacheInitialMovingAverage {
    // Don't bother dividing cached value; makes update easier.
    return self.cachedMovingAverage * self.frequency;
}

- (float)updateMovingAverage:(float)price {
    self.cachedMovingAverage += price;
    self.cachedMovingAverage -= [[self.priceQueue firstObject] floatValue];
    [self.priceQueue removeObjectAtIndex:0];
    
    return self.cachedMovingAverage * self.frequency;
}

@end
