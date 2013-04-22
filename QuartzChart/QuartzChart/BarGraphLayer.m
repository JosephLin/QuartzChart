//
//  BarGraphLayer.m
//  QuartzChart
//
//  Created by Joseph Lin on 2/28/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "BarGraphLayer.h"


@interface BarGraphLayer ()
@property (nonatomic, strong) CAShapeLayer *barsLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CABasicAnimation* animation;
@end


@implementation BarGraphLayer

- (id)init
{
    self = [super init];
    if (self)
    {
        self.lineCap = kCALineCapButt;
        self.lineJoin = kCALineJoinRound;
        self.lineWidth = 8;
        
        self.gradientStartPoint = CGPointMake(0.5, 1.0);
        self.gradientEndPoint = CGPointMake(0.5, 0.0);
        self.gradientColors = @[(id)[UIColor orangeColor].CGColor,
                                (id)[UIColor yellowColor].CGColor];
        
        self.maxValue = 100;
        self.padding = CGSizeZero;
        self.barWidth = 6.0;
        
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


#pragma mark -

// Not in use. We can only animate the bounds with this.
- (UIBezierPath *)bezierPathWithRects
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat width = CGRectGetWidth(self.frame) - self.padding.width * 2;
    CGFloat height = CGRectGetHeight(self.frame) - self.padding.height * 2;
    CGFloat x = self.padding.width;
    CGFloat step = width / (self.values.count - 1);

    [path moveToPoint:CGPointMake(x - self.barWidth/2, self.padding.height + height)];

    for (NSNumber *value in self.values)
    {
        CGFloat y = self.padding.height + height * (1 - [value floatValue] / self.maxValue);

        // Hack to avoid a shadowPath bug.
        [path addLineToPoint:CGPointMake(x - self.barWidth/2, self.padding.height + height)];
        [path addLineToPoint:CGPointMake(x - self.barWidth/2, y)];
        [path addLineToPoint:CGPointMake(x + self.barWidth/2, y + 0.01)];
        [path addLineToPoint:CGPointMake(x + self.barWidth/2, self.padding.height + height)];
        
//        CGRect rect = CGRectMake(x - self.barWidth/2, y, self.barWidth, height * ([value floatValue] / self.maxValue));
//        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:rect];
//        [path appendPath:rectPath];
        
        x += step;
    }
    
    [path closePath];
    
    return path;
}

// Animates the lines provides a more exciting animation efffect.
- (UIBezierPath *)bezierPathWithLines
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat width = CGRectGetWidth(self.frame) - self.padding.width * 2;
    CGFloat height = CGRectGetHeight(self.frame) - self.padding.height * 2;
    CGFloat x = self.padding.width;
    CGFloat step = width / (self.values.count - 1);
    
    for (NSNumber *value in self.values)
    {
        CGFloat y = self.padding.height + height * (1 - [value floatValue] / self.maxValue);
        
        [path moveToPoint:CGPointMake(x, self.padding.height + height)];
        [path addLineToPoint:CGPointMake(x, y)];
        
        x += step;
    }
    
    return path;
}


#pragma mark -

- (void)display
{
    CGFloat maxWidth = CGRectGetWidth(self.frame) / self.values.count;
    CGFloat optimalBarWidth = MAX(1, MIN(self.barWidth, maxWidth) - 1);
    
    UIBezierPath *bezierPath = [self bezierPathWithLines];
    
    CAShapeLayer *barsLayer = [CAShapeLayer layer];
    barsLayer.frame = self.bounds;
    barsLayer.lineWidth = optimalBarWidth;
    barsLayer.lineCap = self.lineCap;
    barsLayer.lineJoin = self.lineJoin;
    barsLayer.strokeColor = [[UIColor blackColor] CGColor];
    barsLayer.path = bezierPath.CGPath;
    if (self.showShadow)
    {
        barsLayer.shadowOffset = CGSizeMake(2, 2);
        barsLayer.shadowOpacity = 0.7;
        barsLayer.shadowRadius = 2.0;
        barsLayer.shadowColor = [UIColor blackColor].CGColor;
    }
    [self.barsLayer removeAllAnimations];
    self.barsLayer = barsLayer;


    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.startPoint = self.gradientStartPoint;
    gradientLayer.endPoint = self.gradientEndPoint;
    gradientLayer.colors = self.gradientColors;
    gradientLayer.locations = self.gradientLocations;
    gradientLayer.mask = barsLayer;
    [self addSublayer:gradientLayer];
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer = gradientLayer;
    
    
    if (self.animation)
    {
        [self.barsLayer addAnimation:self.animation forKey:@"strokeEndAnimation"];
        self.animation = nil;
    }
}

- (void)animateWithDuration:(NSTimeInterval)duration
{
    [self.barsLayer removeAllAnimations];
    
    self.animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.animation.duration = duration;
    self.animation.fromValue = @0;
    self.animation.toValue = @1;
    
    [self setNeedsDisplay];
}

@end
