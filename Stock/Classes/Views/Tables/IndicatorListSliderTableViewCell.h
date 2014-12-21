//
//  IndicatorListSliderTableViewCell.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Indicator, IndicatorListSliderView;

@interface IndicatorListSliderTableViewCell : UITableViewCell

@property (nonatomic, assign) IndicatorListSliderView *owner;

- (void)setupWithIndicator:(Indicator *)indicator
                  isActive:(BOOL)isActive;

@end
