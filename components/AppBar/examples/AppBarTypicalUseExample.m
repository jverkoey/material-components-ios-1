/*
 Copyright 2016-present the Material Components for iOS authors. All Rights Reserved.

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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "MaterialAppBar.h"
#import "MaterialAppBar+ColorThemer.h"
#import "MaterialAppBar+TypographyThemer.h"

@interface AppBarTypicalUseExample : UIViewController

// Step 1: Create an App Bar.
@property(nonatomic, strong) MDCAppBar *appBar;
@property(nonatomic, strong) MDCSemanticColorScheme *colorScheme;
@property(nonatomic, strong) MDCTypographyScheme *typographyScheme;

@end

@implementation AppBarTypicalUseExample

- (void)dealloc {
  // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
  self.appBar.headerViewController.headerView.trackingScrollView = nil;
}

- (id)init {
  self = [super init];
  if (self) {
    self.title = @"App Bar";

    // Step 2: Initialize the App Bar and add the headerViewController as a child.
    _appBar = [[MDCAppBar alloc] init];

    // Behavioral flags.
    _appBar.inferTopSafeAreaInsetFromViewController = YES;
    _appBar.headerViewController.topLayoutGuideViewController = self;
    _appBar.headerViewController.headerView.minMaxHeightIncludesSafeArea = NO;
    // Allows us to avoid forwarding events, but means we can't enable shift behaviors.
    _appBar.headerViewController.headerView.observesTrackingScrollViewScrollEvents = YES;

    _appBar.headerViewController.useAdditionalSafeAreaInsetsAPIs = YES;

    [self addChildViewController:_appBar.headerViewController];

    _appBar.navigationBar.inkColor = [UIColor colorWithWhite:0.9f alpha:0.1f];

    self.colorScheme = [[MDCSemanticColorScheme alloc] init];
    self.typographyScheme = [[MDCTypographyScheme alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [MDCAppBarColorThemer applySemanticColorScheme:self.colorScheme toAppBar:_appBar];
  [MDCAppBarTypographyThemer applyTypographyScheme:self.typographyScheme toAppBar:_appBar];

  // Need to update the status bar style after applying the theme.
  [self setNeedsStatusBarAppearanceUpdate];

  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
  [self.view addSubview:webView];

  NSURL *url = [NSURL URLWithString:@"http://localhost:8000"];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [webView loadRequest:request];

#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
  if (@available(iOS 11.0, *)) {
    // No need to do anything - additionalSafeAreaInsets will inset our content.
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  } else {
#endif
  webView.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:
   @[[NSLayoutConstraint constraintWithItem:webView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.topLayoutGuide
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:webView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:webView
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1.0
                                   constant:0],
     [NSLayoutConstraint constraintWithItem:webView
                                  attribute:NSLayoutAttributeRight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeRight
                                 multiplier:1.0
                                   constant:0]
     ]];
#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
  }
#endif
  // Recommended step: Set the tracking scroll view.
  self.appBar.headerViewController.headerView.trackingScrollView = webView.scrollView;

  // Step 3: Register the App Bar views.
  [self.appBar addSubviewsToParent];

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil];
}

// Optional step: If you allow the header view to hide the status bar you must implement this
//                method and return the headerViewController.
- (UIViewController *)childViewControllerForStatusBarHidden {
  return self.appBar.headerViewController;
}

// Optional step: The Header View Controller does basic inspection of the header view's background
//                color to identify whether the status bar should be light or dark-themed.
- (UIViewController *)childViewControllerForStatusBarStyle {
  return self.appBar.headerViewController;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end

@implementation AppBarTypicalUseExample (CatalogByConvention)

+ (NSArray *)catalogBreadcrumbs {
  return @[ @"App Bar", @"App Bar" ];
}

+ (NSString *)catalogDescription {
  return @"The top app bar displays information and actions relating to the current view.";
}

+ (BOOL)catalogIsPrimaryDemo {
  return YES;
}

- (BOOL)catalogShouldHideNavigation {
  return YES;
}

+ (BOOL)catalogIsPresentable {
  return YES;
}

@end
