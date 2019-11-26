# HC Garden UI

The user interface for HC Garden, with the bottom sheet, flora & fauna pages, and more.

## TODOs

### High Priority

#### All Pages
- Tapping on the info row should also expand the bottom sheet fully

#### Trail Location Overview Page
- ~~Better animated circles (TS)~~ ✔️
- ~~Fauna circles: Display image within circle as well (TS)~~ ✔️

#### Firebase Data (TS)
- Filter out invalid data from Firebase (e.g. MISSING INFO)
- Ensure app is resilient even if there is invalid data and no red screen of death within the app
- ~~Sort the data for trails better~~ ✔️

#### Map Markers
- ~~Green markers depending on which page the user is on to show the current location(s)~~ ✔️
- Going to location should also focus on the marker (need wait for package update)
- Marker window should also contain image (need wait for package update)

#### Onboarding (TS?)
- Onboarding tutorial on how to use the apps
	- Overlays, ability to skip, able to access from settings

#### Sorting
- Sorting by distance (TS)
- Different types of fauna

#### Breadcrumb Navigation
- Breadcrumbs in the bottom app bar when going to different pages, to indicate navigation history, and also easily go back home
- Rough plan: Use AnimatedList to animate new active breadcrumb into view, Integrate AnimatedListState methods into AppNotifier push and pop methods, Use TextPainter to calculate padding needed to centralise active breadcrumb.

### Medium Priority

#### History Screen
- Update to new design as suggested by Dr Chia

#### About Screen
- Update to whatever new design suggested

### Low Priority

#### Search
- Search should be unified for both flora and fauna
- Search should perhaps highlight the searchTerm within the name for clarity

#### Map
- Highlight buildings on map, correct colour selection (high school/college) (Galen)
- Improved dark theme

#### Offline Mode
- Users can still use the app offline

#### Image Zooming
- Make use of upcoming pan and zoom widget (https://github.com/flutter/flutter/issues/12878)

#### Trail Location Overview Page
- Zooming of image/Ability to expand image size (Quite hard)

## Bugs

### High Priority
- Map bottom padding sometimes does not update when collapsing the bottom sheet

### Medium Priority
- Images in EntityListPage sometimes flicker when opening entity's DetailsPage

## Future Improvements

### Possible
- Images should not use a new cache, but somehow utilise ImageCache instead. Make use of ImageProvider to place images directly in ImageCache.
- ExpandPageRouteTransition can be simplified greatly, and also figure out how to properly use Heroes to animate the Entity thumbnail to the DetailsPage. (Update: finally found out why heroes do not work: https://github.com/flutter/flutter/issues/25261, heroes now work!)

### Possible but very hard
- Tablet support
- Web support

### Far Future
- Should there be a Google Maps for Dart SDK in the future, migrate to it asap.
