//
//  StockSelectionTableView.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockSelectionTableView.h"

#import "ClassUtils.h"
#import "StockSelectionTableViewCell.h"
#import "StockSelectionViewController.h"

@implementation StockSelectionTableView

static NSString *cellDequeueClassIdentifier = @"StockSelectionTableViewCell";

#pragma mark - Lifecycle

- (void)dealloc {
    _controller = nil;
    
    [super dealloc];
}

#pragma mark - Cell Dequeue

- (StockSelectionTableViewCell *)cell {
    StockSelectionTableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellDequeueClassIdentifier];
    
    if (!cell) {
        [self registerNib:[UINib nibWithNibName:cellDequeueClassIdentifier bundle:nil] forCellReuseIdentifier:cellDequeueClassIdentifier];
        cell = [self dequeueReusableCellWithIdentifier:cellDequeueClassIdentifier];
    }
    
    cell.owner = self;
    return cell;
}

#pragma mark - cell action handlers

- (void)handleStockSelected:(Stock *)stock {
    [self.controller handleStockSelected:stock];
}

- (void)favoriteButtonClickedForStock:(Stock *)stock {
    [self.controller toggleFavoriteStatusForStock:stock];
}

@end
