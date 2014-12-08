//
//  CallCenter.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton+Protocol.h"

#define RegisterWithCallCenter \
+ (void)load {\
    [GET(CallCenter) registerViewController:[self class]];\
}

#define VC(X) \
(X *)[GET(CallCenter) viewControllerInstance:[X class]]

@interface CallCenter : NSObject <Singleton>

- (void)registerViewController:(Class)viewControllerClass;
- (UIViewController *)viewControllerInstance:(Class)viewControllerClass;

- (void)unloadViewControllersExcept:(NSArray *)savedViewControllers;

@end
