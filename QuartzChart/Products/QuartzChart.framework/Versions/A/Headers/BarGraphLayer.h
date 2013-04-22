//
//  BarGraphLayer.h
//  QuartzChart
//
//  Created by Joseph Lin on 2/28/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface BarGraphLayer : CALayer

/* Bars (CAShapeLayer) properties */
@property (copy) NSString *lineCap;
@property (copy) NSString *lineJoin;
@property CGFloat lineWidth;

/* Gradient (CAGradientLayer) properties */
@property CGPoint startPoint;
@property CGPoint endPoint;
@property (copy) NSArray *locations;
@property (copy) NSArray *colors;

/* Data source */
@property (nonatomic, strong) NSArray *values;
@property (nonatomic) float maxValue; // Default = 100
@property (nonatomic) CGSize padding; // Default = (0,0)
@property (nonatomic) CGFloat barWidth; // Default = 10
@property (nonatomic) BOOL showShadow; // Default = NO

- (void)animateWithDuration:(NSTimeInterval)duration;

@end
