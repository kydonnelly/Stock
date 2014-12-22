//
//  IndicatorDetailTableViewCell.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "IndicatorDetailTableViewCell.h"

#import "ClassUtils.h"
#import "Indicator.h"

@interface IndicatorDetailTableViewCell ()

@property (nonatomic, retain) IBOutlet UIView *colorView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;

@end

@implementation IndicatorDetailTableViewCell

- (void)dealloc {
    ReleaseIvar(_colorView);
    ReleaseIvar(_nameLabel);
    ReleaseIvar(_detailLabel);

    [super dealloc];
}

- (void)setupWithIndicator:(Indicator *)indicator forPriceIndex:(int)index {
    [self.colorView setBackgroundColor:[indicator displayColor]];
    [self.nameLabel setText:[indicator displayName]];
    [self.detailLabel setText:[indicator displayDetailsAtPriceIndex:index]];
}

@end
