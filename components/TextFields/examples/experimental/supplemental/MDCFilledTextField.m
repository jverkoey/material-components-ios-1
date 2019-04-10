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

#import "MDCFilledTextField.h"

#import <Foundation/Foundation.h>

#import <MDFInternationalization/MDFInternationalization.h>

#import "MDCContainerStylePathDrawingUtils.h"
#import "MDCTextFieldLayout.h"
#import "MaterialMath.h"

static const CGFloat kFilledContainerStyleTopCornerRadius = (CGFloat)4.0;
static const CGFloat kFloatingPlaceholderAnimationVelocityInPointsPerSecond = (CGFloat)200;

@interface MDCFilledTextField ()

@property(strong, nonatomic) CAShapeLayer *filledSublayer;
@property(strong, nonatomic) CAShapeLayer *filledSublayerUnderline;

@property(strong, nonatomic) UIButton *clearButton;
@property(strong, nonatomic) UIImageView *clearButtonImageView;
@property(strong, nonatomic) UILabel *placeholderLabel;

@property(strong, nonatomic) UILabel *leftUnderlineLabel;
@property(strong, nonatomic) UILabel *rightUnderlineLabel;

@property(strong, nonatomic) MDCTextFieldLayout *layout;

@property(nonatomic, assign) UIUserInterfaceLayoutDirection layoutDirection;

@property(nonatomic, assign) MDCContainedInputViewState containedInputViewState;
@property(nonatomic, assign) MDCContainedInputViewPlaceholderState placeholderState;

@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, id<MDCContainedInputViewColorScheming>> *colorSchemes;

@property(nonatomic, assign) BOOL isAnimating;

@end

@implementation MDCFilledTextField

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCFilledTextFieldInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCFilledTextFieldInit];
  }
  return self;
}

- (void)commonMDCFilledTextFieldInit {
  [self initializeProperties];
  [self setUpPlaceholderLabel];
  [self setUpUnderlineLabels];
  [self setUpClearButton];
  [self setUpFilledSublayers];
}

#pragma mark View Setup

- (void)initializeProperties {
  [self setUpCanPlaceholderFloat];
  [self setUpLayoutDirection];
  [self setUpPlaceholderState];
  [self setUpContainedInputViewState];
  [self setUpColorSchemesDictionary];
}

- (void)setUpCanPlaceholderFloat {
  self.labelFloats = YES;
}

- (void)setUpLayoutDirection {
  self.layoutDirection = self.mdf_effectiveUserInterfaceLayoutDirection;
}

- (void)setUpPlaceholderState {
  self.placeholderState = [self determineCurrentPlaceholderState];
}

- (void)setUpContainedInputViewState {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
}

- (void)setUpColorSchemesDictionary {
  self.colorSchemes = [[NSMutableDictionary alloc] init];
}

