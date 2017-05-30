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
#import "MDMMotionTimingAnimator.h"

#import "MDCMaskedPresentationController.h"
#import "MDCMaskedTransitionMotion.h"

@interface MDCMaskedTransition () <MDMTransitionWithPresentation>
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

#pragma mark - Motion router

+ (MDCMaskedTransitionMotion)motionForContext:(NSObject<MDMTransitionContext> *)context {
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

- (void)startWithContext:(NSObject<MDMTransitionContext> *)context {
  MDCMaskedTransitionMotion motion = [[self class] motionForContext:context];

  UIView *scrimView;
  if (!_presentationController.scrimView) {
    scrimView = [[UIView alloc] initWithFrame:context.containerView.bounds];
    scrimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [context.containerView addSubview:scrimView];

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
    CGPoint initialSourceFrameCenterInContainer = CGPointMake(CGRectGetMidX(initialSourceFrameInContainer),
                                                   CGRectGetMidY(initialSourceFrameInContainer));
    initialMaskedViewInContainer = CGRectMake(initialSourceFrameCenterInContainer.x - originalFrame.size.width / 2,
                                              initialSourceFrameCenterInContainer.y - originalFrame.size.height / 2,
                                              originalFrame.size.width,
                                              originalFrame.size.height);
    vecToEdge = CGVectorMake(initialSourceFrameCenterInContainer.x - CGRectGetMaxX(initialMaskedViewInContainer),
                             initialSourceFrameCenterInContainer.y - CGRectGetMaxY(initialMaskedViewInContainer));

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

  MDMMotionTimingAnimator *animator = [[MDMMotionTimingAnimator alloc] init];
  animator.shouldReverseValues = context.direction == MDMTransitionDirectionBackward;

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

@end
