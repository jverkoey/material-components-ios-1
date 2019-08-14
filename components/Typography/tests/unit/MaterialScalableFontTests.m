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

#import <XCTest/XCTest.h>

#import "MaterialTypography.h"

#import "MaterialMath.h"

@interface UIFont_MaterialScalable : XCTestCase

@end

@implementation UIFont_MaterialScalable

- (void)testNonScaledFontReturnsSelf {
  // Given
  UIFont *font = [UIFont systemFontOfSize:24.0];

  // Note that no scaling curve has been attached to the font, so it will NOT scale
  UIFont *nonScaledFont1 = [font mdc_scaledFontForSizeCategory:UIContentSizeCategoryExtraLarge];

  // Then
  XCTAssert([font mdc_isSimplyEqual:nonScaledFont1]);
}

- (void)testScalingCurveIsCopied {
  // Given
  UIFont *font = [UIFont systemFontOfSize:18.0];
  NSMutableDictionary<UIContentSizeCategory, NSNumber *> *scalingCurve = [@{
    UIContentSizeCategoryExtraSmall : @0,
  } mutableCopy];
  font.mdc_scalingCurve = scalingCurve;

  // When
  scalingCurve[UIContentSizeCategoryExtraSmall] = @100;

  // Then
  XCTAssertNotEqual(font.mdc_scalingCurve[UIContentSizeCategoryExtraSmall],
                    scalingCurve[UIContentSizeCategoryExtraSmall]);
}

- (void)testNegativeAndZeroScalingCurve {
  // Given
  UIFont *font = [UIFont systemFontOfSize:18.0];

  NSDictionary<UIContentSizeCategory, NSNumber *> *scalingCurve = @{
    UIContentSizeCategoryExtraSmall : @0,
    UIContentSizeCategorySmall : @0,
    UIContentSizeCategoryMedium : @0,
    UIContentSizeCategoryLarge : @0,
    UIContentSizeCategoryExtraLarge : @0,
    UIContentSizeCategoryExtraExtraLarge : @0,
    UIContentSizeCategoryExtraExtraExtraLarge : @0,
    UIContentSizeCategoryAccessibilityMedium : @-1,
    UIContentSizeCategoryAccessibilityLarge : @-1,
    UIContentSizeCategoryAccessibilityExtraLarge : @-1,
    UIContentSizeCategoryAccessibilityExtraExtraLarge : @-1,
    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @-1,
  };

  font.mdc_scalingCurve = scalingCurve;

  // Note that scaling curve is 0 @ UIContentSizeCategoryExtraExtraExtraLarge so this font should be
  // the same size.
  UIFont *zeroScaledFont =
      [font mdc_scaledFontForSizeCategory:UIContentSizeCategoryExtraExtraExtraLarge];

  // Note that scaling curve is -1 @ UIContentSizeCategoryAccessibilityExtraExtraExtraLarge so this
  // font should be the same size.
  UIFont *negativeScaledFont =
      [font mdc_scaledFontForSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

  // Then
  XCTAssert([font mdc_isSimplyEqual:zeroScaledFont]);
  XCTAssert([font mdc_isSimplyEqual:negativeScaledFont]);
}

- (void)testIncompleteScalingCurve {
  // Given
  UIFont *font = [UIFont systemFontOfSize:20.0];

  const CGFloat curvePointSize = 12.0;

  // This curve is missing all values over Medius
  NSDictionary<UIContentSizeCategory, NSNumber *> *scalingCurve = @{
    UIContentSizeCategoryExtraSmall : @(curvePointSize),
    UIContentSizeCategorySmall : @(curvePointSize),
    UIContentSizeCategoryMedium : @(curvePointSize),
  };

  font.mdc_scalingCurve = scalingCurve;

  UIFont *mediumScaledFont = [font mdc_scaledFontForSizeCategory:UIContentSizeCategoryMedium];

  UIFont *missingCurveScaledFont =
      [font mdc_scaledFontForSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

  // Then
  XCTAssertEqualWithAccuracy(mediumScaledFont.pointSize, curvePointSize, 0.0001);
  XCTAssert([font mdc_isSimplyEqual:missingCurveScaledFont]);
}

@end

@interface MDCFontScalerTests : XCTestCase

@end

@implementation MDCFontScalerTests

- (void)testScaledFontsReturnEquivalentFonts {
  // Given
  NSArray<MDCTextStyle> *textStyles = @[
    MDCTextStyleHeadline1,
    MDCTextStyleHeadline2,
    MDCTextStyleHeadline3,
    MDCTextStyleHeadline4,
    MDCTextStyleHeadline5,
    MDCTextStyleHeadline6,
    MDCTextStyleSubtitle1,
    MDCTextStyleSubtitle2,
    MDCTextStyleBody1,
    MDCTextStyleBody2,
    MDCTextStyleButton,
    MDCTextStyleCaption,
    MDCTextStyleOverline,
  ];

  for (MDCTextStyle textStyle in textStyles) {
    // When
    UIFont *font1 = [UIFont systemFontOfSize:18.0];
    UIFont *font2 = [UIFont systemFontOfSize:18.0];

    MDCFontScaler *scaler1 = [[MDCFontScaler alloc] initForMaterialTextStyle:textStyle];
    MDCFontScaler *scaler2 = [[MDCFontScaler alloc] initForMaterialTextStyle:textStyle];

    UIFont *scaledFont1 = [scaler1 scaledFontWithFont:font1];
    UIFont *scaledFont2 = [scaler2 scaledFontWithFont:font2];

    // Then
    XCTAssert([font1 mdc_isSimplyEqual:font2]);
    XCTAssert([scaledFont1 mdc_isSimplyEqual:scaledFont2]);
  }
}

- (void)testInvalidStyleFallback {
  // Given
  UIFont *originalFont = [UIFont systemFontOfSize:22.0];

  MDCFontScaler *invalidScaler =
      [[MDCFontScaler alloc] initForMaterialTextStyle:@"IntentionallyNonTextStyleString"];
  MDCFontScaler *bodyScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleBody1];

  UIFont *invalidScalableFont = [invalidScaler scaledFontWithFont:originalFont];
  UIFont *bodyScalableFont = [bodyScaler scaledFontWithFont:originalFont];

  // Then
  XCTAssert([invalidScalableFont mdc_isSimplyEqual:bodyScalableFont]);
}

- (void)testOriginalFontDoesNotGetCurve {
  // Given
  UIFont *originalFont = [UIFont systemFontOfSize:22.0];

  MDCFontScaler *bodyScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleBody1];

  UIFont *bodyScalableFont = [bodyScaler scaledFontWithFont:originalFont];

  // Then
  XCTAssertNil(originalFont.mdc_scalingCurve);
  XCTAssertNotNil(bodyScalableFont.mdc_scalingCurve);
}

