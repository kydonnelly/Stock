//
//  NSArray+Sorted.m
//  Stock
//
//  Created by Kyle Donnelly on 12/21/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "NSArray+Sorted.h"

@implementation NSArray (Sorted)

- (NSComparator)comparator {
    static NSComparator stockComparator = ^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    };
    return stockComparator;
}

- (int)indexOfSortableObject:(id)anObject {
    NSRange searchRange = {0, [self count]};
    return [self indexOfObject:anObject
                 inSortedRange:searchRange
                       options:NSBinarySearchingLastEqual
               usingComparator:[self comparator]];
}

- (BOOL)containsSortableObject:(id)anObject {
    return [self indexOfSortableObject:anObject] != NSNotFound;
}

@end

@implementation NSMutableArray (Sorted)

- (void)addSortableObject:(id)anObject {
    NSRange searchRange = {0, [self count]};
    int index = [self indexOfObject:anObject
                      inSortedRange:searchRange
                            options:NSBinarySearchingInsertionIndex
                    usingComparator:[self comparator]];

    [self insertObject:anObject atIndex:index];
}

- (void)removeSortableObject:(id)anObject {
    int index = [self indexOfSortableObject:anObject];
    if (index != NSNotFound) {
        [self removeObjectAtIndex:index];
    }
}

@end
