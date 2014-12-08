//
//  Singleton.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MakeSingleton \
+ (instancetype)instance {\
    static id instance = nil;\
    static dispatch_once_t token;\
    dispatch_once(&token, ^{\
        instance = [[[self class] alloc] init];\
    });\
    return instance;\
}

#define GET(Singleton) [Singleton instance]

@protocol Singleton <NSObject>

+ (instancetype)instance;

@end
