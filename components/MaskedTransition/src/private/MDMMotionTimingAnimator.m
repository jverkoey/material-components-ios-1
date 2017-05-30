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

#import "MDMMotionTimingAnimator.h"

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coefficient.
#endif

CGFloat simulatorAnimationDragCoefficient(void);
CGFloat simulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

@implementation MDMMotionTimingAnimator

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

  if (_shouldReverseValues) {
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
    animation.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] + timing.delay * simulatorAnimationDragCoefficient();
    animation.fillMode = kCAFillModeBackwards;
  }
  animation.duration = timing.duration * simulatorAnimationDragCoefficient();
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
