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

#import <UIKit/UIKit.h>

#import "MaterialSlider.h"
#import "MDCColorScheme.h"

/**
 Used to apply a color scheme to theme MDCSlider.
 */
@interface MDCSliderColorThemer : NSObject

/**
 Applies a color scheme to theme a MDCSlider.
 
 @param colorScheme The color scheme to apply to MDCSlider.
 @param slider A MDCSlider instance to apply a color scheme. Use a UIAppearance proxy to apply a
     color scheme to all instances of MDCSlider.
 */
+ (void)applyColorScheme:(MDCColorScheme *)colorScheme
                toSlider:(MDCSlider *)slider;

@end
