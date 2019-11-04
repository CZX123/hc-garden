import '../library.dart';

class SortingDrawer extends StatelessWidget {
  const SortingDrawer({Key key}) : super(key: key);

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
                  return Selector<SortNotifier, List<Trail>>(
                    selector: (context, sortNotifier) {
                      return sortNotifier.selectedTrails;
                    },
                    builder: (context, selectedTrails, child) {
                      if (selectedTrails == null) {
                        if (allTrails == null)
                          return const SizedBox.shrink();
                        else {
                          selectedTrails = List.from(allTrails);
                          Provider.of<SortNotifier>(context, listen: false)
                              .updateSelectedTrailsDiscreetly(selectedTrails);
                        }
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          for (var trail in allTrails)
                            ListTile(
                              leading: AnimatedOpacity(
                                opacity: selectedTrails.contains(trail) ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.check),
                              ),
                              title: Text(trail.name),
                              onTap: () {
                                final sortNotifier = Provider.of<SortNotifier>(
                                    context,
                                    listen: false);
                                List<Trail> newTrails;
                                if (selectedTrails.contains(trail)) {
                                  newTrails =
                                      List.from(sortNotifier.selectedTrails)
                                        ..remove(trail);
                                } else {
                                  newTrails =
                                      List.from(sortNotifier.selectedTrails)
                                        ..add(trail);
                                }
                                sortNotifier.selectedTrails = newTrails;
                              },
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

class SortNotifier extends ChangeNotifier {
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
