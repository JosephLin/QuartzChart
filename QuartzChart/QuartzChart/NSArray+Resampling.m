//
//  NSArray+Resampling.m
//  QuartzChart
//
//  Created by Joseph Lin on 4/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NSArray+Resampling.h"


@implementation NSArray (Resampling)

- (NSArray *)resampleToSize:(NSUInteger)newSize method:(ResamplingMethod)method
{
    NSUInteger oldSize = [self count];
    
    if (oldSize == newSize)
        return self;
    
    if (method < ResamplingMethodByAverage || method > ResamplingMethodByAddition) {
        NSLog(@"'%d' is not a valid ResamplingMethod!", method);
        return nil;
    }
    
    
    NSMutableArray *resampled = [NSMutableArray arrayWithCapacity:newSize];
    
    
    for (int i = 0; i < newSize; i++)
    {
        float y = 0;
        
        for (int j = 0; j < oldSize; j++)
        {
            float x = ((float)i * (float)oldSize/newSize) + (float)j / newSize;
            
            y += ([self[(int)x] floatValue] / newSize);
        }
        
        if (method == ResamplingMethodByAverage)
        {
            y *= (float)newSize / oldSize;
        }
        
        [resampled addObject:@(y)];
    }
    
    
    return resampled;
}

@end
