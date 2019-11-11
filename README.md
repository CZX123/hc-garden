# HC Garden UI

The user interface for HC Garden, with the bottom sheet, flora & fauna pages, and more.

## TODOs

### Branding
- App Icon
- App Loading Screen
- App Logo should be bigger

### Search
- Search should be unified for both flora and fauna
- Search should perhaps highlight the searchTerm within the name for clarity

### Sorting
- Sorting by trails, distance
- Different types of fauna

### Onboarding
- Onboarding tutorial on how to use the app
	- Overlays, ability to skip, able to access from settings

### Trails
- TrailDetailsScreen: List of locations in a trail
- TrailLocationOverviewScreen: Image with animated circles
- Linking between map marker and TrailLocationOverviewScreen
	- Require careful organisation of the Navigator stack

### Other Screens
- ~~HistoryScreen~~
- ~~Introduction, CommitteeMessage, Acknowledgements, References~~

### Map
- Going to location from EntityDetailsPage should also focus on the marker (need wait for package update)
- Marker window should also contain image (need wait for package update)
- Highlight buildings on map, correct colour selection

## Bugs

### High Priority

- ScrollController bug when switching between entity list and details page after searching
- ~~Map Widget frequently gets stuck~~ _Not solveable_

### Medium Priority

- Images in EntityListPage sometimes flicker when opening entity's DetailsPage
- Slight flicker/lag when opening and closing keyboard, making search slightly unsightly

### Low Priority

- Improve hero animation when going back from details page to EntityListPage

## Future Improvements

### Possible
- Images should not use a new cache, but somehow utilise ImageCache instead. Make use of ImageProvider to place images directly in ImageCache.
- ExpandPageRouteTransition can be simplified greatly, and also figure out how to properly use Heroes to animate the Entity thumbnail to the DetailsPage.

### Possible but very hard
- Tablet support
- Web support

### Far Future
- Should there be a Google Maps for Dart SDK in the future, migrate to it asap. The native Google Maps view is filled with bugs.
