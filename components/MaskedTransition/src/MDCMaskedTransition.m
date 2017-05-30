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

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coefficient.
#endif

CGFloat MDMSimulatorAnimationDragCoefficient(void);
CGFloat MDMSimulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

struct MDMMotionTiming {
  CFTimeInterval delay;
  CFTimeInterval duration;
  float controlPoints[4];
  const char *keyPath;
};
typedef struct MDMMotionTiming MDMMotionTiming;

struct MDMExpansionMotion {
  MDMMotionTiming contentFade;
  MDMMotionTiming floodBackgroundColor;
  MDMMotionTiming maskTransformation;
  MDMMotionTiming verticalMovement;
  MDMMotionTiming scrimFade;
};
typedef struct MDMExpansionMotion MDMExpansionMotion;

#define MDMEightyForty {0.4f, 0.0f, 0.2f, 1.0f}
#define MDMFortyOut {0.4f, 0.0f, 1.0f, 1.0f}

struct MDMExpansionMotion fullscreenExpansion;

@interface TransitionAnimator : NSObject

- (instancetype)initWithDirection:(MDMTransitionDirection)direction;

- (void)addAnimationWithTiming:(MDMMotionTiming)timing
                        toView:(UIView *)view
                    withValues:(NSArray *)values;
- (void)addAnimationWithTiming:(MDMMotionTiming)timing
                       toLayer:(CALayer *)layer
                    withValues:(NSArray *)values;

@end

@interface MDCMaskedTransition () <MDMTransitionWithPresentation>
@end

@interface MDCMaskedPresentationController : UIPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                  calculateFrameOfPresentedView:(CGRect (^)(UIPresentationController *))calculateFrameOfPresentedView
    NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
    NS_UNAVAILABLE;

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

- (MDMExpansionMotion)motionForContext:(NSObject<MDMTransitionContext> *)context {
  return fullscreenExpansion;
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
  UIView *maskedContainerView = [[UIView alloc] initWithFrame:context.foreViewController.view.frame];
  {
    CGRect reparentedFrame = context.foreViewController.view.frame;
    reparentedFrame.origin = CGPointZero;
    context.foreViewController.view.frame = reparentedFrame;
  }

  maskedContainerView.clipsToBounds = YES;
  [context.containerView addSubview:maskedContainerView];

  UIView *floodFillView = [[UIView alloc] initWithFrame:context.foreViewController.view.bounds];

  // TODO(featherless): Should we expose the flood fill color as an API?
  floodFillView.backgroundColor = _sourceView.backgroundColor;

  // TODO(featherless): Profile whether it's more performant to fade the flood fill out or to
  // fade the fore view in (what we're currently doing).
  [maskedContainerView addSubview:floodFillView];
  [maskedContainerView addSubview:context.foreViewController.view];

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

  // Must set this in order to use convertRect:toView:
  maskedContainerView.frame = startingFrame;
  CGRect sourceFrameInContent = [maskedContainerView convertRect:sourceFrameInContainer
                                                        fromView:context.containerView];

  CGFloat targetRadius = (CGFloat)sqrt(vecToEdge.dx * vecToEdge.dx + vecToEdge.dy * vecToEdge.dy);
  CGRect foreMaskBounds = CGRectMake(CGRectGetMidX(sourceFrameInContent) - targetRadius,
                                     CGRectGetMidY(sourceFrameInContent) - targetRadius,
                                     targetRadius * 2,
                                     targetRadius * 2);

  // # Masking

  CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
  maskedContainerView.layer.mask = shapeLayer;

  _sourceView.hidden = true;

  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // Restore our state before we complete.
    context.foreViewController.view.frame = originalFrame;
    [originalSuperview addSubview:context.foreViewController.view];
    [scrimView removeFromSuperview];
    [maskedContainerView removeFromSuperview];

    _sourceView.hidden = false;

    [context transitionDidEnd];
  }];

  TransitionAnimator *animator = [[TransitionAnimator alloc] initWithDirection:context.direction];

  MDMExpansionMotion motion = [self motionForContext:context];

  [animator addAnimationWithTiming:motion.contentFade
                            toView:context.foreViewController.view
                        withValues:@[ @0, @1 ]];

  UIColor *foreColor = context.foreViewController.view.backgroundColor;
  if (!foreColor) {
    foreColor = [UIColor whiteColor];
  }
  [animator addAnimationWithTiming:motion.floodBackgroundColor
                            toView:floodFillView
                        withValues:@[ floodFillView.backgroundColor, foreColor ]];

  [animator addAnimationWithTiming:motion.maskTransformation
                           toLayer:shapeLayer
                        withValues:@[ [UIBezierPath bezierPathWithOvalInRect:sourceFrameInContent],
                                      [UIBezierPath bezierPathWithOvalInRect:foreMaskBounds] ]];
  // Upon completion of the animation we want all of the content to be visible, so we jump to a full
  // bounds mask.
  shapeLayer.path = [[UIBezierPath bezierPathWithRect:context.foreViewController.view.bounds] CGPath];

  [animator addAnimationWithTiming:motion.verticalMovement
                            toView:maskedContainerView
                        withValues:@[ @(CGRectGetMidY(startingFrame)),
                                      @(CGRectGetMidY(originalFrame)) ]];

  [animator addAnimationWithTiming:motion.scrimFade
                            toView:scrimView
                        withValues:@[ @0, @1 ]];

  [CATransaction commit];
}

