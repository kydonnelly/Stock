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

static const int kMaxGraphPoints = 500;
static const double kDefaultDaysShown = 1.0f;
static const double kMinTimePeriodShown = 1.f;

static const float kPanDampeningFactor = 0.01f;

@interface PriceGraphViewController () <IndicatorDatasource, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet ExtendedStateButton *favoriteButton;
@property (nonatomic, retain) IBOutlet GraphView *graphView;
@property (nonatomic, retain) IBOutlet PriceDetailView *priceDetailView;
@property (nonatomic, retain) IBOutlet IndicatorListSliderView *optionsSliderView;

@property (nonatomic, retain) Stock *stock;
@property (nonatomic) StockSelectionCategory stockCategory;

@property (nonatomic) float displayedStartTime;
@property (nonatomic) float displayedEndTime;
@property (nonatomic) float lastClosePrice;

@property (nonatomic, retain) NSMutableArray *primaryIndicators;
@property (nonatomic, retain) NSMutableArray *secondaryIndicators;

@property (nonatomic) float lastScale;
@property (nonatomic) float initialScalingAmount;

@property (nonatomic) float lastPan;

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.optionsSliderView setExpanded:NO animated:NO];
}

- (void)dealloc {
    ReleaseIvar(_graphView);
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

- (void)setupWithStock:(Stock *)stock {
    self.stock = stock;
    
    StockListManager *slm = GET(StockListManager);
    if ([[slm activeStocksForCategory:StockSelectionCategoryFavorite] containsObject:[Stock keyForStockId:self.stock.stockId]]) {
        self.stockCategory = StockSelectionCategoryFavorite;
    } else {
        self.stockCategory = StockSelectionCategoryTemporary;
    }
    
    self.lastClosePrice = [GET(StockPriceManager) lastPriceForStockId:self.stock.stockId daysAgo:1];
    self.displayedStartTime = -1 * kDefaultDaysShown;
    self.displayedEndTime = 0;
    [self sanitizeDisplayEndpoints];
}

- (void)setupOutlets {
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_ON_IMAGE] forState:UIControlStateApplication];
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_OFF_IMAGE] forState:UIControlStateNormal];
    
    UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGraphPinched:)] autorelease];
    [self addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGraphPan:)] autorelease];
    [self addGestureRecognizer:pan];
    
    UILongPressGestureRecognizer *hold = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGraphHold:)] autorelease];
    [self addGestureRecognizer:hold];
    
    [self.graphView setIndicatorDatasource:self];
    
    self.priceDetailView = [[[PriceDetailView alloc] init] autorelease];
    [self.priceDetailView setupWithDatasource:self];
    self.priceDetailView.hidden = YES;
    [self.view addSubview:self.priceDetailView];
    
    [self.optionsSliderView setupWithDatasource:self];
}

- (void)setupIndicators {
    self.primaryIndicators = [NSMutableArray arrayWithObject:[[[StockPriceIndicator alloc] init] autorelease]];
    self.secondaryIndicators = [NSMutableArray array];
    
    for (Indicator *indicator in appData(defaultIndicators)) {
        [[self activeIndicatorsOfType:indicator.indicatorType] addSortableObject:indicator];
    }
}

#pragma mark - Refresh

- (void)refresh {
    [self.nameLabel setText:self.stock.ticker];
    
    [self refreshFavoriteButton];
    [self refreshOptionsSlider];
    [self refreshGraphView];
    [self refreshPriceDetailView];
}

- (void)refreshFavoriteButton {
    BOOL isFavorite = (self.stockCategory == StockSelectionCategoryFavorite);
    [self.favoriteButton setInCustomState:isFavorite];
}

- (void)refreshGraphView {
    float minPrice = FLT_MAX;
    float maxPrice = 0.f;
    
    NSArray *prices = [GET(StockPriceManager) pricesOfStockId:self.stock.stockId startDaysAgo:self.displayedStartTime endDaysAgo:self.displayedEndTime];
    prices = [self trimmedPricesForCurrentDisplay:prices];
    
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

- (void)refreshPriceDetailView {
    [self.priceDetailView refresh];
}

#pragma mark - Display Sanity

- (void)sanitizeDisplayEndpoints {
    int daysAvailable = [GET(StockPriceManager) daysAvailableForStockId:self.stock.stockId];
    int minEndTime = -1 * daysAvailable + kMinTimePeriodShown;
    int maxEndTime = 0;
    
    if (self.displayedEndTime < minEndTime) {
        self.displayedEndTime = minEndTime;
    } else if (self.displayedEndTime > maxEndTime) {
        self.displayedEndTime = maxEndTime;
    }
    
    int minStartTime = -1 * daysAvailable;
    int maxStartTime = self.displayedEndTime - kMinTimePeriodShown;
    
    if (self.displayedStartTime < minStartTime) {
        self.displayedStartTime = minStartTime;
    } else if (self.displayedStartTime > maxStartTime) {
        self.displayedStartTime = maxStartTime;
    }
    
    AssertWithFormat(minStartTime <= maxStartTime && minEndTime <= maxEndTime,
                     @"Not enough price history to display %.2f days.", kMinTimePeriodShown);
}

- (NSArray *)trimmedPricesForCurrentDisplay:(NSArray *)originalPrices {
    NSMutableArray *trimmedPrices = [NSMutableArray array];
    
    int pricesCount = [originalPrices count];
    float xScale = (self.displayedEndTime - self.displayedStartTime) / pricesCount;
    float endTimeOffset = ceilf(ABS(self.displayedEndTime)) - ABS(self.displayedEndTime);
    
    int removalMod = pricesCount / kMaxGraphPoints;
    int offsetMod = removalMod + 1;
    
    int zoomOffset = pricesCount % offsetMod;
    int slideOffset = (int)ceil(endTimeOffset / xScale) % offsetMod;
    int removalCounter = (removalMod * 2 - zoomOffset - slideOffset) % offsetMod;
    
    for (NSNumber *priceNumber in originalPrices) {
        if (removalCounter < removalMod) {
            removalCounter++;
        } else {
            removalCounter = 0;
            [trimmedPrices addObject:priceNumber];
        }
    }
    
    return trimmedPrices;
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

#pragma mark - Gesture Recognizers

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [gestureRecognizer setDelegate:self];
    [gestureRecognizer setDelaysTouchesBegan:YES];
    [self.graphView addGestureRecognizer:gestureRecognizer];
}

- (void)handleGraphPinched:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.f;
        self.initialScalingAmount = self.displayedEndTime - self.displayedStartTime;
    }
    
    float scale = gestureRecognizer.scale / self.lastScale;
    self.lastScale = gestureRecognizer.scale;
    
    self.displayedStartTime += self.initialScalingAmount * (scale - 1.f);
    
    [self sanitizeDisplayEndpoints];
    [self refreshGraphView];
}

- (void)handleGraphPan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPan = 0;
    }
    
    float pan = [gestureRecognizer translationInView:self.graphView].x * kPanDampeningFactor;
    float delta = pan - self.lastPan;
    self.lastPan = pan;
    
    self.displayedStartTime -= delta;
    self.displayedEndTime -= delta;
    
    [self sanitizeDisplayEndpoints];
    [self refreshGraphView];
}

- (void)handleGraphHold:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            self.priceDetailView.hidden = YES;
            return;
        default:
            break;
    }
    
    self.priceDetailView.hidden = NO;
    CGPoint holdPoint = [gestureRecognizer locationInView:self.view];
    [self.priceDetailView setPosition:holdPoint inBounds:self.view.frame];
}

@end
