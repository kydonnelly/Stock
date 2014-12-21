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

- (int)displayPriority {
    return INT_MAX;
}

- (NSString *)displayName {
    return @"Price";
}

- (UIColor *)displayColor {
    return [UIColor blackColor];
}

- (float)lineWidth {
    return 0.4;
}

@end
