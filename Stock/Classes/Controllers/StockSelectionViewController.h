//
//  StockSelectionViewController.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stock, StockSelectionTableView;

@interface StockSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)handleStockSelected:(Stock *)stock;
- (void)toggleFavoriteStatusForStock:(Stock *)stock;

@end
