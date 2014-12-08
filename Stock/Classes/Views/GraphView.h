//
//  GraphView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/6/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

- (void)setMinX:(float)minX
           maxX:(float)maxX
           minY:(float)minY
           maxY:(float)maxY
          axisY:(float)axis
        yValues:(NSArray *)yValues;

@end
