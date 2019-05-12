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

#import "MDCContainerScheme.h"

@interface MDCContainerSchemeProxy<T: id<NSObject>> : NSProxy

- (void)applyInvocationsToInstance:(nonnull T)instance;

@end

@implementation MDCContainerSchemeProxy {
  NSMutableArray<NSInvocation *> *_invocations;
  Class _aClass;
}

- (instancetype)initWithClass:(Class)aClass {
  _invocations = [NSMutableArray array];
  _aClass = aClass;
  return self;
}

+ (id<NSObject>)proxyWithClass:(Class)aClass {
  return [[MDCContainerSchemeProxy alloc] initWithClass:aClass];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  return [_aClass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [_invocations addObject:invocation];
}

- (void)applyInvocationsToInstance:(nonnull id<NSObject>)instance {
  for (NSInvocation *invocation in _invocations) {
    [invocation invokeWithTarget:instance];
  }
}

@end

@implementation MDCContainerScheme {
  NSMapTable<Class, MDCContainerSchemeProxy *> *_classProxies;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _classProxies = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsOpaquePersonality)
                                          valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)];

    _colorScheme =
        [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201804];
    _typographyScheme =
        [[MDCTypographyScheme alloc] initWithDefaults:MDCTypographySchemeDefaultsMaterial201804];
  }
  return self;
}

- (nonnull id)proxyForClass:(nonnull Class)aClass {
  id proxy = [_classProxies objectForKey:aClass];
  if (!proxy) {
    proxy = [[MDCContainerSchemeProxy alloc] initWithClass:aClass];
    [_classProxies setObject:proxy forKey:aClass];
  }
  return proxy;
}

- (void)applyProxyInvocationsToInstance:(id)instance {
  Class iterator = [instance class];
  NSMutableArray *hierarchy = [NSMutableArray array];
  while (iterator) {
    [hierarchy addObject:iterator];
    iterator = [iterator superclass];
  }

  for (Class aClass in [hierarchy reverseObjectEnumerator]) {
    [[_classProxies objectForKey:aClass] applyInvocationsToInstance:instance];
  }
}

@end
