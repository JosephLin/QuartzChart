//
//  NSArray+Resampling.h
//  QuartzChart
//
//  Created by Joseph Lin on 4/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ResamplingMethod){
    ResamplingMethodByAverage = 0,
    ResamplingMethodByAddition,
};


@interface NSArray (Resampling)

- (NSArray *)resampleToSize:(NSUInteger)size method:(ResamplingMethod)method;

@end
