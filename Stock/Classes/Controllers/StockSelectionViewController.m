//
//  StockSelectionViewController.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "StockSelectionViewController.h"

#import "CallCenter.h"
#import "ClassUtils.h"
#import "AppData.h"
#import "LocalizationHelper.h"
#import "MasterViewController.h"
#import "PriceGraphViewController.h"
#import "Stock.h"
#import "StockListManager.h"
#import "StockSelectionTableView.h"
#import "StockSelectionTableViewCell.h"

@interface StockSelectionViewController ()

@property (nonatomic, retain) IBOutlet StockSelectionTableView *stockTableView;

@property (nonatomic, retain) NSArray *activeCategories;
@property (nonatomic, retain) NSMutableDictionary *stocksForCategory;
@property (nonatomic, retain) NSMutableDictionary *categoryForStock;

@end

@implementation StockSelectionViewController

#pragma mark - Static display decisions

+ (NSString *)displayTitleForCategory:(StockSelectionCategory)category {
    switch (category) {
        case StockSelectionCategoryRecent:
            return localizedString(@"Recents");
        case StockSelectionCategoryFavorite:
            return localizedString(@"Favorites");
        case StockSelectionCategoryTemporary:
            return localizedString(@"Others");
        default:
            return @"Unknown";
    }
}

#pragma mark - Lifecycle

RegisterWithCallCenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
}

- (void)setup {
    self.stockTableView.controller = self;
    [self refresh];
}

- (void)dealloc {
    ReleaseIvar(_stockTableView);
    
    ReleaseIvar(_activeCategories);
    ReleaseIvar(_stocksForCategory);
    ReleaseIvar(_categoryForStock);
    
    [super dealloc];
}

- (void)placeStocks:(NSArray *)stocks inCategory:(id)categoryKey {
    for (id stockKey in stocks) {
        [self.categoryForStock setObject:categoryKey forKey:stockKey];
    }
}

- (void)refresh {
    StockListManager *slm = GET(StockListManager);
    self.activeCategories = [[slm activeStockCategories] sortedArrayUsingSelector:@selector(compare:)];
    
    self.stocksForCategory = [NSMutableDictionary dictionaryWithCapacity:[self.activeCategories count]];
    self.categoryForStock = [NSMutableDictionary dictionaryWithCapacity:[appData(stocks) count]];
    
    for (id categoryKey in self.activeCategories) {
        StockSelectionCategory category = [[slm class] categoryForKey:categoryKey];
        NSArray *stocksInCategory = [slm activeStocksForCategory:category];
        
        [self.stocksForCategory setObject:stocksInCategory forKey:categoryKey];
        
        switch (category) {
            case StockSelectionCategoryFavorite:
            case StockSelectionCategoryTemporary:
                [self placeStocks:stocksInCategory inCategory:categoryKey];
                break;
            case StockSelectionCategoryRecent:
            default:
                break;
        }
    }
    
    [self.stockTableView reloadData];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Update handling

- (void)handleStockSelected:(Stock *)stock {
    [GET(StockListManager) addStockIdToRecentQueue:stock.stockId];
    
    [VC(PriceGraphViewController) setupWithStock:stock];
    JumpToViewController(PriceGraphViewController);
}

- (void)toggleFavoriteStatusForStock:(Stock *)stock {
    StockListManager *slm = GET(StockListManager);
    id stockKey = [Stock keyForStockId:stock.stockId];
    id categoryKey = [self.categoryForStock objectForKey:stockKey];
    
    StockSelectionCategory category = [[slm class] categoryForKey:categoryKey];
    [slm changeStatusForStock:stock currentCategory:category];
    [self refresh];
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.activeCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.stockTableView) {
        if (section < [self.activeCategories count]) {
            id categoryKey = [self.activeCategories objectAtIndex:section];
            StockSelectionCategory category = [[GET(StockListManager) class] categoryForKey:categoryKey];
            
            return [[self class] displayTitleForCategory:category];
        }
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.stockTableView) {
        if (section < [self.activeCategories count]) {
            id categoryKey = [self.activeCategories objectAtIndex:section];
            NSArray *stocksInCategory = [self.stocksForCategory objectForKey:categoryKey];
            
            return [stocksInCategory count];
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.stockTableView) {
        StockSelectionTableViewCell *cell = [self.stockTableView cell];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.stockTableView) {
        StockSelectionTableViewCell *customCell = (StockSelectionTableViewCell *)cell;
        id categoryKey = [self.activeCategories objectAtIndex:indexPath.section];
        NSArray *stocksInCategory = [self.stocksForCategory objectForKey:categoryKey];
        
        if (indexPath.row < [stocksInCategory count]) {
            id stockKey = [stocksInCategory objectAtIndex:indexPath.row];
            Stock *stock = [Stock loadByStockId:[stockKey intValue]];
            [customCell setupWithStock:stock];
        }
    }
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
