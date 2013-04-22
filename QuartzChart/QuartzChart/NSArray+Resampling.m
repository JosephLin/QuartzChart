//
//  NSArray+Resampling.m
//  QuartzChart
//
//  Created by Joseph Lin on 4/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NSArray+Resampling.h"


@implementation NSArray (Resampling)

- (NSArray *)resampleToSize:(NSUInteger)size method:(ResamplingMethod)method
{
    if (self.count < size)
        return self;
    
    if (method < ResamplingMethodByAverage || method > ResamplingMethodByAddition) {
        NSLog(@"'%d' is not a valid ResamplingMethod!", method);
        return nil;
    }
    
    
    float x0 = 0;
    float x1 = 0;
    float ratio = (float)size / self.count;
    float ratioOrOne = (method == ResamplingMethodByAverage) ? ratio : 1;
    NSMutableArray *resampled = [NSMutableArray arrayWithCapacity:size];
    
    for (int i = 0; i < self.count; i++)
    {
        x1 = ratio * i;
        
        int floor0 = floorf(x0);
        int floor1 = floorf(x1);
        
        if (floor0 == floor1)
        {
            while (resampled.count <= floor1) {
                [resampled addObject:@0];
            }
            
            resampled[floor1] = @( [resampled[floor1] floatValue] + [self[i] floatValue] * ratioOrOne );
        }
        else
        {
            while (resampled.count <= floor0) {
                [resampled addObject:@0];
            }
            float value0 = [self[i] floatValue] * (floor1 - x0) / (x1 - x0);
            
            resampled[floor0] = @( [resampled[floor0] floatValue] + value0 * ratioOrOne );
            
            
            while (resampled.count <= floor1) {
                [resampled addObject:@0];
            }
            float value1 = [self[i] floatValue] * (x1 - floor1) / (x1 - x0);

            resampled[floor1] = @( [resampled[floor1] floatValue] + value1 * ratioOrOne );
        }
        
        x0 = x1;
    }
    
    return resampled;
}

@end