@end

@interface MaterialScalableFontTests : XCTestCase

@end

@implementation MaterialScalableFontTests

- (void)testUIKitDynamicTypeCurveValuesCanary {
  if (@available(iOS 10.0, *)) {
    // Given
    NSMutableArray<UIFontTextStyle> *textStyles = [@[
      UIFontTextStyleTitle1,
      UIFontTextStyleTitle2,
      UIFontTextStyleTitle3,
      UIFontTextStyleHeadline,
      UIFontTextStyleSubheadline,
      UIFontTextStyleBody,
      UIFontTextStyleCallout,
      UIFontTextStyleFootnote,
      UIFontTextStyleCaption1,
      UIFontTextStyleCaption2,
    ] mutableCopy];

    NSArray<UIContentSizeCategory> *sizeCategories = @[
      UIContentSizeCategoryExtraSmall,
      UIContentSizeCategorySmall,
      UIContentSizeCategoryMedium,
      UIContentSizeCategoryLarge,
      UIContentSizeCategoryExtraLarge,
      UIContentSizeCategoryExtraExtraLarge,
      UIContentSizeCategoryExtraExtraExtraLarge,
      UIContentSizeCategoryAccessibilityMedium,
      UIContentSizeCategoryAccessibilityLarge,
      UIContentSizeCategoryAccessibilityExtraLarge,
      UIContentSizeCategoryAccessibilityExtraExtraLarge,
      UIContentSizeCategoryAccessibilityExtraExtraExtraLarge,
    ];

    NSMutableDictionary<UIFontTextStyle, NSDictionary<UIContentSizeCategory, NSNumber *> *>
        *scaledFontSizes = [@{
          UIFontTextStyleTitle1 : @{
            UIContentSizeCategoryExtraSmall : @25,
            UIContentSizeCategorySmall : @26,
            UIContentSizeCategoryMedium : @27,
            UIContentSizeCategoryLarge : @28,
            UIContentSizeCategoryExtraLarge : @30,
            UIContentSizeCategoryExtraExtraLarge : @32,
            UIContentSizeCategoryExtraExtraExtraLarge : @34,
            UIContentSizeCategoryAccessibilityMedium : @38,
            UIContentSizeCategoryAccessibilityLarge : @43,
            UIContentSizeCategoryAccessibilityExtraLarge : @48,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @53,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @58,
          },
          UIFontTextStyleTitle2 : @{
            UIContentSizeCategoryExtraSmall : @19,
            UIContentSizeCategorySmall : @20,
            UIContentSizeCategoryMedium : @21,
            UIContentSizeCategoryLarge : @22,
            UIContentSizeCategoryExtraLarge : @24,
            UIContentSizeCategoryExtraExtraLarge : @26,
            UIContentSizeCategoryExtraExtraExtraLarge : @28,
            UIContentSizeCategoryAccessibilityMedium : @34,
            UIContentSizeCategoryAccessibilityLarge : @39,
            UIContentSizeCategoryAccessibilityExtraLarge : @44,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @50,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @56,
          },
          UIFontTextStyleTitle3 : @{
            UIContentSizeCategoryExtraSmall : @17,
            UIContentSizeCategorySmall : @18,
            UIContentSizeCategoryMedium : @19,
            UIContentSizeCategoryLarge : @20,
            UIContentSizeCategoryExtraLarge : @22,
            UIContentSizeCategoryExtraExtraLarge : @24,
            UIContentSizeCategoryExtraExtraExtraLarge : @26,
            UIContentSizeCategoryAccessibilityMedium : @31,
            UIContentSizeCategoryAccessibilityLarge : @37,
            UIContentSizeCategoryAccessibilityExtraLarge : @43,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @49,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @55,
          },
          UIFontTextStyleHeadline : @{
            UIContentSizeCategoryExtraSmall : @14,
            UIContentSizeCategorySmall : @15,
            UIContentSizeCategoryMedium : @16,
            UIContentSizeCategoryLarge : @17,
            UIContentSizeCategoryExtraLarge : @19,
            UIContentSizeCategoryExtraExtraLarge : @21,
            UIContentSizeCategoryExtraExtraExtraLarge : @23,
            UIContentSizeCategoryAccessibilityMedium : @28,
            UIContentSizeCategoryAccessibilityLarge : @33,
            UIContentSizeCategoryAccessibilityExtraLarge : @40,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @47,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @53,
          },
          UIFontTextStyleSubheadline : @{
            UIContentSizeCategoryExtraSmall : @12,
            UIContentSizeCategorySmall : @13,
            UIContentSizeCategoryMedium : @14,
            UIContentSizeCategoryLarge : @15,
            UIContentSizeCategoryExtraLarge : @17,
            UIContentSizeCategoryExtraExtraLarge : @19,
            UIContentSizeCategoryExtraExtraExtraLarge : @21,
            UIContentSizeCategoryAccessibilityMedium : @25,
            UIContentSizeCategoryAccessibilityLarge : @30,
            UIContentSizeCategoryAccessibilityExtraLarge : @36,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @42,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @49,
          },
          UIFontTextStyleBody : @{
            UIContentSizeCategoryExtraSmall : @14,
            UIContentSizeCategorySmall : @15,
            UIContentSizeCategoryMedium : @16,
            UIContentSizeCategoryLarge : @17,
            UIContentSizeCategoryExtraLarge : @19,
            UIContentSizeCategoryExtraExtraLarge : @21,
            UIContentSizeCategoryExtraExtraExtraLarge : @23,
            UIContentSizeCategoryAccessibilityMedium : @28,
            UIContentSizeCategoryAccessibilityLarge : @33,
            UIContentSizeCategoryAccessibilityExtraLarge : @40,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @47,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @53,
          },
          UIFontTextStyleCallout : @{
            UIContentSizeCategoryExtraSmall : @13,
            UIContentSizeCategorySmall : @14,
            UIContentSizeCategoryMedium : @15,
            UIContentSizeCategoryLarge : @16,
            UIContentSizeCategoryExtraLarge : @18,
            UIContentSizeCategoryExtraExtraLarge : @20,
            UIContentSizeCategoryExtraExtraExtraLarge : @22,
            UIContentSizeCategoryAccessibilityMedium : @26,
            UIContentSizeCategoryAccessibilityLarge : @32,
            UIContentSizeCategoryAccessibilityExtraLarge : @38,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @44,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @51,
          },
          UIFontTextStyleFootnote : @{
            UIContentSizeCategoryExtraSmall : @12,
            UIContentSizeCategorySmall : @12,
            UIContentSizeCategoryMedium : @12,
            UIContentSizeCategoryLarge : @13,
            UIContentSizeCategoryExtraLarge : @15,
            UIContentSizeCategoryExtraExtraLarge : @17,
            UIContentSizeCategoryExtraExtraExtraLarge : @19,
            UIContentSizeCategoryAccessibilityMedium : @23,
            UIContentSizeCategoryAccessibilityLarge : @27,
            UIContentSizeCategoryAccessibilityExtraLarge : @33,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @38,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @44,
          },
          UIFontTextStyleCaption1 : @{
            UIContentSizeCategoryExtraSmall : @11,
            UIContentSizeCategorySmall : @11,
            UIContentSizeCategoryMedium : @11,
            UIContentSizeCategoryLarge : @12,
            UIContentSizeCategoryExtraLarge : @14,
            UIContentSizeCategoryExtraExtraLarge : @16,
            UIContentSizeCategoryExtraExtraExtraLarge : @18,
            UIContentSizeCategoryAccessibilityMedium : @22,
            UIContentSizeCategoryAccessibilityLarge : @26,
            UIContentSizeCategoryAccessibilityExtraLarge : @32,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @37,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @43,
          },
          UIFontTextStyleCaption2 : @{
            UIContentSizeCategoryExtraSmall : @11,
            UIContentSizeCategorySmall : @11,
            UIContentSizeCategoryMedium : @11,
            UIContentSizeCategoryLarge : @11,
            UIContentSizeCategoryExtraLarge : @13,
            UIContentSizeCategoryExtraExtraLarge : @15,
            UIContentSizeCategoryExtraExtraExtraLarge : @17,
            UIContentSizeCategoryAccessibilityMedium : @20,
            UIContentSizeCategoryAccessibilityLarge : @24,
            UIContentSizeCategoryAccessibilityExtraLarge : @29,
            UIContentSizeCategoryAccessibilityExtraExtraLarge : @34,
            UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @40,
          },
        } mutableCopy];

    if (@available(iOS 11.0, *)) {
      [textStyles addObject:UIFontTextStyleLargeTitle];
      scaledFontSizes[UIFontTextStyleLargeTitle] = @{
        UIContentSizeCategoryExtraSmall : @31,
        UIContentSizeCategorySmall : @32,
        UIContentSizeCategoryMedium : @33,
        UIContentSizeCategoryLarge : @34,
        UIContentSizeCategoryExtraLarge : @36,
        UIContentSizeCategoryExtraExtraLarge : @38,
        UIContentSizeCategoryExtraExtraExtraLarge : @40,
        UIContentSizeCategoryAccessibilityMedium : @44,
        UIContentSizeCategoryAccessibilityLarge : @48,
        UIContentSizeCategoryAccessibilityExtraLarge : @52,
        UIContentSizeCategoryAccessibilityExtraExtraLarge : @56,
        UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @60,
      };
    }

    for (UIFontTextStyle textStyle in textStyles) {
      // When
      for (UIContentSizeCategory contentSizeCategory in sizeCategories) {
        UITraitCollection *traitCollection =
            [UITraitCollection traitCollectionWithPreferredContentSizeCategory:contentSizeCategory];

        UIFont *font = [UIFont preferredFontForTextStyle:textStyle
                           compatibleWithTraitCollection:traitCollection];

        CGFloat expectedFontSize =
            (CGFloat)[scaledFontSizes[textStyle][contentSizeCategory] doubleValue];
        XCTAssertEqualWithAccuracy(font.pointSize, expectedFontSize, 0.001,
                                   @"Text style: %@ with size category %@ did not match expected"
                                   @" value of %@, was %@ instead",
                                   textStyle, contentSizeCategory, @(expectedFontSize),
                                   @(font.pointSize));
      }
    }


    if (@available(iOS 11.0, *)) {
      for (UIFontTextStyle textStyle in textStyles) {
        NSLog(@"%@", textStyle);
        for (UIContentSizeCategory contentSizeCategory in sizeCategories) {
          UITraitCollection *traitCollection =
              [UITraitCollection traitCollectionWithPreferredContentSizeCategory:contentSizeCategory];

          NSMutableArray *line = [@[contentSizeCategory] mutableCopy];
          UILabel *label = [[UILabel alloc] init];
          for (CGFloat fontSize = 10; fontSize < 100; fontSize++) {
            UIFont *customFont = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
            label.font = [[UIFontMetrics metricsForTextStyle:textStyle] scaledFontForFont:customFont
                                                            compatibleWithTraitCollection:traitCollection];
            [line addObject:@(label.font.pointSize)];
          }
          NSLog(@"%@", [line componentsJoinedByString:@", "]);
        }
        NSLog(@"");
      }
    }
  }
}

