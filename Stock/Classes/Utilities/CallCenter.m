//
//  CallCenter.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "CallCenter.h"

#import "ClassUtils.h"

@interface CallCenter ()

@property (nonatomic, retain) NSMutableDictionary *viewControllers;

@end

@implementation CallCenter

#pragma mark - Class Convention

+ (id)keyForViewControllerClass:(Class)viewControllerClass {
    return NSStringFromClass(viewControllerClass);
}

#pragma mark - Lifecycle

MakeSingleton

- (id)init {
    if (self = [super init]) {
        self.viewControllers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    ReleaseIvar(_viewControllers);
    
    [super dealloc];
}

#pragma mark - Registration

- (void)registerViewController:(Class)viewControllerClass {
    id key = [[self class] keyForViewControllerClass:viewControllerClass];
    UIViewController *viewController = [[[viewControllerClass alloc] init] autorelease];
    
    [self.viewControllers setObject:viewController forKey:key];
}

- (UIViewController *)viewControllerInstance:(Class)viewControllerClass {
    id key = [[self class] keyForViewControllerClass:viewControllerClass];
    UIViewController *viewController = [self.viewControllers objectForKey:key];
    
    if (!viewController) {
        AssertWithFormat(NO, @"Had to force registration of %@", NSStringFromClass(viewControllerClass));
        [self registerViewController:viewControllerClass];
    }
    
    return [self.viewControllers objectForKey:key];
}

#pragma mark - Memory Warning

- (void)unloadViewControllersExcept:(NSArray *)savedViewControllers {
    [self.viewControllers removeAllObjects];
    
    for (UIViewController *viewController in savedViewControllers) {
        id key = [[self class] keyForViewControllerClass:[viewController class]];
        [self.viewControllers setObject:viewController forKey:key];
    }
}

@end
