# HC Garden UI

The user interface for HC Garden, with the bottom sheet, flora & fauna pages, and more.

## TODOs

### Branding
- App Icon
- App Loading Screen
- ~~HCI logo and banner should be visible on the home page~~

### Search
- ~~Search keyboard should close when~~
	- ~~going to details page, and should not open again when going back if searchTerm is blank~~
	- ~~scrolling the entity list~~
- ~~Search fab should also disappear when navigating to details page~~
- Search should be unified for both flora and fauna
- ~~Search should also show scientific name~~, and perhaps highlight the searchTerm within the name for clarity

### Entity Details Page
- Latin names should be italicised (clarify with Dr Chia)
- Image gallery widget (expand photo in image scrollview)
- ~~Locations of entity~~
- Interaction with map
- ~~correct bottom sheet snapping~~

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
- HistoryScreen
- Introduction, CommitteeMessage, Acknowledgements, References

## Bugs

### High Priority

- Map Widget frequently gets stuck

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
