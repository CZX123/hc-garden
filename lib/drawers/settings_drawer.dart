import 'dart:io' show Platform;
import '../library.dart';
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

  void _changeMapType(CustomMapType newType) {
    Provider.of<MapNotifier>(context, listen: false).mapType = newType;
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                          title: const Text('Dark Mode'),
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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Map Type',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Selector<MapNotifier, CustomMapType>(
                      selector: (context, m) => m.mapType,
                      builder: (context, mapType, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<CustomMapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: CustomMapType.normal,
                              title: const Text('Normal'),
                              onChanged: _changeMapType,
                            ),
                            RadioListTile<CustomMapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: CustomMapType.dark,
                              title: const Text('Dark'),
                              onChanged: _changeMapType,
                            ),
                            RadioListTile<CustomMapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: CustomMapType.satellite,
                              title: const Text('Satellite'),
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
                                    const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                child: Text(
                                  'Debug',
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                              ),
                              CheckboxListTile(
                                dense: true,
                                title: const Text('Show Performance Overlay'),
                                value: debugInfo.showPerformanceOverlay,
                                checkColor: Theme.of(context).canvasColor,
                                onChanged: (_) =>
                                    debugInfo.togglePerformanceOverlay(),
                              ),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return CheckboxListTile(
                                    dense: true,
                                    title: const Text('Slow Animations'),
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
                                title: const Text('Toggle iOS'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
