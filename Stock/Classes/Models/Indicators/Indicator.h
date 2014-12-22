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

#import "GraphData+Protocols.h"
#import "Indicator+Types.h"

@interface Indicator : NSObject <GraphObject>

- (IndicatorType)indicatorType;

- (float)minPrice;
- (float)maxPrice;

- (NSString *)displayDetailsAtPriceIndex:(int)index;
- (NSString *)displayName;
- (int)displayPriority;

@end

@interface SecondaryIndicator : Indicator

@end