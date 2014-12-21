//
//  StockSelectionTableView.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stock, StockSelectionTableViewCell, StockSelectionViewController;

@interface StockSelectionTableView : UITableView

@property (nonatomic, assign) StockSelectionViewController *controller;

- (StockSelectionTableViewCell *)cell;

- (void)handleStockSelected:(Stock *)stock;
- (void)favoriteButtonClickedForStock:(Stock *)stock;

@end
