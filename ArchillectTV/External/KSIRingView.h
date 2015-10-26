//
//  KSIRingView.h
//  Kisai
//
//  Created by Charles Magahern on 2/28/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSIRingPattern : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) CGFloat beginSegmentAngle;
@property (nonatomic, readonly) CGFloat segmentWidth;
@property (nonatomic, readonly) CGFloat segmentLengthRadians;
@property (nonatomic, readonly) CGFloat segmentIntervalRadians;
@property (nonatomic, readonly) NSUInteger segmentsCount;

- (instancetype)initWithColor:(UIColor *)color
                segmentLength:(CGFloat)segmentLengthInRadians
                segmentsCount:(NSUInteger)segmentsCount;

@end

@interface KSIMutableRingPattern : KSIRingPattern

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat beginSegmentAngle;
@property (nonatomic, assign) CGFloat segmentWidth;
@property (nonatomic, assign) CGFloat segmentLengthRadians;
@property (nonatomic, assign) CGFloat segmentIntervalRadians;
@property (nonatomic, assign) NSUInteger segmentsCount;

@end

// -----------------------------------------------------------------------------

@interface KSIRingView : UIView

@property (nonatomic, readonly) NSArray *ringPatterns; // KSIRingPattern(s)

- (void)addRingPattern:(KSIRingPattern *)pattern;
- (void)insertRingPattern:(KSIRingPattern *)pattern atIndex:(NSUInteger)index;
- (void)removeAllRingPatterns;

@end
