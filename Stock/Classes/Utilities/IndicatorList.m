//
//  IndicatorList.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "IndicatorList.h"

#import "ClassUtils.h"
#import "Indicator.h"
#import "NSArray+Sorted.h"

@interface IndicatorList ()

@property (nonatomic, retain) NSMutableArray *indicators;

@end

@implementation IndicatorList

#pragma mark - Lifecycle

MakeSingleton

- (id)init {
    if (self = [super init]) {
        self.indicators = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    ReleaseIvar(_indicators);
    
    [super dealloc];
}

#pragma mark - Registration

- (void)registerIndicator:(Indicator *)indicator {
    [self.indicators addSortableObject:indicator];
}

#pragma mark - Query

- (NSArray *)allIndicators {
    return self.indicators;
}

@end
