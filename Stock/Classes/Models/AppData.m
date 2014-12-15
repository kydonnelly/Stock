//
//  AppData.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "AppData.h"

#import "ClassUtils.h"
#import "Stock.h" // for testing

@implementation AppData

#pragma mark - Lifecycle

MakeSingleton

- (id)init {
    if (self = [super init]) {
        self.stocks = [NSMutableDictionary dictionary];
        
        self.stockPriceHistories = [NSMutableDictionary dictionary];
        
        self.favoriteStocks = [NSMutableArray array];
        self.offlineStocks = [NSMutableArray array];
        self.recentStocks = [NSMutableArray array];
        
        self.defaultIndicators = [NSMutableArray array];
        
        [self initializeStockDataForTesting];
    }
    
    return self;
}

- (void)dealloc {
    ReleaseIvar(_stocks);
    
    ReleaseIvar(_stockPriceHistories);
    
    ReleaseIvar(_favoriteStocks);
    ReleaseIvar(_offlineStocks);
    ReleaseIvar(_recentStocks);
    
    ReleaseIvar(_defaultIndicators);
    
    [super dealloc];
}

#pragma mark - Test setup

- (void)initializeStockDataForTesting {
    // NOTE(kyle): favorites will later be loaded from stored user data or passed from server. Temporary and recents will probably only be stored on client so this simulates a fresh launch.
    NSArray *testTickers = @[@"MSFT", @"AAPL", @"GOOG", @"INTC", @"TSLA", @"P"];
    
    int i=0;
    for (NSString *ticker in testTickers) {
        Stock *testStock = [[[Stock alloc] init] autorelease];
        testStock.stockId = ++i;
        testStock.ticker = ticker;
        
        [self.stocks setObject:testStock forKey:KEY(i)];
        [self.favoriteStocks addObject:KEY(i)];
        
        NSMutableArray *priceHistory = [NSMutableArray array];
        float startingPrice = arc4random() % 100;
        float lastPrice = startingPrice;
        
        for (int day = 0; day < 5; day++) {
            NSMutableArray *prices = [NSMutableArray array];
            for (int price = 0; price < 250; price++) {
                float random = arc4random() % 11;
                float delta = (random - 5) / 10.f;
                float newPrice = MAX(0.01f, lastPrice + delta);
                [prices addObject:@(newPrice)];
                lastPrice = newPrice;
            }
            
            [priceHistory addObject:prices];
        }
        
        [self.stockPriceHistories setObject:priceHistory forKey:KEY(i)];
    }
}

@end
