import 'library.dart';

String lowerRes(String image) {
  if (image.isEmpty) return '';
  var split = image.split('.');
  final end = '.' + split.removeLast();
  return split.join('.') + 'h' + end;
}

// /// Data Object is either an [Entity], a [Trail] or a [TrailLocation].
// /// Used as an argument when pushing routes in AppNotifier.
// abstract class DataObject {
//   const DataObject();
//   bool operator ==(Object other);
//   int get hashCode;
// }

/// Data Key is used for the id of an [Entity], a [Trail] or a [TrailLocation].
/// Used as an argument when pushing routes in AppNotifier.
abstract class DataKey {
  final int id;
  const DataKey({@required this.id});
  bool operator ==(Object other);
  int get hashCode;
  bool get isValid {
    return id != null;
  }
}

/// A unique identifier for each [Entity]. Consists of its `category` and `id`.
class EntityKey extends DataKey {
  final String category;
  EntityKey({@required this.category, @required int id}) : super(id: id);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityKey && category == other.category && id == other.id;
  }

  @override
  int get hashCode => hashValues(category, id);

  @override
  bool get isValid {
    return category != null && id != null;
  }

  @override
  String toString() {
    return 'EntityKey(category: $category, id: $id)';
  }
}

/// A unique identifier for a [Trail]. Wraps its `id`.
class TrailKey extends DataKey {
  TrailKey({@required int id}) : super(id: id);

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is TrailKey && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TrailKey(id: $id)';
  }
}

/// A unique identifier for a [TrailLocation]. Wraps its `id`.
class TrailLocationKey extends DataKey {
  final TrailKey trailKey;
  TrailLocationKey({@required this.trailKey, @required int id}) : super(id: id);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrailLocationKey &&
            trailKey == other.trailKey &&
            id == other.id;
  }

  @override
  int get hashCode => hashValues(trailKey, id);

  @override
  bool get isValid {
    return trailKey.isValid && id != null;
  }

  @override
  String toString() {
    return 'TrailLocationKey(trailId: ${trailKey.id}, id: $id)';
  }
}

/// An [Entity] refers to any flora or fauna, and fauna may include any birds, butterflies, etc.
class Entity implements Comparable{
  final EntityKey key;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final List<EntityLocation> locations;

  const Entity({
    this.key,
    this.name,
    this.sciName,
    this.description,
    this.smallImage,
    this.images,
    this.locations,
  });

  factory Entity.fromJson({
    @required String category,
    @required int id,
    @required dynamic data,
  }) {
    final images = List<String>.from(data['imageRef']);
    List<EntityLocation> locations;

    /// `data['locations']` is in the format of `"trail-01/route-09,trail-02/route-06"`.
    if (data.containsKey('locations')) {
      final List<String> strings = data['locations'].split(',');
      // There may be trailing commas, so need to filter out invalid values.
      strings.removeWhere((value) => value == null || value.isEmpty);
      locations = [];
      strings.forEach((value) {
        final split = value.split('/');
        final trailKey = TrailKey(
          id: int.tryParse(split.first.split('-').last),
        );
        final location = EntityLocation(
          trailLocationKey: TrailLocationKey(
            trailKey: trailKey,
            id: int.tryParse(split.last.split('-').last),
          ),
        );
        if (location.isValid) locations.add(location);
      });
    }

    return Entity(
      key: EntityKey(category: category, id: id),
      name: data['name'],
      sciName: data['sciName'],
      description: data['description'],
      smallImage: data['smallImage'],
      images: images,
      locations: locations,
    );
  }

