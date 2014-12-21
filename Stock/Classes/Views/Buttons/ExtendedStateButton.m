//
//  ExtendedStateButton.m
//  Stock
//
//  Created by Kyle Donnelly on 11/30/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "ExtendedStateButton.h"

@interface ExtendedStateButton ()

@property (nonatomic) NSUInteger customState;

@end

@implementation ExtendedStateButton

- (void)setInCustomState:(BOOL)isInCustomState {
    if (isInCustomState) {
        self.state = UIControlStateApplication;
    } else {
        self.state &= ~UIControlStateApplication;
    }
}

- (void)setState:(UIControlState)state {
    if (_customState != state) {
        _customState = state;
        [self layoutSubviews];
    }
}

- (UIControlState)state {
    if (_customState > UIControlStateNormal) {
        return self.customState;
    } else {
        return [super state];
    }
}

@end
