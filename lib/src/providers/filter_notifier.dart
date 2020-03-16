import 'package:hc_garden/src/library.dart';

/// [FilterNotifier] is a single [ChangeNotifier] that deals with anything
/// involving searching, sorting & filtering of [Entity]s.
///
/// Notable properties:
/// - [searchTerm]: set the search term when searching [Entity]s
/// - [selectedTrailKeys]: the list of trail keys that are selected in [FilterDrawer]
/// - [toggleSortByDist()]: toggle the sorting by distance for all [Entity]s
/// - [filter]: accepts an [EntityMap] and returns a sorted & filtered [EntityMap]
/// based on the different filters present in the [FilterNotifier]

class FilterNotifier extends ChangeNotifier {
  // Searching of [Entity]

  final searchBarFocusNode = FocusNode();
  void unfocusSearchBar() {
    searchBarFocusNode?.unfocus();
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();
  }

  // Filtering by [Trail]

  /// All trails are selected by default
  List<TrailKey> _selectedTrailKeys = [
    for (final i in [0, 1, 2]) TrailKey(id: i)
  ];
  List<TrailKey> get selectedTrailKeys => _selectedTrailKeys;
  set selectedTrailKeys(List<TrailKey> selectedTrailKeys) {
    _selectedTrailKeys = selectedTrailKeys;
    notifyListeners();
  }

  // Sorting alpabetically or by distance

  bool _isSortedByDistance = false;
  bool get isSortedByDistance => _isSortedByDistance;

  Map<String, List<EntityDistance>> entitiesByDist = {};

  Future<DistanceSortingState> toggleSortByDist(BuildContext context) async {
    if (_isSortedByDistance) {
      entitiesByDist.clear();
    } else {
      final firebaseData = Provider.of<FirebaseData>(
        context,
        listen: false,
      );
      final mapNotifier = context.provide<MapNotifier>(listen: false);
      final location = Location();
      if (!mapNotifier.permissionEnabled) {
        final success = await location.requestPermission();
        if (success) {
          mapNotifier.permissionEnabled = true;
        } else {
          return DistanceSortingState.locationPermissionDenied;
        }
      }
      if (!mapNotifier.gpsOn) {
        final success = await location.requestService();
        if (success) {
          mapNotifier.gpsOn = true;
        } else {
          return DistanceSortingState.locationOff;
        }
      }
      final locationData = await location.getLocation();
      _sortEntitiesByDist(
        firebaseData.entities,
        firebaseData.trails,
        locationData,
      );
    }
    notifyListeners();
    _isSortedByDistance = !_isSortedByDistance;
    return DistanceSortingState.none;
  }

  void _sortEntitiesByDist(
    EntityMap entities,
    TrailMap trails,
    LocationData locationData,
  ) {
    entities.forEach((category, entityList) {
      entitiesByDist[category] = [];
      for (final entity in entityList) {
        double minDist = double.infinity;
        for (var location in entity.locations) {
          final trailLocation = trails[location.trailLocationKey.trailKey]
              [location.trailLocationKey];
          final dist = sqrt(
            pow(
                  trailLocation.coordinates.latitude - locationData.latitude,
                  2,
                ) +
                pow(
                  trailLocation.coordinates.longitude - locationData.longitude,
                  2,
                ),
          );
          if (dist < minDist) minDist = dist;
        }
        entitiesByDist[category].add(EntityDistance(
          key: entity.key,
          name: entity.name,
          distance: minDist,
        ));
      }
      entitiesByDist[category].sort();
    });
  }

  EntityMap filter(EntityMap entities) {
    final newEntityMap = EntityMap();
    final categories = entities.keys.toList()..sort();
    for (final category in categories) {
      // Sort by distance and does filtering based on trails and search inside as well
      if (isSortedByDistance) {
        newEntityMap[category] = [];
        for (final entityDistance in entities[category]) {
          final entity = entities[category][entityDistance.key.id];
          if (!selectedTrailKeys.every((trailKey) {
                return entity.locations.every((location) {
                  return location.trailLocationKey.trailKey != trailKey;
                });
              }) &&
              entity.satisfies(searchTerm)) newEntityMap[category].add(entity);
        }
      }

      // Filter by trail, no sorting by distance
      else {
        if (selectedTrailKeys.length == 3) {
          newEntityMap[category] = entities[category].where((entity) {
            return entity.satisfies(searchTerm);
          }).toList();
        } else {
          newEntityMap[category] = entities[category].where((entity) {
            return !selectedTrailKeys.every((trailKey) {
                  return entity.locations.every((location) {
                    return location.trailLocationKey.trailKey != trailKey;
                  });
                }) &&
                entity.satisfies(searchTerm);
          }).toList();
        }
        newEntityMap[category].sort();
      }
    }
    return newEntityMap;
  }
}

class EntityDistance implements Comparable {
  final EntityKey key;
  final String name;
  final double distance;
  const EntityDistance({this.key, this.name, this.distance});

  @override
  int compareTo(other) {
    final EntityDistance typedOther = other;
    final int comparison = distance.compareTo(typedOther.distance);
    if (comparison == 0) return name.compareTo(typedOther.name);
    return comparison;
  }
}
