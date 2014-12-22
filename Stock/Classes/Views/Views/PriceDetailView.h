//
//  PriceDetailView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "XibView.h"

#import "GraphData+Protocols.h"
#import "IndicatorDatasource+Protocol.h"

@interface PriceDetailView : XibView

- (void)setupWithDatasource:(id<IndicatorDatasource, GraphDatasource>)datasource;
- (void)setPosition:(CGPoint)position inBounds:(CGRect)bounds;

- (void)reset;
- (void)refresh;

@end
