/*
 Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MDCMaskedTransition.h"

struct MDMMotionTiming {
  const char *keyPath;
  CFTimeInterval delay;
  CFTimeInterval duration;
  float controlPoints[4];
};
typedef struct MDMMotionTiming MDMMotionTiming;

struct MDMExpansionMotion {
  MDMMotionTiming contentFade;
  MDMMotionTiming floodBackgroundColor;
};
typedef struct MDMExpansionMotion MDMExpansionMotion;

struct MDMExpansionMotion fullscreenExpansion = {
  .contentFade = {
    .keyPath = "opacity",
    .delay = 0.150,
    .duration = 0.225,
    .controlPoints = {0.4f, 0.0f, 0.2f, 1.0f}
  },
  .floodBackgroundColor = {
    .keyPath = "backgroundColor",
    .delay = 0,
    .duration = 0.075,
    .controlPoints = {0.4f, 0.0f, 0.2f, 1.0f}
  }
};

@interface TransitionAnimator : NSObject
@end

@implementation TransitionAnimator {
  MDMTransitionDirection _direction;
}

- (instancetype)initWithDirection:(MDMTransitionDirection)direction {
  self = [super init];
  if (self) {
    _direction = direction;
  }
  return self;
}

- (void)animate:(UIView *)view withValues:(NSArray *)values timing:(MDMMotionTiming)timing {
  if (_direction == MDMTransitionDirectionBackward) {
    values = [[values reverseObjectEnumerator] allObjects];
  }
  if ([[values firstObject] isKindOfClass:[UIColor class]]) {
    NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:values.count];
    for (UIColor *color in values) {
      [convertedArray addObject:(id)color.CGColor];
    }
    values = convertedArray;
  }

  NSString *keyPath = [NSString stringWithCString:timing.keyPath encoding:NSUTF8StringEncoding];
  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:keyPath];
  if (timing.delay != 0) {
    fade.beginTime = [view.layer convertTime:CACurrentMediaTime() fromLayer:nil] + timing.delay;
    fade.fillMode = kCAFillModeBackwards;
  }
  fade.duration = timing.duration;
  fade.timingFunction = [CAMediaTimingFunction functionWithControlPoints:timing.controlPoints[0]
                                                                        :timing.controlPoints[1]
                                                                        :timing.controlPoints[2]
                                                                        :timing.controlPoints[3]];
  fade.fromValue = [values firstObject];
  fade.toValue = [values lastObject];
  [view.layer addAnimation:fade forKey:fade.keyPath];
  [view.layer setValue:fade.toValue forKey:fade.keyPath];
}

@end

@implementation MDCMaskedTransition {
  UIView *_sourceView;
}

- (instancetype)initWithSourceView:(UIView *)sourceView {
  self = [super init];
  if (self) {
    _sourceView = sourceView;
  }
  return self;
}

- (void)startWithContext:(NSObject<MDMTransitionContext> *)context {
  UIView *scrimView = [[UIView alloc] initWithFrame:context.containerView.bounds];
  scrimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
  [context.containerView addSubview:scrimView];

  // We're going to reparent the fore view, so keep this information for later.
  UIView *originalSuperview = context.foreViewController.view.superview;
  CGRect originalFrame = context.foreViewController.view.frame;

  // # Reparenting

  // Our fore view will be reparented into this view. To avoid double-counting any frame offset, we
  // assign the fore view's frame here and then zero out the fore view's origin. This keeps the fore
  // view at the same relative location on screen.
  UIView *clippedShiftingView = [[UIView alloc] initWithFrame:context.foreViewController.view.frame];
  CGRect reparentedFrame = context.foreViewController.view.frame;
  reparentedFrame.origin = CGPointZero;
  context.foreViewController.view.frame = reparentedFrame;

  clippedShiftingView.clipsToBounds = YES;
  [context.containerView addSubview:clippedShiftingView];

  UIView *floodFillView = [[UIView alloc] initWithFrame:context.foreViewController.view.bounds];

  // TODO(featherless): Should we expose the flood fill color as an API?
  floodFillView.backgroundColor = _sourceView.backgroundColor;

  // TODO(featherless): Profile whether it's more performant to fade the flood fill out or to
  // fade the fore view in (what we're currently doing).
  [clippedShiftingView addSubview:floodFillView];
  [clippedShiftingView addSubview:context.foreViewController.view];

  // # Frame calculations

  CGRect sourceFrameInContainer = [_sourceView convertRect:_sourceView.bounds
                                                    toView:context.containerView];
  CGRect startingFrame = CGRectMake(originalFrame.origin.x,
                                    sourceFrameInContainer.origin.y - 20,
                                    originalFrame.size.width,
                                    originalFrame.size.height);

  CGVector vecToEdge;
  if (CGRectGetMidX(sourceFrameInContainer) < CGRectGetMidX(startingFrame)) {
    vecToEdge = CGVectorMake(CGRectGetMidX(sourceFrameInContainer) - CGRectGetMaxX(startingFrame),
                             CGRectGetMidY(sourceFrameInContainer) - CGRectGetMidY(startingFrame));
  } else {
    vecToEdge = CGVectorMake(CGRectGetMidX(sourceFrameInContainer) - CGRectGetMinX(startingFrame),
                             CGRectGetMidY(sourceFrameInContainer) - CGRectGetMidY(startingFrame));
  }

//  clippedShiftingView.frame = startingFrame;

//  CGRect sourceFrameInContent = [clippedShiftingView convertRect:sourceFrameInContainer
//                                                          toView:context.containerView];
  CGRect endingFrame = originalFrame;

  // # Masking

  CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
  // TODO(featherless): We're assuming that the shape is circular. Ideally we'd support animating
  // from any arbitrary shape.
  shapeLayer.path = [[UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                 0,
                                                                 endingFrame.size.width,
                                                                 endingFrame.size.height)]
                     CGPath];
  clippedShiftingView.layer.mask = shapeLayer;

  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // Restore our state before we complete.
    context.foreViewController.view.frame = originalFrame;
    [originalSuperview addSubview:context.foreViewController.view];
    [scrimView removeFromSuperview];

    [context transitionDidEnd];
  }];

  MDMExpansionMotion motion = fullscreenExpansion;

  TransitionAnimator *animator = [[TransitionAnimator alloc] initWithDirection:context.direction];

  [animator animate:context.foreViewController.view withValues:@[ @0, @1 ]
             timing:motion.contentFade];

  UIColor *foreColor = context.foreViewController.view.backgroundColor;
  if (!foreColor) {
    foreColor = [UIColor whiteColor];
  }
  [animator animate:floodFillView withValues:@[ floodFillView.backgroundColor, foreColor]
             timing:motion.floodBackgroundColor];

  [CATransaction commit];
}

@end
