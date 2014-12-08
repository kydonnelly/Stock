//
//  StockSelectionTableViewCell.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockSelectionTableViewCell.h"

#import "ClassUtils.h"
#import "DisplayUtils.h"
#import "ExtendedStateButton.h"
#import "Stock.h"
#import "StockListManager.h"
#import "StockPriceManager.h"
#import "StockSelectionTableView.h"

typedef enum {
    ColorTagPriceDecrease = -1,
    ColorTagPriceSame,
    ColorTagPriceIncrease,
} ColorTag;

@interface StockSelectionTableViewCell ()

@property (nonatomic, retain) IBOutlet UILabel *tickerLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastPriceLabel;
@property (nonatomic, retain) IBOutlet ExtendedStateButton *favoriteButton;

@property (nonatomic, retain) Stock *stock;

@end

@implementation StockSelectionTableViewCell

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_tickerLabel);
    ReleaseIvar(_lastPriceLabel);
    ReleaseIvar(_favoriteButton);
    
    ReleaseIvar(_stock);
    
    _owner = nil;
    
    [super dealloc];
}

- (void)setupWithStock:(Stock *)stock {
    self.stock = stock;
    [self.tickerLabel setText:self.stock.ticker];
    
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_ON_IMAGE] forState:UIControlStateApplication];
    [self.favoriteButton setImage:[UIImage imageNamed:FAVORITE_OFF_IMAGE] forState:UIControlStateNormal];
    
    [self refresh];
}

#pragma mark - refresh

- (void)refresh {
    // todo: call this after server response
    [self refreshPriceLabel];
    [self refreshFavoriteButton];
}

- (void)refreshPriceLabel {
    StockPriceManager *spm = GET(StockPriceManager);
    float price = [spm priceForStockId:self.stock.stockId];
    float closePrice = [spm lastPriceForStockId:self.stock.stockId daysAgo:1];
    float percentChange = 100 * ABS(price - closePrice) / closePrice;
    
    NSString *displayPrice = [[NSString stringWithFormat:@"%.2f", percentChange] stringByAppendingString:@"%"];
    if (![self.lastPriceLabel.text isEqualToString:displayPrice]) {
        [self.lastPriceLabel setText:displayPrice];
    }
    
    ColorTag tag = ColorTagPriceSame;
    if (price > closePrice + FLT_EPSILON) {
        tag = ColorTagPriceIncrease;
    } else if (price < closePrice - FLT_EPSILON) {
        tag = ColorTagPriceDecrease;
    }
    
    // don't use tag
    if (tag != self.lastPriceLabel.tag) {
        self.lastPriceLabel.tag = tag;
        switch (tag) {
            case ColorTagPriceDecrease:
                [self.lastPriceLabel setTextColor:[UIColor colorWithRed:1.f green:0.27f blue:0 alpha:1]];
                break;
            case ColorTagPriceSame:
                [self.lastPriceLabel setTextColor:[UIColor blackColor]];
                break;
            case ColorTagPriceIncrease:
                [self.lastPriceLabel setTextColor:[UIColor colorWithRed:0.133f green:0.545f blue:0.133f alpha:1]];
                break;
            default:
                break;
        }
    }
}

- (void)refreshFavoriteButton {
    id stockKey = [Stock keyForStockId:self.stock.stockId];
    NSArray *favoriteStocks = [GET(StockListManager) activeStocksForCategory:StockSelectionCategoryFavorite];
    
    if ([favoriteStocks containsObject:stockKey]) {
        self.favoriteButton.state = UIControlStateApplication;
    } else {
        self.favoriteButton.state &= ~UIControlStateApplication;
    }
}

#pragma mark - Action handlers

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (IBAction)handleSelection {
    [self.owner handleStockSelected:self.stock];
}

- (IBAction)favoriteButtonPressed {
    [self.owner favoriteButtonClickedForStock:self.stock];
    [self refresh];
}

@end
