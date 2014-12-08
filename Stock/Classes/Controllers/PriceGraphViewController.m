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
#import "GraphView.h"
#import "MasterViewController.h"
#import "Stock.h"
#import "StockListManager.h"
#import "StockPriceManager.h"
#import "StockSelectionViewController.h"

#define MAX_GRAPH_POINTS 500

@interface PriceGraphViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet GraphView *graphView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet ExtendedStateButton *favoriteButton;
@property (nonatomic, retain) IBOutlet UIView *optionsSliderView;

@property (nonatomic, retain) Stock *stock;
@property (nonatomic) StockSelectionCategory stockCategory;

@property (nonatomic) float displayedStartTime;
@property (nonatomic) float displayedEndTime;
@property (nonatomic) int lastClosePrice;

@end

@implementation PriceGraphViewController

RegisterWithCallCenter

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupOutlets];
    [self refresh];
}

- (void)dealloc {
    ReleaseIvar(_graphView);
    ReleaseIvar(_nameLabel);
    ReleaseIvar(_favoriteButton);
    ReleaseIvar(_optionsSliderView);
    
    ReleaseIvar(_stock);
    
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
    self.displayedStartTime = -2;
    self.displayedEndTime = 0;
}

- (void)setupOutlets {
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_ON_IMAGE] forState:UIControlStateApplication];
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_OFF_IMAGE] forState:UIControlStateNormal];
    
    [self.nameLabel setText:self.stock.ticker];
    
    UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGraphPinched:)] autorelease];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [self.graphView addGestureRecognizer:pinch];
}

#pragma mark - Refresh

- (void)refresh {
    [self refreshFavoriteButton];
    [self refreshGraphView];
}

- (void)refreshFavoriteButton {
    if (self.stockCategory == StockSelectionCategoryFavorite) {
        self.favoriteButton.state = UIControlStateApplication;
    } else {
        self.favoriteButton.state &= ~UIControlStateApplication;
    }
}

- (void)refreshGraphView {
    float minPrice = FLT_MAX;
    float maxPrice = 0.f;
    NSArray *prices = [GET(StockPriceManager) pricesOfStockId:self.stock.stockId startTime:self.displayedStartTime endTime:self.displayedEndTime];
    
    NSMutableArray *trimmedPrices = [NSMutableArray array];
    int removalMod = [prices count] / MAX_GRAPH_POINTS;
    int removalCounter = 0;
    
    for (NSNumber *priceNumber in prices) {
        float price = [priceNumber floatValue];
        if (price < minPrice) {
            minPrice = price;
        }
        if (price > maxPrice) {
            maxPrice = price;
        }
        
        if (removalCounter >= removalMod) {
            [trimmedPrices addObject:priceNumber];
            removalCounter = 0;
        } else {
            removalCounter++;
        }
    }
    
    [self.graphView setMinX:self.displayedStartTime maxX:self.displayedEndTime minY:minPrice maxY:maxPrice axisY:self.lastClosePrice yValues:trimmedPrices];
}

- (void)refreshOptionsSlider {
    // todo
}

#pragma mark - Actions

- (IBAction)backButtonPressed {
    JumpToViewController(StockSelectionViewController);
}

- (IBAction)favoriteButtonPressed {
    self.stockCategory = [GET(StockListManager) changeStatusForStock:self.stock currentCategory:self.stockCategory];
    [self refreshFavoriteButton];
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
