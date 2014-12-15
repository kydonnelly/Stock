//
//  IndicatorListSliderTableViewCell.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "IndicatorListSliderTableViewCell.h"

#import "ClassUtils.h"
#import "Indicator.h"
#import "IndicatorListSliderView.h"

@interface IndicatorListSliderTableViewCell ()

@property (nonatomic, retain) IBOutlet UILabel *indicatorNameLabel;
@property (nonatomic, retain) IBOutlet UISwitch *indicatorActiveSwitch;

@property (nonatomic, retain) Indicator *indicator;

@end

@implementation IndicatorListSliderTableViewCell

#pragma mark - Lifecycle

- (void)dealloc {
    _owner = nil;
    
    ReleaseIvar(_indicatorNameLabel);
    ReleaseIvar(_indicatorActiveSwitch);
    
    ReleaseIvar(_indicator);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithIndicator:(Indicator *)indicator isActive:(BOOL)isActive {
    self.indicator = indicator;
    
    [self.indicatorNameLabel setText:[indicator displayName]];
    self.indicatorActiveSwitch.on = isActive;
}

#pragma mark - Action

- (IBAction)activeSwitchPressed {
    [self.owner toggleIndicator:self.indicator activeState:self.indicatorActiveSwitch.on];
}

@end
