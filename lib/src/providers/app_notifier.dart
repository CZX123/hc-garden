import 'package:hc_garden/src/library.dart';

/// Information needed for the new screen to be displayed within the bottom sheet.
/// Contains the name of the route, the [DataObject] it contains,
/// and the active scroll controller for the bottom sheet.
class RouteInfo<T> {
  /// Name of route, to be displayed on bottom nav bar
  final String name;

  /// The [Route] to be pushed to the custom [Navigator] within the bottom sheet
  final Route<T> route;

  /// An [EntityKey], [TrailKey] or [TrailLocationKey]
  final DataKey dataKey;

  /// The [ScrollController] within the new route. Usually updated after the
  /// route is pushed, and on first creation of the new screen, using the
  /// [AppNotifier.updateScrollController] function.
  ScrollController scrollController;

  RouteInfo({
    @required this.name,
    @required this.route,
    this.dataKey,
    this.scrollController,
  })  : assert(name != null),
        assert(route != null);

  @override
  String toString() {
    return name;
  }
}

/// The main notifier in charge of app state, and pushing and popping routes within the bottom sheet
class AppNotifier extends ChangeNotifier {
  int tabIndex = 0;
  final homeScrollControllers = [ScrollController(), ScrollController()];
  // Both routes and navigator stack are kept in sync with each other
  final navigatorKey = GlobalKey<NavigatorState>();
  List<RouteInfo> routes = [];

  int _state = 0;

  /// 0: [EntityListPage] or [TrailDetailsPage]
  ///
  /// 1: [EntityDetailsPage] or [TrailLocationOverviewPage]
  ///
  /// 2: [ImageGallery]
  int get state => _state;

  void popUntil(BuildContext context, int index) {
    if (index == null) return;
    if (index < 0) {
      while (routes.isNotEmpty) pop(context);
    } else {
      while (routes.length > index + 1) pop(context);
    }
  }

  /// Pop the current screen in the bottom sheet
  void pop(BuildContext context) {
    if (routes.length == 0) return;
    routes.removeLast();
    if (routes.isEmpty) {
      changeState(
        context: context,
        isHome: true,
      );
    } else {
      changeState(
        context: context,
        routeInfo: routes.last,
      );
    }
    // print('After pop: $routes');
    // Ensure that routes and navigator stack remains in sync even if there is an error, by resetting when going back to home
    if (routes.isEmpty) {
      navigatorKey.currentState.popUntil((route) => route.isFirst);
    } else {
      navigatorKey.currentState.pop();
    }
  }

  /// Update active scroll controller after new route is pushed onto the bottom sheet.
  ///
  /// The 'data' argument is still needed for checking if the last [RouteInfo] is still equivalent.
  void updateScrollController({
    @required BuildContext context,
    @required DataKey dataKey,
    @required ScrollController scrollController,
  }) {
    final bottomSheetNotifier =
        context.provide<BottomSheetNotifier>(listen: false);
    if (routes.last.dataKey == dataKey) {
      routes.last.scrollController = scrollController;
      bottomSheetNotifier.activeScrollController = scrollController;
      // print('Updated scroll controller for ${routes.last.name}');
    } else {
      throw 'Last route data is not equivalent!';
    }
  }

  /// Displays a new screen within the bottom sheet
  Future<T> push<T>({
    @required BuildContext context,
    @required RouteInfo routeInfo,
    bool disableDragging = false,
  }) async {
    routes.add(routeInfo);
    changeState(
      context: context,
      routeInfo: routeInfo,
      disableDragging: disableDragging,
    );
    // print('After push: $routes');
    return navigatorKey.currentState.push(routeInfo.route);
  }

  void changeState({
    @required BuildContext context,
    RouteInfo routeInfo,
    bool isHome = false,
    bool disableDragging = false,
    bool notify = true,
  }) {
    final bottomSheetNotifier = context.provide<BottomSheetNotifier>(listen: false);
    if (disableDragging && !isHome) {
      _state = 2;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (notify) notifyListeners();
      bottomSheetNotifier
        ..draggingDisabled = true
        ..animateTo(
          0,
          const Duration(milliseconds: 340),
        );
      return;
    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final heightTooSmall = height - Sizes.kBottomHeight < 100;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final mapNotifier = Provider.of<MapNotifier>(context, listen: false);
    if (isHome || routeInfo.dataKey is TrailKey) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      _state = 0;
      mapNotifier.bottomSheetHeight = heightTooSmall
          ? Sizes.kBottomHeight -
              Sizes.hEntityButtonHeight -
              Sizes.hBottomBarHeight -
              8
          : Sizes.kBottomHeight - Sizes.hBottomBarHeight;
      bottomSheetNotifier.snappingPositions.value = [
        0,
        if (!heightTooSmall)
          height - Sizes.kBottomHeight - bottomPadding
        else if (isHome)
          height -
              Sizes.kBottomHeight +
              Sizes.hEntityButtonHeight +
              8 -
              bottomPadding,
        isHome
            ? height - Sizes.hBottomBarHeight - bottomPadding
            : height - Sizes.tCollapsedHeight - bottomPadding,
      ];
      if (isHome) {
        if (!disableDragging) mapNotifier.animateBackToCenter(adjusted: true);
      } else {
        final adjusted = bottomSheetNotifier.animation.value <
                height - Sizes.kCollapsedHeight &&
            !heightTooSmall;
        mapNotifier.animateToTrail(
          locations: FirebaseData.getTrail(
            context: context,
            key: routeInfo.dataKey,
            listen: false,
          ).values.toList(),
          adjusted: adjusted,
          mapSize: Size(
            width,
            adjusted
                ? height - Sizes.kBottomHeight - bottomPadding
                : height - Sizes.hBottomBarHeight - bottomPadding,
          ),
        );
      }
    } else {
      _state = 1;
      bottomSheetNotifier.snappingPositions.value = [
        0,
        if (!heightTooSmall) height - Sizes.kBottomHeight - bottomPadding,
        height - Sizes.kCollapsedHeight - bottomPadding,
      ];
      final adjusted = bottomSheetNotifier.animation.value <
              height - Sizes.kCollapsedHeight &&
          !heightTooSmall;
      if (routeInfo.dataKey is EntityKey) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        Provider.of<FilterNotifier>(context, listen: false).unfocusSearchBar();
        final firebaseData = Provider.of<FirebaseData>(context, listen: false);
        mapNotifier.animateToEntity(
          entity: FirebaseData.getEntity(
            context: context,
            key: routeInfo.dataKey,
            listen: false,
          ),
          trails: firebaseData.trails,
          adjusted: adjusted,
          mapSize: Size(
            width,
            adjusted
                ? height - Sizes.kBottomHeight - bottomPadding
                : height - Sizes.hBottomBarHeight - bottomPadding,
          ),
        );
      } else {
        mapNotifier.animateToLocation(
          location: FirebaseData.getTrailLocation(
            context: context,
            key: routeInfo.dataKey,
            listen: false,
          ),
          adjusted: adjusted,
          changeMarkerColor: true,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
    if (notify) notifyListeners();
    bottomSheetNotifier
      ..draggingDisabled = disableDragging
      ..endCorrection =
          isHome ? topPadding - Sizes.hOffsetTranslation : topPadding
      ..activeScrollController = isHome
          ? homeScrollControllers[tabIndex]
          : routeInfo?.scrollController;
  }

  @override
  void dispose() {
    for (var controller in homeScrollControllers) controller.dispose();
    super.dispose();
  }
}
