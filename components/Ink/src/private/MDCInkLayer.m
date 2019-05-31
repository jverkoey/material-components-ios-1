// Copyright 2015-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MDCInkLayer.h"
#import "MaterialMath.h"

static const CGFloat kAnimationDuration = (CGFloat)0.083;
static const CGFloat kEndFadeOutDuration = (CGFloat)0.15;
static const CGFloat kStartScaleAndPositionDuration = (CGFloat)0.333;
static const CGFloat kStartFadeHalfDuration = (CGFloat)0.167;
static const CGFloat kStartFadeHalfBeginTimeFadeOutDuration = (CGFloat)0.25;

static const CGFloat kScaleStartMin = (CGFloat)0.2;
static const CGFloat kScaleStartMax = (CGFloat)0.6;
static const CGFloat kScaleDivisor = 300;

static NSString *const kOpacityKeyPath = @"opacity";
static NSString *const kPositionKeyPath = @"position";
static NSString *const kScaleKeyPath = @"transform.scale";

@implementation MDCInkLayer

- (instancetype)init {
  self = [super init];
  if (self) {
    _inkColor = [UIColor colorWithWhite:0 alpha:(CGFloat)0.08];
  }
  return self;
}

- (instancetype)initWithLayer:(id)layer {
  self = [super initWithLayer:layer];
  if (self) {
    _endAnimationDelay = 0;
    _finalRadius = 0;
    _initialRadius = 0;
    _inkColor = [UIColor colorWithWhite:0 alpha:(CGFloat)0.08];
    _startAnimationActive = NO;
    if ([layer isKindOfClass:[MDCInkLayer class]]) {
      MDCInkLayer *inkLayer = (MDCInkLayer *)layer;
      _endAnimationDelay = inkLayer.endAnimationDelay;
      _finalRadius = inkLayer.finalRadius;
      _initialRadius = inkLayer.initialRadius;
      _maxRippleRadius = inkLayer.maxRippleRadius;
      _inkColor = inkLayer.inkColor;
      _startAnimationActive = NO;
    }
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];

  if (self) {
    _inkColor = [UIColor colorWithWhite:0 alpha:(CGFloat)0.08];
  }

  return self;
}

- (void)setNeedsLayout {
  [super setNeedsLayout];
  [self setRadiiWithRect:self.bounds];
}

