import 'dart:io' show Platform;
import 'package:hc_garden/src/library.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class DebugNotifier extends ChangeNotifier {
  bool _isIOS = Platform.isIOS;
  bool get isIOS => _isIOS;
  bool _showPerformanceOverlay = false;
  bool get showPerformanceOverlay => _showPerformanceOverlay;

  void toggleIOS() {
    _isIOS = !_isIOS;
    notifyListeners();
  }

  void toggleSlowAnimations() {
    timeDilation = timeDilation == 1.0 ? 5.0 : 1.0;
  }

  void togglePerformanceOverlay() {
    _showPerformanceOverlay = !_showPerformanceOverlay;
    notifyListeners();
  }
}

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key key}) : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  bool _showDebug = false;

  void _toggleDebugOptions() {
    setState(() {
      _showDebug = !_showDebug;
    });
  }

  void _changeMapType(MapType newType) {
    final mapNotifier = context.provide<MapNotifier>(listen: false);
    mapNotifier.mapType = newType;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    return Drawer(
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, topPadding + 16, 0, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height - topPadding - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Preferences',
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
                        'App Theme',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Consumer<ThemeNotifier>(
                      builder: (context, themeNotifier, child) {
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 0, 8, 0),
                          title: Text(
                            'Dark Mode',
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Switch(
                            value: themeNotifier.value,
                            onChanged: (value) => themeNotifier.value = value,
                          ),
                          onLongPress: _toggleDebugOptions,
                          onTap: () =>
                              themeNotifier.value = !themeNotifier.value,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'Map Type',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Selector<MapNotifier, MapType>(
                      selector: (context, m) => m.mapType,
                      builder: (context, mapType, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<MapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: MapType.normal,
                              title: Text(
                                'Normal',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: _changeMapType,
                            ),
                            RadioListTile<MapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: MapType.hybrid,
                              title: Text(
                                'Satellite',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: _changeMapType,
                            ),
                          ],
                        );
                      },
                    ),
                    if (_showDebug)
                      Consumer<DebugNotifier>(
                        builder: (context, debugInfo, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 28, 16, 12),
                                child: Text(
                                  'Debug',
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                              ),
                              CheckboxListTile(
                                dense: true,
                                title: Text(
                                  'Show Performance Overlay',
                                  style: Theme.of(context).textTheme.body1,
                                ),
                                value: debugInfo.showPerformanceOverlay,
                                checkColor: Theme.of(context).canvasColor,
                                onChanged: (_) =>
                                    debugInfo.togglePerformanceOverlay(),
                              ),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return CheckboxListTile(
                                    dense: true,
                                    title: Text(
                                      'Slow Animations',
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                    value: timeDilation != 1.0,
                                    checkColor: Theme.of(context).canvasColor,
                                    onChanged: (_) {
                                      debugInfo.toggleSlowAnimations();
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                              CheckboxListTile(
                                dense: true,
                                title: Text(
                                  'Toggle iOS',
                                  style: Theme.of(context).textTheme.body1,
                                ),
                                value: debugInfo.isIOS,
                                checkColor: Theme.of(context).canvasColor,
                                onChanged: (_) => debugInfo.toggleIOS(),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox.shrink(),
                IconButton(
                  icon: const Icon(Icons.help),
                  color: Theme.of(context).hintColor,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, OnboardingPageRoute(
                      builder: (context) => OnboardingPage(),
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
