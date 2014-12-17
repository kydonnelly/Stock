//
//  StockPriceManager.m
//  Stock
//
//  Created by Kyle Donnelly on 11/30/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockPriceManager.h"

#import "AppData.h"
#import "ClassUtils.h"
#import "Stock.h"

@implementation StockPriceManager

MakeSingleton

#pragma mark - Helpers

- (NSArray *)dailyPricesForStock:(int)stockId {
    id stockKey = [Stock keyForStockId:stockId];
    return [appData(stockPriceHistories) objectForKey:stockKey];
}

- (int)daysAvailableForStockId:(int)stockId {
    return [[self dailyPricesForStock:stockId] count];
}

#pragma mark - Price access

- (float)priceForStockId:(int)stockId {
    return [self lastPriceForStockId:stockId daysAgo:0];
}

- (float)lastPriceForStockId:(int)stockId daysAgo:(int)daysAgo {
    NSArray *dailyPrices = [self dailyPricesForStock:stockId];;
    int dailyPricesCount = [dailyPrices count];
    
    NSArray *prices = nil;
    if (dailyPricesCount > daysAgo) {
        prices = [dailyPrices objectAtIndex:(dailyPricesCount - daysAgo - 1)];
    }
    
    return [[prices lastObject] floatValue];
}

- (NSArray *)pricesOfStockId:(int)stockId startDaysAgo:(float)startTime endDaysAgo:(float)endTime {
    Assert(startTime < 0.f && endTime <= 0.f, @"Requesting prices in the future.");
    
    NSArray *dailyPrices = [self dailyPricesForStock:stockId];
    int dailyPricesCount = [dailyPrices count];
    
    float startIndex = MAX(dailyPricesCount + startTime, 0);
    float endIndex = dailyPricesCount + endTime;
    int endIndexCeiling = ceil(endIndex);
    
    float startOffset = startIndex - (int)startIndex;
    float endOffset = 1.f - (endIndexCeiling - endIndex);
    
    NSArray *startPrices = [dailyPrices objectAtIndex:(int)startIndex];
    NSArray *endPrices = [dailyPrices objectAtIndex:(endIndexCeiling - 1)];
    int startPricesCount = [startPrices count];
    BOOL startEndOverlap = ((int)startIndex >= endIndexCeiling - 1);
    
    NSRange range;
    range.location = startPricesCount * startOffset;
    range.length = startPricesCount - range.location;
    if (startEndOverlap) {
        range.length = [endPrices count] * endOffset - range.location;
    }
    
    NSMutableArray *prices = [NSMutableArray array];
    [prices addObjectsFromArray:[startPrices subarrayWithRange:range]];
    
    for (int i = startIndex + 1; i < endIndexCeiling - 1; i++) {
        [prices addObjectsFromArray:[dailyPrices objectAtIndex:i]];
    }
    
    if (!startEndOverlap) {
        range.location = 0;
        range.length = [endPrices count] * endOffset;
        [prices addObjectsFromArray:[endPrices subarrayWithRange:range]];
    }
    
    return prices;
}

@end