- (void)setRadiiWithRect:(CGRect)rect {
  self.initialRadius =
      (CGFloat)(MDCHypot(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2 * (CGFloat)0.6);
  self.finalRadius = (CGFloat)(MDCHypot(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2 + 10);
}

- (void)startAnimationAtPoint:(CGPoint)point {
  [self startInkAtPoint:point animated:YES];
}

- (void)startInkAtPoint:(CGPoint)point animated:(BOOL)animated {
  CGFloat radius = self.finalRadius;
  if (self.maxRippleRadius > 0) {
    radius = self.maxRippleRadius;
  }
  CGRect ovalRect = CGRectMake(CGRectGetWidth(self.bounds) / 2 - radius,
                               CGRectGetHeight(self.bounds) / 2 - radius, radius * 2, radius * 2);
  UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
  self.path = circlePath.CGPath;
  self.fillColor = self.inkColor.CGColor;
  if (!animated) {
    self.opacity = 1;
    self.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
  } else {
    self.opacity = 0;
    self.position = point;
    _startAnimationActive = YES;

    CAMediaTimingFunction *materialTimingFunction =
        [[CAMediaTimingFunction alloc] initWithControlPoints:(float) 0.4:0:(float)0.2:1];

    CGFloat scaleStart =
        MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / kScaleDivisor;
    if (scaleStart < kScaleStartMin) {
      scaleStart = kScaleStartMin;
    } else if (scaleStart > kScaleStartMax) {
      scaleStart = kScaleStartMax;
    }

    CABasicAnimation *scaleAnim = [[CABasicAnimation alloc] init];
    scaleAnim.keyPath = kScaleKeyPath;
    scaleAnim.fromValue = @(scaleStart);
    scaleAnim.toValue = @1;
    scaleAnim.duration = kStartScaleAndPositionDuration;
    scaleAnim.beginTime = kAnimationDuration;
    scaleAnim.timingFunction = materialTimingFunction;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.removedOnCompletion = NO;

    UIBezierPath *centerPath = [UIBezierPath bezierPath];
    CGPoint startPoint = point;
    CGPoint endPoint =
        CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    [centerPath moveToPoint:startPoint];
    [centerPath addLineToPoint:endPoint];
    [centerPath closePath];

    CAKeyframeAnimation *positionAnim = [[CAKeyframeAnimation alloc] init];
    positionAnim.keyPath = kPositionKeyPath;
    positionAnim.path = centerPath.CGPath;
    positionAnim.keyTimes = @[ @0, @1 ];
    positionAnim.values = @[ @0, @1 ];
    positionAnim.duration = kStartScaleAndPositionDuration;
    positionAnim.beginTime = kAnimationDuration;
    positionAnim.timingFunction = materialTimingFunction;
    positionAnim.fillMode = kCAFillModeForwards;
    positionAnim.removedOnCompletion = NO;

    CABasicAnimation *fadeInAnim = [[CABasicAnimation alloc] init];
    fadeInAnim.keyPath = kOpacityKeyPath;
    fadeInAnim.fromValue = @0;
    fadeInAnim.toValue = @1;
    fadeInAnim.duration = kAnimationDuration;
    fadeInAnim.beginTime = kAnimationDuration;
    fadeInAnim.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeInAnim.fillMode = kCAFillModeForwards;
    fadeInAnim.removedOnCompletion = NO;

    [CATransaction begin];
    CAAnimationGroup *animGroup = [[CAAnimationGroup alloc] init];
    animGroup.animations = @[ scaleAnim, positionAnim, fadeInAnim ];
    animGroup.duration = kStartScaleAndPositionDuration;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.removedOnCompletion = NO;
    [CATransaction setCompletionBlock:^{
      self->_startAnimationActive = NO;
    }];
    [self addAnimation:animGroup forKey:nil];
    [CATransaction commit];
  }
  if ([self.animationDelegate respondsToSelector:@selector(inkLayerAnimationDidStart:)]) {
    [self.animationDelegate inkLayerAnimationDidStart:self];
  }
}

- (void)changeAnimationAtPoint:(CGPoint)point {
  CGFloat animationDelay = 0;
  if (self.startAnimationActive) {
    animationDelay = kStartFadeHalfBeginTimeFadeOutDuration + kStartFadeHalfDuration;
  }

  BOOL viewContainsPoint = CGRectContainsPoint(self.bounds, point) ? YES : NO;
  CGFloat currOpacity = self.presentationLayer.opacity;
  CGFloat updatedOpacity = 0;
  if (viewContainsPoint) {
    updatedOpacity = 1;
  }

  CABasicAnimation *changeAnim = [[CABasicAnimation alloc] init];
  changeAnim.keyPath = kOpacityKeyPath;
  changeAnim.fromValue = @(currOpacity);
  changeAnim.toValue = @(updatedOpacity);
  changeAnim.duration = kAnimationDuration;
  changeAnim.beginTime = [self convertTime:(CACurrentMediaTime() + animationDelay) fromLayer:nil];
  changeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  changeAnim.fillMode = kCAFillModeForwards;
  changeAnim.removedOnCompletion = NO;
  [self addAnimation:changeAnim forKey:nil];
}

- (void)endAnimationAtPoint:(CGPoint)point {
  [self endInkAtPoint:point animated:YES];
}

- (void)endInkAtPoint:(CGPoint)point animated:(BOOL)animated {
  if (self.startAnimationActive) {
    self.endAnimationDelay = kStartFadeHalfBeginTimeFadeOutDuration;
  }

  CGFloat opacity = 1;
  BOOL viewContainsPoint = CGRectContainsPoint(self.bounds, point) ? YES : NO;
  if (!viewContainsPoint) {
    opacity = 0;
  }

  if (!animated) {
    self.opacity = 0;
    if ([self.animationDelegate respondsToSelector:@selector(inkLayerAnimationDidEnd:)]) {
      [self.animationDelegate inkLayerAnimationDidEnd:self];
    }
    [self removeFromSuperlayer];
  } else {
    [CATransaction begin];
    CABasicAnimation *fadeOutAnim = [[CABasicAnimation alloc] init];
    fadeOutAnim.keyPath = kOpacityKeyPath;
    fadeOutAnim.fromValue = @(opacity);
    fadeOutAnim.toValue = @0;
    fadeOutAnim.duration = kEndFadeOutDuration;
    fadeOutAnim.beginTime = [self convertTime:(CACurrentMediaTime() + self.endAnimationDelay)
                                    fromLayer:nil];
    fadeOutAnim.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeOutAnim.fillMode = kCAFillModeForwards;
    fadeOutAnim.removedOnCompletion = NO;
    [CATransaction setCompletionBlock:^{
      if ([self.animationDelegate respondsToSelector:@selector(inkLayerAnimationDidEnd:)]) {
        [self.animationDelegate inkLayerAnimationDidEnd:self];
      }
      [self removeFromSuperlayer];
    }];
    [self addAnimation:fadeOutAnim forKey:nil];
    [CATransaction commit];
  }
}

@end
