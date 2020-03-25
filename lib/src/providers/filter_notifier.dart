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

  bool get isSearching => _searchTerm.trim().isNotEmpty;

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
      // Clone and sort the list alphabetically first
      entityList = List.from(entityList);
      entityList.sort();
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

  bool _entityIsInTrails(Entity entity) {
    if (selectedTrailKeys.length == 3) return true;
    return !selectedTrailKeys.every((trailKey) {
      return entity.locations.every((location) {
        return location.trailLocationKey.trailKey != trailKey;
      });
    });
  }

  EntityMap filter(EntityMap entities) {
    final newEntityMap = EntityMap();
    final categories = entities.keys.toList()..sort();
    for (final category in categories) {
      // Sort by distance and does filtering based on trails and search inside as well
      if (isSortedByDistance) {
        if (isSearching) {
          final matchingEntities = <MapEntry<Entity, int>>[];
          for (final entityDistance in entitiesByDist[category]) {
            final entity = entities[category][entityDistance.key.id];
            if (_entityIsInTrails(entity)) {
              final relevance = entity.matches(searchTerm);
              if (relevance != 0) {
                matchingEntities.add(MapEntry(entity, relevance));
              }
            }
          }
          // From highest to lowest
          matchingEntities.sort((a, b) => b.value.compareTo(a.value));
          newEntityMap[category] =
              matchingEntities.map((entry) => entry.key).toList();
        } else {
          newEntityMap[category] = [];
          for (final entityDistance in entitiesByDist[category]) {
            final entity = entities[category][entityDistance.key.id];
            if (_entityIsInTrails(entity)) {
              newEntityMap[category].add(entity);
            }
          }
        }
      }

      // Filter by trail, no sorting by distance
      else {
        if (isSearching) {
          final matchingEntities = <MapEntry<Entity, int>>[];
          final entityList = List.from(entities[category])..sort();
          for (final entity in entityList) {
            if (_entityIsInTrails(entity)) {
              final relevance = entity.matches(searchTerm);
              if (relevance != 0) {
                matchingEntities.add(MapEntry(entity, relevance));
              }
            }
          }
          // From highest to lowest
          matchingEntities.sort((a, b) => b.value.compareTo(a.value));
          newEntityMap[category] =
              matchingEntities.map((entry) => entry.key).toList();
        } else {
          newEntityMap[category] =
              entities[category].where(_entityIsInTrails).toList();
          newEntityMap[category].sort();
        }
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

class Search {
  /// Checks if the start of each word within [text] starts with the [pattern]
  /// Uses spaces to separate between different words in [text]
  static bool matches(String text, String pattern) {
    assert(pattern.isNotEmpty);
    bool check = true;
    final m = text.length - pattern.length + 1;
    for (int i = 0; i < m; i++) {
      if (check) {
        if (text
            .substring(i)
            .toLowerCase()
            .startsWith(pattern.trim().toLowerCase())) {
          return true;
        }
        check = false;
      }
      if (text[i] == ' ') check = true;
    }
    return false;
  }
}
