import '../library.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: topPadding,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height - topPadding,
              ),
              child: Selector<FirebaseData, List<Trail>>(
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
                          Provider.of<FilterNotifier>(context, listen: false)
                              .updateSelectedTrailsDiscreetly(selectedTrails);
                        }
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Selector<MapNotifier, CustomMapType>(
                            selector: (context, m) => m.mapType,
                            builder: (context, mapType, child) {

                              void onChanged(CustomMapType newType) {
                                Provider.of<MapNotifier>(context, listen: false)
                                    .mapType = newType;
                              }

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      'Map Type',
                                      style:
                                          Theme.of(context).textTheme.subtitle,
                                    ),
                                  ),
                                  RadioListTile<CustomMapType>(
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    groupValue: mapType,
                                    value: CustomMapType.normal,
                                    title: const Text('Normal'),
                                    onChanged: onChanged,
                                  ),
                                  RadioListTile<CustomMapType>(
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    groupValue: mapType,
                                    value: CustomMapType.dark,
                                    title: const Text('Dark'),
                                    onChanged: onChanged,
                                  ),
                                  RadioListTile<CustomMapType>(
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    groupValue: mapType,
                                    value: CustomMapType.satellite,
                                    title: const Text('Satellite'),
                                    onChanged: onChanged,
                                  ),
                                ],
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'Filter',
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                              ),
                              for (var trail in allTrails)
                                CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  value: selectedTrails.contains(trail),
                                  title: Text(
                                    trail.name.split('(').first.trimRight(),
                                  ),
                                  checkColor: Theme.of(context).canvasColor,
                                  onChanged: (value) {
                                    final sortNotifier =
                                        Provider.of<FilterNotifier>(
                                      context,
                                      listen: false,
                                    );
                                    List<Trail> newTrails =
                                        List.from(sortNotifier.selectedTrails);
                                    newTrails.remove(trail);
                                    if (value) {
                                      newTrails.add(trail);
                                    }
                                    sortNotifier.selectedTrails = newTrails;
                                  },
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterNotifier extends ChangeNotifier {
  List<Trail> _selectedTrails;
  List<Trail> get selectedTrails => _selectedTrails;
  set selectedTrails(List<Trail> selectedTrails) {
    _selectedTrails = selectedTrails;
    notifyListeners();
  }

  void updateSelectedTrailsDiscreetly(List<Trail> selectedTrails) {
    _selectedTrails = selectedTrails;
  }
}
