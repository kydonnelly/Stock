//
//  GraphViewController.m
//  Stock
//
//  Created by Kyle Donnelly on 12/21/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "GraphViewController.h"

#import "ClassUtils.h"
#import "GraphView.h"

typedef struct {
    stepInfo stepInfo;
    int displayPrecision;
} displayStepInfo;

static const int kSecondsInDay = 86400;

static const int kMaxGraphPoints = 500;
static const double kDefaultDomainShown = 1.0f;
static const double kMinDomainShown = 1.f;

static const int kVerticalSpacing = 70;
static const int kHorizontalSpacing = 90;
static const CGFloat kMinVerticalBuffer = .05f;
static const CGFloat kStepRoundingFactor = 4.f;
static const CGFloat kInvStepRoundingFactor = 0.25f;

static const float kPanDampeningFactor = 0.01f;

@interface GraphViewController () <GraphDatasource, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet GraphView *graphView;

@property (nonatomic) float displayedMinY;
@property (nonatomic) float displayedMaxY;
@property (nonatomic) float displayedStartTime;
@property (nonatomic) float displayedEndTime;

@property (nonatomic) displayStepInfo rangeInfo;
@property (nonatomic) displayStepInfo domainInfo;

@property (nonatomic) float lastScale;
@property (nonatomic) float initialScalingAmount;
@property (nonatomic) float lastPan;

@end

@implementation GraphViewController

#pragma mark - Lifecycle

- (void)dealloc {
    ReleaseIvar(_graphView);
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.graphView setDatasource:self];
    [self setupGestures];
}

#pragma mark - Setup

- (void)setup {
    self.displayedStartTime = -1 * kDefaultDomainShown;
    self.displayedEndTime = 0;
    [self sanitizeDisplayEndpoints];
}

- (void)setupGestures {
    UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGraphPinched:)] autorelease];
    [self addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGraphPan:)] autorelease];
    [self addGestureRecognizer:pan];
}

#pragma mark - Refresh

- (void)refresh {
    [self refreshGraph];
}

- (NSArray *)currentGraphValues {
    AbstractMethod
    return nil;
}

- (void)refreshGraph {
    NSArray *yValues = [self currentGraphValues];
    yValues = [self trimmedValuesForCurrentDisplay:yValues];
    
    [self prepareGraphData:yValues];
    [self refreshStepInfo];
    
    [self.graphView refresh];
}

- (void)prepareGraphData:(NSArray *)sanitizedValues {
    for (id<GraphObject> object in [self graphObjects]) {
        [object initializeFromValues:sanitizedValues];
    }
}

#pragma mark - GraphDatasource methods

- (NSArray *)graphObjects {
    AbstractMethod
    return nil;
}

- (NSString *)labelForX:(CGFloat)x {
    return [self labelForX:x format:@"MM/dd/YY HH:mm:ss"];
}

- (NSString *)labelForX:(CGFloat)x format:(NSString *)format {
    CGFloat percentAlongAxis = x / self.graphView.frame.size.width;
    CGFloat distanceFromStart = (self.displayedEndTime - self.displayedStartTime) * percentAlongAxis;
    float daysAgo = self.displayedStartTime + distanceFromStart;
    
    // todo: accurate times
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:format];
    
    NSDate *now = [[[NSDate alloc] init] autorelease];
    
    return [formatter stringFromDate:[now dateByAddingTimeInterval:(daysAgo * kSecondsInDay)]];
}

- (NSString *)labelForY:(CGFloat)y {
    CGFloat percentAlongAxis = y / self.graphView.frame.size.height;
    CGFloat distanceFromMax = (self.displayedMaxY - self.displayedMinY) * percentAlongAxis;
    float value = self.displayedMaxY - distanceFromMax;
    
    NSString *format = [@"%" stringByAppendingString:[NSString stringWithFormat:@".%df", self.rangeInfo.displayPrecision]];
    return [NSString stringWithFormat:format, value];
}

- (float)minX {
    return self.displayedStartTime;
}

- (float)maxX {
    return self.displayedEndTime;
}

- (float)minY {
    return self.displayedMinY;
}

- (float)maxY {
    return self.displayedMaxY;
}

#pragma mark - Display Sanity

- (float)maxDomain {
    AbstractMethod
    return 0;
}

