import 'library.dart';

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
abstract class Entity extends DataObject {
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
        images = List<String>.from(parsedJson['imageRef']),
        locations =
            List.from(parsedJson['locations'].split(',')).where((value) {
          return value != null && value.isNotEmpty;
        }).map((value) {
          final split = value.split('/');
          return Tuple(
            int.tryParse(split.first.split('-').last),
            int.tryParse(split.last.split('-').last),
          );
        }).toList();

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

  bool operator ==(Object other) {
    return super == other && other is Flora;
  }

  @override
  int get hashCode => super.hashCode;
}

class FirebaseData {
  final List<Flora> floraList;
  final List<Fauna> faunaList;
  final Map<Trail, List<TrailLocation>> trails;
  final List<HistoricalData> historicalDataList;
  final List<AboutPageData> aboutPageDataList;
  const FirebaseData({
    this.floraList,
    this.faunaList,
    this.trails,
    this.historicalDataList,
    this.aboutPageDataList,
  });
}

class Trail extends DataObject {
  final int id;
  final String name;
  final String color;
  const Trail({this.id, this.name, this.color});
  factory Trail.fromJson(String key, dynamic parsedJson) {
    return Trail(
      id: int.tryParse(key.split('-').last),
      name: parsedJson['name'],
      color: parsedJson['color'],
    );
  }

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Trail &&
            id == other.id &&
            name == other.name &&
            color == other.color;
  }

  @override
  int get hashCode => hashValues(id, name, color);
}

/// A TrailLocation is a point on the trail
class TrailLocation extends DataObject {
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
    @required List<Flora> floraList,
    @required List<Fauna> faunaList,
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
      entityPositions: List.from(parsedJson['points']).map((point) {
        return EntityPosition.fromJson(
          point,
          floraList: floraList,
          faunaList: faunaList,
        );
      }).toList(),
    );
  }

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
  final num pulse;
  final num size;
  const EntityPosition({
    this.entity,
    this.left,
    this.top,
    this.pulse,
    this.size,
  });
  factory EntityPosition.fromJson(
    dynamic parsedJson, {
    @required List<Flora> floraList,
    @required List<Fauna> faunaList,
  }) {
    final name = parsedJson['params']['name'];
    final id = int.tryParse(name.split('-').last);
    Entity entity;
    if (name.startsWith('flora')) {
      entity = floraList.firstWhere((flora) {
        return flora.id == id;
      }, orElse: () => null);
    } else if (name.startsWith('fauna')) {
      entity = faunaList.firstWhere((fauna) {
        return fauna.id == id;
      }, orElse: () => null);
    }
    return EntityPosition(
      entity: entity,
      left: parsedJson['left'],
      top: parsedJson['top'],
      pulse: parsedJson['pulse'],
      size: parsedJson['size'],
    );
  }
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
}

String lowerRes(String image) {
  if (image.isEmpty) return '';
  var split = image.split('.');
  final end = '.' + split.removeLast();
  return split.join('.') + 'h' + end;
}

/// Information needed for the new screen to be displayed within the bottom sheet. Contains the name of  the route, the [DataObject] it contains, and the active scroll controller for the bottom sheet.
class RouteInfo {
  final String name; // To be displayed on the bottom app bar
  final DataObject data; // Entity, Trail or TrailLocation
  ScrollController scrollController;
  RouteInfo({
    @required this.name,
    this.data,
    this.scrollController,
  });
  @override
  String toString() {
    return name;
  }
}

class AppNotifier extends ChangeNotifier {
  // Both routes and navigator stack are kept in sync with each other
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<RouteInfo> routes = [];

  /// Needed for map to correctly apply padding when bottom sheet is fully expanded
  final hasEntity = ValueNotifier(false);

  int _state = 0;

  /// 0: [EntityListPage] or [TrailDetailsPage]
  ///
  /// 1: [EntityDetailsPage] or [TrailLocationOverviewPage]
  ///
  /// 2: [ImageGallery]
  int get state => _state;

  /// Pop the current screen in the bottom sheet
  void pop(BuildContext context) {
    routes.removeLast();
    if (routes.isEmpty) {
      _changeState(
        context: context,
        isHome: true,
      );
    } else {
      _changeState(
        context: context,
        routeInfo: routes.last,
      );
    }
    print('After pop: $routes');
    navigatorKey.currentState.pop();
  }

  /// Update active scroll controller after new route is pushed onto the bottom sheet.
  ///
  /// The 'data' argument is still needed for checking if the last [RouteInfo] is still equivalent.
  void updateScrollController({
    BuildContext context,
    DataObject data,
    ScrollController scrollController,
  }) {
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    if (routes.last.data == data) {
      routes.last.scrollController = scrollController;
      bottomSheetNotifier.activeScrollController = scrollController;
      print('Updated scroll controller for ${routes.last.name}');
    } else {
      throw 'Last route data is not equivalent!';
    }
  }

  /// Displays a new screen within the bottom sheet
  Future<T> push<T>({
    @required BuildContext context,
    @required Route<T> route,
    @required RouteInfo routeInfo,
    bool disableDragging = false,
  }) async {
    routes.add(routeInfo);
    _changeState(
      context: context,
      routeInfo: routeInfo,
      disableDragging: disableDragging,
    );
    print('After push: $routes');
    return navigatorKey.currentState.push(route);
  }

  void _changeState({
    @required BuildContext context,
    RouteInfo routeInfo,
    bool isHome = false,
    bool disableDragging = false,
  }) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    if (disableDragging) {
      _state = 2;
      notifyListeners();
      bottomSheetNotifier
        ..draggingDisabled = true
        ..animateTo(
          0,
          const Duration(milliseconds: 340),
        );
      return;
    }
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final mapNotifier = Provider.of<MapNotifier>(context, listen: false);
    if (isHome || routeInfo.data is Trail) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      hasEntity.value = false;
      _state = 0;
      bottomSheetNotifier.snappingPositions.value = [
        0,
        height - bottomHeight,
        isHome ? height - bottomBarHeight : height - 48 - 76,
      ];
      if (isHome) {
        mapNotifier.animateBackToCenter(adjusted: true);
      } else {
        final adjusted = bottomSheetNotifier.animation.value < height - 48 - 96;
        mapNotifier.animateToTrail(
          locations: Provider.of<FirebaseData>(context, listen: false)
              .trails[routeInfo.data],
          adjusted: adjusted,
          mapSize: Size(
            width,
            adjusted ? height - bottomHeight : height - 62,
          ),
        );
      }
    } else {
      _state = 1;
      bottomSheetNotifier.snappingPositions.value = [
        0,
        height - 48 - 96 - 218 - 16,
        height - 48 - 96,
      ];
      final adjusted = bottomSheetNotifier.animation.value < height - 48 - 96;
      if (routeInfo.data is Entity) {
        hasEntity.value = true;
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        Provider.of<SearchNotifier>(context, listen: false).isSearching = false;
        mapNotifier.animateToEntity(
          entity: routeInfo.data,
          trails: Provider.of<FirebaseData>(context, listen: false).trails,
          adjusted: adjusted,
          mapSize: Size(
            width,
            adjusted ? height - bottomHeight : height - 62,
          ),
        );
      } else {
        mapNotifier.animateToLocation(
          location: routeInfo.data as TrailLocation,
          adjusted: adjusted,
        );
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
    notifyListeners();
    bottomSheetNotifier
      ..draggingDisabled = false
      ..endCorrection = isHome ? topPadding - offsetTranslation : topPadding
      ..activeScrollController = routeInfo?.scrollController;
  }
}
