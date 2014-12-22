//
//  XibView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "XibView.h"

@implementation XibView

- (id)initWithOwner:(id)owner {
    [self autorelease];
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil];
    return [[subviewArray lastObject] retain];
}

@end
