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

@property (nonatomic, retain) IBOutlet UIView *colorView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UISwitch *activeSwitch;

@property (nonatomic, retain) Indicator *indicator;

@end

@implementation IndicatorListSliderTableViewCell

#pragma mark - Lifecycle

- (void)dealloc {
    _owner = nil;
    
    ReleaseIvar(_colorView);
    ReleaseIvar(_nameLabel);
    ReleaseIvar(_activeSwitch);
    
    ReleaseIvar(_indicator);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setupWithIndicator:(Indicator *)indicator isActive:(BOOL)isActive {
    self.indicator = indicator;
    
    [self.colorView setBackgroundColor:[indicator displayColor]];
    [self.nameLabel setText:[indicator displayName]];
    self.activeSwitch.on = isActive;
}

#pragma mark - Action

- (IBAction)activeSwitchPressed {
    [self.owner toggleIndicator:self.indicator activeState:self.activeSwitch.on];
}

@end
