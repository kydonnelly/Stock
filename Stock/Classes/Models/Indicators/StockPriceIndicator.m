//
//  StockPriceIndicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockPriceIndicator.h"

#import "Indicator+Protected.h"

@implementation StockPriceIndicator

- (float)indicatorPriceForRawPrice:(float)price {
    return price;
}

@end
