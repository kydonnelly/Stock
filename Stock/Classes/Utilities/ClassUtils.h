//
//  ClassUtils.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIAlertView.h>

#define ReleaseIvar(_ivar) {\
    [_ivar release], _ivar = nil;\
}

#define KEY(intValue) [NSString stringWithFormat:@"%d", intValue]

#define Assert(condition, failMessage) AssertWithFormat(condition, failMessage)
#define AssertWithFormat(condition, failMessage, ...) \
if (!condition) {\
    [[[[UIAlertView alloc] initWithTitle:@"Assertion Failure" message:[NSString stringWithFormat:failMessage, ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"continue" otherButtonTitles:nil] autorelease] show];\
}

#define AbstractMethod AssertWithFormat(NO, @"Abstract method %@ called in class %@", NSStringFromSelector(_cmd), [[self class] description])