import 'package:hc_garden/src/library.dart';
import 'dart:collection';

class FirebaseData {
  final EntityMap entities;
  final TrailMap trails;
  final List<HistoricalData> historicalDataList;
  final List<AboutPageData> aboutPageDataList;
  final Set<Polygon> mapPolygons;

  const FirebaseData({
    this.entities,
    this.trails,
    this.historicalDataList,
    this.aboutPageDataList,
    this.mapPolygons,
  });

  static const List<String> trailNames = [
    'Jing Xian Trail',
    'Kong Chian Trail',
    'Kah Kee Trail',
  ];

  static Entity getEntity({
    @required BuildContext context,
    @required EntityKey key,
    bool listen = true,
  }) {
    // TODO: replace with context.select in the future
    return Provider.of<FirebaseData>(
      context,
      listen: listen,
    ).entities[key.category][key.id];
  }

  static TrailLocation getTrailLocation({
    @required BuildContext context,
    @required TrailLocationKey key,
    bool listen = true,
  }) {
    return Provider.of<FirebaseData>(
      context,
      listen: listen,
    ).trails[key.trailKey][key];
  }

  static Map<TrailLocationKey, TrailLocation> getTrail({
    @required BuildContext context,
    @required TrailKey key,
    bool listen = true,
  }) {
    return Provider.of<FirebaseData>(
      context,
      listen: listen,
    ).trails[key];
  }

  /// Needed when the data is a list, to return a map anyways
  static Map _getMap(data) {
    if (data is List)
      return data.asMap();
    else
      return Map.from(data);
  }

  /// Creates an instance of [FirebaseData] based on the `data` supplied.
  /// `data` should be the JSON data of the entire database.
  factory FirebaseData.fromJson(dynamic data) {
    final entities = EntityMap();
    final trails = TrailMap();
    final List<HistoricalData> historicalDataList = [];
    final List<AboutPageData> aboutPageDataList = [];
    final Set<Polygon> mapPolygons = {};

    // Adding entities
    entities.addEntities(
      category: 'flora',
      entitiesJson: _getMap(data['flora']),
    );
    data['fauna'].forEach((category, value) {
      entities.addEntities(
        category: category,
        entitiesJson: _getMap(value),
      );
    });

    // Adding trails
    _getMap(data['trails']).forEach((trailId, trailValue) {
      final trailKey = TrailKey(id: trailId);
      if (trailValue['name'].contains(trailNames[trailId])) {
        trails[trailKey] = {};
        _getMap(trailValue['locations']).forEach((locationId, locationValue) {
          final trailLocationKey = TrailLocationKey(
            trailKey: trailKey,
            id: locationId,
          );
          final location = TrailLocation.fromJson(
            key: trailLocationKey,
            trailKey: trailKey,
            data: locationValue,
          );
          if (location.isValid) trails[trailKey][trailLocationKey] = location;
        });
      }
    });

    // Add historical data
    _getMap(data['historical']).forEach((key, value) {
      final historicalData = HistoricalData.fromJson(key, value);
      if (historicalData.isValid) historicalDataList.add(historicalData);
    });
    historicalDataList.sort((a, b) => a.id.compareTo(b.id));

    // Add AboutPage data
    _getMap(data['about']).forEach((key, value) {
      final aboutPageData = AboutPageData.fromJson(key, value);
      if (aboutPageData.isValid) aboutPageDataList.add(aboutPageData);
    });
    aboutPageDataList.sort((a, b) => a.id.compareTo(b.id));

    // Add Map Polygons/Outlines for each building
    _getMap(data['mapPolygons']).forEach((key, value) {
      final polygon = generatePolygonFromJson(key, value);
      if (polygon != null) mapPolygons.add(polygon);
    });

    return FirebaseData(
      entities: entities,
      trails: trails,
      historicalDataList: historicalDataList,
      aboutPageDataList: aboutPageDataList,
      mapPolygons: mapPolygons,
    );
  }
}

/// Entities are first grouped by their category, and then by their id in the list.
class EntityMap extends MapView<String, List<Entity>> {
  EntityMap() : super({});

  /// Returns a shallow copy of the current [EntityMap]
  EntityMap clone() {
    final newMap = EntityMap();
    forEach((category, entityList) {
      newMap[category] = entityList;
    });
    return newMap;
  }

  /// Adds entities by their `category`.
  void addEntities({String category, Map entitiesJson}) {
    this[category] = [];
    entitiesJson.forEach((id, data) {
      final entity = Entity.fromJson(category: category, id: id, data: data);
      if (entity.isValid) this[category].add(entity);
    });
  }
}

class TrailMap extends MapView<TrailKey, Map<TrailLocationKey, TrailLocation>> {
  TrailMap() : super({});
}
