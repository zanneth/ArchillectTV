//
//  KSIRingView.m
//  Kisai
//
//  Created by Charles Magahern on 2/28/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

#import "KSIRingView.h"

@implementation KSIRingPattern {
@protected
    UIColor *_color;
    CGFloat _beginSegmentAngle;
    CGFloat _segmentWidth;
    CGFloat _segmentLengthRadians;
    CGFloat _segmentIntervalRadians;
    NSUInteger _segmentsCount;
}

- (instancetype)initWithColor:(UIColor *)color
                segmentLength:(CGFloat)segmentLengthInRadians
                segmentsCount:(NSUInteger)segmentsCount
{
    self = [super init];
    if (self) {
        _color = color;
        _beginSegmentAngle = 0.0;
        _segmentWidth = 5.0;
        _segmentLengthRadians = segmentLengthInRadians;
        _segmentIntervalRadians = 0.0;
        _segmentsCount = segmentsCount;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithColor:[UIColor whiteColor] segmentLength:(2.0 * M_PI) segmentsCount:1];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self _copyWithZone:zone usingConcreteClass:[KSIRingPattern class]];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self _copyWithZone:zone usingConcreteClass:[KSIMutableRingPattern class]];
}

#pragma mark - Internal

- (id)_copyWithZone:(NSZone *)zone usingConcreteClass:(Class)concreteClass
{
    KSIRingPattern *copy = [[concreteClass allocWithZone:zone] init];
    copy->_color = _color;
    copy->_beginSegmentAngle = _beginSegmentAngle;
    copy->_segmentWidth = _segmentWidth;
    copy->_segmentLengthRadians = _segmentLengthRadians;
    copy->_segmentIntervalRadians = _segmentIntervalRadians;
    copy->_segmentsCount = _segmentsCount;
    return copy;
}

@end

// -----------------------------------------------------------------------------

@implementation KSIMutableRingPattern
@dynamic color;
@dynamic beginSegmentAngle;
@dynamic segmentWidth;
@dynamic segmentLengthRadians;
@dynamic segmentIntervalRadians;
@dynamic segmentsCount;

- (void)setColor:(UIColor *)color { _color = color; }
- (void)setBeginSegmentAngle:(CGFloat)beginSegmentAngle { _beginSegmentAngle = beginSegmentAngle; }
- (void)setSegmentWidth:(CGFloat)segmentWidth { _segmentWidth = segmentWidth; }
- (void)setSegmentLengthRadians:(CGFloat)segmentLengthRadians { _segmentLengthRadians = segmentLengthRadians; }
- (void)setSegmentIntervalRadians:(CGFloat)segmentIntervalRadians { _segmentIntervalRadians = segmentIntervalRadians; }
- (void)setSegmentsCount:(NSUInteger)segmentsCount { _segmentsCount = segmentsCount; }

@end

// -----------------------------------------------------------------------------

@implementation KSIRingView {
    NSMutableArray *_ringPatterns;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ringPatterns = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Accessors

- (NSArray *)ringPatterns
{
    return _ringPatterns;
}

#pragma mark - API

- (void)addRingPattern:(KSIRingPattern *)pattern
{
    [_ringPatterns addObject:[pattern copy]];
    [self setNeedsDisplay];
}

- (void)insertRingPattern:(KSIRingPattern *)pattern atIndex:(NSUInteger)index
{
    [_ringPatterns insertObject:[pattern copy] atIndex:index];
    [self setNeedsDisplay];
}

- (void)removeAllRingPatterns
{
    [_ringPatterns removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    const CGFloat radius = rint(rect.size.height / 2.0 - 1.0);
    const CGPoint center = {
        .x = rint(rect.size.width / 2.0),
        .y = rint(rect.size.height / 2.0)
    };
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat currentRadius = radius;
    
    for (KSIRingPattern *ringPattern in _ringPatterns) {
        if (![ringPattern.color isEqual:[UIColor clearColor]]) {
            NSUInteger segmentsCount = ringPattern.segmentsCount;
            CGFloat currentAngle = ringPattern.beginSegmentAngle;
            CGFloat segmentWidth = ringPattern.segmentWidth;
            
            [ringPattern.color setStroke];
            
            for (unsigned i = 0; i < segmentsCount; ++i) {
                CGFloat beginAngle = currentAngle;
                CGFloat endAngle = beginAngle + ringPattern.segmentLengthRadians;
                CGContextAddArc(ctx, center.x, center.y, currentRadius - (segmentWidth / 2.0), beginAngle, endAngle, NO);
                
                if (i < segmentsCount - 1) {
                    currentAngle += ringPattern.segmentIntervalRadians;
                }
                
                CGContextSetLineWidth(ctx, segmentWidth);
                CGContextStrokePath(ctx);
            }
        }
    
        currentRadius -= ringPattern.segmentWidth - 1.0;
    }
}

@end
