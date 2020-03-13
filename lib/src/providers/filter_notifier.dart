import 'package:hc_garden/src/library.dart';

/// [FilterNotifier] is a single [ChangeNotifier] that deals with anything
/// involving searching, sorting & filtering of [Entity]s.
/// 
/// Notable properties:
/// - [searchTerm]: set the search term when searching [Entity]s
/// - [selectedTrailKeys]: the list of trail keys that are selected in [FilterDrawer]
/// - [toggleSortByDist()]: toggle the sorting by distance for all [Entity]s

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

  void toggleSortByDist(BuildContext context) async {
    if (_isSortedByDistance) {
      entitiesByDist.clear();
    } else {
      final firebaseData = Provider.of<FirebaseData>(
        context,
        listen: false,
      );
      final location = Location();
      final locationData = await location.getLocation();
      _sortEntitiesByDist(
        firebaseData.entities,
        firebaseData.trails,
        locationData,
      );
    }
    notifyListeners();
    _isSortedByDistance = !_isSortedByDistance;
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