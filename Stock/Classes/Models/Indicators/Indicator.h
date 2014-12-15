//
//  Indicator.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//
//  Primary indicators have a range which scales
//      according to the underlying stock's price.
//  eg. moving averages, bollinger bands
//
//  Secondary indicators have a different scale.
//  eg. RSI, MACD
//

#import <Foundation/Foundation.h>

#import "Indicator+Types.h"

@interface Indicator : NSObject

- (void)setupWithPrices:(NSArray *)prices;

- (NSArray *)allPrices;

- (float)minPrice;
- (float)maxPrice;

- (IndicatorType)indicatorType;
- (NSString *)displayName;

@end

@interface SecondaryIndicator : Indicator

@end