  /// Returns whether the [Entity] satisfies the `searchTerm`
  bool satisfies(String searchTerm) {
    if (searchTerm.isEmpty || searchTerm == '*') return true;
    return !name.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        }) ||
        !sciName.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        });
  }

  bool get isValid {
    return key.isValid &&
        name != null &&
        sciName != null &&
        description != null &&
        smallImage != null &&
        images != null &&
        locations != null;
  }

  @override
  int compareTo(other) {
    final Entity typedOther = other;
    return name.compareTo(typedOther.name);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Entity &&
            key == other.key &&
            name == other.name &&
            sciName == other.sciName &&
            description == other.description &&
            smallImage == other.smallImage &&
            listEquals(images, other.images) &&
            listEquals(locations, other.locations);
  }

  @override
  int get hashCode {
    return hashValues(
      key,
      name,
      sciName,
      description,
      smallImage,
      hashList(images),
      hashList(locations),
    );
  }

  @override
  String toString() {
    return 'Entity(category: ${key.category}, id: ${key.id}, name: $name)';
  }
}

/// Used in [Entity]
class EntityLocation {
  final TrailLocationKey trailLocationKey;
  const EntityLocation({@required this.trailLocationKey});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityLocation &&
            trailLocationKey == other.trailLocationKey;
  }

  @override
  int get hashCode => trailLocationKey.hashCode;

  bool get isValid {
    return trailLocationKey.isValid;
  }
}

/// NOTE: [Flora] & [Fauna] are now removed due to multiple different kinds of [Fauna],
/// and also because of the redundance of `area` and `coordinates` attributes in [Fauna].
/// All subsequent mentions should always use [Entity]. [Entity] is also no longer abstract.
/// TODO: Remove this entirely.
// class Fauna extends Entity {
//   // A fauna has 2 extra keys: areas and coordinates. These are most likely not to be used.
//   final String type;
//   final List<LatLng> area;
//   final LatLng coordinates;
//   Fauna.fromJson(String key, dynamic data)
//       : type = data['type'],
//         area = data.containsKey('area')
//             ? List.from(data['area']).map((position) {
//                 return LatLng(position['latitude'], position['longitude']);
//               }).toList()
//             : null,
//         coordinates = data.containsKey('latitude')
//             ? LatLng(data['latitude'], data['longitude'])
//             : null,
//         super.fromJson(key, data);

//   // @override
//   // bool get isValid {
//   //   return super.isValid && area != null && coordinates != null;
//   // }

//   @override
//   bool operator ==(Object other) {
//     return super == other &&
//         other is Fauna &&
//         listEquals(area, other.area) &&
//         coordinates == other.coordinates;
//   }

//   @override
//   int get hashCode => hashValues(id, name, sciName, description, smallImage,
//       hashList(images), hashList(locations), hashList(area), coordinates);
// }

// class Flora extends Entity {
//   Flora.fromJson(String key, dynamic data)
//       : super.fromJson(key, data);

//   @override
//   bool operator ==(Object other) {
//     return super == other && other is Flora;
//   }

//   @override
//   int get hashCode => super.hashCode;
// }

// class FirebaseData {
//   final Map<int, Flora> floraMap;
//   final Map<int, Fauna> faunaMap;
//   final Map<Trail, Map<int, TrailLocation>> trails;
//   final List<HistoricalData> historicalDataList;
//   final List<AboutPageData> aboutPageDataList;
//   const FirebaseData({
//     this.floraMap,
//     this.faunaMap,
//     this.trails,
//     this.historicalDataList,
//     this.aboutPageDataList,
//   });

//   @override
//   bool operator ==(Object other) {
//     return identical(this, other) ||
//         other is FirebaseData &&
//             mapEquals(floraMap, other.floraMap) &&
//             mapEquals(faunaMap, other.faunaMap) &&
//             listEquals(historicalDataList, other.historicalDataList) &&
//             listEquals(aboutPageDataList, other.aboutPageDataList) &&
//             mapEquals(trails, other.trails);
//   }

//   @override
//   int get hashCode => hashValues(
//         floraMap,
//         faunaMap,
//         hashList(historicalDataList),
//         hashList(aboutPageDataList),
//         trails,
//       );
// }

// class Trail {
//   final TrailKey key;
//   final String name;
//   const Trail({this.key, this.name});
//   factory Trail.fromJson(String key, dynamic data) {
//     return Trail(
//       key: TrailKey(id: int.tryParse(key.split('-').last)),
//       name: data is Map ? data['name'] : null,
//     );
//   }

