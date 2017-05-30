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

#import "MDCMaskedTransitionMotion.h"

#define MDMEightyForty {0.4f, 0.0f, 0.2f, 1.0f}
#define MDMFortyOut {0.4f, 0.0f, 1.0f, 1.0f}
#define MDMEightyIn {0.0f, 0.0f, 0.2f, 1.0f}

struct MDCMaskedTransitionMotion fullscreenExpansion = {
  .contentFade = {
    .delay = 0.150, .duration = 0.225, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.000, .duration = 0.075, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.000, .duration = 0.105, .controlPoints = MDMFortyOut,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = MDMNoTiming,
  .verticalMovement = {
    .delay = 0.045, .duration = 0.330, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = false
};

struct MDCMaskedTransitionMotion bottomSheetExpansion = {
  .contentFade = { // No spec for this
    .delay = 0.100, .duration = 0.200, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.000, .duration = 0.075, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.000, .duration = 0.105, .controlPoints = MDMFortyOut,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = MDMNoTiming,
  .verticalMovement = {
    .delay = 0.045, .duration = 0.330, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = false
};

struct MDCMaskedTransitionMotion bottomCardExpansion = {
  .contentFade = {
    .delay = 0.150, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.075, .duration = 0.075, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.045, .duration = 0.225, .controlPoints = MDMFortyOut,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "position.x",
  },
  .verticalMovement = {
    .delay = 0.000, .duration = 0.345, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.075, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = true
};

struct MDCMaskedTransitionMotion bottomCardCollapse = {
  .contentFade = {
    .delay = 0.000, .duration = 0.075, .controlPoints = MDMFortyOut,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.060, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.000, .duration = 0.180, .controlPoints = MDMEightyIn,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = {
    .delay = 0.045, .duration = 0.255, .controlPoints = MDMEightyForty,
    .keyPath = "position.x",
  },
  .verticalMovement = {
    .delay = 0.000, .duration = 0.255, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = true
};

struct MDCMaskedTransitionMotion toolbarExpansion = {
  .contentFade = {
    .delay = 0.150, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.075, .duration = 0.075, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.045, .duration = 0.225, .controlPoints = MDMFortyOut,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = {
    .delay = 0.000, .duration = 0.300, .controlPoints = MDMEightyForty,
    .keyPath = "position.x",
  },
  .verticalMovement = {
    .delay = 0.000, .duration = 0.120, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.075, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = true
};

struct MDCMaskedTransitionMotion toolbarCollapse = {
  .contentFade = {
    .delay = 0.000, .duration = 0.075, .controlPoints = MDMFortyOut,
    .keyPath = "opacity",
  },
  .floodBackgroundColor = {
    .delay = 0.060, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "backgroundColor",
  },
  .maskTransformation = {
    .delay = 0.000, .duration = 0.180, .controlPoints = MDMEightyIn,
    .keyPath = "transform.scale.xy",
  },
  .horizontalMovement = {
    .delay = 0.105, .duration = 0.195, .controlPoints = MDMEightyForty,
    .keyPath = "position.x",
  },
  .verticalMovement = {
    .delay = 0.000, .duration = 0.255, .controlPoints = MDMEightyForty,
    .keyPath = "position.y",
  },
  .scrimFade = {
    .delay = 0.000, .duration = 0.150, .controlPoints = MDMEightyForty,
    .keyPath = "opacity",
  },
  .isCentered = true
};
