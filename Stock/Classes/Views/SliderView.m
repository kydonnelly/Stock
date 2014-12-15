//
//  SliderView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "SliderView.h"

#import "CallCenter.h"
#import "ClassUtils.h"
#import "ExtendedStateButton.h"
#import "LocalizationHelper.h"

static const double kSliderAnimationDuration = 0.5;

@interface SliderView ()

@property (nonatomic, retain) IBOutlet ExtendedStateButton *expandButton;
@property (nonatomic, retain) IBOutlet UIView *alwaysVisibleView;
@property (nonatomic, retain) IBOutlet UIView *collapsableView;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic) CGRect expandedFrame;
@property (nonatomic) CGRect collapsedFrame;

@end

@implementation SliderView

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_expandButton);
    ReleaseIvar(_alwaysVisibleView);
    ReleaseIvar(_collapsableView);
    
    [super dealloc];
}

#pragma mark - Setup

- (void)setup {
    [self setupReferenceFrames];
    [self setupExpandButton];
    [self completeSetExpanded:NO animated:NO];
}

- (void)setupReferenceFrames {
    self.expandedFrame = self.frame;
    self.collapsedFrame = CGRectMake(self.frame.origin.x,
                                     self.frame.origin.y + self.collapsableView.frame.size.height,
                                     self.frame.size.width,
                                     self.frame.size.height);
}

- (void)setupExpandButton {
    LocalizationHelper *helper = GET(LocalizationHelper);
    NSString *expandedString = [helper localizedStringForKey:@"Expand"];
    NSString *collapsedString = [helper localizedStringForKey:@"Hide"];
    
    [self.expandButton setTitle:expandedString forState:UIControlStateNormal];
    [self.expandButton setTitle:expandedString forState:UIControlStateHighlighted];
    
    [self.expandButton setTitle:collapsedString forState:UIControlStateApplication];
    [self.expandButton setTitle:collapsedString forState:(UIControlStateApplication|UIControlStateHighlighted)];
}

#pragma mark - Expanding

- (void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded animated:YES];
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (_expanded != expanded && !self.isAnimating) {
        [self completeSetExpanded:expanded animated:animated];
    }
}

- (void)completeSetExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (animated) {
        self.isAnimating = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kSliderAnimationDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    }
    
    if (expanded) {
        self.frame = self.expandedFrame;
    } else {
        self.frame = self.collapsedFrame;
    }
    
    if (animated) {
        [UIView commitAnimations];
    } else {
        [self animationFinished];
    }
    
    [self.expandButton setInCustomState:expanded];
    _expanded = expanded;
}

- (void)animationFinished {
    self.isAnimating = NO;
}

#pragma mark - Actions

- (IBAction)expandButtonTapped {
    self.expanded = !self.expanded;
}

@end
