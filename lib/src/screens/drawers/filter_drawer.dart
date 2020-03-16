import 'package:hc_garden/src/library.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({Key key}) : super(key: key);

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

enum DistanceSortingState {
  none,
  loading,
  locationPermissionDenied,
  locationOff,
}

class _FilterDrawerState extends State<FilterDrawer> {
  final _distanceSortingState = ValueNotifier(DistanceSortingState.none);
  Timer _errorFadeOutTimer;

  @override
  void dispose() {
    _distanceSortingState.dispose();
    super.dispose();
  }

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
                              title: Row(
                                children: <Widget>[
                                  Text(
                                    'Distance',
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                  Spacer(),
                                  ValueListenableBuilder<DistanceSortingState>(
                                    valueListenable: _distanceSortingState,
                                    builder: (context, value, _) {
                                      Widget child = SizedBox.shrink(
                                        key: ObjectKey(value),
                                      );
                                      if (value ==
                                          DistanceSortingState.loading) {
                                        child = SizedBox(
                                          key: ObjectKey(value),
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      } else if (value != DistanceSortingState.none) {
                                        child = Text(
                                          value ==
                                                  DistanceSortingState
                                                      .locationPermissionDenied
                                              ? 'Permission\ndenied'
                                              : 'Location\noff',
                                          style: TextStyle(
                                            fontSize: 11,
                                            height: 1,
                                            color: Theme.of(context).errorColor,
                                          ),
                                          textAlign: TextAlign.right,
                                        );
                                      }
                                      return CustomAnimatedSwitcher(
                                        child: child,
                                        alignment: Alignment.centerRight,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onChanged: (value) async {
                                _errorFadeOutTimer?.cancel();
                                _distanceSortingState.value =
                                    DistanceSortingState.loading;
                                _distanceSortingState.value =
                                    await Provider.of<FilterNotifier>(
                                  context,
                                  listen: false,
                                ).toggleSortByDist(context);
                                if (_distanceSortingState.value !=
                                    DistanceSortingState.none) {
                                  _errorFadeOutTimer =
                                      Timer(const Duration(seconds: 3), () {
                                    _distanceSortingState.value =
                                        DistanceSortingState.none;
                                  });
                                }
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
