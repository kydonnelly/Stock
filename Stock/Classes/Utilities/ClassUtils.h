//
//  ClassUtils.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#define ReleaseIvar(_ivar) {\
    [_ivar release], _ivar = nil;\
}

#define KEY(intValue) [NSString stringWithFormat:@"%d", intValue]