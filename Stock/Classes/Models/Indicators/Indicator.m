//
//  Indicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Indicator.h"

#import "ClassUtils.h"

#define MAX_GRAPH_POINTS 500

@interface Indicator ()

@property (nonatomic, retain) NSMutableArray *yValues;

@property (nonatomic) float minPrice;
@property (nonatomic) float maxPrice;

@end

@implementation Indicator

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_yValues);
    
    [super dealloc];
}

#pragma mark - setup

- (void)setupWithPrices:(NSArray *)prices {
    self.minPrice = FLT_MAX;
    self.maxPrice = 0.f;
    
    self.yValues = [NSMutableArray array];
    int removalMod = [prices count] / MAX_GRAPH_POINTS;
    int removalCounter = 0;
    
    for (NSNumber *priceNumber in prices) {
        if (removalCounter < removalMod) {
            removalCounter++;
        } else {
            float price = [self indicatorPriceForRawPrice:[priceNumber floatValue]];
            if (price < self.minPrice) {
                self.minPrice = price;
            }
            if (price > self.maxPrice) {
                self.maxPrice = price;
            }
            
            removalCounter = 0;
            [self.yValues addObject:@(price)];
        }
    }
}

- (float)indicatorPriceForRawPrice:(float)price {
    AbstractMethod
    return 0;
}

#pragma mark - Display Queries

- (NSArray *)allPrices {
    return self.yValues;
}

- (IndicatorType)indicatorType {
    return IndicatorTypePrimary;
}

- (NSString *)displayName {
    AbstractMethod
    return nil;
}

@end

@implementation SecondaryIndicator

- (IndicatorType)indicatorType {
    return IndicatorTypeSecondary;
}

@end