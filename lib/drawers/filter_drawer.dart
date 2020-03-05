import '../library.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    return Drawer(
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, topPadding + 16, 0, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height - topPadding - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Filter',
                    style: Theme.of(context).textTheme.display2,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'Trails',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Selector<FilterNotifier, List<TrailKey>>(
                      selector: (context, filterNotifier) {
                        return filterNotifier.selectedTrailKeys;
                      },
                      builder: (context, selectedTrailKeys, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: FirebaseData.trailNames
                              .asMap()
                              .entries
                              .map((trailEntry) {
                            return CheckboxListTile(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: !selectedTrailKeys.every((key) {
                                return key.id != trailEntry.key;
                              }),
                              title: Text(
                                trailEntry.value,
                                style: Theme.of(context).textTheme.body1,
                              ),
                              checkColor: Theme.of(context).canvasColor,
                              onChanged: (value) {
                                final filterNotifier =
                                    Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                );
                                final newTrailKeys = List<TrailKey>.from(
                                  filterNotifier.selectedTrailKeys,
                                );
                                final trailKey = TrailKey(id: trailEntry.key);
                                newTrailKeys.remove(trailKey);
                                if (value) {
                                  newTrailKeys.add(trailKey);
                                }
                                filterNotifier.selectedTrailKeys = newTrailKeys;
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'Sort',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Selector<FilterNotifier, bool>(
                      selector: (context, filterNotifier) {
                        return filterNotifier.isSortedByDistance;
                      },
                      builder: (context, groupValue, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<bool>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: groupValue,
                              value: false,
                              title: Text(
                                'Alphabetical',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: (value) {
                                Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                ).toggleSortByDist(context);
                              },
                            ),
                            RadioListTile<bool>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: groupValue,
                              value: true,
                              title: Text(
                                'Distance',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: (value) {
                                Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                ).toggleSortByDist(context);
                              },
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterNotifier extends ChangeNotifier {
  /// All trails are selected by default
  List<TrailKey> _selectedTrailKeys = [
    for (final i in [0, 1, 2]) TrailKey(id: i)
  ];
  List<TrailKey> get selectedTrailKeys => _selectedTrailKeys;
  set selectedTrailKeys(List<TrailKey> selectedTrailKeys) {
    _selectedTrailKeys = selectedTrailKeys;
    notifyListeners();
  }

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
