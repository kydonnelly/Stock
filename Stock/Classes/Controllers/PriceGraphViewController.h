//
//  PriceGraphViewController.h
//  Stock
//
//  Created by Kyle Donnelly on 12/3/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stock;

@interface PriceGraphViewController : UIViewController

- (void)setupWithStock:(Stock *)stock;

@end
