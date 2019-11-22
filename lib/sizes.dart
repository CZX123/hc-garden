import 'library.dart';

/// Contains all the important heights of the various widgets used throughout the app.
class Sizes {
  // This prevents Sizes from being instantiated as a default constructor,
  // i.e. calling Sizes() will return an error.
  // This is because Dart by default will have a default constructor
  // if there is no constructor defined, so there is a need to define a
  // separate private constructor that cannot be used
  Sizes._();

  // All values starting with h are for the explore header. 'h' stands for Header.
  /// Amount of vertical spacing in the explore header
  static const hSpacing = 4 * 8 + 16 + 12 + 8 + 4.0;

  /// Height of the app logo/image
  static const hLogoHeight = 28.0;

  /// Height of the text 'Explore HC Garden'
  static const hHeadingHeight = 28.0;

  /// Height of the 3 trail buttons
  static const hTrailButtonHeight = 80.0;

  /// Height of the flora & fauna buttons in its default state
  static const hEntityButtonHeight = 108.0;

  /// Collapsed height of the flora & fauna buttons when bottom sheet is fully expanded
  static const hEntityButtonHeightCollapsed = 64.0;

  /// Height of the [BottomAppBar] covering the bottom sheet
  static const hBottomBarHeight = 62.0;

  /// Height of the bottom sheet in the semi-collapsed state. Also the sum of all the individual heights in [ExploreHeader].
  static const kBottomHeight = hSpacing +
      hHeadingHeight +
      hLogoHeight +
      hTrailButtonHeight +
      hEntityButtonHeight +
      hBottomBarHeight;

  /// Translation required to move the entity buttons up to the top during the expansion of the bottom sheet. Excludes the top padding.
  static const hOffsetTranslation = kBottomHeight -
      16 - // 16 is the vertical space that surrounds the flora & fauna buttons
      hEntityButtonHeight -
      hBottomBarHeight; // without topPadding

  /// Height of the bottom bar of the bottom sheet in all the other screens: [TrailDetailsPage], [EntityDetailsPage], [TrailLocationOverviewPage] and [ImageGallery], all excluding the home page.
  static const kBottomBarHeight = 48.0;

  /// Height of trail name in [TrailDetailsPage]. 't' stands for Trail.
  static const tHeadingHeight = 76.0;

  /// Height of fully collapsed bottom sheet in [TrailDetailsPage]. 't' stands for Trail.
  static const tCollapsedHeight = kBottomBarHeight + tHeadingHeight;

  /// An info row is a row which contains a circular image, and 2 lines of text on the right.
  /// It is present in [EntityDetailsPage] and [TrailLocationOverviewPage].
  static const kInfoRowHeight = 96.0;

  /// Height of fully collapsed bottom sheet in [EntityDetailsPage] or [TrailLocationOverviewPage]
  static const kCollapsedHeight = kBottomBarHeight + kInfoRowHeight;

  /// Height of the image slider in [EntityDetailsPage]
  static const kImageHeight = kBottomHeight - kInfoRowHeight - kBottomBarHeight - 16;
}
