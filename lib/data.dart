import 'library.dart';

String lowerRes(String image) {
  if (image.isEmpty) return '';
  var split = image.split('.');
  final end = '.' + split.removeLast();
  return split.join('.') + 'h' + end;
}

class Tuple<A, B> {
  final A item1;
  final B item2;
  const Tuple(this.item1, this.item2);
  operator [](int i) {
    if (i == 0)
      return item1;
    else if (i == 1)
      return item2;
    else
      throw RangeError.range(i, 0, 1);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Tuple<A, B> && item1 == other.item1 && item2 == other.item2;
  }

  @override
  int get hashCode => hashValues(item1, item2);
}

/// Data Object is either an [Entity], a [Trail] or a [TrailLocation].
/// Used as an argument when pushing routes in AppNotifier.
abstract class DataObject {
  const DataObject();
  bool operator ==(Object other);
  int get hashCode;
}

/// An [Entity] is a super class of a [Flora] or a [Fauna]
abstract class Entity implements DataObject {
  final int id;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final List<Tuple<int, int>> locations;

  Entity.fromJson(String key, dynamic parsedJson)
      : id = int.tryParse(key.split('-').last),
        name = parsedJson['name'],
        sciName = parsedJson['sciName'],
        description = parsedJson['description'],
        smallImage = parsedJson['smallImage'],
        images = (parsedJson['imageRef'] == null)
            ? null
            : List<String>.from(parsedJson['imageRef']),
        locations = (parsedJson['locations'] == null)
            ? null
            : List.from(parsedJson['locations'].split(',')).where((value) {
                return value != null && value.isNotEmpty;
              }).map((value) {
                final split = value.split('/');
                return Tuple(
                  int.tryParse(split.first.split('-').last),
                  int.tryParse(split.last.split('-').last),
                );
              }).toList();

  bool get isValid {
    return id != null &&
        name != null &&
        sciName != null &&
        description != null &&
        smallImage != null &&
        images != null &&
        locations != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Entity &&
            id == other.id &&
            name == other.name &&
            sciName == other.sciName &&
            description == other.description &&
            smallImage == other.smallImage &&
            listEquals(images, other.images) &&
            listEquals(locations, other.locations);
  }

  @override
  int get hashCode => hashValues(id, name, sciName, description, smallImage,
      hashList(images), hashList(locations));

  @override
  String toString() {
    return 'Entity(name: $name, sciName: $sciName)';
  }
}

class Fauna extends Entity {
  // A fauna has 2 extra keys: areas and coordinates. These are most likely not to be used.
  final List<LatLng> area;
  final LatLng coordinates;
  Fauna.fromJson(String key, dynamic parsedJson)
      : area = parsedJson.containsKey('area')
            ? List.from(parsedJson['area']).map((position) {
                return LatLng(position['latitude'], position['longitude']);
              }).toList()
            : null,
        coordinates = parsedJson.containsKey('latitude')
            ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
            : null,
        super.fromJson(key, parsedJson);

  @override
  bool get isValid {
    return super.isValid && area != null && coordinates != null;
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is Fauna &&
        listEquals(area, other.area) &&
        coordinates == other.coordinates;
  }

  @override
  int get hashCode => hashValues(id, name, sciName, description, smallImage,
      hashList(images), hashList(locations), hashList(area), coordinates);
}

class Flora extends Entity {
  Flora.fromJson(String key, dynamic parsedJson)
      : super.fromJson(key, parsedJson);

  @override
  bool operator ==(Object other) {
    return super == other && other is Flora;
  }

  @override
  int get hashCode => super.hashCode;
}

class FirebaseData {
  final Map<int, Flora> floraMap;
  final Map<int, Fauna> faunaMap;
  final Map<Trail, Map<int, TrailLocation>> trails;
  final List<HistoricalData> historicalDataList;
  final List<AboutPageData> aboutPageDataList;
  const FirebaseData({
    this.floraMap,
    this.faunaMap,
    this.trails,
    this.historicalDataList,
    this.aboutPageDataList,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FirebaseData &&
            mapEquals(floraMap, other.floraMap) &&
            mapEquals(faunaMap, other.faunaMap) &&
            listEquals(historicalDataList, other.historicalDataList) &&
            listEquals(aboutPageDataList, other.aboutPageDataList) &&
            mapEquals(trails, other.trails);
  }

  @override
  int get hashCode => hashValues(
        floraMap,
        faunaMap,
        hashList(historicalDataList),
        hashList(aboutPageDataList),
        trails,
      );
}

class Trail implements DataObject {
  final int id;
  final String name;
  const Trail({this.id, this.name});
  factory Trail.fromJson(String key, dynamic parsedJson) {
    return Trail(
      id: int.tryParse(key.split('-').last),
      name: parsedJson is Map ? parsedJson['name'] : null,
    );
  }

  bool get isValid {
    return id != null && name != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Trail && id == other.id && name == other.name;
  }

