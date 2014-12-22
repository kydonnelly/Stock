//
//  PriceGraphViewController.h
//  Stock
//
//  Created by Kyle Donnelly on 12/3/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "GraphViewController.h"

@class Stock;

@interface PriceGraphViewController : GraphViewController

- (void)setupWithStock:(Stock *)stock;

@end
