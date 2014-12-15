//
//  StockPriceManager.m
//  Stock
//
//  Created by Kyle Donnelly on 11/30/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockPriceManager.h"

#import "AppData.h"
#import "Stock.h"

@implementation StockPriceManager

MakeSingleton

- (float)priceForStockId:(int)stockId {
    return [self lastPriceForStockId:stockId daysAgo:0];
}

- (float)lastPriceForStockId:(int)stockId daysAgo:(int)daysAgo {
    id stockKey = [Stock keyForStockId:stockId];
    NSArray *dailyPrices = [appData(stockPriceHistories) objectForKey:stockKey];
    int dailyPricesCount = [dailyPrices count];
    
    NSArray *prices = nil;
    if (dailyPricesCount > daysAgo) {
        prices = [dailyPrices objectAtIndex:(dailyPricesCount - daysAgo - 1)];
    }
    
    return [[prices lastObject] floatValue];
}

- (NSArray *)pricesOfStockId:(int)stockId startTime:(int)startTime endTime:(int)endTime {
    id stockKey = [Stock keyForStockId:stockId];
    NSArray *dailyPrices = [appData(stockPriceHistories) objectForKey:stockKey];
    int dailyPricesCount = [dailyPrices count];
    
    int startIndex = MAX(dailyPricesCount + startTime - 1, 0);
    int endIndex = dailyPricesCount + endTime;
    
    NSMutableArray *prices = [NSMutableArray array];
    for (int i=startIndex; i < endIndex; i++) {
        [prices addObjectsFromArray:[dailyPrices objectAtIndex:i]];
    }
    
    return prices;
}

@end
