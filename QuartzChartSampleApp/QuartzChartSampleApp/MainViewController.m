//
//  MainViewController.m
//  QuartzChartSampleApp
//
//  Created by Joseph Lin on 4/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "QuartzChart.h"

#define kMaxValue 100
#define kSampleCount 40

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
@property (nonatomic) NSUInteger curveSamples;
@property (nonatomic) NSUInteger barGraphSamples;
@property (nonatomic, strong) NSMutableArray *values;
@end


@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.barGraphSamplesSlider.maximumValue = self.curveSamplesSlider.maximumValue = kSampleCount * 2;
    self.curveSamplesSlider.value = self.curveSamples = kSampleCount;
    self.barGraphSamplesSlider.value = self.barGraphSamples = kSampleCount;

    [self reloadButtonTapped:nil];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
//    link.frameInterval = 10;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)update:(CADisplayLink *)sender
{
    float value = arc4random_uniform(kMaxValue);

    [self.values removeObjectAtIndex:0];
    [self.values addObject:@(value)];
    
    [self reloadCurveAnimated:NO];
    [self reloadBarGraphAnimated:NO];
}



- (IBAction)reloadButtonTapped:(id)sender
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"values" ofType:@"plist"];
//    self.values = [NSArray arrayWithContentsOfFile:path];

    self.values = [self randomArrayOfSize:kSampleCount];
    
    [self reloadCurveAnimated:YES];
    [self reloadBarGraphAnimated:YES];
}

- (NSMutableArray *)randomArrayOfSize:(NSUInteger)size
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:size];
    for (int i = 0; i < size; i++)
    {
        float value = arc4random_uniform(kMaxValue);
        [array addObject:@(value)];
    }
    return array;
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
        _curveLayer.gradientStartPoint = CGPointMake(0.5, 1.0);
        _curveLayer.gradientEndPoint = CGPointMake(0.5, 0.0);
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
    NSArray *curveValues = [self.values resampleToSize:self.curveSamples method:ResamplingMethodByAverage];
    
    NSUInteger optimalGranularity = ceil(CGRectGetWidth(self.curveLayer.frame)/curveValues.count);
    self.curveLayer.granularity = optimalGranularity;
    
    self.curveLayer.values = curveValues;
    self.curveLayer.maxValue = kMaxValue;
    
    if (animated)
    {
        [self.curveLayer animateWithDuration:2.0];
    }
}

- (void)reloadBarGraphAnimated:(BOOL)animated
{
    NSArray *barGraphValues = [self.values resampleToSize:self.barGraphSamples method:ResamplingMethodByAverage];

    self.barGraphLayer.values = barGraphValues;
    self.barGraphLayer.maxValue = kMaxValue;
    
    if (animated)
    {
        [self.barGraphLayer animateWithDuration:2.0];
    }
}


#pragma mark - Settings

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
            self.curveLayer.smoothingAlgorithm = SmoothingAlgorithmBSpline;
            break;
            
        case SegmentedControlIndexKBSplines:
            self.curveLayer.smoothingAlgorithm = SmoothingAlgorithmKBSpline;
            break;
            
        case SegmentedControlIndexQuadEasing:
            self.curveLayer.smoothingAlgorithm = SmoothingAlgorithmQuadEasingInOut;
            break;
    }
}

- (void)setCurveSamples:(NSUInteger)curveSamples
{
    _curveSamples = curveSamples;
    NSString *text = [NSString stringWithFormat:@"Curve samples: %d", curveSamples];
    if (curveSamples > kSampleCount)
        text = [text stringByAppendingString:@" (Oversampling)"];
    else if (curveSamples < kSampleCount)
        text = [text stringByAppendingString:@" (Downsampling)"];
    
    self.curveSamplesLabel.text = text;
}

- (void)setBarGraphSamples:(NSUInteger)barGraphSamples
{
    _barGraphSamples = barGraphSamples;
    NSString *text = [NSString stringWithFormat:@"Curve samples: %d", barGraphSamples];
    if (barGraphSamples > kSampleCount)
        text = [text stringByAppendingString:@" (Oversampling)"];
    else if (barGraphSamples < kSampleCount)
        text = [text stringByAppendingString:@" (Downsampling)"];
    
    self.barGraphSamplesLabel.text = text;
}


@end
