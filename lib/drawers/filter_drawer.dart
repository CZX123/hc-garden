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
                    Selector<FirebaseData, List<Trail>>(
                      selector: (context, firebaseData) {
                        return firebaseData.trails.keys.toList();
                      },
                      builder: (context, allTrails, child) {
                        return Selector<FilterNotifier, List<Trail>>(
                          selector: (context, sortNotifier) {
                            return sortNotifier.selectedTrails;
                          },
                          builder: (context, selectedTrails, child) {
                            if (selectedTrails == null) {
                              if (allTrails == null)
                                return const SizedBox.shrink();
                              else {
                                selectedTrails = List.from(allTrails);
                                Provider.of<FilterNotifier>(context,
                                        listen: false)
                                    .updateSelectedTrailsDiscreetly(
                                        selectedTrails);
                              }
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: allTrails.map((trail) {
                                return CheckboxListTile(
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: selectedTrails.contains(trail),
                                  title: Text(
                                    trail.name.split('(').first.trimRight(),
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                  checkColor: Theme.of(context).canvasColor,
                                  onChanged: (value) {
                                    final sortNotifier =
                                        Provider.of<FilterNotifier>(context,
                                            listen: false);
                                    List<Trail> newTrails =
                                        List.from(sortNotifier.selectedTrails);
                                    newTrails.remove(trail);
                                    if (value) {
                                      newTrails.add(trail);
                                    }
                                    sortNotifier.selectedTrails = newTrails;
                                  },
                                );
                              }).toList(),
                            );
                          },
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
                        return filterNotifier.groupValue;
                      },
                      builder: (context, groupValue, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<bool>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: groupValue,
                              value: true,
                              title: Text(
                                'Alphabetical',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: (value) {
                                Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                ).groupValue = value;
                              },
                            ),
                            RadioListTile<bool>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: groupValue,
                              value: false,
                              title: Text(
                                'Distance',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: (value) async {
                                final filterNotifier =
                                    Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                );
                                final firebaseData = Provider.of<FirebaseData>(
                                    context,
                                    listen: false);
                                final location = Location();
                                final locationData =
                                    await location.getLocation();
                                final floraListByDist =
                                    filterNotifier.sortEntityByDist(
                                        firebaseData.floraMap,
                                        firebaseData.trails,
                                        locationData);
                                final faunaListByDist =
                                    filterNotifier.sortEntityByDist(
                                        firebaseData.faunaMap,
                                        firebaseData.trails,
                                        locationData);
                                floraListByDist.sort((a, b) => a.distMin.compareTo(b.distMin));
                                faunaListByDist.sort((a, b) => a.distMin.compareTo(b.distMin));
                                filterNotifier.updateLists(
                                    floraListByDist, faunaListByDist);
                                filterNotifier.groupValue = value;
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
  bool _groupValue = true;
  bool get groupValue => _groupValue;
  set groupValue(bool groupValue) {
    _groupValue = groupValue;
    notifyListeners();
  }

  List<Trail> _selectedTrails;
  List<Trail> get selectedTrails => _selectedTrails;
  set selectedTrails(List<Trail> selectedTrails) {
    _selectedTrails = selectedTrails;
    notifyListeners();
  }

  List<Entity> _floraList;
  List<Entity> get floraList => _floraList;
  List<Entity> _faunaList;
  List<Entity> get faunaList => _faunaList;
  void updateLists(List<Entity> floraList, List<Entity> faunaList) {
    _floraList = floraList;
    _faunaList = faunaList;
    notifyListeners();
  }

  List<Entity> sortEntityByDist(Map<int, Entity> entityMap,
      Map<Trail, Map<int, TrailLocation>> trails, LocationData locationData) {
    final List<Entity> entityListByDist = [];
    entityMap.forEach((key, value) {
      for (var location in value.locations) {
        final trail = trails.keys.firstWhere((trail) {
          return trail.id == location[0];
        });
        final trailLocation = trails[trail][location[1]];
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
        if (dist < value.distMin) value.distMin = dist;
      }
      entityListByDist.add(value);
    });
    return entityListByDist;
  }

  void updateSelectedTrailsDiscreetly(List<Trail> selectedTrails) {
    _selectedTrails = selectedTrails;
  }
}
