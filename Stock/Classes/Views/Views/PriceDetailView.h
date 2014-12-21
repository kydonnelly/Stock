//
//  PriceDetailView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "XibView.h"

#import "IndicatorDatasource+Protocol.h"

@interface PriceDetailView : XibView

- (void)setupWithDatasource:(id<IndicatorDatasource>)datasource;
- (void)setPosition:(CGPoint)position inBounds:(CGRect)bounds;

- (void)refresh;

@end
