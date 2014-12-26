//
//  GraphView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/6/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GraphData+Protocols.h"

@interface GraphView : UIView

- (void)setDatasource:(id<GraphDatasource>)datasource;

- (void)refresh;
- (void)resetView;
- (void)addAxisAtY:(float)axisY;

@end
