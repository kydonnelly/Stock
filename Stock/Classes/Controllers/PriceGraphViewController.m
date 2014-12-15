//
//  PriceGraphViewController.m
//  Stock
//
//  Created by Kyle Donnelly on 12/3/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PriceGraphViewController.h"

#import "CallCenter.h"
#import "ClassUtils.h"
#import "DisplayUtils.h"
#import "ExtendedStateButton.h"
#import "AppData.h"
#import "GraphView.h"
#import "Indicator.h"
#import "IndicatorDatasource+Protocol.h"
#import "IndicatorListSliderView.h"
#import "MasterViewController.h"
#import "StockPriceIndicator.h"
#import "Stock.h"
#import "StockListManager.h"
#import "StockPriceManager.h"
#import "StockSelectionViewController.h"

@interface PriceGraphViewController () <IndicatorDatasource, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet GraphView *graphView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet ExtendedStateButton *favoriteButton;
@property (nonatomic, retain) IBOutlet IndicatorListSliderView *optionsSliderView;

@property (nonatomic, retain) Stock *stock;
@property (nonatomic) StockSelectionCategory stockCategory;

@property (nonatomic) float displayedStartTime;
@property (nonatomic) float displayedEndTime;
@property (nonatomic) float lastClosePrice;

@property (nonatomic, retain) NSMutableSet *primaryIndicators;
@property (nonatomic, retain) NSMutableSet *secondaryIndicators;

- (NSMutableSet *)activeIndicatorsOfType:(IndicatorType)indicatorType;

@end

@implementation PriceGraphViewController

RegisterWithCallCenter

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupIndicators];
    [self setupOutlets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.optionsSliderView setExpanded:NO animated:NO];
}

- (void)dealloc {
    ReleaseIvar(_graphView);
    ReleaseIvar(_nameLabel);
    ReleaseIvar(_favoriteButton);
    ReleaseIvar(_optionsSliderView);
    
    ReleaseIvar(_stock);
    
    ReleaseIvar(_primaryIndicators);
    ReleaseIvar(_secondaryIndicators);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithStock:(Stock *)stock {
    self.stock = stock;
    
    StockListManager *slm = GET(StockListManager);
    if ([[slm activeStocksForCategory:StockSelectionCategoryFavorite] containsObject:[Stock keyForStockId:self.stock.stockId]]) {
        self.stockCategory = StockSelectionCategoryFavorite;
    } else {
        self.stockCategory = StockSelectionCategoryTemporary;
    }
    
    self.lastClosePrice = [GET(StockPriceManager) lastPriceForStockId:self.stock.stockId daysAgo:1];
    self.displayedStartTime = -1;
    self.displayedEndTime = 0;
}

- (void)setupOutlets {
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_ON_IMAGE] forState:UIControlStateApplication];
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_OFF_IMAGE] forState:UIControlStateNormal];
    
    UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGraphPinched:)] autorelease];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [self.graphView addGestureRecognizer:pinch];
    [self.graphView setIndicatorDatasource:self];
    
    [self.optionsSliderView setupWithDatasource:self];
}

- (void)setupIndicators {
    self.primaryIndicators = [NSMutableSet setWithObject:[[[StockPriceIndicator alloc] init] autorelease]];
    self.secondaryIndicators = [NSMutableSet set];
    
    for (Indicator *indicator in appData(defaultIndicators)) {
        [[self activeIndicatorsOfType:indicator.indicatorType] addObject:indicator];
    }
}

#pragma mark - Refresh

- (void)refresh {
    [self.nameLabel setText:self.stock.ticker];
    
    [self refreshFavoriteButton];
    [self refreshOptionsSlider];
    [self refreshGraphView];
}

- (void)refreshFavoriteButton {
    BOOL isFavorite = (self.stockCategory == StockSelectionCategoryFavorite);
    [self.favoriteButton setInCustomState:isFavorite];
}

- (void)refreshGraphView {
    float minPrice = FLT_MAX;
    float maxPrice = 0.f;
    NSArray *prices = [GET(StockPriceManager) pricesOfStockId:self.stock.stockId startTime:self.displayedStartTime endTime:self.displayedEndTime];
    
    for (Indicator *primaryIndicator in self.primaryIndicators) {
        [primaryIndicator setupWithPrices:prices];
        
        minPrice = MIN(minPrice, primaryIndicator.minPrice);
        maxPrice = MAX(maxPrice, primaryIndicator.maxPrice);
    }
    
    for (Indicator *secondaryIndicator in self.secondaryIndicators) {
        [secondaryIndicator setupWithPrices:prices];
    }
    
    [self.graphView setMinX:self.displayedStartTime maxX:self.displayedEndTime minY:minPrice maxY:maxPrice axisY:self.lastClosePrice];
}

- (void)refreshOptionsSlider {
    // todo: might be better UX to revert selections to default indicators
}

#pragma mark - Actions

- (IBAction)backButtonPressed {
    JumpToViewController(StockSelectionViewController);
}

- (IBAction)favoriteButtonPressed {
    self.stockCategory = [GET(StockListManager) changeStatusForStock:self.stock currentCategory:self.stockCategory];
    [self refreshFavoriteButton];
}

#pragma mark - IndicatorDatasource methods

- (NSMutableSet *)activeIndicatorsOfType:(IndicatorType)indicatorType {
    switch (indicatorType) {
        case IndicatorTypePrimary:
            return self.primaryIndicators;
        case IndicatorTypeSecondary:
            return self.secondaryIndicators;
        default:
            return nil;
    }
}

- (void)updateIndicator:(Indicator *)indicator isActive:(BOOL)isActive {
    NSMutableSet *indicators = [self activeIndicatorsOfType:indicator.indicatorType];
    if (isActive) {
        [indicators addObject:indicator];
    } else {
        [indicators removeObject:indicator];
    }
    
    [self refresh];
}

// todo
#pragma mark - Gesture Recognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

- (void)handleGraphPinched:(UIGestureRecognizer *)gestureRecognizer {
    [self refreshGraphView];
}

@end
