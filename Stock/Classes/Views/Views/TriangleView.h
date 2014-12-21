//
//  TriangleView.h
//  Stock
//
//  Created by Kyle Donnelly on 12/20/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TriangleTypeDown = 0,
    TriangleTypeUp,
} TriangleType;

@interface TriangleView : UIView

@property (nonatomic) TriangleType triangleType;

@end
