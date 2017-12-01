/*
 Copyright 201&-present the Material Components for iOS authors. All Rights Reserved.

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

#import <Foundation/Foundation.h>
#import <MotionInterchange/MotionInterchange.h>

// This macro is introduced in Xcode 9.
#ifndef CF_TYPED_ENUM // What follows is backwards compat for Xcode 8 and below.
#if __has_attribute(swift_wrapper)
#define CF_TYPED_ENUM __attribute__((swift_wrapper(enum)))
#else
#define CF_TYPED_ENUM
#endif
#endif

/**
 A representation of a Material Design motion curve.
 */
typedef MDMMotionCurve MDCMotionCurve CF_TYPED_ENUM;

/**
 This is the most frequently used interpolation curve for Material Design animations. This curve
 is slow both at the beginning and end. It has similar characteristics to the system's EaseInOut.
 */
FOUNDATION_EXPORT const MDCMotionCurve MDCMotionCurveStandard;

/**
 This curve should be used for motion when entering frame or when fading in from 0% opacity. This
 curve is slow at the end. It has similar characteristics to the system's EaseOut.
 */
FOUNDATION_EXPORT const MDCMotionCurve MDCMotionCurveDeceleration;

/**
 This curve should be used for motion when exiting frame or when fading out to 0% opacity. This
 curve is slow at the beginning. It has similar characteristics to the system's EaseIn.
 */
FOUNDATION_EXPORT const MDCMotionCurve MDCMotionCurveAcceleration;

/**
 This curve should be used for motion when elements quickly accelerate and decelerate. It is
 used by exiting elements that may return to the screen at any time. The deceleration is
 faster than the standard curve since it doesn't follow an exact path to the off-screen point.
 */
FOUNDATION_EXPORT const MDCMotionCurve MDCMotionCurveSharp;

