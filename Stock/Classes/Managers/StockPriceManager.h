//
//  StockPriceManager.h
//  Stock
//
//  Created by Kyle Donnelly on 11/30/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Singleton+Protocol.h"

@interface StockPriceManager : NSObject <Singleton>

+ (int)daysAvailableForStockId:(int)stockId;

- (float)priceForStockId:(int)stockId;
- (float)lastPriceForStockId:(int)stockId daysAgo:(int)daysAgo;

- (NSArray *)pricesOfStockId:(int)stockId startDaysAgo:(float)startTime endDaysAgo:(float)endTime;

@end