- (void)testScalingCurvesIncrease {
  // Given
  NSArray<MDCTextStyle> *textStyles = @[
    MDCTextStyleHeadline1,
    MDCTextStyleHeadline2,
    MDCTextStyleHeadline3,
    MDCTextStyleHeadline4,
    MDCTextStyleHeadline5,
    MDCTextStyleHeadline6,
    MDCTextStyleSubtitle1,
    MDCTextStyleSubtitle2,
    MDCTextStyleBody1,
    MDCTextStyleBody2,
    MDCTextStyleButton,
    MDCTextStyleCaption,
    MDCTextStyleOverline,
  ];

  // The following array MUST be ordered from smallest to largest
  NSArray<UIContentSizeCategory> *sizeCategories = @[
    UIContentSizeCategoryExtraSmall,
    UIContentSizeCategorySmall,
    UIContentSizeCategoryMedium,
    UIContentSizeCategoryLarge,
    UIContentSizeCategoryExtraLarge,
    UIContentSizeCategoryExtraExtraLarge,
    UIContentSizeCategoryExtraExtraExtraLarge,
    UIContentSizeCategoryAccessibilityMedium,
    UIContentSizeCategoryAccessibilityLarge,
    UIContentSizeCategoryAccessibilityExtraLarge,
    UIContentSizeCategoryAccessibilityExtraExtraLarge,
    UIContentSizeCategoryAccessibilityExtraExtraExtraLarge,
  ];

  for (MDCTextStyle textStyle in textStyles) {
    // When
    UIFont *font = [UIFont systemFontOfSize:18.0];

    MDCFontScaler *scaler = [[MDCFontScaler alloc] initForMaterialTextStyle:textStyle];

    UIFont *scalableFont = [scaler scaledFontWithFont:font];

    for (unsigned long ii = 0; ii < sizeCategories.count - 1; ++ii) {
      UIContentSizeCategory smallerSizeCategory = sizeCategories[ii];
      UIContentSizeCategory largerSizeCategory = sizeCategories[ii + 1];

      UIFont *smallerFont = [scalableFont mdc_scaledFontForSizeCategory:smallerSizeCategory];
      UIFont *largerFont = [scalableFont mdc_scaledFontForSizeCategory:largerSizeCategory];

      // Then
      XCTAssert(smallerFont.pointSize <= largerFont.pointSize);
    }
  }
}

