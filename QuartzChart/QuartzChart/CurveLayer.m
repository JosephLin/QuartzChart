//
//  CurveLayer.m
//  QuartzChart
//
//  Created by Joseph Lin on 2/25/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CurveLayer.h"
#import "UIBezierPath+Smoothing.h"


@interface CurveLayer ()
@property (nonatomic, strong) CAShapeLayer *curveLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *curveLayerDup;
@property (nonatomic, strong) CAShapeLayer* shadowLayer;
@property (nonatomic, strong) CABasicAnimation* animation;
@end


@implementation CurveLayer

- (id)init
{
    self = [super init];
    if (self)
    {
        self.lineCap = kCALineCapRound;
        self.lineJoin = kCALineJoinRound;
        self.lineWidth = 6;
        self.granularity = 15;

        self.gradientStartPoint = CGPointMake(0.0, 0.5);
        self.gradientEndPoint = CGPointMake(1.0, 0.5);
        self.gradientColors = @[(id)[UIColor redColor].CGColor,
                                (id)[UIColor yellowColor].CGColor];
        
        self.maxValue = 100;
        self.padding = CGSizeZero;

        self.masksToBounds = YES;
    }
    return self;
}

#pragma mark -

- (void)setValues:(NSArray *)values
{
    _values = values;
    self.animation = nil;
    [self setNeedsDisplay];
}

- (void)setSmoothingAlgorithm:(SmoothingAlgorithm)smoothingAlgorithm
{
    _smoothingAlgorithm = smoothingAlgorithm;
    self.animation = nil;
    [self setNeedsDisplay];
}

- (void)setGranularity:(NSUInteger)granularity
{
    _granularity = granularity;
    self.animation = nil;
    [self setNeedsDisplay];
}

- (void)setTension:(float)tension
{
    _tension = tension;
    self.animation = nil;
    [self setNeedsDisplay];
}

- (void)setBias:(float)bias
{
    _bias = bias;
    self.animation = nil;
    [self setNeedsDisplay];
}

- (void)setContinuity:(float)continuity
{
    _continuity = continuity;
    self.animation = nil;
    [self setNeedsDisplay];
}


#pragma mark -

- (UIBezierPath *)bezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (self.values.count > 1)
    {
        CGFloat width = CGRectGetWidth(self.frame) - self.padding.width * 2;
        CGFloat height = CGRectGetHeight(self.frame) - self.padding.height * 2;
        CGFloat x = self.padding.width;
        CGFloat step = width / (self.values.count - 1);
        
        for (NSNumber *value in self.values)
        {
            CGFloat y = self.padding.height + height * (1 - [value floatValue] / self.maxValue);
            CGPoint point = CGPointMake(x, y);
            
            if (x == 0) {
                [path moveToPoint:point];
            }
            else {
                [path addLineToPoint:point];
            }
            
            x += step;
        }
    }
    return path;
}


#pragma mark -

- (void)display
{
    UIBezierPath *bezierPath = [self bezierPath];

    UIBezierPath *smoothedPath;
    switch (self.smoothingAlgorithm) {
        case SmoothingAlgorithmCatmullRomSpline:
            smoothedPath = [bezierPath catmullRomSplinesPathWithGranularity:self.granularity];
            break;
            
        case SmoothingAlgorithmCardinalSpline:
            smoothedPath = [bezierPath cardinalSplinesPathWithGranularity:self.granularity tension:self.tension];
            break;
            
        case SmoothingAlgorithmKBSpline:
            smoothedPath = [bezierPath kbSplinesPathWithGranularity:self.granularity tension:self.tension bias:self.bias continuity:self.continuity];
            break;
            
        case SmoothingAlgorithmBSpline:
            smoothedPath = [bezierPath bSplinesPathWithGranularity:self.granularity];
            break;

        case SmoothingAlgorithmQuadEasingInOut:
            smoothedPath = [bezierPath quadEasingInOutPathWithGranularity:self.granularity];
            break;
            
        default:
            smoothedPath = bezierPath;
            break;
    }
    
    UIBezierPath *closedPath = [smoothedPath closedPathWithMaxY:CGRectGetHeight(self.frame)];

    
    // Curve: curve mask on top of a gradient
    
    CAShapeLayer *curveLayer = [CAShapeLayer layer];
    curveLayer.frame = self.bounds;
    curveLayer.lineWidth = self.lineWidth;
    curveLayer.lineCap = self.lineCap;
    curveLayer.lineJoin = self.lineJoin;
    curveLayer.fillColor = [[UIColor clearColor] CGColor];
    curveLayer.strokeColor = [[UIColor blackColor] CGColor];
    curveLayer.path = smoothedPath.CGPath;
    [self.curveLayer removeAllAnimations];
    self.curveLayer = curveLayer;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.startPoint = self.gradientStartPoint;
    gradientLayer.endPoint = self.gradientEndPoint;
    gradientLayer.colors = self.gradientColors;
    gradientLayer.locations = self.gradientLocations;
    gradientLayer.mask = curveLayer;
    [self addSublayer:gradientLayer];
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer = gradientLayer;
    
    
    // Shadow: curve mask on top of the shadow of a closed path.

    CAShapeLayer *curveLayerDup = [CAShapeLayer layer];
    curveLayerDup.frame = curveLayer.frame;
    curveLayerDup.lineWidth = curveLayer.lineWidth;
    curveLayerDup.lineCap = curveLayer.lineCap;
    curveLayerDup.lineJoin = curveLayer.lineJoin;
    curveLayerDup.fillColor = curveLayer.fillColor;
    curveLayerDup.strokeColor = curveLayer.strokeColor;
    curveLayerDup.path = curveLayer.path;
    [self.curveLayerDup removeAllAnimations];
    self.curveLayerDup = curveLayerDup;
    
    CAShapeLayer* shadowLayer = [CAShapeLayer layer];
    shadowLayer.frame = self.bounds;
    shadowLayer.shadowOffset = CGSizeMake(0, 3.0);
    shadowLayer.shadowOpacity = 0.2;
    shadowLayer.shadowRadius = 1.0;
    shadowLayer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    shadowLayer.shadowPath = closedPath.CGPath;
    shadowLayer.mask = curveLayerDup;
    [self addSublayer:shadowLayer];
    [self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = shadowLayer;

    
    if (self.animation)
    {
        [self.curveLayer addAnimation:self.animation forKey:@"strokeEndAnimation"];
        [self.curveLayerDup addAnimation:self.animation forKey:@"strokeEndAnimation"];
        self.animation = nil;
    }
}

- (void)animateWithDuration:(NSTimeInterval)duration
{
    [self.curveLayer removeAllAnimations];
    [self.curveLayerDup removeAllAnimations];

    self.animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.animation.duration = duration;
    self.animation.fromValue = @0;
    self.animation.toValue = @1;
    
    [self setNeedsDisplay];
}

@end
