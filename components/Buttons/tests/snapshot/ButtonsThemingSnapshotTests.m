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

#import "MaterialSnapshot.h"

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "MaterialButtons+Theming.h"
#import "MaterialButtons.h"
#import "MaterialContainerScheme.h"

/** Snapshot tests for @c MDCButton when a theming extension has been applied. */
@interface ButtonsThemingSnapshotTests : MDCSnapshotTestCase
@property(nonatomic, strong, nullable) MDCButton *button;
@property(nonatomic, strong, nullable) MDCContainerScheme *containerScheme;
@end

@implementation ButtonsThemingSnapshotTests

- (void)setUp {
  [super setUp];

  // Uncomment below to recreate all the goldens (or add the following line to the specific
  // test you wish to recreate the golden for).
  //  self.recordMode = YES;

  self.button = [[MDCButton alloc] init];
  [self.button setTitle:@"Material" forState:UIControlStateNormal];
  UIImage *buttonImage = [[UIImage mdc_testImageOfSize:CGSizeMake(24, 24)]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.button setImage:buttonImage forState:UIControlStateNormal];
  self.containerScheme = [[MDCContainerScheme alloc] init];
}

- (void)tearDown {
  self.button = nil;

  [super tearDown];
}

- (void)generateSnapshotAndVerifyForView:(MDCButton *)button {
  [self generateSnapshotAndVerifyForView:button showFrame:NO];
}

- (void)generateSnapshotAndVerifyForView:(MDCButton *)button showFrame:(BOOL)showFrame {
  [button sizeToFit];
  button.frame = CGRectMake(0, 0,
                            button.bounds.size.width
                            + button.shapeGeneratorMarginsHint.left
                            + button.shapeGeneratorMarginsHint.right,
                            button.bounds.size.height
                            + button.shapeGeneratorMarginsHint.top
                            + button.shapeGeneratorMarginsHint.bottom);

  UIView *viewToSnapshot;
  if (showFrame) {
    UIView *frameView = [[UIView alloc] initWithFrame:button.frame];
    frameView.layer.borderWidth = 1;
    frameView.layer.borderColor = UIColor.blackColor.CGColor;
    [frameView addSubview:button];
    viewToSnapshot = frameView;
  } else {
    viewToSnapshot = button;
  }

  UIView *snapshotView = [viewToSnapshot mdc_addToBackgroundView];
  [self snapshotVerifyView:snapshotView];
}

#pragma mark - Tests

/** Test a @c MDCButton being themed with @c applyTextThemeWithScheme:. */
- (void)testTextThemedButton {
  // When
  [self.button applyTextThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button];
}

/** Test a @c MDCButton being themed with @c applyContainedThemeWithScheme:. */
- (void)testContainedThemedButton {
  // When
  [self.button applyContainedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button];
}

/** Test a @c MDCButton being themed with @c applyOutlinedThemeWithScheme:. */
- (void)testOutlineThemedButton {
  // When
  [self.button applyOutlinedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button];
}

/** Test a @c MDCFloatingButton being themed with @c applySecondaryThemeWithScheme:. */
- (void)testFloatingButtonWithDefaultContainerScheme {
  // Given
  MDCFloatingButton *floatingButton = [[MDCFloatingButton alloc] init];
  UIImage *buttonImage = [[UIImage mdc_testImageOfSize:CGSizeMake(24, 24)]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [floatingButton setImage:buttonImage forState:UIControlStateNormal];
  self.containerScheme = [[MDCContainerScheme alloc] init];

  // When
  [floatingButton applySecondaryThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:floatingButton];
}

- (void)testTextThemedButtonWithFrame {
  // When
  [self.button applyTextThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

- (void)testContainedThemedButtonWithFrame {
  // When
  [self.button applyContainedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

- (void)testOutlineThemedButtonWithFrame {
  // When
  [self.button applyOutlinedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

- (void)testTextThemedButtonWithMarginsAndVisibleFrame {
  // When
  self.button.marginsHint = UIEdgeInsetsMake(8, 8, 8, 8);
  self.containerScheme.shapeScheme =
      [[MDCShapeScheme alloc] initWithDefaults:MDCShapeSchemeDefaultsMaterial201809];
  [self.button applyTextThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

- (void)testContainedThemedButtonWithMarginsAndVisibleFrame {
  // When
  self.button.marginsHint = UIEdgeInsetsMake(8, 8, 8, 8);
  self.containerScheme.shapeScheme =
      [[MDCShapeScheme alloc] initWithDefaults:MDCShapeSchemeDefaultsMaterial201809];
  [self.button applyContainedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

- (void)testOutlineThemedButtonWithMarginsAndVisibleFrame {
  // When
  self.button.marginsHint = UIEdgeInsetsMake(8, 8, 8, 8);
  self.containerScheme.shapeScheme =
      [[MDCShapeScheme alloc] initWithDefaults:MDCShapeSchemeDefaultsMaterial201809];
  [self.button applyOutlinedThemeWithScheme:self.containerScheme];

  // Then
  [self generateSnapshotAndVerifyForView:self.button showFrame:YES];
}

@end