- (void)testScaledFontDefaultEqualsLarge {
  // Given
  NSArray<MDCTextStyle> *textStyles = @[
    MDCTextStyleHeadline1,
    MDCTextStyleHeadline2,
    MDCTextStyleHeadline3,
    MDCTextStyleHeadline4,
    MDCTextStyleHeadline5,
    MDCTextStyleHeadline6,
    MDCTextStyleSubtitle1,
    MDCTextStyleSubtitle2,
    MDCTextStyleBody1,
    MDCTextStyleBody2,
    MDCTextStyleButton,
    MDCTextStyleCaption,
    MDCTextStyleOverline,
  ];

  for (MDCTextStyle textStyle in textStyles) {
    // When
    UIFont *font = [UIFont systemFontOfSize:18.0];

    MDCFontScaler *scaler = [[MDCFontScaler alloc] initForMaterialTextStyle:textStyle];

    UIFont *scalabledFont = [scaler scaledFontWithFont:font];

    UIFont *defaultFont = [scalabledFont mdc_scaledFontAtDefaultSize];
    UIFont *largeFont = [scalabledFont mdc_scaledFontForSizeCategory:UIContentSizeCategoryLarge];

    // Then
    XCTAssert([defaultFont mdc_isSimplyEqual:largeFont]);
  }
}

// TODO: #6937 Identify why testValueScaling works locally but not on Kokoro
/* Re-enable when possible
- (void)testValueScaling {
  // Given
  UIFont *originalFont = [UIFont systemFontOfSize:20.0];
  CGFloat originalValue = 10.0;

  MDCFontScaler *scaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleBody1];
  UIFont *scalableFont = [scaler scaledFontWithFont:originalFont];

  // When
  UIFont *defaultFont = [scalableFont mdc_scaledFontAtDefaultSize];
  UIFont *currentFont = [scalableFont mdc_scaledFontForCurrentSizeCategory];

  CGFloat fontScaleFactor = currentFont.pointSize / defaultFont.pointSize;
  CGFloat fontScaledValue = originalValue * fontScaleFactor;

  CGFloat scalerScaledValue = [scaler scaledValueForValue:originalValue];

  // Then
  XCTAssertEqualWithAccuracy(fontScaledValue, scalerScaledValue, 0.0001);
}
 */

@end
