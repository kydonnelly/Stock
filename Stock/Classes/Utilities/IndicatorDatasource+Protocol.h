//
//  ActiveIndicatorDatasource.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Indicator+Types.h"

@protocol IndicatorDatasource

- (NSMutableSet *)indicatorsOfType:(IndicatorType)indicatorType;

@end
