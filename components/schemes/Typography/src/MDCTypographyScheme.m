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

#import "MDCTypographyScheme.h"

#import <MaterialComponents/MaterialTypography.h>

@implementation MDCTypographyScheme

- (instancetype)init {
  return [self initWithDefaults:MDCTypographySchemeDefaultsMaterial201902];
}

- (instancetype)initWithDefaults:(MDCTypographySchemeDefaults)defaults {
  self = [super init];
  if (self) {
    _useCurrentContentSizeCategoryWhenApplied = NO;

    switch (defaults) {
      case MDCTypographySchemeDefaultsMaterial201804:
        _headline1 = [UIFont systemFontOfSize:96.0 weight:UIFontWeightLight];
        _headline2 = [UIFont systemFontOfSize:60.0 weight:UIFontWeightLight];
        _headline3 = [UIFont systemFontOfSize:48.0 weight:UIFontWeightRegular];
        _headline4 = [UIFont systemFontOfSize:34.0 weight:UIFontWeightRegular];
        _headline5 = [UIFont systemFontOfSize:24.0 weight:UIFontWeightRegular];
        _headline6 = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
        _subtitle1 = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _subtitle2 = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        _body1 = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _body2 = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        _caption = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
        _button = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        _overline = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        break;
      case MDCTypographySchemeDefaultsMaterial201902:
        _headline1 = [UIFont systemFontOfSize:96.0 weight:UIFontWeightLight];
        _headline2 = [UIFont systemFontOfSize:60.0 weight:UIFontWeightLight];
        _headline3 = [UIFont systemFontOfSize:48.0 weight:UIFontWeightRegular];
        _headline4 = [UIFont systemFontOfSize:34.0 weight:UIFontWeightRegular];
        _headline5 = [UIFont systemFontOfSize:24.0 weight:UIFontWeightRegular];
        _headline6 = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
        _subtitle1 = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _subtitle2 = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        _body1 = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _body2 = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        _caption = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
        _button = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        _overline = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];

        // Attach a sizing curve to all fonts
        MDCFontScaler *fontScaler =
            [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline1];
        _headline1 = [fontScaler scaledFontWithFont:_headline1];
        _headline1 = [_headline1 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline2];
        _headline2 = [fontScaler scaledFontWithFont:_headline2];
        _headline2 = [_headline2 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline3];
        _headline3 = [fontScaler scaledFontWithFont:_headline3];
        _headline3 = [_headline3 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline4];
        _headline4 = [fontScaler scaledFontWithFont:_headline4];
        _headline4 = [_headline4 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline5];
        _headline5 = [fontScaler scaledFontWithFont:_headline5];
        _headline5 = [_headline5 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleHeadline6];
        _headline6 = [fontScaler scaledFontWithFont:_headline6];
        _headline6 = [_headline6 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleSubtitle1];
        _subtitle1 = [fontScaler scaledFontWithFont:_subtitle1];
        _subtitle1 = [_subtitle1 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleSubtitle2];
        _subtitle2 = [fontScaler scaledFontWithFont:_subtitle2];
        _subtitle2 = [_subtitle2 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleBody1];
        _body1 = [fontScaler scaledFontWithFont:_body1];
        _body1 = [_body1 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleBody2];
        _body2 = [fontScaler scaledFontWithFont:_body2];
        _body2 = [_body2 mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleCaption];
        _caption = [fontScaler scaledFontWithFont:_caption];
        _caption = [_caption mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleButton];
        _button = [fontScaler scaledFontWithFont:_button];
        _button = [_button mdc_scaledFontAtDefaultSize];

        fontScaler = [[MDCFontScaler alloc] initForMaterialTextStyle:MDCTextStyleOverline];
        _overline = [fontScaler scaledFontWithFont:_overline];
        _overline = [_overline mdc_scaledFontAtDefaultSize];

        break;
    }
  }
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
  MDCTypographyScheme *copy = [[MDCTypographyScheme alloc] init];
  copy.headline1 = self.headline1;
  copy.headline2 = self.headline2;
  copy.headline3 = self.headline3;
  copy.headline4 = self.headline4;
  copy.headline5 = self.headline5;
  copy.headline6 = self.headline6;
  copy.subtitle1 = self.subtitle1;
  copy.subtitle2 = self.subtitle2;
  copy.body1 = self.body1;
  copy.body2 = self.body2;
  copy.caption = self.caption;
  copy.button = self.button;
  copy.overline = self.overline;
  copy.useCurrentContentSizeCategoryWhenApplied = self.useCurrentContentSizeCategoryWhenApplied;
  return copy;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  return [self mutableCopyWithZone:zone];
}

- (BOOL)mdc_adjustsFontForContentSizeCategory {
  return self.useCurrentContentSizeCategoryWhenApplied;
}

