//
//  ActiveIndicatorDatasource.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Indicator+Types.h"

@class Indicator;

@protocol IndicatorDatasource

- (NSSet *)activeIndicatorsOfType:(IndicatorType)indicatorType;
- (void)updateIndicator:(Indicator *)indicator isActive:(BOOL)isActive;

@end
