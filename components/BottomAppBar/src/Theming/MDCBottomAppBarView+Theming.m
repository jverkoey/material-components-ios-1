// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
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

#import "MaterialBottomAppBar+Theming.h"

@implementation MDCBottomAppBarView (MaterialTheming)

- (void)applySurfaceThemeWithScheme:(id<MDCContainerScheming>)containerScheme {
  [self resetUIStatesForTheming:bottomAppBarView.floatingButton];

  [self applySurfaceThemeWithColorScheme:scheme.colorScheme];
  [self applyThemeWithTypographyScheme:scheme.typographyScheme];
}

#pragma mark - Internal Helpers

- (void)applySurfaceThemeWithColorScheme:(id<MDCColorScheming>)colorScheme {
  bottomAppBarView.barTintColor = colorScheme.surfaceColor;
  UIColor *barItemTintColor = [colorScheme.onSurfaceColor colorWithAlphaComponent:(CGFloat)0.6];
  bottomAppBarView.leadingBarItemsTintColor = barItemTintColor;
  bottomAppBarView.trailingBarItemsTintColor = barItemTintColor;
  [bottomAppBarView.floatingButton setBackgroundColor:colorScheme.primaryColor
                                             forState:UIControlStateNormal];
  [bottomAppBarView.floatingButton setTitleColor:colorScheme.onPrimaryColor
                                        forState:UIControlStateNormal];
  [bottomAppBarView.floatingButton setImageTintColor:colorScheme.onPrimaryColor
                                            forState:UIControlStateNormal];

  if (colorScheme.elevationOverlayEnabledForDarkMode) {
    self.mdc_elevationDidChangeBlock =
        ^(id<MDCElevatable> _Nonnull object, CGFloat absoluteElevation) {
          if ([object isKindOfClass:[MDCBottomAppBarView class]]) {
            MDCBottomAppBarView *bottomAppBarView = (MDCBottomAppBarView *)object;
            UIColor *elevationSurfaceColor = [colorScheme.surfaceColor
                mdc_resolvedColorWithTraitCollection:bottomAppBarView.traitCollection
                                           elevation:bottomAppBarView.mdc_absoluteElevation];
            bottomAppBarView.backgroundColor = elevationSurfaceColor;
          }
        };
    self.traitCollectionDidChangeBlock = ^(MDCBottomAppBarView *_Nonnull bottomAppBarView,
                                           UITraitCollection *_Nullable previousTraitCollection) {
      bottomAppBarView.backgroundColor = [colorScheme.surfaceColor
          mdc_resolvedColorWithTraitCollection:bottomAppBarView.traitCollection
                       previousTraitCollection:previousTraitCollection
                                     elevation:bottomAppBarView.mdc_absoluteElevation];
    };
  }
}

- (void)applyThemeWithTypographyScheme:(id<MDCTypographyScheming>)typographyScheme {
  
}

#pragma mark - Utility methods

- (void)resetUIStatesForTheming:(MDCButton *)button {
  UIControlState maxState = UIControlStateNormal | UIControlStateHighlighted |
                            UIControlStateDisabled | UIControlStateSelected;
  for (UIControlState state = 0; state <= maxState; ++state) {
    [button setImageTintColor:nil forState:state];
    [button setTitleColor:nil forState:state];
    [button setBackgroundColor:nil forState:state];
  }
}

@end
