//
//  MasterViewController.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "MasterViewController.h"

#import "CallCenter.h"
#import "ClassUtils.h"

@interface MasterViewController ()

@property (nonatomic, retain) UIViewController *currentViewController;

@end

@implementation MasterViewController

#pragma mark - Lifecycle

RegisterWithCallCenter

- (void)dealloc {
    ReleaseIvar(_currentViewController);
    
    [super dealloc];
}

#pragma mark - Controller Logic

- (void)jumpToViewController:(UIViewController *)targetViewController {
    if (self.currentViewController == targetViewController) {
        NSLog(@"Trying to jump into class that is already current. %@", NSStringFromClass([targetViewController class]));
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self didJumpOutOfViewController:self.currentViewController];
    }];
    [self presentViewController:targetViewController animated:NO completion:^{
        [self didJumpIntoViewController:targetViewController];
    }];
}

- (void)didJumpOutOfViewController:(UIViewController *)viewController {
    self.currentViewController = nil;
}

- (void)didJumpIntoViewController:(UIViewController *)targetViewController {
    self.currentViewController = targetViewController;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
