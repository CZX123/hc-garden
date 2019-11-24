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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Sort',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    RadioListTile<bool>(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: true,
                      value: true,
                      title: const Text('Alphabetical'),
                      onChanged: (_) {},
                    ),
                    RadioListTile<bool>(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: true,
                      value: false,
                      title: const Text('Distance'),
                      subtitle: const Text('Coming Soon'),
                    ),
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
