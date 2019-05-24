// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
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

#import "UIFont+MaterialScalable.h"

#import <objc/runtime.h>

#import "MaterialApplication.h"

#import "MDCTypography.h"
#import "private/MDCTypographyUtilities.h"

static char MDCFontScaleObjectKey;

@implementation UIFont (MaterialScalable)

- (UIFont *)mdc_scaledFontForSizeCategory:(UIContentSizeCategory)sizeCategory {
  if (!self.mdc_scalingCurve) {
    return self;
  }

  NSNumber *fontSizeNumber;
  if (sizeCategory) {
    fontSizeNumber = self.mdc_scalingCurve[sizeCategory];
  }

  // Guard against broken / incomplete scaling curves by returning self if fontSizeNumber is nil.
  if (fontSizeNumber == nil) {
    return self;
  }

  CGFloat fontSize = (CGFloat)fontSizeNumber.doubleValue;

  // Guard against broken scaling curves encoded with 0.0 or negative values
  if (fontSize <= 0.0) {
    return self;
  }

  UIFont *scaledFont = [UIFont fontWithDescriptor:self.fontDescriptor size:fontSize];
  scaledFont.mdc_scalingCurve = self.mdc_scalingCurve;

  return scaledFont;
}

- (UIFont *)mdc_scaledFontForTraitEnvironment:(id<UITraitEnvironment>)traitEnvironment {
  UIContentSizeCategory sizeCategory = UIContentSizeCategoryLarge;
  if (@available(iOS 10.0, *)) {
    sizeCategory = traitEnvironment.traitCollection.preferredContentSizeCategory;
  } else if ([UIApplication mdc_safeSharedApplication]) {
    sizeCategory = [UIApplication mdc_safeSharedApplication].preferredContentSizeCategory;
  }
  return [self mdc_scaledFontForSizeCategory:sizeCategory];
}

- (UIFont *)mdc_scaledFontForCurrentSizeCategory {
  UIContentSizeCategory currentSizeCategory = GetCurrentSizeCategory();

  return [self mdc_scaledFontForSizeCategory:currentSizeCategory];
}

- (nonnull UIFont *)mdc_scaledFontAtDefaultSize {
  return [self mdc_scaledFontForSizeCategory:UIContentSizeCategoryLarge];
}

- (NSDictionary<UIContentSizeCategory, NSNumber *> *)mdc_scalingCurve {
  return (NSDictionary<UIContentSizeCategory, NSNumber *> *)objc_getAssociatedObject(
      self, &MDCFontScaleObjectKey);
}

- (void)mdc_setScalingCurve:(NSDictionary<UIContentSizeCategory, NSNumber *> *)scalingCurve {
  objc_setAssociatedObject(self, &MDCFontScaleObjectKey, scalingCurve,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
