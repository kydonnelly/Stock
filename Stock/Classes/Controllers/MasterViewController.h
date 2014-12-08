//
//  MasterViewController.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JumpToViewController(X)\
[VC(MasterViewController) jumpToViewController:VC(X)]

@interface MasterViewController : UIViewController

- (UIViewController *)currentViewController;

- (void)jumpToViewController:(UIViewController *)targetViewController;

@end
