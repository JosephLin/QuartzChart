//
//  MainViewController.m
//  QuartzChartSampleApp
//
//  Created by Joseph Lin on 4/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzChart/QuartzChart.h>

typedef NS_ENUM(NSUInteger, SegmentedControlIndex){
    SegmentedControlIndexBSplines = 0,
    SegmentedControlIndexKBSplines,
    SegmentedControlIndexQuadEasing,
};


@interface MainViewController ()
@property (nonatomic, strong) CurveLayer *curveLayer;
@property (nonatomic, strong) BarGraphLayer *barGraphLayer;
@property (nonatomic, weak) IBOutlet UIView *graphView;
@property (nonatomic, weak) IBOutlet UILabel *curveSamplesLabel;
@property (nonatomic, weak) IBOutlet UISlider *curveSamplesSlider;
@property (nonatomic, weak) IBOutlet UILabel *barGraphSamplesLabel;
@property (nonatomic, weak) IBOutlet UISlider *barGraphSamplesSlider;
@property (nonatomic, weak) IBOutlet UISegmentedControl *curveTypeSegmentedControl;
@property (nonatomic) SmoothingAlgorithm smoothingAlgorithm;
@property (nonatomic) NSUInteger curveSamples;
@property (nonatomic) NSUInteger barGraphSamples;
@property (nonatomic, strong) NSArray *values;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"values" ofType:@"plist"];
    self.values = [NSArray arrayWithContentsOfFile:path];
    
    NSUInteger size = [self.values count];
    self.barGraphSamplesSlider.maximumValue = self.curveSamplesSlider.maximumValue = size;
    self.curveSamplesSlider.value = self.curveSamples = size;
    self.barGraphSamplesSlider.value = self.barGraphSamples = size;
    
    [self reloadCurveAnimated:YES];
    [self reloadBarGraphAnimated:YES];
}


#pragma mark - Accessor

- (CurveLayer *)curveLayer
{
    if (!_curveLayer)
    {
        _curveLayer = [CurveLayer layer];
        _curveLayer.frame = self.graphView.bounds;
        _curveLayer.lineWidth = 3.0;
        _curveLayer.padding = CGSizeMake(0, 4);
        _curveLayer.gradientColors = @[(id)[UIColor redColor].CGColor,
                                       (id)[UIColor yellowColor].CGColor,
                                       (id)[UIColor greenColor].CGColor];
        
        _curveLayer.gradientLocations = @[@(0), @(0.3), @(1)];
        _curveLayer.smoothingAlgorithm = SmoothingAlgorithmBSpline;

        [self.graphView.layer addSublayer:_curveLayer];
    }
    return _curveLayer;
}

- (BarGraphLayer *)barGraphLayer
{
    if (!_barGraphLayer)
    {
        _barGraphLayer = [BarGraphLayer layer];
        _barGraphLayer.frame = self.graphView.bounds;
        _barGraphLayer.padding = CGSizeMake(0, 4);
        _barGraphLayer.gradientColors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.2].CGColor,
                                          (id)[UIColor colorWithWhite:0.0 alpha:0.2].CGColor];

        [self.graphView.layer insertSublayer:_barGraphLayer below:self.curveLayer];
    }
    return _barGraphLayer;
}


#pragma mark -

- (void)reloadCurveAnimated:(BOOL)animated
{
    NSArray *curveValues = [self resampleArray:self.values toSize:self.curveSamples];
    NSNumber *maxCurveValue = [curveValues valueForKeyPath:@"@max.floatValue"];
    
    NSUInteger optimalGranularity = ceil(CGRectGetWidth(self.curveLayer.frame)/curveValues.count);
    self.curveLayer.granularity = optimalGranularity;
    
    self.curveLayer.values = curveValues;
    self.curveLayer.maxValue = [maxCurveValue floatValue];
    
    if (animated)
    {
        [self.curveLayer animateWithDuration:2.0];
    }
}

- (void)reloadBarGraphAnimated:(BOOL)animated
{
    NSArray *barGraphValues = [self resampleArray:self.values toSize:self.barGraphSamples];
    NSNumber *maxBarGraphValues = [barGraphValues valueForKeyPath:@"@max.floatValue"];

    self.barGraphLayer.values = barGraphValues;
    self.barGraphLayer.maxValue = [maxBarGraphValues floatValue];
    
    if (animated)
    {
        [self.barGraphLayer animateWithDuration:2.0];
    }
}

- (NSArray *)resampleArray:(NSArray *)array toSize:(NSUInteger)size
{
    if (array.count < size)
        return array;
    
    NSMutableArray *resampled = [NSMutableArray arrayWithCapacity:size];
    
    
    float x0 = 0;
    float x1 = 0;
    float ratio = (float)size / array.count;
    
    for (int i = 0; i < array.count; i++)
    {
        x1 = ratio * i;
        
        int floor0 = floorf(x0);
        int floor1 = floorf(x1);
        
        if (floor0 == floor1)
        {
            while (resampled.count <= floor1) {
                [resampled addObject:@0];
            }
            //            resampled[floor1] = @([resampled[floor1] floatValue] + [array[i] floatValue]);
            resampled[floor1] = @( [resampled[floor1] floatValue] + [array[i] floatValue] * ratio );
        }
        else
        {
            while (resampled.count <= floor0) {
                [resampled addObject:@0];
            }
            float value0 = [array[i] floatValue] * (floor1 - x0) / (x1 - x0);
            //            resampled[floor0] = @([resampled[floor0] floatValue] + value0);
            resampled[floor0] = @( [resampled[floor0] floatValue] + value0 * ratio );
            
            while (resampled.count <= floor1) {
                [resampled addObject:@0];
            }
            float value1 = [array[i] floatValue] * (x1 - floor1) / (x1 - x0);
            //            resampled[floor1] = @([resampled[floor1] floatValue] + value1);
            resampled[floor1] = @( [resampled[floor1] floatValue] + value1 * ratio );
        }
        
        x0 = x1;
    }
    
    return resampled;
}




#pragma mark - IBAction
#pragma mark - SettingsViewControllerDelegate


- (IBAction)sliderValueChanged:(UISlider *)sender
{
    if (sender == self.curveSamplesSlider)
    {
        self.curveSamples = sender.value;
        [self reloadCurveAnimated:NO];
    }
    else if (sender == self.barGraphSamplesSlider)
    {
        self.barGraphSamples = sender.value;
        [self reloadBarGraphAnimated:NO];
    }
}

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case SegmentedControlIndexBSplines:
        default:
            self.smoothingAlgorithm = SmoothingAlgorithmBSpline;
            break;
            
        case SegmentedControlIndexKBSplines:
            self.smoothingAlgorithm = SmoothingAlgorithmKBSpline;
            break;
            
        case SegmentedControlIndexQuadEasing:
            self.smoothingAlgorithm = SmoothingAlgorithmQuadEasingInOut;
            break;
    }
}

- (void)setCurveSamples:(NSUInteger)curveSamples
{
    _curveSamples = curveSamples;
    self.curveSamplesLabel.text = [NSString stringWithFormat:@"Curve samples: %d", curveSamples];
}

- (void)setBarGraphSamples:(NSUInteger)barGraphSamples
{
    _barGraphSamples = barGraphSamples;
    self.barGraphSamplesLabel.text = [NSString stringWithFormat:@"Bar graph samples: %d", barGraphSamples];
}

- (void)setSmoothingAlgorithm:(SmoothingAlgorithm)smoothingAlgorithm
{
    _smoothingAlgorithm = smoothingAlgorithm;
    self.curveLayer.smoothingAlgorithm = smoothingAlgorithm;
}


@end