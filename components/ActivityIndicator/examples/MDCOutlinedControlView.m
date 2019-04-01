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

#import "MDCOutlinedControlView.h"

static const UIEdgeInsets kControlInsets = {14, 14, 14, 14};

@implementation MDCOutlinedControlView {
  UIView *_outlineView;
  UIView *_outlineHoleView;
}

@synthesize outlineColor = _outlineColor;

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];

    _contentView = contentView;

    _outlineView = [[UIView alloc] initWithFrame:self.bounds];
    _outlineView.userInteractionEnabled = YES;
    _outlineView.layer.borderWidth = 2;
    _outlineView.layer.cornerRadius = 4;
    _outlineView.layer.borderColor = [UIColor blueColor].CGColor;
    _contentView.frame = _outlineView.bounds;

    [self addSubview:_outlineView];
    [_outlineView addSubview:_contentView];

    // TODO: Properly render the border + hole.
    _outlineHoleView = [[UIView alloc] init];
    [self addSubview:_outlineHoleView];

    _floatingLabel = [[UILabel alloc] init];
    _floatingLabel.hidden = YES; // Hidden until focused.
    if (@available(iOS 8.2, *)) {
      _floatingLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
    }
    _floatingLabel.backgroundColor = self.backgroundColor;
    _floatingLabel.textAlignment = NSTextAlignmentCenter;
    _leadingUnderlineLabel = [[UILabel alloc] init];
    _trailingUnderlineLabel = [[UILabel alloc] init];
    [self addSubview:_floatingLabel];
    [self addSubview:_leadingUnderlineLabel];
    [self addSubview:_trailingUnderlineLabel];

    // TODO: Extract this logic out to a behavior-binding object via delegate.
    if ([_contentView isKindOfClass:[UIControl class]]) {
      UIControl *control = (UIControl *)_contentView;
      [control addTarget:self
                  action:@selector(controlEditingDidBegin)
        forControlEvents:UIControlEventEditingDidBegin];
      [control addTarget:self
                  action:@selector(controlEditingDidEnd)
        forControlEvents:UIControlEventEditingDidEnd];

    } else if ([_contentView isKindOfClass:[UITextView class]]) {
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(controlEditingDidBegin)
                                                   name:UITextViewTextDidBeginEditingNotification
                                                 object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(controlEditingDidEnd)
                                                   name:UITextViewTextDidEndEditingNotification
                                                 object:nil];

    }
  }
  return self;
}

#pragma mark - Control events

- (void)controlEditingDidBegin {
  _floatingLabel.hidden = NO;
}

- (void)controlEditingDidEnd {
  if ([_contentView isKindOfClass:[UITextField class]]) {
    UITextField *textField = (UITextField *)_contentView;
    _floatingLabel.hidden = textField.text.length == 0;
  } else if ([_contentView isKindOfClass:[UITextView class]]) {
    UITextView *textView = (UITextView *)_contentView;
    _floatingLabel.hidden = textView.text.length == 0;
  } else {
    _floatingLabel.hidden = YES;
  }
}

#pragma mark - Touch forwarding

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *view = [super hitTest:point withEvent:event];
  if (view == _outlineView) {
    return _contentView;
  }
  return view;
}

#pragma mark - Layout

- (void)layoutSubviews {
  [super layoutSubviews];

  if (_floatingLabel.text != nil) {
    CGFloat topLineWidth = self.bounds.size.width - _outlineView.layer.cornerRadius * 2;
    CGSize floatingLabelSize = [_floatingLabel sizeThatFits:CGSizeMake(topLineWidth, CGFLOAT_MAX)];
    _floatingLabel.frame = CGRectMake(_outlineView.layer.cornerRadius + 6,
                                      (CGFloat)floorf((float)(-floatingLabelSize.height / 2.)) + 2,
                                      floatingLabelSize.width + 8, floatingLabelSize.height);
  }

  _outlineView.frame = self.bounds;
  _contentView.frame = UIEdgeInsetsInsetRect(_outlineView.bounds, kControlInsets);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize calculatedSize = CGSizeMake(size.width, kControlInsets.top + kControlInsets.bottom);
  calculatedSize.height += [_contentView sizeThatFits:CGSizeMake(size.width - kControlInsets.left - kControlInsets.right,
                                                                 size.height)].height;
  return calculatedSize;
}

#pragma mark - Public

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];

  _floatingLabel.backgroundColor = backgroundColor;
}

- (void)setOutlineColor:(UIColor *)outlineColor {
  _outlineColor = outlineColor;

  _outlineView.layer.borderColor = outlineColor.CGColor;
}

- (void)setOutlineCornerRadius:(CGFloat)outlineCornerRadius {
  _outlineView.layer.cornerRadius = outlineCornerRadius;
}

- (CGFloat)outlineCornerRadius {
  return _outlineView.layer.cornerRadius;
}

@end
