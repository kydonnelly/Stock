//
//  IndicatorListSliderView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "IndicatorListSliderView.h"

#import "ClassUtils.h"
#import "Indicator.h"
#import "IndicatorList.h"
#import "IndicatorListSliderTableViewCell.h"
#import "NSArray+Sorted.h"

static NSString *cellDequeueClassIdentifier = @"IndicatorListSliderTableViewCell";

@interface IndicatorListSliderView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *indicatorTable;

@property (nonatomic, assign) id<IndicatorDatasource> datasource;

@end

@implementation IndicatorListSliderView

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_indicatorTable);
    _datasource = nil;
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithDatasource:(id<IndicatorDatasource>)datasource {
    self.datasource = datasource;
    
    [super setup];
}

#pragma mark - cell action handlers

- (void)toggleIndicator:(Indicator *)indicator activeState:(BOOL)isActive {
    [self.datasource updateIndicator:indicator isActive:isActive];
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.indicatorTable) {
        return [[GET(IndicatorList) allIndicators] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.indicatorTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDequeueClassIdentifier];
        
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:cellDequeueClassIdentifier bundle:nil] forCellReuseIdentifier:cellDequeueClassIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellDequeueClassIdentifier];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.indicatorTable) {
        NSArray *indicators = [GET(IndicatorList) allIndicators];
        IndicatorListSliderTableViewCell *customCell = (IndicatorListSliderTableViewCell *)cell;
        
        if (indexPath.row < [indicators count]) {
            Indicator *indicator = [indicators objectAtIndex:indexPath.row];
            BOOL isActive = [[self.datasource activeIndicatorsOfType:indicator.indicatorType] containsSortableObject:indicator];
            
            customCell.owner = self;
            [customCell setupWithIndicator:indicator isActive:isActive];
        }
    }
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
