import '../library.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController _mapController;
  final _padding = ValueNotifier(EdgeInsets.zero);
  bool _init = false;
  AppNotifier _appNotifier;
  BottomSheetNotifier _bottomSheetNotifier;
  ThemeNotifier _themeNotifier;
  int _state;
  double _height;

  void themeListener() {
    if (_themeNotifier.value)
      // _mapController.setMapStyle(darkMapStyle);
      _mapController.setMapStyle(mapStyle);
    else
      _mapController.setMapStyle(mapStyle);
  }

  void stateListener() {
    if (_appNotifier.state == _state || _appNotifier.state == 2) return;
    if (_appNotifier.state == 1) {
      _bottomSheetNotifier.animation.removeListener(animListener);
      _padding.value = _padding.value.copyWith(
        bottom: 48.0 + 96.0 - bottomBarHeight,
      );
    } else {
      _bottomSheetNotifier.animation.addListener(animListener);
      animListener();
    }
    _state = _appNotifier.state;
  }

  void animListener() {
    if (_bottomSheetNotifier.animation.value >= _height - bottomHeight + 8) {
      if (_padding.value.bottom != 0) {
        _padding.value = _padding.value.copyWith(
          bottom: 0,
        );
        // _mapController?.getScreenCoordinate(center)?.then((c) {
        //   print(c);
        //   print((bottomHeight - bottomBarHeight) /
        //       -2 *
        //       MediaQuery.of(context).devicePixelRatio);
        // });
        // _mapController?.animateCamera(CameraUpdate.scrollBy(
        //   0,
        //   (bottomHeight - bottomBarHeight) /
        //       -2 *
        //       MediaQuery.of(context).devicePixelRatio,
        // ));
      }
    } else if (_padding.value.bottom != bottomHeight - bottomBarHeight) {
      _padding.value = _padding.value.copyWith(
        bottom: bottomHeight - bottomBarHeight,
      );
      // _mapController?.animateCamera(CameraUpdate.scrollBy(
      //   0,
      //   (bottomHeight - bottomBarHeight) / 2,
      // ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    Provider.of<MapNotifier>(
      context,
      listen: false,
    ).mapController = _mapController;
    setState(() {}); // Needed to apply padding to map
    _padding.value = _padding.value.copyWith(
      top: MediaQuery.of(context).padding.top,
    );
    stateListener();
    themeListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _height = MediaQuery.of(context).size.height;
    if (!_init) {
      _appNotifier = Provider.of<AppNotifier>(
        context,
        listen: false,
      )..addListener(stateListener);
      _bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
        context,
        listen: false,
      );
      _themeNotifier = Provider.of<ThemeNotifier>(
        context,
        listen: false,
      )..addListener(themeListener);
      stateListener();
      _init = true;
    }
  }

  @override
  void dispose() {
    _appNotifier.removeListener(stateListener);
    _bottomSheetNotifier.animation.removeListener(animListener);
    _themeNotifier.removeListener(themeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeNotifier>(context).value;
    return Selector<FirebaseData, Map<Trail, List<TrailLocation>>>(
      selector: (context, firebaseData) => firebaseData.trails,
      builder: (context, trails, child) {
        Set<Marker> markers = {};
        if (trails.isNotEmpty) {
          if (markers.isEmpty) {
            int i = 0;
            final trailList = trails.keys.toList()
              ..sort(
                (a, b) => a.id.compareTo(b.id),
              );
            for (var trail in trailList) {
              final hues = [
                isDark ? 30.0 : 42.0,
                isDark ? 352.0 : 340.0,
                isDark ? 210.0 : 199.0,
              ];
              for (var location in trails[trail]) {
                markers.add(
                  Marker(
                    markerId: MarkerId('${trail.id} ${location.id}'),
                    position: location.coordinates,
                    infoWindow: InfoWindow(
                      title: location.name,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrailLocationOverviewPage(
                                  trail: trail, trailLocation: location)),
                        );
                      },
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(hues[i]),
                  ),
                );
              }
              i++;
            }
          }
        }
        return CustomAnimatedSwitcher(
          crossShrink: false,
          child: trails.isEmpty || markers.isEmpty
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                  ),
                )
              : ValueListenableBuilder<EdgeInsets>(
                  valueListenable: _padding,
                  builder: (context, value, child) {
                    return GoogleMap(
                      padding: value,
                      myLocationEnabled: true,
                      // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                      //   northeast: northEastBound,
                      //   southwest: southWestBound,
                      // )),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: bottomSheetCenter,
                        zoom: 16.8,
                      ),
                      // polygons: polygons,
                      markers: markers,
                    );
                  },
                ),
        );
      },
    );
  }
}

class MapNotifier extends ChangeNotifier {
  // TODO: Do something with these information
  bool permissionEnabled;
  bool gpsOn;
  GoogleMapController mapController;

  void animateToLocation(TrailLocation location) {
    // TODO: Focus on the specific marker as well
    // (need to wait for upcoming update for google maps plugin)
    // https://github.com/flutter/flutter/issues/33481
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(location.coordinates, 18.5));
  }

  void animateToPosition(LatLng coordinates, [double zoom]) {
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(coordinates, zoom ?? 18));
  }
}
