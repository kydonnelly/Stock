//
//  Stock.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Stock.h"

#import "ClassUtils.h"
#import "AppData.h"

@implementation Stock

#pragma mark - Access helper

+ (id)keyForStockId:(int)stockId {
    return KEY(stockId);
}

+ (Stock *)loadByStockId:(int)stockId {
    return [appData(stocks) objectForKey:[self keyForStockId:stockId]];
}

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_ticker);
    ReleaseIvar(_companyName);
    
    [super dealloc];
}

@end
