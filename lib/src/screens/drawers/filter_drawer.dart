import 'package:hc_garden/src/library.dart';

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