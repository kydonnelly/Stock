//
//  LocalizationHelper.m
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "LocalizationHelper.h"

@implementation LocalizationHelper

MakeSingleton

- (NSString *)localizedStringForKey:(NSString *)key {
    // does not support localization yet
    return key;
}

@end
