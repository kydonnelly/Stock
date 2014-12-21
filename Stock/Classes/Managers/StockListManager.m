//
//  StockListManager.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockListManager.h"

#import "AppData.h"
#import "ClassUtils.h"
#import "NSArray+Sorted.h"
#import "Stock.h"

static const int kRecentlyViewedQueueSize = 5;

@interface StockListManager ()

@property (nonatomic, retain) NSMutableDictionary *stockKeysForCategory;

@end

@implementation StockListManager

#pragma mark - Class Convention

+ (id)keyForStockCategory:(StockSelectionCategory)category {
    return KEY(category);
}

+ (StockSelectionCategory)categoryForKey:(id)key {
    return [key intValue];
}

#pragma mark - Lifecycle

MakeSingleton

- (id)init {
    if (self = [super init]) {
        self.stockKeysForCategory = [NSMutableDictionary dictionary];
        
        [self setupStockCategories];
    }
    
    return self;
}

- (void)dealloc {
    ReleaseIvar(_stockKeysForCategory);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupStocks:(NSMutableArray *)stocks inCategory:(StockSelectionCategory)category {
    id categoryKey = [[self class] keyForStockCategory:category];
    [self.stockKeysForCategory setObject:stocks forKey:categoryKey];
}

- (void)setupStockCategories {
    [self setupStocks:appData(favoriteStocks)
           inCategory:StockSelectionCategoryFavorite];
    
    [self setupStocks:appData(offlineStocks)
           inCategory:StockSelectionCategoryTemporary];
    
    [self setupStocks:appData(recentStocks)
           inCategory:StockSelectionCategoryRecent];
}

#pragma mark - queries

- (NSArray *)activeStockCategories {
    NSMutableArray *activeCategories = [NSMutableArray arrayWithCapacity:[self.stockKeysForCategory count]];
    
    for (id key in self.stockKeysForCategory) {
        NSArray *stocksInCategory = [self.stockKeysForCategory objectForKey:key];
        if ([stocksInCategory count]) {
            [activeCategories addObject:key];
        }
    }
    
    return activeCategories;
}

- (NSArray *)activeStocksForCategory:(StockSelectionCategory)category {
    // public interface is not mutable
    return [self stocksForCategory:category];
}

- (NSMutableArray *)stocksForCategory:(StockSelectionCategory)category {
    id categoryKey = [[self class] keyForStockCategory:category];
    return [self.stockKeysForCategory objectForKey:categoryKey];
}

#pragma mark - Updates

- (StockSelectionCategory)changeStatusForStock:(Stock *)stock currentCategory:(StockSelectionCategory)currentCategory {
    StockSelectionCategory newCategory = StockSelectionCategoryNone;
    BOOL isValidStatusChange = YES;
    
    switch (currentCategory) {
        case StockSelectionCategoryTemporary:
            newCategory = StockSelectionCategoryFavorite;
            break;
        case StockSelectionCategoryFavorite:
            newCategory = StockSelectionCategoryTemporary;
            break;
        default:
            isValidStatusChange = NO;
            break;
    }
    
    if (isValidStatusChange) {
        [self addStockId:stock.stockId toCategory:newCategory];
        [self removeStockId:stock.stockId fromCategory:currentCategory];
    }
    
    return newCategory;
}

- (void)addStockId:(int)stockId toCategory:(StockSelectionCategory)category {
    id stockKey = [Stock keyForStockId:stockId];
    NSMutableArray *stockKeys = [self stocksForCategory:category];
    [stockKeys addSortableObject:stockKey];
}

- (void)removeStockId:(int)stockId fromCategory:(StockSelectionCategory)category {
    id stockKey = [Stock keyForStockId:stockId];
    NSMutableArray *stockKeys = [self stocksForCategory:category];
    [stockKeys removeSortableObject:stockKey];
}

- (void)addStockIdToRecentQueue:(int)stockId {
    id stockKey = [Stock keyForStockId:stockId];
    NSMutableArray *stockKeys = [self stocksForCategory:StockSelectionCategoryRecent];
    
    if (![stockKeys containsObject:stockKey]) {
        [stockKeys insertObject:stockKey atIndex:0];
        while ([stockKeys count] > kRecentlyViewedQueueSize) {
            [stockKeys removeLastObject];
        }
    }
}

@end
