import 'dart:io' show Platform;
import 'library.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class DebugNotifier extends ChangeNotifier {
  bool _isIOS = Platform.isIOS;
  bool get isIOS => _isIOS;
  bool _debugShowMaterialGrid = false;
  bool get debugShowMaterialGrid => _debugShowMaterialGrid;
  bool _showPerformanceOverlay = false;
  bool get showPerformanceOverlay => _showPerformanceOverlay;
  bool _checkerboardRasterCacheImages = false;
  bool get checkerboardRasterCacheImages => _checkerboardRasterCacheImages;
  bool _checkerboardOffscreenLayers = false;
  bool get checkerboardOffscreenLayers => _checkerboardOffscreenLayers;
  bool _showSemanticsDebugger = false;
  bool get showSemanticsDebugger => _showSemanticsDebugger;
  bool _debugShowCheckedModeBanner = true;
  bool get debugShowCheckedModeBanner => _debugShowCheckedModeBanner;

  void toggleIOS() {
    _isIOS = !_isIOS;
    notifyListeners();
  }

  void toggleSlowAnimations() {
    timeDilation = timeDilation == 1.0 ? 5.0 : 1.0;
  }

  void toggleMaterialGrid() {
    _debugShowMaterialGrid = !_debugShowMaterialGrid;
    notifyListeners();
  }

  void togglePerformanceOverlay() {
    _showPerformanceOverlay = !_showPerformanceOverlay;
    notifyListeners();
  }

  void toggleCheckerboardRasterCacheImages() {
    _checkerboardRasterCacheImages = !_checkerboardRasterCacheImages;
    notifyListeners();
  }

  void toggleCheckerboardOffscreenLayers() {
    _checkerboardOffscreenLayers = !_checkerboardOffscreenLayers;
    notifyListeners();
  }

  void toggleSemanticsDebugger() {
    _showSemanticsDebugger = !_showSemanticsDebugger;
    notifyListeners();
  }

  void toggleCheckedModeBanner() {
    _debugShowCheckedModeBanner = !_debugShowCheckedModeBanner;
    notifyListeners();
  }
}

class DebugDrawer extends StatefulWidget {
  const DebugDrawer({Key key}) : super(key: key);

  @override
  _DebugDrawerState createState() => _DebugDrawerState();
}

class _DebugDrawerState extends State<DebugDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Consumer<DebugNotifier>(
          builder: (context, debugInfo, child) {
            return ListView(
              shrinkWrap: true,
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Show Material Grid'),
                  value: debugInfo.debugShowMaterialGrid,
                  onChanged: (_) => debugInfo.toggleMaterialGrid(),
                ),
                SwitchListTile(
                  title: const Text('Show Performance Overlay'),
                  value: debugInfo.showPerformanceOverlay,
                  onChanged: (_) => debugInfo.togglePerformanceOverlay(),
                ),
                SwitchListTile(
                  title: const Text('Checkerboard Raster Cache Images'),
                  value: debugInfo.checkerboardRasterCacheImages,
                  onChanged: (_) =>
                      debugInfo.toggleCheckerboardRasterCacheImages(),
                ),
                SwitchListTile(
                  title: const Text('Checkerboard Offscreen Layers'),
                  value: debugInfo.checkerboardOffscreenLayers,
                  onChanged: (_) => debugInfo.toggleCheckerboardOffscreenLayers(),
                ),
                SwitchListTile(
                  title: const Text('Show Semantics Debugger'),
                  value: debugInfo.showSemanticsDebugger,
                  onChanged: (_) => debugInfo.toggleSemanticsDebugger(),
                ),
                SwitchListTile(
                  title: const Text('Show Checked Mode Banner'),
                  value: debugInfo.debugShowCheckedModeBanner,
                  onChanged: (_) => debugInfo.toggleCheckedModeBanner(),
                ),
                SwitchListTile(
                  title: const Text('Slow Animations'),
                  value: timeDilation != 1.0,
                  onChanged: (_) {
                    debugInfo.toggleSlowAnimations();
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('Toggle iOS'),
                  value: debugInfo.isIOS,
                  onChanged: (_) => debugInfo.toggleIOS(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