#pragma mark - MDMTransitionWithPresentation

- (UIModalPresentationStyle)defaultModalPresentationStyle {
  if (_calculateFrameOfPresentedView != nil) {
    return UIModalPresentationCustom;
  }
  return UIModalPresentationFullScreen;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
  return [[MDCMaskedPresentationController alloc] initWithPresentedViewController:presented
                                                         presentingViewController:presenting
                                                    calculateFrameOfPresentedView:_calculateFrameOfPresentedView];
}

@end

@implementation MDCMaskedPresentationController {
  CGRect (^_calculateFrameOfPresentedView)(UIPresentationController *);
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                  calculateFrameOfPresentedView:(CGRect (^)(UIPresentationController *))calculateFrameOfPresentedView {
  self = [super initWithPresentedViewController:presentedViewController
                       presentingViewController:presentingViewController];
  if (self) {
    _calculateFrameOfPresentedView = calculateFrameOfPresentedView;
  }
  return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
  return _calculateFrameOfPresentedView(self);
}

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

- (void)addAnimationWithTiming:(MDMMotionTiming)timing
                        toView:(UIView *)view
                    withValues:(NSArray *)values {
  [self addAnimationWithTiming:timing toLayer:view.layer withValues:values];
}

- (void)addAnimationWithTiming:(MDMMotionTiming)timing
                       toLayer:(CALayer *)layer
                    withValues:(NSArray *)values {
  if (_direction == MDMTransitionDirectionBackward) {
    values = [[values reverseObjectEnumerator] allObjects];
  }
  if ([[values firstObject] isKindOfClass:[UIColor class]]) {
    NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:values.count];
    for (UIColor *color in values) {
      [convertedArray addObject:(id)color.CGColor];
    }
    values = convertedArray;
  } else if ([[values firstObject] isKindOfClass:[UIBezierPath class]]) {
    NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:values.count];
    for (UIBezierPath *bezierPath in values) {
      [convertedArray addObject:(id)bezierPath.CGPath];
    }
    values = convertedArray;
  }

  NSString *keyPath = [NSString stringWithCString:timing.keyPath encoding:NSUTF8StringEncoding];
  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:keyPath];
  if (timing.delay != 0) {
    fade.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] + timing.delay * MDMSimulatorAnimationDragCoefficient();
    fade.fillMode = kCAFillModeBackwards;
  }
  fade.duration = timing.duration * MDMSimulatorAnimationDragCoefficient();
  fade.timingFunction = [CAMediaTimingFunction functionWithControlPoints:timing.controlPoints[0]
                                                                        :timing.controlPoints[1]
                                                                        :timing.controlPoints[2]
                                                                        :timing.controlPoints[3]];
  fade.fromValue = [values firstObject];
  fade.toValue = [values lastObject];
  [layer addAnimation:fade forKey:fade.keyPath];
  [layer setValue:fade.toValue forKey:fade.keyPath];
}

@end

struct MDMExpansionMotion fullscreenExpansion = {
  .contentFade = {
    .delay = 0.150, .duration = 0.225, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.000, .duration = 0.075, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.000, .duration = 0.105, .controlPoints = MDMFortyOut,
    .keyPath = "path",
  },
  .verticalMovement = {
    .delay = 0.045, .duration = 0.330, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  }
};
