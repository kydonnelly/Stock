//
//  GraphViewController+Protected.h
//  Stock
//
//  Created by Kyle Donnelly on 12/21/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "GraphViewController.h"

#import "GraphData+Protocols.h"

@interface GraphViewController (Protected) <GraphDatasource>

// abstract

- (float)maxDomain;
- (NSArray *)currentGraphValues;

// expose

@property (nonatomic) float displayedMinY;
@property (nonatomic) float displayedMaxY;

- (float)displayedStartTime;
- (float)displayedEndTime;

- (GraphView *)graphView;
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

// extend

- (void)setupGestures;
- (void)prepareGraphData:(NSArray *)sanitizedValues;

@end