  @override
  int get hashCode => hashValues(id, name);
}

/// A TrailLocation is a point on the trail
class TrailLocation implements DataObject {
  final int id;
  final Trail trail;
  final String name;
  final String image;
  final String smallImage;
  final LatLng coordinates;
  final List<EntityPosition> entityPositions;
  const TrailLocation({
    this.id,
    this.trail,
    this.name,
    this.image,
    this.smallImage,
    this.coordinates,
    this.entityPositions,
  });
  factory TrailLocation.fromJson(
    String key,
    dynamic parsedJson, {
    @required Trail trail,
    @required Map<int, Flora> floraMap,
    @required Map<int, Fauna> faunaMap,
  }) {
    return TrailLocation(
      id: int.tryParse(key.split('-').last),
      trail: trail,
      name: parsedJson['title'],
      image: parsedJson['imageRef'],
      smallImage: parsedJson['smallImage'],
      coordinates: parsedJson.containsKey('latitude')
          ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
          : null,
      entityPositions: parsedJson.containsKey('points')
          ? List.from(parsedJson['points']).map((point) {
              final entityPosition = EntityPosition.fromJson(
                point, 
                floraMap: floraMap,
                faunaMap: faunaMap,
              );
              if (entityPosition.isValid) return entityPosition;
              else return null;
            }).where((position) => position != null).toList()
          : null,
    );
  }

  bool get isValid {
    return id != null &&
        trail != null &&
        name != null &&
        image != null &&
        smallImage != null &&
        coordinates != null &&
        entityPositions != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrailLocation &&
            id == other.id &&
            trail == other.trail &&
            name == other.name &&
            image == other.image &&
            smallImage == other.smallImage &&
            coordinates == other.coordinates &&
            listEquals(entityPositions, other.entityPositions);
  }

  @override
  int get hashCode => hashValues(id, trail, name, image, smallImage,
      coordinates, hashList(entityPositions));
}

class EntityPosition {
  final Entity entity;
  final double left;
  final double top;
  final num size;
  const EntityPosition({
    this.entity,
    this.left,
    this.top,
    this.size,
  });

  factory EntityPosition.fromJson(
    dynamic parsedJson, {
    @required Map<int, Flora> floraMap,
    @required Map<int, Fauna> faunaMap,
  }) {
    final name = parsedJson['params']['name'];
    final id = int.tryParse(name.split('-').last);
    Entity entity;
    if (name.startsWith('flora')) {
      entity = floraMap[id];
    } else if (name.startsWith('fauna')) {
      entity = faunaMap[id];
    }
    return EntityPosition(
      entity: entity,
      left: parsedJson['left'],
      top: parsedJson['top'],
      size: parsedJson['size'],
    );
  }

  bool get isValid{
    return entity != null &&
            left != null &&
            top != null &&
            size != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityPosition &&
            entity == other.entity &&
            left == other.left &&
            top == other.top &&
            size == other.size;
  }

  @override
  int get hashCode => hashValues(entity, left, top, size);
}

class HistoricalData {
  final int id;
  final String description;
  final String image;
  final String name;
  final num height;
  final num width;
  const HistoricalData({
    this.id,
    this.description,
    this.image,
    this.name,
    this.height,
    this.width,
  });

  factory HistoricalData.fromJson(String key, dynamic parsedJson) {
    return HistoricalData(
      id: int.tryParse(key.split('-').last),
      description: parsedJson['description'],
      image: parsedJson['imageRef'],
      name: parsedJson['name'],
      height: parsedJson['height'],
      width: parsedJson['width'],
    );
  }

  bool get isValid {
    return id != null &&
        description != null &&
        image != null &&
        name != null &&
        height != null &&
        width != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HistoricalData &&
            id == other.id &&
            description == other.description &&
            image == other.image &&
            name == other.name &&
            height == other.height &&
            width == other.width;
  }

  @override
  int get hashCode => hashValues(id, description, image, name, height, width);

  @override
  String toString() {
    return 'HistoricalData(id: $id, description: $description, imageURL: $image)';
  }
}

class AboutPageData {
  final String body;
  final int id;
  final String quote;
  final String title;
  bool isExpanded = false;
  AboutPageData({this.body, this.id, this.quote, this.title, this.isExpanded});

  factory AboutPageData.fromJson(String key, dynamic parsedJson) {
    return AboutPageData(
      body: parsedJson['body'],
      id: parsedJson['id'],
      quote: parsedJson['quote'],
      title: parsedJson['title'],
      isExpanded: false,
    );
  }

  bool get isValid {
    return body != null && id != null && title != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AboutPageData &&
            body == other.body &&
            id == other.id &&
            quote == other.quote &&
            title == other.title &&
            isExpanded == other.isExpanded;
  }

  @override
  int get hashCode => hashValues(body, id, quote, title, isExpanded);
}

/// Information needed for the new screen to be displayed within the bottom sheet. Contains the name of  the route, the [DataObject] it contains, and the active scroll controller for the bottom sheet.
class RouteInfo<T> {
  /// Name of route, to be displayed on bottom nav bar
  final String name;

  /// The [Route] to be pushed to the custom [Navigator] within the bottom sheet
  final Route<T> route;

  /// An [Entity], [Trail] or [TrailLocation]
  final DataObject data;

  /// The [ScrollController] within the new route. Usually updated after the route is pushed, and on first creation of the new screen, using the [AppNotifier.updateScrollController] function.
  ScrollController scrollController;

  RouteInfo({
    @required this.name,
    @required this.route,
    this.data,
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
    @required DataObject data,
    @required ScrollController scrollController,
  }) {
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    if (routes.last.data == data) {
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
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
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
    if (isHome || routeInfo.data is Trail) {
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
          locations: Provider.of<FirebaseData>(context, listen: false)
              .trails[routeInfo.data].values.toList(),
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
      if (routeInfo.data is Entity) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        Provider.of<SearchNotifier>(context, listen: false).unfocus();
        mapNotifier.animateToEntity(
          entity: routeInfo.data,
          trails: Provider.of<FirebaseData>(context, listen: false).trails,
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
          location: routeInfo.data as TrailLocation,
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
