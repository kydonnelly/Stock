//
//  PriceGraphViewController.m
//  Stock
//
//  Created by Kyle Donnelly on 12/3/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PriceGraphViewController.h"

#import "AppData.h"
#import "CallCenter.h"
#import "ClassUtils.h"
#import "DisplayUtils.h"
#import "ExtendedStateButton.h"
#import "GraphView.h"
#import "GraphViewController+Protected.h"
#import "Indicator.h"
#import "IndicatorDatasource+Protocol.h"
#import "IndicatorListSliderView.h"
#import "MasterViewController.h"
#import "NSArray+Sorted.h"
#import "PriceDetailView.h"
#import "StockPriceIndicator.h"
#import "Stock.h"
#import "StockListManager.h"
#import "StockPriceManager.h"
#import "StockSelectionViewController.h"

enum {
    DisplayScaleDaysThreshold = 3,
    DisplayScaleWeeksThreshold = 60,
    DisplayScaleMonthsThreshold = 300,
};

static const int kHighDetailSpacing = 100;
static const int kLowDetailSpacing = 80;

@interface PriceGraphViewController () <IndicatorDatasource>

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet ExtendedStateButton *favoriteButton;
@property (nonatomic, retain) IBOutlet IndicatorListSliderView *optionsSliderView;

@property (nonatomic, retain) PriceDetailView *priceDetailView;

@property (nonatomic, retain) Stock *stock;
@property (nonatomic) StockSelectionCategory stockCategory;
@property (nonatomic) float lastClosePrice;

@property (nonatomic, retain) NSMutableArray *primaryIndicators;
@property (nonatomic, retain) NSMutableArray *secondaryIndicators;

- (NSMutableArray *)activeIndicatorsOfType:(IndicatorType)indicatorType;

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view layoutSubviews];
    
    [self.optionsSliderView resetView];
    [self.graphView resetView];
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideDetailView];
    [self.optionsSliderView setExpanded:NO animated:NO];
}

- (void)dealloc {
    ReleaseIvar(_nameLabel);
    ReleaseIvar(_favoriteButton);
    ReleaseIvar(_optionsSliderView);
    
    ReleaseIvar(_priceDetailView);
    
    ReleaseIvar(_stock);
    
    ReleaseIvar(_primaryIndicators);
    ReleaseIvar(_secondaryIndicators);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setup {
    [super setup];
    Assert(NO, @"Call setupWithStock:");
}

- (void)setupWithStock:(Stock *)stock {
    self.stock = stock;
    [super setup];
    
    StockListManager *slm = GET(StockListManager);
    if ([[slm activeStocksForCategory:StockSelectionCategoryFavorite] containsObject:[Stock keyForStockId:self.stock.stockId]]) {
        self.stockCategory = StockSelectionCategoryFavorite;
    } else {
        self.stockCategory = StockSelectionCategoryTemporary;
    }
    
    self.lastClosePrice = [GET(StockPriceManager) lastPriceForStockId:self.stock.stockId daysAgo:1];
}

- (void)setupOutlets {
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_ON_IMAGE] forState:UIControlStateApplication];
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_OFF_IMAGE] forState:UIControlStateNormal];
    
    self.priceDetailView = [[[PriceDetailView alloc] initWithOwner:self] autorelease];
    self.priceDetailView.frame = self.graphView.frame;
    self.priceDetailView.hidden = YES;
    [self.priceDetailView setupWithDatasource:self];
    [self.view addSubview:self.priceDetailView];
    
    [self.optionsSliderView setupWithDatasource:self];
    [self.view bringSubviewToFront:self.optionsSliderView];
}

- (void)setupIndicators {
    Indicator *priceIndicator = [[[StockPriceIndicator alloc] init] autorelease];
    
    self.primaryIndicators = [NSMutableArray arrayWithObject:priceIndicator];
    self.secondaryIndicators = [NSMutableArray array];
    
    for (Indicator *indicator in appData(defaultIndicators)) {
        [[self activeIndicatorsOfType:indicator.indicatorType] addSortableObject:indicator];
    }
}

- (void)setupGestures {
    [super setupGestures];
    
    UILongPressGestureRecognizer *hold = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGraphHold:)] autorelease];
    [self addGestureRecognizer:hold];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailView)] autorelease];
    [self addGestureRecognizer:tap];
}

