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

#import "MDMMotionTiming.h"
#import "MDCMaskedTransitionMotion.h"

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

@property(nonatomic, strong) UIView *sourceView;
@property(nonatomic, strong) UIView *scrimView;

@end

@implementation MDCMaskedTransition {
  UIView *_sourceView;
  MDCMaskedPresentationController *_presentationController;
}

- (instancetype)initWithSourceView:(UIView *)sourceView {
  self = [super init];
  if (self) {
    _sourceView = sourceView;
  }
  return self;
}

- (MDCMaskedTransitionMotion)motionForContext:(NSObject<MDMTransitionContext> *)context {
  if (CGRectEqualToRect(context.foreViewController.view.frame, context.containerView.bounds)) {
    if (context.direction == MDMTransitionDirectionForward) {
      return fullscreenExpansion;
    } else {
      //return nil;
    }

  } else if (context.foreViewController.view.bounds.size.width == context.containerView.bounds.size.width
             && CGRectGetMaxY(context.foreViewController.view.frame) == CGRectGetMaxY(context.containerView.bounds)) {
    if (context.foreViewController.view.frame.size.height > 100) {
      if (context.direction == MDMTransitionDirectionForward) {
        return bottomSheetExpansion;
      } else {
        //return nil
      }

    } else {
      if (context.direction == MDMTransitionDirectionForward) {
        return toolbarExpansion;
      } else {
        return toolbarCollapse;
      }
    }

  } else if (context.foreViewController.view.bounds.size.width < context.containerView.bounds.size.width
             && CGRectGetMidY(context.foreViewController.view.frame) >= CGRectGetMidY(context.containerView.bounds)) {
    if (context.direction == MDMTransitionDirectionForward) {
      return bottomCardExpansion;
    } else {
      return bottomCardCollapse;
    }
  }

  // TODO: Support returning nil in some way.
  return fullscreenExpansion;
}

