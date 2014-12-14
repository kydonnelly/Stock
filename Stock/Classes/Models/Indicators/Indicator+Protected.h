//
//  Indicator+Protected.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "Indicator.h"

@interface Indicator (Protected)

- (float)indicatorPriceForRawPrice:(float)price;

@end
