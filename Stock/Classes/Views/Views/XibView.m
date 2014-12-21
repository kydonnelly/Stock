//
//  XibView.m
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "XibView.h"

@implementation XibView

- (id)init {
    [self autorelease];
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    return [[subviewArray lastObject] retain];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [self init]) {
        self.frame = frame;
    }
    
    return self;
}

@end
