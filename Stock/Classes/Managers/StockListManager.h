//
//  StockListManager.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton+Protocol.h"

typedef enum {
    StockSelectionCategoryNone = 0,
    StockSelectionCategoryRecent,
    StockSelectionCategoryFavorite,
    StockSelectionCategoryTemporary,
} StockSelectionCategory;

@class Stock;

@interface StockListManager : NSObject <Singleton>

+ (StockSelectionCategory)categoryForKey:(id)key;

// todo(kyle): make these sorted arrays
- (NSArray *)activeStockCategories;
- (NSArray *)activeStocksForCategory:(StockSelectionCategory)category;

- (StockSelectionCategory)changeStatusForStock:(Stock *)stock currentCategory:(StockSelectionCategory)currentCategory;

- (void)addStockIdToRecentQueue:(int)stockId;

@end
