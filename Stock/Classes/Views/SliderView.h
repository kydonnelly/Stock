//
//  SliderView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderView : UIView

@property (nonatomic) BOOL expanded;

- (void)setup;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
