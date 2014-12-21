//
//  Indicator.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Indicator.h"

#import "ClassUtils.h"

@interface Indicator ()

@property (nonatomic, retain) NSMutableArray *prices;

@property (nonatomic) float minPrice;
@property (nonatomic) float maxPrice;

@end

@implementation Indicator

#pragma mark - Lifecycle

- (IndicatorType)indicatorType {
    return IndicatorTypePrimary;
}

- (void)dealloc {
    ReleaseIvar(_prices);
    
    [super dealloc];
}

#pragma mark - setup

- (void)setupWithPrices:(NSArray *)prices {
    self.prices = [NSMutableArray arrayWithCapacity:[prices count]];
    
    self.minPrice = FLT_MAX;
    self.maxPrice = 0.f;
    
    for (NSNumber *priceNumber in prices) {
        float price = [self indicatorPriceForRawPrice:[priceNumber floatValue]];
        [self.prices addObject:@(price)];
        
        if (price < self.minPrice) {
            self.minPrice = price;
        }
        if (price > self.maxPrice) {
            self.maxPrice = price;
        }
    }
}

- (float)indicatorPriceForRawPrice:(float)price {
    AbstractMethod
    return 0;
}

#pragma mark - Display Queries

- (NSArray *)allPrices {
    return self.prices;
}

- (NSString *)displayDetailsAtPriceIndex:(int)index {
    // todo: variable display precision as in graph view
    return [NSString stringWithFormat:@"%.2f", [[self.prices objectAtIndex:index] floatValue]];
}

- (NSString *)displayName {
    AbstractMethod
    return nil;
}

- (UIColor *)displayColor {
    AbstractMethod
    return [UIColor blackColor];
}

- (float)lineWidth {
    AbstractMethod
    return 0.f;
}

#pragma mark - Display Sorting

- (int)displayPriority {
    return 0;
}

- (NSComparisonResult)compare:(Indicator *)otherIndicator {
    int priority1 = [self displayPriority];
    int priority2 = [otherIndicator displayPriority];
    
    if (priority1 > priority2) {
        return NSOrderedAscending;
    } else if (priority1 < priority2) {
        return NSOrderedDescending;
    } else {
        return [[self displayName] compare:[otherIndicator displayName]];
    }
}

@end

@implementation SecondaryIndicator

- (IndicatorType)indicatorType {
    return IndicatorTypeSecondary;
}

@end