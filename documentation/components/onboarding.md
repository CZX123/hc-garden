# Onboarding

## Introduction

As with most onboarding experiences, the onboarding pages are basically hard-coded, so There are 6 pages in total,  each of which has either static and dynamic components, or both. To layer one widget over another, a [stack](https://api.flutter.dev/flutter/widgets/Stack-class.html) is used. 

## Contents

- [Static Components](#static-components)
- [Dynamic Components](#dynamic-components)

## Relevant Files

- [/lib/src/screens/onboarding/onboarding.dart](/lib/src/screens/onboarding/onboarding.dart)

## Static Components

Static components are widgets displayed in the onboarding pages that **remain stationery with respect to the page** (i.e. they stick to the page). This is essentially the conventional scrolling system - the contents are on the pages, and they move left or right based on your scrolling. 

As evident from the code below, there are three pages which contain static components, namely pages 1, 2 and 6. 

```dart
if (index == 0)
    return _OnboardingPageOne();
else if (index == 1)
    return _OnboardingPageTwo();
else if (index == 5) return _OnboardingPageSix();
    return SizedBox.shrink()
```

Pages 1 & 6 are completely static, whilst (as you will see in [Dynamic Components](#dynamic-components)) page 2 has both static (the text) and dynamic (the screenshot) components. 

## Dynamic Components

On the contrary, dynamic components are widgets which can be **animated freely** without necessarily having to follow the page it is stuck to. 

For the purposes of onboarding and aesthetics, however, the components are animated to follow the horizontal scrolling of the 


