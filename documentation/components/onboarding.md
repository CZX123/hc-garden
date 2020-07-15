# Onboarding

## Contents

- [Introduction](#introduction)
- [Static Pages](#static-pages)

## Relevant Files

- [/lib/src/screens/onboarding/onboarding.dart](/lib/src/screens/onboarding/onboarding.dart)

## Introduction

As with most onboarding experiences, the onboarding pages are basically hard-coded. There are 6 pages in total,  each of which has either static and dynamic components, or both. To layer one widget over another, a [stack](https://api.flutter.dev/flutter/widgets/Stack-class.html) is used. 

## Static Pages

As you might be able to glean from the code below, there are three pages which have static components, namely pages 1, 2 and 6. 

```dart
if (index == 0)
    return _OnboardingPageOne();
else if (index == 1)
    return _OnboardingPageTwo();
else if (index == 5) return _OnboardingPageSix();
    return SizedBox.shrink()
```


