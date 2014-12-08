//
//  LocalizationHelper.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton+Protocol.h"

#define localizedString(stringKey) [GET(LocalizationHelper) localizedStringForKey:stringKey]

@interface LocalizationHelper : NSObject <Singleton>

- (NSString *)localizedStringForKey:(NSString *)key;

@end
