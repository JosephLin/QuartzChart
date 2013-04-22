//
//  UIBezierPath+Smooth.h
//  QuartzChart
//
//  http://stackoverflow.com/questions/8702696/drawing-smooth-curves-methods-needed
//  http://www.cubic.org/docs/hermite.htm
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Smoothing)

- (UIBezierPath*)catmullRomSplinesPathWithGranularity:(NSInteger)granularity;
- (UIBezierPath*)cardinalSplinesPathWithGranularity:(NSInteger)granularity tension:(float)tension;
- (UIBezierPath*)kbSplinesPathWithGranularity:(NSInteger)granularity tension:(float)t bias:(float)b continuity:(float)c;
- (UIBezierPath*)bSplinesPathWithGranularity:(NSInteger)granularity;
- (UIBezierPath*)quadEasingInOutPathWithGranularity:(NSInteger)granularity;

- (UIBezierPath *)closedPathWithMaxY:(CGFloat)maxY;

@end
