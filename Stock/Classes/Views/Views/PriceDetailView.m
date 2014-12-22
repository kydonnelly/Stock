//
//  PriceDetailView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PriceDetailView.h"

#import "ClassUtils.h"
#import "Indicator.h"
#import "IndicatorDetailTableViewCell.h"
#import "TriangleView.h"

static NSString *cellDequeueClassIdentifier = @"IndicatorDetailTableViewCell";

static const CGFloat kGraphLineBuffer = 15;

@interface PriceDetailView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *mobileView;
@property (nonatomic, retain) IBOutlet UIView *detailView;
@property (nonatomic, retain) IBOutlet TriangleView *anchorView;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UITableView *detailsTable;

@property (nonatomic, assign) id<IndicatorDatasource, GraphDatasource> datasource;
@property (nonatomic) CGFloat percentAcrossScreen;

@property (nonatomic, retain) NSArray *primaryIndicators;
@property (nonatomic, retain) NSArray *secondaryIndicators;

@end

@implementation PriceDetailView

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_mobileView);
    ReleaseIvar(_detailView);
    ReleaseIvar(_anchorView);
    ReleaseIvar(_dateLabel);
    ReleaseIvar(_detailsTable);
    
    _datasource = nil;
    
    ReleaseIvar(_primaryIndicators);
    ReleaseIvar(_secondaryIndicators);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithDatasource:(id<IndicatorDatasource, GraphDatasource>)datasource {
    self.datasource = datasource;
}

#pragma mark - Refresh

- (void)refresh {
    self.primaryIndicators = [self.datasource activeIndicatorsOfType:IndicatorTypePrimary];
    self.secondaryIndicators = [self.datasource activeIndicatorsOfType:IndicatorTypeSecondary];
    
    [self.detailsTable reloadData];
}

- (void)reset {
    [self.detailsTable setContentOffset:CGPointZero animated:NO];
}

- (void)setPosition:(CGPoint)position inBounds:(CGRect)bounds {
    NSArray *indicators = [self.datasource graphObjects];
    int highestPriority = 0;
    float price = 0.f;
    
    Assert([indicators count], @"No indicator for detail box position.");
    self.percentAcrossScreen = position.x / bounds.size.width;
    
    for (Indicator *indicator in indicators) {
        if ([indicator displayPriority] > highestPriority) {
            highestPriority = [indicator displayPriority];
            int priceIndex = [self currentPriceIndexForGraphObject:indicator];
            price = [[[indicator yValues] objectAtIndex:priceIndex] floatValue];
        }
    }
    
    CGFloat maxX = bounds.size.width - self.mobileView.frame.size.width;
    CGFloat x = position.x - self.mobileView.frame.size.width / 2.f;
    float yPercent = (self.datasource.maxY - price) / (self.datasource.maxY - self.datasource.minY);
    CGFloat y = yPercent * bounds.size.height;
    
    [self moveToX:x y:y maxX:maxX];
    
    [self.dateLabel setText:[self.datasource labelForX:position.x]];
    [self refresh];
}

- (int)currentPriceIndexForGraphObject:(id<GraphObject>)model {
    return [[model yValues] count] * self.percentAcrossScreen;
}

#pragma mark - Positioning

- (void)stackViews:(NSArray *)views {
    CGFloat ySum = 0;
    for (UIView *view in views) {
        view.frame = CGRectMake(view.frame.origin.x,
                                ySum,
                                view.frame.size.width,
                                view.frame.size.height);
        ySum += view.frame.size.height;
    }
}

- (void)setupLayoutAbove {
    self.anchorView.triangleType = TriangleTypeDown;
    [self stackViews:[NSArray arrayWithObjects:self.detailView, self.anchorView, nil]];
}

- (void)setupLayoutBelow {
    self.anchorView.triangleType = TriangleTypeUp;
    [self stackViews:[NSArray arrayWithObjects:self.anchorView, self.detailView, nil]];
}

- (void)moveToX:(CGFloat)x y:(CGFloat)y maxX:(CGFloat)maxX {
    if (y - self.mobileView.frame.size.height - kGraphLineBuffer < 0) {
        [self setupLayoutBelow];
        y += kGraphLineBuffer;
    } else {
        [self setupLayoutAbove];
        y -= self.mobileView.frame.size.height + kGraphLineBuffer;
    }
    
    CGFloat anchorWidth = self.anchorView.frame.size.width;
    CGFloat mobileWidth = self.mobileView.frame.size.width;
    CGFloat referenceX = mobileWidth / 2.f - anchorWidth / 2.f;
    CGFloat dx = 0;
    
    if (x < 0) {
        dx = x;
        x = 0;
    } else if (x > maxX) {
        dx = x - maxX;
        x = maxX;
    }
    
    self.anchorView.frame = CGRectMake(referenceX + dx,
                                       self.anchorView.frame.origin.y,
                                       anchorWidth,
                                       self.anchorView.frame.size.height);
    self.mobileView.frame = CGRectMake(x,
                                       y,
                                       mobileWidth,
                                       self.mobileView.frame.size.height);
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
        
        int index = [self currentPriceIndexForGraphObject:indicator];
        [customCell setupWithIndicator:indicator forPriceIndex:index];
    }
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
