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

@property (nonatomic, retain) IBOutlet StockSelectionTableView *stockTableView;

- (void)handleStockSelected:(Stock *)stock;
- (void)toggleFavoriteStatusForStock:(Stock *)stock;

@end