#pragma mark - Refresh

- (void)refreshGraph {
    [super refreshGraph];
    [self.graphView addAxisAtY:self.lastClosePrice];
}

- (void)refresh {
    [super refresh];
    
    [self refreshFavoriteButton];
    [self refreshOptionsSlider];
    [self refreshPriceDetailView];
    [self.nameLabel setText:self.stock.ticker];
}

- (void)refreshFavoriteButton {
    BOOL isFavorite = (self.stockCategory == StockSelectionCategoryFavorite);
    [self.favoriteButton setInCustomState:isFavorite];
}

- (void)refreshOptionsSlider {
    // todo: might be better UX to revert selections to default indicators
}

- (void)refreshPriceDetailView {
    [self.priceDetailView refresh];
}

#pragma mark - IndicatorDatasource methods

- (NSMutableArray *)activeIndicatorsOfType:(IndicatorType)indicatorType {
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
    NSMutableArray *indicators = [self activeIndicatorsOfType:indicator.indicatorType];
    if (isActive) {
        [indicators addSortableObject:indicator];
    } else {
        [indicators removeSortableObject:indicator];
    }
    
    [self refresh];
}

#pragma mark - Actions

- (IBAction)backButtonPressed {
    JumpToViewController(StockSelectionViewController);
}

- (IBAction)favoriteButtonPressed {
    self.stockCategory = [GET(StockListManager) changeStatusForStock:self.stock currentCategory:self.stockCategory];
    [self refreshFavoriteButton];
}

#pragma mark - Graphing Overrides

- (NSString *)labelForX:(CGFloat)x {
    int days = self.displayedEndTime - self.displayedStartTime;
    
    NSString *format = nil;
    if (days <= DisplayScaleDaysThreshold) {
        format = @"MM/dd HH:mm";
    } else if (days <= DisplayScaleWeeksThreshold) {
        format = @"MM/dd";
    } else if (days <= DisplayScaleMonthsThreshold) {
        format = @"MM/dd/YY";
    } else {
        format = @"MM/YY";
    }
    
    return [self labelForX:x format:format];
}

- (int)horizontalSpacing {
    int days = self.displayedEndTime - self.displayedStartTime;
    
    if (days <= DisplayScaleDaysThreshold) {
        return kHighDetailSpacing;
    } else {
        return kLowDetailSpacing;
    }
}

- (float)maxDomain {
    return [GET(StockPriceManager) daysAvailableForStockId:self.stock.stockId];
}

- (NSArray *)currentGraphValues {
    return [GET(StockPriceManager) pricesOfStockId:self.stock.stockId
                                      startDaysAgo:self.displayedStartTime
                                        endDaysAgo:self.displayedEndTime];
}

- (NSArray *)graphObjects {
    NSMutableArray *graphObjects = [NSMutableArray array];
    
    [graphObjects addObjectsFromArray:[self activeIndicatorsOfType:IndicatorTypePrimary]];
    [graphObjects addObjectsFromArray:[self activeIndicatorsOfType:IndicatorTypeSecondary]];
    
    return graphObjects;
}

#pragma mark - Graphing extenstions

- (void)prepareGraphData:(NSArray *)sanitizedValues {
    [super prepareGraphData:sanitizedValues];
    
    self.displayedMinY = FLT_MAX;
    self.displayedMaxY = 0.f;
    
    Assert([self.primaryIndicators count], @"Nothing to graph!");
    for (Indicator *primaryIndicator in self.primaryIndicators) {
        self.displayedMinY = MIN(self.displayedMinY, primaryIndicator.minPrice);
        self.displayedMaxY = MAX(self.displayedMaxY, primaryIndicator.maxPrice);
    }
}

#pragma mark - Gesture Recognizers

- (void)handleGraphHold:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            // price detail view will stay on screen
            return;
        default:
            break;
    }
    
    self.priceDetailView.hidden = NO;
    CGPoint holdPoint = [gestureRecognizer locationInView:self.graphView];
    [self.priceDetailView setPosition:holdPoint inBounds:self.graphView.frame];
}

- (IBAction)hideDetailView {
    self.priceDetailView.hidden = YES;
    [self.priceDetailView reset];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
