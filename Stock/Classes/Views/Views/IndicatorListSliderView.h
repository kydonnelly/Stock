//
//  IndicatorListSliderView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "SliderView.h"

#import "IndicatorDatasource+Protocol.h"

@interface IndicatorListSliderView : SliderView

- (void)setupWithDatasource:(id<IndicatorDatasource>)datasource;

- (void)toggleIndicator:(Indicator *)indicator activeState:(BOOL)isActive;

@end
