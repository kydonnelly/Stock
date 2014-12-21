//
//  PriceDetailView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PriceDetailView.h"

#import "Indicator.h"
#import "IndicatorDetailTableViewCell.h"
#import "TriangleView.h"

static NSString *cellDequeueClassIdentifier = @"IndicatorDetailTableViewCell";

@interface PriceDetailView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *detailView;
@property (nonatomic, retain) IBOutlet TriangleView *anchorView;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UITableView *detailsTable;

@property (nonatomic, assign) id<IndicatorDatasource> datasource;
@property (nonatomic) float percentAcrossScreen;

@property (nonatomic, retain) NSArray *primaryIndicators;
@property (nonatomic, retain) NSArray *secondaryIndicators;

@end

@implementation PriceDetailView

#pragma mark - Lifecycle

- (void)dealloc {
    [_detailView release], _detailView = nil;
    [_anchorView release], _anchorView = nil;
    [_dateLabel release], _dateLabel = nil;
    [_detailsTable release], _detailsTable = nil;
    
    _datasource = nil;
    
    [_primaryIndicators release], _primaryIndicators = nil;
    [_secondaryIndicators release], _secondaryIndicators = nil;
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithDatasource:(id<IndicatorDatasource>)datasource {
    self.datasource = datasource;
}

#pragma mark - Refresh

- (void)refresh {
    self.primaryIndicators = [[self.datasource activeIndicatorsOfType:IndicatorTypePrimary] allObjects];
    self.secondaryIndicators = [[self.datasource activeIndicatorsOfType:IndicatorTypeSecondary] allObjects];
    
    [self.detailsTable reloadData];
}

- (void)setPosition:(CGPoint)position inBounds:(CGRect)bounds {
    self.percentAcrossScreen = position.x / bounds.size.width;
    self.anchorView.triangleType = TriangleTypeDown;
    
    [self refresh];
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.detailsTable) {
        return [self.primaryIndicators count] + [self.secondaryIndicators count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.detailsTable) {
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
    if (tableView == self.detailsTable) {
        IndicatorDetailTableViewCell *customCell = (IndicatorDetailTableViewCell *)cell;
        Indicator *indicator = nil;
        int numPrimaryIndicators = [self.primaryIndicators count];
        int numSecondaryIndicators = [self.secondaryIndicators count];
        
        if (indexPath.row < numPrimaryIndicators) {
            indicator = [self.primaryIndicators objectAtIndex:indexPath.row];
        } else if (indexPath.row < numPrimaryIndicators + numSecondaryIndicators) {
            indicator = [self.secondaryIndicators objectAtIndex:(indexPath.row - numPrimaryIndicators)];
        }
        
        int index = [[indicator allPrices] count] * self.percentAcrossScreen;
        [customCell setupWithIndicator:indicator forPriceIndex:index];
    }
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
