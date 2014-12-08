//
//  Stock.h
//  Stock
//
//  Created by Kyle Donnelly on 11/29/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stock : NSObject

+ (id)keyForStockId:(int)stockId;
+ (Stock *)loadByStockId:(int)stockId;

@property (nonatomic) int stockId;
@property (nonatomic, retain) NSString *ticker;
@property (nonatomic, retain) NSString *companyName;

@end
