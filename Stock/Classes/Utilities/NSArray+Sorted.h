//
//  NSArray+Sorted.h
//  Stock
//
//  Created by Kyle Donnelly on 12/21/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Sorted)

- (BOOL)containsSortableObject:(id)anObject;

@end

@interface NSMutableArray (Sorted)

- (void)addSortableObject:(id)anObject;
- (void)removeSortableObject:(id)anObject;

@end