//   bool get isValid {
//     return key.isValid && name != null;
//   }

//   @override
//   bool operator ==(Object other) {
//     return identical(this, other) ||
//         other is Trail && key == other.key && name == other.name;
//   }

//   @override
//   int get hashCode => hashValues(key, name);
// }

/// A TrailLocation is a point on the trail
class TrailLocation {
  final TrailLocationKey key;
  final String name;
  final String image;
  final String smallImage;
  final LatLng coordinates;
  final List<EntityPosition> entityPositions;
  const TrailLocation({
    this.key,
    this.name,
    this.image,
    this.smallImage,
    this.coordinates,
    this.entityPositions,
  });
  factory TrailLocation.fromJson({
    @required TrailLocationKey key,
    @required TrailKey trailKey,
    @required dynamic data,
  }) {
    List<EntityPosition> entityPositions;
    if (data.containsKey('points')) {
      entityPositions = [];
      for (dynamic point in data['points']) {
        final entityPosition = EntityPosition.fromJson(point);
        if (entityPosition.isValid) entityPositions.add(entityPosition);
      }
      entityPositions.sort((a, b) => a.left.compareTo(b.left));
    }
    return TrailLocation(
      key: key,
      name: data['title'],
      image: data['imageRef'],
      smallImage: data['smallImage'],
      coordinates: data.containsKey('latitude')
          ? LatLng(data['latitude'], data['longitude'])
          : null,
      entityPositions: entityPositions,
    );
  }

  bool get isValid {
    return key.isValid &&
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
            key == other.key &&
            name == other.name &&
            image == other.image &&
            smallImage == other.smallImage &&
            coordinates == other.coordinates &&
            listEquals(entityPositions, other.entityPositions);
  }

  @override
  int get hashCode => hashValues(
        key,
        name,
        image,
        smallImage,
        coordinates,
        hashList(entityPositions),
      );
}

class EntityPosition {
  final EntityKey entityKey;
  final double left;
  final double top;
  final num size;
  const EntityPosition({
    this.entityKey,
    this.left,
    this.top,
    this.size,
  });

  factory EntityPosition.fromJson(dynamic data) {
    return EntityPosition(
      entityKey: EntityKey(
        category: data['params']['category'],
        id: data['params']['id'],
      ),
      left: data['left'],
      top: data['top'],
      size: data['size'],
    );
  }

  bool get isValid {
    return entityKey.isValid && left != null && top != null && size != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityPosition &&
            entityKey == other.entityKey &&
            left == other.left &&
            top == other.top &&
            size == other.size;
  }

  @override
  int get hashCode => hashValues(entityKey, left, top, size);
}

class HistoricalData {
  final int id;
  final String description;
  final String image;
  final String newImage;
  final String name;
  final num height;
  final num width;
  const HistoricalData({
    this.id,
    this.description,
    this.image,
    this.newImage,
    this.name,
    this.height,
    this.width,
  });

  factory HistoricalData.fromJson(dynamic key, dynamic data) {
    return HistoricalData(
      id: key,
      description: data['description'],
      image: data['imageRef'],
      newImage: data['newImageRef'],
      name: data['name'],
      height: data['height'],
      width: data['width'],
    );
  }

  bool get isValid {
    return id != null &&
        description != null &&
        image != null &&
        newImage != null &&
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
            newImage == other.newImage &&
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

  factory AboutPageData.fromJson(int key, dynamic data) {
    return AboutPageData(
      body: data['body'],
      id: key,
      quote: data['quote'],
      title: data['title'],
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

  /// An [EntityKey], [TrailKey] or [TrailLocationKey]
  final DataKey dataKey;

  /// The [ScrollController] within the new route. Usually updated after the route is pushed, and on first creation of the new screen, using the [AppNotifier.updateScrollController] function.
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
        Provider.of<BottomSheetNotifier>(context, listen: false);
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
        Provider.of<SearchNotifier>(context, listen: false).unfocus();
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