- (void)setUpUnderlineLabels {
  CGFloat underlineFontSize = MDCRound([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *underlineFont = [UIFont systemFontOfSize:underlineFontSize];
  self.leftUnderlineLabel = [[UILabel alloc] init];
  self.leftUnderlineLabel.font = underlineFont;
  self.rightUnderlineLabel = [[UILabel alloc] init];
  self.rightUnderlineLabel.font = underlineFont;
  [self addSubview:self.leftUnderlineLabel];
  [self addSubview:self.rightUnderlineLabel];
}

- (void)setUpPlaceholderLabel {
  self.placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
  [self addSubview:self.placeholderLabel];
}

- (void)setUpClearButton {
  CGFloat clearButtonSideLength = MDCTextFieldLayout.clearButtonSideLength;
  CGRect clearButtonFrame = CGRectMake(0, 0, clearButtonSideLength, clearButtonSideLength);
  self.clearButton = [[UIButton alloc] initWithFrame:clearButtonFrame];
  [self.clearButton addTarget:self
                       action:@selector(clearButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];

  CGFloat clearButtonImageViewSideLength = MDCTextFieldLayout.clearButtonImageViewSideLength;
  CGRect clearButtonImageViewRect =
      CGRectMake(0, 0, clearButtonImageViewSideLength, clearButtonImageViewSideLength);
  self.clearButtonImageView = [[UIImageView alloc] initWithFrame:clearButtonImageViewRect];
  UIImage *clearButtonImage =
      [[self untintedClearButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.clearButtonImageView.image = clearButtonImage;
  [self.clearButton addSubview:self.clearButtonImageView];
  [self addSubview:self.clearButton];
  self.clearButtonImageView.center = self.clearButton.center;
}

- (void)setUpFilledSublayers {
  self.filledSublayer = [[CAShapeLayer alloc] init];
  self.filledSublayer.lineWidth = 0.0;
  self.filledSublayerUnderline = [[CAShapeLayer alloc] init];
  [self.filledSublayer addSublayer:self.filledSublayerUnderline];
}

#pragma mark UIView Overrides

- (void)layoutSubviews {
  [self preLayoutSubviews];
  [super layoutSubviews];
  [self postLayoutSubviews];
}

// UITextField's sizeToFit calls this method and then also calls setNeedsLayout.
// When the system calls this method the size parameter is the view's current size.
- (CGSize)sizeThatFits:(CGSize)size {
  return [self preferredSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
  return [self preferredSizeWithWidth:CGRectGetWidth(self.bounds)];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self setUpLayoutDirection];
}

#pragma mark Layout

- (void)preLayoutSubviews {
  self.containedInputViewState = [self determineCurrentContainedInputViewState];
  self.placeholderState = [self determineCurrentPlaceholderState];
  CGSize fittingSize = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
  self.layout = [self calculateLayoutWithTextFieldSize:fittingSize];
}

- (void)postLayoutSubviews {
  UIFont *normalFont = [self determineEffectiveFont];
  UIFont *floatingFont = [self floatingPlaceholderFontWithFont:normalFont];
  [self layOutPlaceholderWithState:self.placeholderState
                        normalFont:normalFont
                      floatingFont:floatingFont];
  self.clearButton.frame = [self clearButtonFrameFromLayout:self.layout
                                           placeholderState:self.placeholderState];
  self.clearButton.hidden = self.layout.clearButtonHidden;
  self.leftUnderlineLabel.frame = self.layout.leftUnderlineLabelFrame;
  self.rightUnderlineLabel.frame = self.layout.rightUnderlineLabelFrame;
  self.leftView.hidden = self.layout.leftViewHidden;
  self.rightView.hidden = self.layout.rightViewHidden;
}

- (void)stateDidChange {
  CGFloat underlineThickness = [self underlineThicknessForState:self.state];
  CGFloat topRowBottomRowDividerY = CGRectGetMaxY([self containerRect]);
  [self applyStyleWithTopRowBottomRowDividerY:topRowBottomRowDividerY
                           underlineThickness:underlineThickness];
}

- (void)applyStyleWithTopRowBottomRowDividerY:(CGFloat)topRowBottomRowDividerY
                           underlineThickness:(CGFloat)underlineThickness {
  UIBezierPath *filledSublayerPath =
      [self filledSublayerPathWithTextFieldBounds:self.bounds
                          topRowBottomRowDividerY:topRowBottomRowDividerY];
  UIBezierPath *filledSublayerUnderlinePath =
      [self filledSublayerUnderlinePathWithTextFieldBounds:self.bounds
                                   topRowBottomRowDividerY:topRowBottomRowDividerY
                                        underlineThickness:underlineThickness];
  self.filledSublayer.path = filledSublayerPath.CGPath;
  self.filledSublayerUnderline.path = filledSublayerUnderlinePath.CGPath;
  if (self.filledSublayer.superlayer != self.layer) {
    [self.layer insertSublayer:self.filledSublayer atIndex:0];
  }
}

- (UIBezierPath *)filledSublayerPathWithTextFieldBounds:(CGRect)viewBounds
                                topRowBottomRowDividerY:(CGFloat)topRowBottomRowDividerY {
  UIBezierPath *path = [[UIBezierPath alloc] init];
  CGFloat topRadius = kFilledContainerStyleTopCornerRadius;
  CGFloat bottomRadius = 0;
  CGFloat textFieldWidth = CGRectGetWidth(viewBounds);
  CGFloat sublayerMinY = 0;
  CGFloat sublayerMaxY = topRowBottomRowDividerY;

  CGPoint startingPoint = CGPointMake(topRadius, sublayerMinY);
  CGPoint topRightCornerPoint1 = CGPointMake(textFieldWidth - topRadius, sublayerMinY);
  [path moveToPoint:startingPoint];
  [path addLineToPoint:topRightCornerPoint1];

  CGPoint topRightCornerPoint2 = CGPointMake(textFieldWidth, sublayerMinY + topRadius);
  [MDCContainerStylePathDrawingUtils addTopRightCornerToPath:path
                                                   fromPoint:topRightCornerPoint1
                                                     toPoint:topRightCornerPoint2
                                                  withRadius:topRadius];

  CGPoint bottomRightCornerPoint1 = CGPointMake(textFieldWidth, sublayerMaxY - bottomRadius);
  CGPoint bottomRightCornerPoint2 = CGPointMake(textFieldWidth - bottomRadius, sublayerMaxY);
  [path addLineToPoint:bottomRightCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomRightCornerToPath:path
                                                      fromPoint:bottomRightCornerPoint1
                                                        toPoint:bottomRightCornerPoint2
                                                     withRadius:bottomRadius];

  CGPoint bottomLeftCornerPoint1 = CGPointMake(bottomRadius, sublayerMaxY);
  CGPoint bottomLeftCornerPoint2 = CGPointMake(0, sublayerMaxY - bottomRadius);
  [path addLineToPoint:bottomLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomLeftCornerToPath:path
                                                     fromPoint:bottomLeftCornerPoint1
                                                       toPoint:bottomLeftCornerPoint2
                                                    withRadius:bottomRadius];

  CGPoint topLeftCornerPoint1 = CGPointMake(0, sublayerMinY + topRadius);
  CGPoint topLeftCornerPoint2 = CGPointMake(topRadius, sublayerMinY);
  [path addLineToPoint:topLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addTopLeftCornerToPath:path
                                                  fromPoint:topLeftCornerPoint1
                                                    toPoint:topLeftCornerPoint2
                                                 withRadius:topRadius];

  return path;
}

- (UIBezierPath *)filledSublayerUnderlinePathWithTextFieldBounds:(CGRect)viewBounds
                                         topRowBottomRowDividerY:(CGFloat)topRowBottomRowDividerY
                                              underlineThickness:(CGFloat)underlineThickness {
  UIBezierPath *path = [[UIBezierPath alloc] init];
  CGFloat textFieldWidth = CGRectGetWidth(viewBounds);
  CGFloat sublayerMaxY = topRowBottomRowDividerY;
  CGFloat sublayerMinY = sublayerMaxY - underlineThickness;

  CGPoint startingPoint = CGPointMake(0, sublayerMinY);
  CGPoint topRightCornerPoint1 = CGPointMake(textFieldWidth, sublayerMinY);
  [path moveToPoint:startingPoint];
  [path addLineToPoint:topRightCornerPoint1];

  CGPoint topRightCornerPoint2 = CGPointMake(textFieldWidth, sublayerMinY);
  [MDCContainerStylePathDrawingUtils addTopRightCornerToPath:path
                                                   fromPoint:topRightCornerPoint1
                                                     toPoint:topRightCornerPoint2
                                                  withRadius:0];

  CGPoint bottomRightCornerPoint1 = CGPointMake(textFieldWidth, sublayerMaxY);
  CGPoint bottomRightCornerPoint2 = CGPointMake(textFieldWidth, sublayerMaxY);
  [path addLineToPoint:bottomRightCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomRightCornerToPath:path
                                                      fromPoint:bottomRightCornerPoint1
                                                        toPoint:bottomRightCornerPoint2
                                                     withRadius:0];

  CGPoint bottomLeftCornerPoint1 = CGPointMake(0, sublayerMaxY);
  CGPoint bottomLeftCornerPoint2 = CGPointMake(0, sublayerMaxY);
  [path addLineToPoint:bottomLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addBottomLeftCornerToPath:path
                                                     fromPoint:bottomLeftCornerPoint1
                                                       toPoint:bottomLeftCornerPoint2
                                                    withRadius:0];

  CGPoint topLeftCornerPoint1 = CGPointMake(0, sublayerMinY);
  CGPoint topLeftCornerPoint2 = CGPointMake(0, sublayerMinY);
  [path addLineToPoint:topLeftCornerPoint1];
  [MDCContainerStylePathDrawingUtils addTopLeftCornerToPath:path
                                                  fromPoint:topLeftCornerPoint1
                                                    toPoint:topLeftCornerPoint2
                                                 withRadius:0];

  return path;
}

- (CGFloat)underlineThicknessForState:(UIControlState)state {
  if (self.isEditing || self.isErrored) {
    return 2;
  } else {
    return 1;
  }
}

- (CGRect)clearButtonFrameFromLayout:(MDCTextFieldLayout *)layout
                    placeholderState:(MDCContainedInputViewPlaceholderState)placeholderState {
  CGRect clearButtonFrame = layout.clearButtonFrame;
  if (placeholderState == MDCContainedInputViewPlaceholderStateFloating) {
    clearButtonFrame = layout.clearButtonFrameFloatingPlaceholder;
  }
  return clearButtonFrame;
}

- (MDCTextFieldLayout *)calculateLayoutWithTextFieldSize:(CGSize)textFieldSize {
  UIFont *effectiveFont = [self determineEffectiveFont];
  UIFont *floatingFont = [self floatingPlaceholderFontWithFont:effectiveFont];
  CGFloat normalizedCustomUnderlineLabelDrawPriority =
      [self normalizedCustomUnderlineLabelDrawPriority:self.customUnderlineLabelDrawPriority];
  return [[MDCTextFieldLayout alloc]
                  initWithTextFieldSize:textFieldSize
                                   text:self.text
                            placeholder:self.placeholder
                                   font:effectiveFont
                floatingPlaceholderFont:floatingFont
                    canPlaceholderFloat:self.labelFloats
                               leftView:self.leftView
                           leftViewMode:self.leftViewMode
                              rightView:self.rightView
                          rightViewMode:self.rightViewMode
                            clearButton:self.clearButton
                        clearButtonMode:self.clearButtonMode
                     leftUnderlineLabel:self.leftUnderlineLabel
                    rightUnderlineLabel:self.rightUnderlineLabel
             underlineLabelDrawPriority:self.underlineLabelDrawPriority
       customUnderlineLabelDrawPriority:normalizedCustomUnderlineLabelDrawPriority
         preferredMainContentAreaHeight:0
      preferredUnderlineLabelAreaHeight:0
                                  isRTL:self.isRTL
                              isEditing:self.isEditing];
}

- (CGFloat)normalizedCustomUnderlineLabelDrawPriority:(CGFloat)customPriority {
  CGFloat value = customPriority;
  if (value < 0) {
    value = 0;
  } else if (value > 1) {
    value = 1;
  }
  return value;
}

- (CGSize)preferredSizeWithWidth:(CGFloat)width {
  CGSize fittingSize = CGSizeMake(width, CGFLOAT_MAX);
  MDCTextFieldLayout *layout = [self calculateLayoutWithTextFieldSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

#pragma mark UITextField Accessor Overrides

- (void)setPlaceholder:(NSString *)placeholder {
  self.placeholderLabel.attributedText = nil;
  self.placeholderLabel.text = [placeholder copy];
}

- (NSString *)placeholder {
  return self.placeholderLabel.text;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
  self.placeholderLabel.text = [attributedPlaceholder string];
  self.placeholderLabel.attributedText = [attributedPlaceholder copy];
  // TODO: Actually support this by incorporating it into the layout calculations
}

- (NSAttributedString *)attributedPlaceholder {
  return self.placeholderLabel.attributedText;
}

- (void)setLeftViewMode:(UITextFieldViewMode)leftViewMode {
  NSLog(@"Setting leftViewMode is not recommended. Consider setting leadingViewMode and "
        @"trailingViewMode instead.");
  [self mdc_setLeftViewMode:leftViewMode];
}

- (void)setRightViewMode:(UITextFieldViewMode)rightViewMode {
  NSLog(@"Setting rightViewMode is not recommended. Consider setting leadingViewMode and "
        @"trailingViewMode instead.");
  [self mdc_setRightViewMode:rightViewMode];
}

- (void)setLeftView:(UIView *)leftView {
  NSLog(@"Setting rightView and leftView are not recommended. Consider setting leadingView and "
        @"trailingView instead.");
  [self mdc_setLeftView:leftView];
}

- (void)setRightView:(UIView *)rightView {
  NSLog(@"Setting rightView and leftView are not recommended. Consider setting leadingView and "
        @"trailingView instead.");
  [self mdc_setRightView:rightView];
}

#pragma mark Custom Accessors

- (UILabel *)leadingUnderlineLabel {
  if ([self isRTL]) {
    return self.rightUnderlineLabel;
  } else {
    return self.leftUnderlineLabel;
  }
}

- (UILabel *)trailingUnderlineLabel {
  if ([self isRTL]) {
    return self.leftUnderlineLabel;
  } else {
    return self.rightUnderlineLabel;
  }
}

- (void)setTrailingView:(UIView *)trailingView {
  if ([self isRTL]) {
    [self mdc_setLeftView:trailingView];
  } else {
    [self mdc_setRightView:trailingView];
  }
}

- (UIView *)trailingView {
  if ([self isRTL]) {
    return self.leftView;
  } else {
    return self.rightView;
  }
}

- (void)setLeadingView:(UIView *)leadingView {
  if ([self isRTL]) {
    [self mdc_setRightView:leadingView];
  } else {
    [self mdc_setLeftView:leadingView];
  }
}

- (UIView *)leadingView {
  if ([self isRTL]) {
    return self.rightView;
  } else {
    return self.leftView;
  }
}

- (void)mdc_setLeftView:(UIView *)leftView {
  [super setLeftView:leftView];
  // TODO: Determine if a call to setNeedsLayout is necessary or if super calls it
}

- (void)mdc_setRightView:(UIView *)rightView {
  [super setRightView:rightView];
  // TODO: Determine if a call to setNeedsLayout is necessary or if super calls it
}

- (void)setTrailingViewMode:(UITextFieldViewMode)trailingViewMode {
  if ([self isRTL]) {
    [self mdc_setLeftViewMode:trailingViewMode];
  } else {
    [self mdc_setRightViewMode:trailingViewMode];
  }
}

- (UITextFieldViewMode)trailingViewMode {
  if ([self isRTL]) {
    return self.leftViewMode;
  } else {
    return self.rightViewMode;
  }
}

- (void)setLeadingViewMode:(UITextFieldViewMode)leadingViewMode {
  if ([self isRTL]) {
    [self mdc_setRightViewMode:leadingViewMode];
  } else {
    [self mdc_setLeftViewMode:leadingViewMode];
  }
}

- (UITextFieldViewMode)leadingViewMode {
  if ([self isRTL]) {
    return self.rightViewMode;
  } else {
    return self.leftViewMode;
  }
}

- (void)mdc_setLeftViewMode:(UITextFieldViewMode)leftViewMode {
  [super setLeftViewMode:leftViewMode];
}

- (void)mdc_setRightViewMode:(UITextFieldViewMode)rightViewMode {
  [super setRightViewMode:rightViewMode];
}

- (void)setLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection {
  if (_layoutDirection == layoutDirection) {
    return;
  }
  _layoutDirection = layoutDirection;
  [self setNeedsLayout];
}

- (void)setLabelFloats:(BOOL)labelFloats {
  if (_labelFloats == labelFloats) {
    return;
  }
  _labelFloats = labelFloats;
  [self setNeedsLayout];
}

- (CGRect)textRectFromLayout:(MDCTextFieldLayout *)layout
            placeholderState:(MDCContainedInputViewPlaceholderState)placeholderState {
  CGRect textRect = layout.textRect;
  if (placeholderState == MDCContainedInputViewPlaceholderStateFloating) {
    textRect = layout.textRectFloatingPlaceholder;
  }
  return textRect;
}

- (CGRect)adjustTextAreaFrame:(CGRect)textRect
    withParentClassTextAreaFrame:(CGRect)parentClassTextAreaFrame {
  CGFloat systemDefinedHeight = CGRectGetHeight(parentClassTextAreaFrame);
  CGFloat minY = CGRectGetMidY(textRect) - (systemDefinedHeight * (CGFloat)0.5);
  return CGRectMake(CGRectGetMinX(textRect), minY, CGRectGetWidth(textRect), systemDefinedHeight);
}

- (CGRect)containerRect {
  return CGRectMake(0, 0, CGRectGetWidth(self.frame), self.layout.topRowBottomRowDividerY);
}

#pragma mark UITextField Layout Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout placeholderState:self.placeholderState];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super textRectForBounds:bounds]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout placeholderState:self.placeholderState];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super editingRectForBounds:bounds]];
}

// The implementations for this method and the method below deserve some context! Unfortunately,
// Apple's RTL behavior with these methods is very unintuitive. Imagine you're in an RTL locale and
// you set @c leftView on a standard UITextField. Even though the property that you set is called @c
// leftView, the method @c -rightViewRectForBounds: will be called. They are treating @c leftView as
// @c rightView, even though @c rightView is nil. It's bonkers.
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  if ([self isRTL]) {
    return self.layout.rightViewFrame;
  } else {
    return self.layout.leftViewFrame;
  }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  if ([self isRTL]) {
    return self.layout.leftViewFrame;
  } else {
    return self.layout.rightViewFrame;
  }
}

- (CGRect)borderRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
  return CGRectZero;
}

#pragma mark Fonts

- (UIFont *)determineEffectiveFont {
  return self.font ?: [self uiTextFieldDefaultFont];
}

- (UIFont *)uiTextFieldDefaultFont {
  static dispatch_once_t onceToken;
  static UIFont *font;
  dispatch_once(&onceToken, ^{
    font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
  });
  return font;
}

#pragma mark Text Field State

- (MDCContainedInputViewState)determineCurrentContainedInputViewState {
  return [self containedInputViewStateWithIsEnabled:self.isEnabled
                                          isErrored:self.isErrored
                                          isEditing:self.isEditing
                                         isSelected:self.isSelected
                                        isActivated:self.isActivated];
}

- (MDCContainedInputViewState)containedInputViewStateWithIsEnabled:(BOOL)isEnabled
                                                         isErrored:(BOOL)isErrored
                                                         isEditing:(BOOL)isEditing
                                                        isSelected:(BOOL)isSelected
                                                       isActivated:(BOOL)isActivated {
  if (isEnabled) {
    if (isErrored) {
      return MDCContainedInputViewStateErrored;
    } else {
      if (isEditing) {
        return MDCContainedInputViewStateFocused;
      } else {
        if (isSelected || isActivated) {
          return MDCContainedInputViewStateActivated;
        } else {
          return MDCContainedInputViewStateNormal;
        }
      }
    }
  } else {
    return MDCContainedInputViewStateDisabled;
  }
}

#pragma mark Clear Button

- (UIImage *)untintedClearButtonImage {
  CGFloat sideLength = MDCTextFieldLayout.clearButtonImageViewSideLength;
  CGRect rect = CGRectMake(0, 0, sideLength, sideLength);
  UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
  [[UIColor blackColor] setFill];
  [[MDCContainerStylePathDrawingUtils pathForClearButtonImageWithFrame:rect] fill];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  return image;
}

#pragma mark Placeholder

- (MDCContainedInputViewPlaceholderState)determineCurrentPlaceholderState {
  return [self placeholderStateWithPlaceholder:self.placeholder
                                          text:self.text
                                   labelFloats:self.labelFloats
                                     isEditing:self.isEditing];
}

- (MDCContainedInputViewPlaceholderState)placeholderStateWithPlaceholder:(NSString *)placeholder
                                                                    text:(NSString *)text
                                                             labelFloats:(BOOL)labelFloats
                                                               isEditing:(BOOL)isEditing {
  BOOL hasPlaceholder = placeholder.length > 0;
  BOOL hasText = text.length > 0;
  if (hasPlaceholder) {
    if (labelFloats) {
      if (isEditing) {
        return MDCContainedInputViewPlaceholderStateFloating;
      } else {
        if (hasText) {
          return MDCContainedInputViewPlaceholderStateFloating;
        } else {
          return MDCContainedInputViewPlaceholderStateNormal;
        }
      }
    } else {
      if (hasText) {
        return MDCContainedInputViewPlaceholderStateNone;
      } else {
        return MDCContainedInputViewPlaceholderStateNormal;
      }
    }
  } else {
    return MDCContainedInputViewPlaceholderStateNone;
  }
}

- (void)layOutPlaceholderWithState:(MDCContainedInputViewPlaceholderState)placeholderState
                        normalFont:(UIFont *)normalFont
                      floatingFont:(UIFont *)floatingFont {
  UIFont *targetFont = normalFont;

  CGRect currentFrame = self.placeholderLabel.frame;
  CGRect normalFrame = self.layout.placeholderFrameNormal;
  CGRect floatingFrame = self.layout.placeholderFrameFloating;
  CGRect targetFrame = normalFrame;

  BOOL placeholderShouldHide = NO;

  switch (placeholderState) {
    case MDCContainedInputViewPlaceholderStateFloating:
      targetFont = floatingFont;
      targetFrame = floatingFrame;
      break;
    case MDCContainedInputViewPlaceholderStateNormal:
      break;
    case MDCContainedInputViewPlaceholderStateNone:
      placeholderShouldHide = YES;
      break;
    default:
      break;
  }

  CGAffineTransform currentTransform = self.placeholderLabel.transform;
  CGAffineTransform targetTransform = CGAffineTransformIdentity;

  if (self.isAnimating || CGRectEqualToRect(currentFrame, CGRectZero)) {
    self.placeholderLabel.transform = CGAffineTransformIdentity;
    self.placeholderLabel.frame = targetFrame;
    self.placeholderLabel.font = targetFont;
    return;
  } else if (!CGRectEqualToRect(currentFrame, targetFrame)) {
    targetTransform = [self transformFromRect:currentFrame toRect:targetFrame];
  }

  self.isAnimating = YES;
  self.placeholderLabel.hidden = placeholderShouldHide;

  CGFloat lowerMinY = MIN(CGRectGetMinY(currentFrame), CGRectGetMinY(targetFrame));
  CGFloat higherMinY = MAX(CGRectGetMinY(currentFrame), CGRectGetMinY(targetFrame));
  CGFloat distanceTravelled = higherMinY - lowerMinY;
  CGFloat animationDuration =
      distanceTravelled / kFloatingPlaceholderAnimationVelocityInPointsPerSecond;

  __weak typeof(self) weakSelf = self;
  [CATransaction begin];
  {
    [CATransaction setCompletionBlock:^{
      weakSelf.placeholderLabel.transform = CGAffineTransformIdentity;
      weakSelf.placeholderLabel.frame = targetFrame;
      weakSelf.placeholderLabel.font = targetFont;
      weakSelf.isAnimating = NO;
    }];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue =
        [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(currentTransform)];
    animation.toValue =
        [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(targetTransform)];
    animation.duration = animationDuration;
    animation.removedOnCompletion = YES;
    weakSelf.placeholderLabel.transform = targetTransform;
    [weakSelf.placeholderLabel.layer addAnimation:animation forKey:animation.keyPath];
  }
  [CATransaction commit];
}

- (CGAffineTransform)transformFromRect:(CGRect)sourceRect toRect:(CGRect)finalRect {
  CGAffineTransform transform = CGAffineTransformIdentity;
  transform =
      CGAffineTransformTranslate(transform, -(CGRectGetMidX(sourceRect) - CGRectGetMidX(finalRect)),
                                 -(CGRectGetMidY(sourceRect) - CGRectGetMidY(finalRect)));
  transform = CGAffineTransformScale(transform, finalRect.size.width / sourceRect.size.width,
                                     finalRect.size.height / sourceRect.size.height);

  return transform;
}

- (UIFont *)floatingPlaceholderFontWithFont:(UIFont *)font {
  CGFloat scaleFactor = ((CGFloat)53 / (CGFloat)71);
  CGFloat floatingPlaceholderFontSize = scaleFactor * [UIFont systemFontSize];
  return [font fontWithSize:floatingPlaceholderFontSize];
}

#pragma mark User Actions

- (void)clearButtonPressed:(UIButton *)clearButton {
  self.text = nil;
  // TODO: I'm pretty sure there is a control event or notification UITextField sens or posts here.
  // Add it!
}

#pragma mark Internationalization

- (BOOL)isRTL {
  return self.layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

@end
