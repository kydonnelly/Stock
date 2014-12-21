//
//  IndicatorDetailTableViewCell.h
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Indicator;

@interface IndicatorDetailTableViewCell : UITableViewCell

- (void)setupWithIndicator:(Indicator *)indicator
             forPriceIndex:(int)index;

@end