- (void)setMdc_adjustsFontForContentSizeCategory:(BOOL)mdc_adjustsFontForContentSizeCategory {
  self.useCurrentContentSizeCategoryWhenApplied = mdc_adjustsFontForContentSizeCategory;
}

@end

#pragma mark - TraitCollectionSupport

@implementation MDCTypographyScheme (TraitCollectionSupport)

#pragma mark Public

- (instancetype)initWithDefaults:(MDCTypographySchemeDefaults)defaults
                 traitCollection:(UITraitCollection *)traitCollection {
  self = [self initWithDefaults:defaults];
  if (self) {
    [MDCTypographyScheme mutateScheme:self forTraitCollection:traitCollection];
  }
  return self;
}

- (void)adjustForTraitCollection:(nonnull UITraitCollection *)traitCollection {
  [MDCTypographyScheme mutateScheme:self forTraitCollection:traitCollection];
}

#pragma mark Private

+ (void)mutateScheme:(MDCTypographyScheme *)scheme
    forTraitCollection:(UITraitCollection *)traitCollection {
  scheme.headline1 = [scheme.headline1 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.headline2 = [scheme.headline2 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.headline3 = [scheme.headline3 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.headline4 = [scheme.headline4 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.headline5 = [scheme.headline5 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.headline6 = [scheme.headline6 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.subtitle1 = [scheme.subtitle1 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.subtitle2 = [scheme.subtitle2 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.body1 = [scheme.body1 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.body2 = [scheme.body2 mdc_scaledFontForTraitCollection:traitCollection];
  scheme.caption = [scheme.caption mdc_scaledFontForTraitCollection:traitCollection];
  scheme.button = [scheme.button mdc_scaledFontForTraitCollection:traitCollection];
  scheme.overline = [scheme.overline mdc_scaledFontForTraitCollection:traitCollection];
}

@end

@protocol GMDCTypographySchemingAdditions <NSObject>

@property(nonatomic, nonnull, readonly) UIFont *subhead1;
@property(nonatomic, nonnull, readonly) UIFont *subhead2;
@property(nonatomic, nonnull, readonly) UIFont *display1;
@property(nonatomic, nonnull, readonly) UIFont *display2;
@property(nonatomic, nonnull, readonly) UIFont *display3;
@property(nonatomic, nonnull, readonly) UIFont *altButton;

@end


@interface GMDCTypographyScheme ()

@property(nonatomic, readonly, nonnull) id<MDCTypographyScheming> mdcTypographyScheme;
@property(nonatomic, readonly, nonnull) id<GMDCTypographySchemingAdditions>
    typographySchemingAdditions;

@end

/**
 Provides Google Material defaults from 201808, with the addition that fonts will have
 appropriate scalingCurves attached, which can be used to support Dynamic Type.
 */
__attribute__((objc_subclassing_restricted)) @interface GMDCMaterialTypographyScheme201905
    : NSObject<MDCTypographyScheming>
@end

/**
 Provides additional Google Material defaults from 201808, with the addition that fonts will
 have appropriate scalingCurves attached, which can be used to support Dynamic Type.
 */
__attribute__((objc_subclassing_restricted)) @interface GMDCMaterialTypographySchemeAdditions201905
    : NSObject<GMDCTypographySchemingAdditions>
@end



@implementation GMDCMaterialTypographyScheme201905 {
  UIFont *_headline1;
  UIFont *_headline2;
  UIFont *_headline3;
  UIFont *_headline4;
  UIFont *_headline5;
  UIFont *_headline6;
  UIFont *_subtitle1;
  UIFont *_subtitle2;
  UIFont *_body1;
  UIFont *_body2;
  UIFont *_caption;
  UIFont *_button;
  UIFont *_overline;
}

- (BOOL)useCurrentContentSizeCategoryWhenApplied {
  return NO;
}

// TODO(b/135471973): This method will eventually be removed and replaced by
// useCurrentContentSizeCategoryWhenApplied.
- (BOOL)mdc_adjustsFontForContentSizeCategory {
  return self.useCurrentContentSizeCategoryWhenApplied;
}

- (UIFont *)headline1 {
  if (_headline1 == nil) {
    // lazy load
  }
  return _headline1;
}

- (UIFont *)headline2 {
  if (_headline2 == nil) {
    // lazy load
  }
  return _headline2;
}

- (UIFont *)headline3 {
  if (_headline3 == nil) {
    // lazy load
  }
  return _headline3;
}

- (UIFont *)headline4 {
  if (_headline4 == nil) {
    // lazy load
  }
  return _headline4;
}

- (UIFont *)headline5 {
  if (_headline5 == nil) {
    // lazy load
  }
  return _headline5;
}

- (UIFont *)headline6 {
  if (_headline6 == nil) {
    // lazy load
  }
  return _headline6;
}

- (UIFont *)subtitle1 {
  if (_subtitle1 == nil) {
    // lazy load
  }
  return _subtitle1;
}

- (UIFont *)subtitle2 {
  if (_subtitle2 == nil) {
    // lazy load
  }
  return _subtitle2;
}

- (UIFont *)body1 {
  if (_body1 == nil) {
    // lazy load
  }
  return _body1;
}

- (UIFont *)body2 {
  if (_body2 == nil) {
    // lazy load
  }
  return _body2;
}

- (UIFont *)caption {
  if (_caption == nil) {
    // lazy load
  }
  return _caption;
}

- (UIFont *)button {
  if (_button == nil) {
    // lazy load
  }
  return _button;
}

- (UIFont *)overline {
  if (_overline == nil) {
    // lazy load
  }
  return _overline;
}

@end

@implementation GMDCMaterialTypographySchemeAdditions201905 {
  UIFont *_subhead1;
  UIFont *_subhead2;
  UIFont *_display1;
  UIFont *_display2;
  UIFont *_display3;
  UIFont *_altButton;
}

- (UIFont *)subhead1 {
  if (_subhead1 == nil) {
    // lazy load
  }
  return _subhead1;
}

- (UIFont *)subhead2 {
  if (_subhead2 == nil) {
    // lazy load
  }
  return _subhead2;
}

- (UIFont *)display1 {
  if (_display1 == nil) {
    // lazy load
  }
  return _display1;
}

- (UIFont *)display2 {
  if (_display2 == nil) {
    // lazy load
  }
  return _display2;
}

- (UIFont *)display3 {
  if (_display3 == nil) {
    // lazy load
  }
  return _display3;
}

// TODO (b/131772342): To be deprecated.
- (UIFont *)altButton {
  if (_altButton == nil) {
    UIFont *altButtonFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    // There is no scaling curve available for altButton in http://go/gmdc-dynamic-type,
    // MDCTextStyleButton is used for altButton here because they use the same font.
    MDCFontScaler *fontScaler = [MDCFontScaler scalerForMaterialTextStyle:MDCTextStyleButton];
    altButtonFont = [fontScaler scaledFontWithFont:altButtonFont];
    _altButton = [altButtonFont mdc_scaledFontAtDefaultSize];
  }
  return _altButton;
}

@end

@implementation GMDCTypographyScheme

- (instancetype)init {
  return [self initWithDefaults:GMDCTypographySchemeDefaultsGoogleMaterial201808];
}

- (instancetype)initWithDefaults:(GMDCTypographySchemeDefaults)defaults {
  self = [super init];
  if (self) {
    _useCurrentContentSizeCategoryWhenApplied = NO;

    _mdcTypographyScheme = [[GMDCMaterialTypographyScheme201905 alloc] init];
    _typographySchemingAdditions = [[GMDCMaterialTypographySchemeAdditions201905 alloc] init];
  }
  return self;
}

- (BOOL)mdc_adjustsFontForContentSizeCategory {
  return self.useCurrentContentSizeCategoryWhenApplied;
}

- (void)setMdc_adjustsFontForContentSizeCategory:(BOOL)mdc_adjustsFontForContentSizeCategory {
  self.useCurrentContentSizeCategoryWhenApplied = mdc_adjustsFontForContentSizeCategory;
}

#pragma mark - MDC fonts

- (UIFont *)headline1 {
  return _mdcTypographyScheme.headline1;
}

- (UIFont *)headline2 {
  return _mdcTypographyScheme.headline2;
}

- (UIFont *)headline3 {
  return _mdcTypographyScheme.headline3;
}

- (UIFont *)headline4 {
  return _mdcTypographyScheme.headline4;
}

- (UIFont *)headline5 {
  return _mdcTypographyScheme.headline5;
}

- (UIFont *)headline6 {
  return _mdcTypographyScheme.headline6;
}

- (UIFont *)subtitle1 {
  return _mdcTypographyScheme.subtitle1;
}

- (UIFont *)subtitle2 {
  return _mdcTypographyScheme.subtitle2;
}

- (UIFont *)body1 {
  return _mdcTypographyScheme.body1;
}

- (UIFont *)body2 {
  return _mdcTypographyScheme.body2;
}

- (UIFont *)caption {
  return _mdcTypographyScheme.caption;
}

- (UIFont *)button {
  return _mdcTypographyScheme.button;
}

- (UIFont *)overline {
  return _mdcTypographyScheme.overline;
}

#pragma mark - GMDC fonts

- (UIFont *)subhead1 {
  return _typographySchemingAdditions.subhead1;
}

- (UIFont *)subhead2 {
  return _typographySchemingAdditions.subhead2;
}

- (UIFont *)display1 {
  return _typographySchemingAdditions.display1;
}

- (UIFont *)display2 {
  return _typographySchemingAdditions.display2;
}

- (UIFont *)display3 {
  return _typographySchemingAdditions.display3;
}

- (UIFont *)altButton {
  return _typographySchemingAdditions.altButton;
}

@end
