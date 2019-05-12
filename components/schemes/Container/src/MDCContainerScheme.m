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
  [invocation retainArguments];
  [_invocations addObject:invocation];
}

- (void)applyInvocationsToInstance:(nonnull id<NSObject>)instance {
  for (NSInvocation *invocation in _invocations) {
    [invocation invokeWithTarget:instance];
  }
}

@end

@interface MDCContainerSchemeThemeInfo : NSObject
@property(nonatomic, strong, readonly) MDCContainerSchemeProxy *theme;
@property(nonatomic, strong, readonly) NSMapTable<NSString *, MDCContainerSchemeProxy *> *namedThemes;

- (instancetype)init NS_UNAVAILABLE;

@end

@implementation MDCContainerSchemeThemeInfo {
  Class _aClass;
}

@synthesize theme = _theme;
@synthesize namedThemes = _namedThemes;

- (instancetype)initWithClass:(nonnull Class)aClass {
  self = [super init];
  if (self) {
    _aClass = aClass;
  }
  return self;
}

- (NSMapTable<NSString *,MDCContainerSchemeProxy *> *)namedThemes {
  if (!_namedThemes) {
    _namedThemes = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                         valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)];
  }
  return _namedThemes;
}

- (MDCContainerSchemeProxy *)theme {
  if (!_theme) {
    _theme = [[MDCContainerSchemeProxy alloc] initWithClass:_aClass];
  }
  return _theme;
}

@end

@implementation MDCContainerScheme {
  NSMapTable<Class, MDCContainerSchemeThemeInfo *> *_themeInfo;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _themeInfo = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsOpaquePersonality)
                                       valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)];

    _colorScheme =
        [[MDCSemanticColorScheme alloc] initWithDefaults:MDCColorSchemeDefaultsMaterial201804];
    _typographyScheme =
        [[MDCTypographyScheme alloc] initWithDefaults:MDCTypographySchemeDefaultsMaterial201804];
  }
  return self;
}

- (MDCContainerSchemeThemeInfo *)themeInfoForClass:(nonnull Class)aClass {
  id info = [_themeInfo objectForKey:aClass];
  if (!info) {
    info = [[MDCContainerSchemeThemeInfo alloc] initWithClass:aClass];
    [_themeInfo setObject:info forKey:aClass];
  }
  return info;
}

- (nonnull id)themeForClass:(nonnull Class)aClass {
  return [self themeInfoForClass:aClass].theme;
}

- (nonnull id)themeNamed:(nonnull NSString *)name forClass:(nonnull Class)aClass {
  NSMapTable<NSString *, MDCContainerSchemeProxy *> * namedThemes = [self themeInfoForClass:aClass].namedThemes;
  id theme = [namedThemes objectForKey:name];
  if (!theme) {
    theme = [[MDCContainerSchemeProxy alloc] initWithClass:aClass];
    [namedThemes setObject:theme forKey:name];
  }
  return theme;
}

- (NSEnumerator<Class> *)hierarchyForClass:(Class)aClass {
  NSMutableArray *hierarchy = [NSMutableArray array];

  Class iterator = aClass;
  while (iterator) {
    [hierarchy addObject:iterator];
    iterator = [iterator superclass];
  }

  return[hierarchy reverseObjectEnumerator];
}

- (void)applyThemeToObject:(id)object {
  for (Class aClass in [self hierarchyForClass:[object class]]) {
    [[self themeForClass:aClass] applyInvocationsToInstance:object];
  }
}

- (void)applyThemeNamed:(nonnull NSString *)name toObject:(nonnull id)object {
  for (Class aClass in [self hierarchyForClass:[object class]]) {
    [[self themeNamed:name forClass:aClass] applyInvocationsToInstance:object];
  }
}

@end
