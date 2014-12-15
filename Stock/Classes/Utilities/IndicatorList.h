//
//  IndicatorList.h
//  Stock
//
//  Created by Kyle Donnelly on 12/14/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Singleton+Protocol.h"

@class Indicator;

#define RegisterForOptionsSlider \
+ (void)load {\
    [GET(IndicatorList) registerIndicator:[[[self alloc] init] autorelease]];\
}

@interface IndicatorList : NSObject <Singleton>

- (void)registerIndicator:(Indicator *)indicator;

- (NSArray *)allIndicators;

@end