- (void)sanitizeDisplayEndpoints {
    int domain = [self maxDomain];
    int minEndTime = -1 * domain + kMinDomainShown;
    int maxEndTime = 0;
    
    if (self.displayedEndTime < minEndTime) {
        self.displayedEndTime = minEndTime;
    } else if (self.displayedEndTime > maxEndTime) {
        self.displayedEndTime = maxEndTime;
    }
    
    int minStartTime = -1 * domain;
    int maxStartTime = self.displayedEndTime - kMinDomainShown;
    
    if (self.displayedStartTime < minStartTime) {
        self.displayedStartTime = minStartTime;
    } else if (self.displayedStartTime > maxStartTime) {
        self.displayedStartTime = maxStartTime;
    }
    
    AssertWithFormat(minStartTime <= maxStartTime && minEndTime <= maxEndTime,
                     @"Insufficient data to fill domain of length %.2f.", kMinDomainShown);
}

- (NSArray *)trimmedValuesForCurrentDisplay:(NSArray *)yValues {
    NSMutableArray *trimmed = [NSMutableArray array];
    
    int numValues = [yValues count];
    float xScale = (self.displayedEndTime - self.displayedStartTime) / numValues;
    float endTimeOffset = ceilf(ABS(self.displayedEndTime)) - ABS(self.displayedEndTime);
    
    int removalMod = numValues / kMaxGraphPoints;
    int offsetMod = removalMod + 1;
    
    int zoomOffset = numValues % offsetMod;
    int slideOffset = (int)ceil(endTimeOffset / xScale) % offsetMod;
    int removalCounter = (removalMod * 2 - zoomOffset - slideOffset) % offsetMod;
    
    for (NSNumber *yValue in yValues) {
        if (removalCounter < removalMod) {
            removalCounter++;
        } else {
            removalCounter = 0;
            [trimmed addObject:yValue];
        }
    }
    
    return trimmed;
}

#pragma mark - Gesture Recognizers

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [gestureRecognizer setDelegate:self];
    [gestureRecognizer setDelaysTouchesBegan:YES];
    [self.graphView addGestureRecognizer:gestureRecognizer];
}

- (void)handleGraphPinched:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.f;
        self.initialScalingAmount = self.displayedEndTime - self.displayedStartTime;
    }
    
    float scale = gestureRecognizer.scale / self.lastScale;
    self.lastScale = gestureRecognizer.scale;
    
    self.displayedStartTime += self.initialScalingAmount * (scale - 1.f);
    
    [self sanitizeDisplayEndpoints];
    [self refreshGraph];
}

- (void)handleGraphPan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPan = 0;
    }
    
    float pan = [gestureRecognizer translationInView:self.graphView].x * kPanDampeningFactor;
    float delta = pan - self.lastPan;
    self.lastPan = pan;
    
    self.displayedStartTime -= delta;
    self.displayedEndTime -= delta;
    
    [self sanitizeDisplayEndpoints];
    [self refreshGraph];
}

#pragma mark - Graph Display Steps

- (displayStepInfo)stepForValuesFrom:(CGFloat)start
                                  to:(CGFloat)end
                            numSteps:(int)steps {
    CGFloat range = end - start;
    CGFloat rawStep = range / steps;
    
    float scale = 1;
    int displayPrecision = 0;
    while (rawStep * scale < 1.f) {
        scale *= 10;
        displayPrecision++;
    }
    while (rawStep * scale > 10.f) {
        scale *= 0.1f;
    }
    
    CGFloat scaledStep = (int)(rawStep * scale * kStepRoundingFactor) * kInvStepRoundingFactor;
    CGFloat remainder = range * scale - (scaledStep * (steps - 1));
    
    stepInfo stepInfo;
    stepInfo.step = scaledStep / scale;
    stepInfo.stepStart = start + (remainder / 2.f) / scale;
    stepInfo.numSteps = steps;
    
    if (ABS(roundf(stepInfo.stepStart) - stepInfo.stepStart) > 0.05f) {
        displayPrecision++;
    } // else round down to trailing zero
    
    displayStepInfo displayInfo;
    displayInfo.stepInfo = stepInfo;
    displayInfo.displayPrecision = displayPrecision;
    
    return displayInfo;
}

- (void)refreshStepInfo {
    CGSize graphSize = self.graphView.frame.size;
    int xSteps = graphSize.width / [self horizontalSpacing];
    int ySteps = graphSize.height / [self verticalSpacing];
    
    self.domainInfo = [self stepForValuesFrom:self.displayedStartTime
                                           to:self.displayedEndTime
                                     numSteps:xSteps];
    
    self.rangeInfo = [self stepForValuesFrom:self.displayedMinY
                                          to:self.displayedMaxY
                                    numSteps:ySteps];
    
    float buffer = (self.displayedMaxY - self.displayedMinY) * kMinVerticalBuffer;
    self.displayedMinY -= buffer;
    self.displayedMaxY += buffer;
}

- (int)verticalSpacing {
    return kVerticalSpacing;
}

- (int)horizontalSpacing {
    return kHorizontalSpacing;
}

@end
