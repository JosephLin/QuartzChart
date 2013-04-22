//
//  CurveLayer.h
//  QuartzChart
//
//  Created by Joseph Lin on 2/25/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, SmoothingAlgorithm) {
    SmoothingAlgorithmNone = 0,
    SmoothingAlgorithmCatmullRomSpline,
    SmoothingAlgorithmCardinalSpline,
    SmoothingAlgorithmKBSpline,
    SmoothingAlgorithmBSpline,
    SmoothingAlgorithmQuadEasingInOut,
};


@interface CurveLayer : CALayer

/* Curve (CAShapeLayer) properties */
@property (copy) NSString *lineCap;
@property (copy) NSString *lineJoin;
@property CGFloat lineWidth;

/* Curve: smoothing properties */
@property (nonatomic) SmoothingAlgorithm smoothingAlgorithm;
@property (nonatomic) NSUInteger granularity;
@property (nonatomic) float tension;
@property (nonatomic) float bias;
@property (nonatomic) float continuity;

/* Gradient (CAGradientLayer) properties */
@property CGPoint gradientStartPoint;
@property CGPoint gradientEndPoint;
@property (copy) NSArray *gradientLocations;
@property (copy) NSArray *gradientColors;

/* Data source */
@property (nonatomic, strong) NSArray *values;
@property (nonatomic) float maxValue; // Default = 100
@property (nonatomic) CGSize padding; // Default = (0,0)

- (void)animateWithDuration:(NSTimeInterval)duration;

@end
