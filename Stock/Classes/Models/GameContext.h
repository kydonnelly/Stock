//
//  GameContext.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Singleton+Protocol.h"

#define gcontext(property) GET(GameContext).property

@interface GameContext : NSObject <Singleton>

@property (nonatomic, retain) NSMutableDictionary *stocks;

@property (nonatomic, retain) NSMutableDictionary *stockPriceHistories;

@property (nonatomic, retain) NSMutableArray *favoriteStocks;
@property (nonatomic, retain) NSMutableArray *offlineStocks;
@property (nonatomic, retain) NSMutableArray *recentStocks;

@property (nonatomic, retain) NSMutableArray *defaultIndicators;

@end