- (void)startWithContext:(NSObject<MDMTransitionContext> *)context {
  MDCMaskedTransitionMotion motion = [self motionForContext:context];

  UIView *scrimView;
  if (!_presentationController.scrimView) {
    scrimView = [[UIView alloc] initWithFrame:context.containerView.bounds];
    scrimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [context.containerView addSubview:scrimView];

    // Give the scrim view to the presentation controller - it will now manage the lifecycle of the
    // scrim view instead of the transition.
    _presentationController.scrimView = scrimView;

  } else {
    scrimView = _presentationController.scrimView;
  }

  _presentationController.sourceView = _sourceView;

  // We're going to reparent the fore view, so keep this information for later.
  UIView *originalSuperview = context.foreViewController.view.superview;
  CGRect originalFrame = context.foreViewController.view.frame;
  UIViewAutoresizing originalAutoresizingMask = context.foreViewController.view.autoresizingMask;

  // # Reparenting

  // Our fore view will be reparented into this view. To avoid double-counting any frame offset, we
  // assign the fore view's frame here and then zero out the fore view's origin. This keeps the fore
  // view at the same relative location on screen.
  UIView *maskedView = [[UIView alloc] initWithFrame:context.foreViewController.view.frame];
  {
    CGRect reparentedFrame = context.foreViewController.view.frame;
    reparentedFrame.origin = CGPointZero;
    context.foreViewController.view.autoresizingMask = UIViewAutoresizingNone;
    context.foreViewController.view.frame = reparentedFrame;
  }

  maskedView.clipsToBounds = YES;
  [context.containerView addSubview:maskedView];

  UIView *floodFillView = [[UIView alloc] initWithFrame:context.foreViewController.view.bounds];

  // TODO(featherless): Should we expose the flood fill color as an API?
  floodFillView.backgroundColor = _sourceView.backgroundColor;

  // TODO(featherless): Profile whether it's more performant to fade the flood fill out or to
  // fade the fore view in (what we're currently doing).
  [maskedView addSubview:floodFillView];
  [maskedView addSubview:context.foreViewController.view];

  // # Frame calculations

  CGRect initialSourceFrameInContainer = [_sourceView convertRect:_sourceView.bounds
                                                           toView:context.containerView];
  CGRect initialMaskedViewInContainer;
  CGVector vecToEdge;
  if (motion.isCentered) {
    initialMaskedViewInContainer = CGRectMake(CGRectGetMidX(initialSourceFrameInContainer) - originalFrame.size.width / 2,
                                              CGRectGetMidY(initialSourceFrameInContainer) - originalFrame.size.height / 2,
                                              originalFrame.size.width,
                                              originalFrame.size.height);
    vecToEdge = CGVectorMake(CGRectGetMidX(initialSourceFrameInContainer) - CGRectGetMaxX(initialMaskedViewInContainer),
                             CGRectGetMidY(initialSourceFrameInContainer) - CGRectGetMaxY(initialMaskedViewInContainer));

  } else {
    initialMaskedViewInContainer = CGRectMake(context.containerView.bounds.origin.x,
                                              initialSourceFrameInContainer.origin.y - 20,
                                              originalFrame.size.width,
                                              originalFrame.size.height);
    if (CGRectGetMidX(initialSourceFrameInContainer) < CGRectGetMidX(initialMaskedViewInContainer)) {
      vecToEdge = CGVectorMake(CGRectGetMidX(initialSourceFrameInContainer) - CGRectGetMaxX(initialMaskedViewInContainer),
                               CGRectGetMidY(initialSourceFrameInContainer) - CGRectGetMidY(initialMaskedViewInContainer));
    } else {
      vecToEdge = CGVectorMake(CGRectGetMidX(initialSourceFrameInContainer) - CGRectGetMinX(initialMaskedViewInContainer),
                               CGRectGetMidY(initialSourceFrameInContainer) - CGRectGetMidY(initialMaskedViewInContainer));
    }
  }

  // Must set this in order to use convertRect:toView:
  maskedView.frame = initialMaskedViewInContainer;
  CGRect initialSourceFrameInMask = [maskedView convertRect:initialSourceFrameInContainer
                                                   fromView:context.containerView];

  CGFloat targetRadius = (CGFloat)sqrt(vecToEdge.dx * vecToEdge.dx + vecToEdge.dy * vecToEdge.dy);
  CGRect finalSourceFrameInMask = CGRectMake(CGRectGetMidX(initialSourceFrameInMask) - targetRadius,
                                             CGRectGetMidY(initialSourceFrameInMask) - targetRadius,
                                             targetRadius * 2,
                                             targetRadius * 2);

  CGRect finalMaskedViewInContainer = originalFrame;

  // # Masking

  CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
  maskedView.layer.mask = shapeLayer;

  _sourceView.hidden = true;

  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    context.foreViewController.view.frame = originalFrame;
    context.foreViewController.view.autoresizingMask = originalAutoresizingMask;

    [originalSuperview addSubview:context.foreViewController.view];

    [maskedView removeFromSuperview];

    if (!_presentationController) {
      [scrimView removeFromSuperview];
      _sourceView.hidden = false;
    }

    [context transitionDidEnd];
  }];

  TransitionAnimator *animator = [[TransitionAnimator alloc] initWithDirection:context.direction];

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
                        withValues:@[ [UIBezierPath bezierPathWithOvalInRect:initialSourceFrameInMask],
                                      [UIBezierPath bezierPathWithOvalInRect:finalSourceFrameInMask] ]];
  if (context.direction == MDMTransitionDirectionForward) {
    // Upon completion of the animation we want all of the content to be visible, so we jump to a
    // full bounds mask.
    shapeLayer.path = [[UIBezierPath bezierPathWithRect:context.foreViewController.view.bounds] CGPath];
  }

  [animator addAnimationWithTiming:motion.horizontalMovement
                            toView:maskedView
                        withValues:@[ @(CGRectGetMidX(initialMaskedViewInContainer)),
                                      @(CGRectGetMidX(finalMaskedViewInContainer)) ]];

  [animator addAnimationWithTiming:motion.verticalMovement
                            toView:maskedView
                        withValues:@[ @(CGRectGetMidY(initialMaskedViewInContainer)),
                                      @(CGRectGetMidY(finalMaskedViewInContainer)) ]];

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
  _presentationController = [[MDCMaskedPresentationController alloc] initWithPresentedViewController:presented
                                                                            presentingViewController:presenting
                                                                       calculateFrameOfPresentedView:_calculateFrameOfPresentedView];
  return _presentationController;
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

- (void)dismissalTransitionDidEnd:(BOOL)completed {
  if (completed) {
    [self.scrimView removeFromSuperview];
    self.scrimView = nil;

    self.sourceView.hidden = false;
    self.sourceView = nil;
  }
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
  if (timing.keyPath == nil) {
    return;
  }

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
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
  if (timing.delay != 0) {
    animation.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] + timing.delay * MDMSimulatorAnimationDragCoefficient();
    animation.fillMode = kCAFillModeBackwards;
  }
  animation.duration = timing.duration * MDMSimulatorAnimationDragCoefficient();
  animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:timing.controlPoints[0]
                                                                             :timing.controlPoints[1]
                                                                             :timing.controlPoints[2]
                                                                             :timing.controlPoints[3]];
  animation.fromValue = [values firstObject];
  animation.toValue = [values lastObject];
  [layer addAnimation:animation forKey:animation.keyPath];
  [layer setValue:animation.toValue forKeyPath:animation.keyPath];
}

@end
