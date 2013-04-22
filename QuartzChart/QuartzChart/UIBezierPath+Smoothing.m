//
//  UIBezierPath+Smooth.m
//  QuartzChart
//
//  http://stackoverflow.com/questions/8702696/drawing-smooth-curves-methods-needed
//  http://www.cubic.org/docs/hermite.htm
//

#import "UIBezierPath+Smoothing.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]


@implementation UIBezierPath (Smoothing)

- (UIBezierPath*)catmullRomSplinesPathWithGranularity:(NSInteger)granularity
{
    return [self cardinalSplinesPathWithGranularity:granularity tension:0];
}

- (UIBezierPath*)cardinalSplinesPathWithGranularity:(NSInteger)granularity tension:(float)t
{
    return [self kbSplinesPathWithGranularity:granularity tension:t bias:0 continuity:0];
}

- (UIBezierPath*)kbSplinesPathWithGranularity:(NSInteger)granularity tension:(float)t bias:(float)b continuity:(float)c
{
    NSMutableArray *points = [[self points] mutableCopy];
    
    if (points.count < 3) return [self copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
                
        CGPoint t1 = CGPointMake((1-t)*(1+b)*(1+c)/2 * (p1.x - p0.x) + (1-t)*(1-b)*(1-c)/2 * (p2.x - p1.x),
                                 (1-t)*(1+b)*(1+c)/2 * (p1.y - p0.y) + (1-t)*(1-b)*(1-c)/2 * (p2.y - p1.y));
        
        CGPoint t2 = CGPointMake((1-t)*(1+b)*(1-c)/2 * (p2.x - p1.x) + (1-t)*(1-b)*(1-c)/2 * (p3.x - p2.x),
                                 (1-t)*(1+b)*(1-c)/2 * (p2.y - p1.y) + (1-t)*(1-b)*(1-c)/2 * (p3.y - p2.y));
        
        
        // now add n points starting at p1 + dx/dy up until p2
        for (int t = 0; t < granularity; t++)
        {
            float s = (float)t / granularity;
            float ss = s * s;
            float sss = s * s * s;
            
            CGPoint pi; // intermediate point
            
            float h1 =  2*sss - 3*ss + 0*s + 1;
            float h2 = -2*sss + 3*ss + 0*s + 0;
            float h3 =  1*sss - 2*ss + 1*s + 0;
            float h4 =  1*sss - 1*ss + 0*s + 0;
            
            pi.x = h1*p1.x + h2*p2.x + h3*t1.x + h4*t2.x;
            pi.y = h1*p1.y + h2*p2.y + h3*t1.y + h4*t2.y;
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

- (UIBezierPath*)bSplinesPathWithGranularity:(NSInteger)granularity
{
    NSMutableArray *points = [[self points] mutableCopy];
    
    if (points.count < 3) return [self copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
        
        for (int t = 0; t < granularity; t++)
        {
            float s = (float)t / granularity;
            float ss = s * s;
            float sss = s * s * s;
            
            CGPoint pi; // intermediate point
            
            float h1 = -1*sss +3*ss -3*s +1;
            float h2 =  3*sss -6*ss +0*s +4;
            float h3 = -3*sss +3*ss +3*s +1;
            float h4 =  1*sss +0*ss +0*s +0;
            
            pi.x = (h1*p0.x + h2*p1.x + h3*p2.x + h4*p3.x) / 6;
            pi.y = (h1*p0.y + h2*p1.y + h3*p2.y + h4*p3.y) / 6;
            [smoothedPath addLineToPoint:pi];
        }
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

// http://bobbograph.robertmesserle.com/test_page.html
// http://gizma.com/easing/
- (UIBezierPath*)quadEasingInOutPathWithGranularity:(NSInteger)granularity
{
    NSMutableArray *points = [[self points] mutableCopy];
    
    if (points.count < 3) return [self copy];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 0; index < points.count - 1; index++)
    {
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        
        for (int t = 0; t < granularity; t++)
        {
            float b = p1.y;
            float c = p2.y - p1.y;
            float d = p2.x - p1.x;
            float s = (float)t / granularity * d;
            
            CGPoint pi; // intermediate point
            pi.x = s + p1.x;
            
            s /= d/2;
            if (s < 1) {
                pi.y = c/2*s*s + b;
            }
            else {
                s--;
                pi.y = -c/2 * (s*(s-2) - 1) + b;
            }

            [smoothedPath addLineToPoint:pi];
        }
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}



#pragma mark -

// Get points from Bezier Curve
void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}


#pragma mark -

- (UIBezierPath *)closedPathWithMaxY:(CGFloat)maxY
{
    NSMutableArray *points = [[self points] mutableCopy];

    if (points.count < 2) return [self copy];

    CGPoint firstPoint = [points[0] CGPointValue];
    CGPoint lastPoint = [[points lastObject] CGPointValue];
    
    
    UIBezierPath *closedPath = [self copy];
    [closedPath moveToPoint:lastPoint];
    [closedPath addLineToPoint:CGPointMake(lastPoint.x, maxY)];
    [closedPath addLineToPoint:CGPointMake(firstPoint.x, maxY)];
    [closedPath addLineToPoint:firstPoint];

    return closedPath;
}


@end
