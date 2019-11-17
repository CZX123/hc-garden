import '../library.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  GoogleMapController _mapController;
  final _padding = ValueNotifier(EdgeInsets.zero);
  bool _init = false;
  AppNotifier _appNotifier;
  BottomSheetNotifier _bottomSheetNotifier;
  ThemeNotifier _themeNotifier;
  double _height;

  void themeListener() {
    if (_themeNotifier.value)
      // TODO: _mapController.setMapStyle(darkMapStyle);
      _mapController?.setMapStyle(mapStyle);
    else
      _mapController?.setMapStyle(mapStyle);
  }

  void animListener() {
    if (_appNotifier.state == 2) return;
    if (_bottomSheetNotifier.animation.value > _height - bottomHeight + 8 ||
        _appNotifier.hasEntity.value &&
            _bottomSheetNotifier.animation.value < 8) {
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
    animListener();
    themeListener();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Needed because of a bug with Google Maps not showing, after going back from recents
      // Don't know if it works just yet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _height = MediaQuery.of(context).size.height;
    if (!_init) {
      _appNotifier = Provider.of<AppNotifier>(
        context,
        listen: false,
      )..hasEntity.addListener(animListener);
      _bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
        context,
        listen: false,
      )..animation.addListener(animListener);
      _themeNotifier = Provider.of<ThemeNotifier>(
        context,
        listen: false,
      )..addListener(themeListener);
      animListener();
      _init = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appNotifier.hasEntity.removeListener(animListener);
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
                        final appNotifier = Provider.of<AppNotifier>(
                          context,
                          listen: false,
                        );
                        if (appNotifier.location != location) {
                          appNotifier
                            ..navigatorKey.currentState.push(
                              CrossFadePageRoute(
                                builder: (context) {
                                  return Material(
                                    color: Theme.of(context).bottomAppBarColor,
                                    child: TrailLocationOverviewPage(
                                      trailLocation: location,
                                    ),
                                  );
                                },
                              ),
                            )
                            ..changeState(
                              context,
                              1,
                            );
                        }
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
  Set<Marker> _markers;
  Set<Marker> get markers => _markers;

  void setMarkers(Set<Marker> markers, {bool notify = true}) {
    _markers = markers;
    if (notify ?? true) notifyListeners();
  }

  void _animateToPoint(LatLng point, double zoom) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(point, zoom));
  }

  void _animateToPoints(List<LatLng> points, double padding) {
    if (points?.isEmpty ?? true)
      return;
    else if (points.length == 1) {
      return _animateToPoint(points.first, 18.5);
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final point in points.sublist(1)) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      } else if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      } else if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        northeast: LatLng(maxLat, maxLng),
        southwest: LatLng(minLat, minLng),
      ),
      padding,
    ));
  }

  /// Animate back to default map of HC Garden
  void animateBackToCenter([bool shiftedUpwards = false]) {
    _animateToPoint(shiftedUpwards ? bottomSheetCenter : center, 16.8);
  }

  /// Moves the map to a specific location on a trail
  void animateToLocation(TrailLocation location, [double zoom = 18.5]) {
    // TODO: Focus on the specific marker as well
    // (need to wait for upcoming update for google maps plugin)
    // https://github.com/flutter/flutter/issues/33481
    _animateToPoint(location.coordinates, zoom ?? 18.5);
  }

  /// Moves the map to the bounding box of all locations of the entity
  void animateToEntity(
    Entity entity,
    Map<Trail, List<TrailLocation>> trails, [
    double padding = 36,
  ]) {
    final points = entity.locations.map((tuple) {
      final int trailId = tuple[0];
      final int locationId = tuple[1];
      final trail = trails.keys.firstWhere((trail) {
        return trail.id == trailId;
      });
      final location = trails[trail].firstWhere((loc) {
        return loc.id == locationId;
      });
      return location.coordinates;
    }).toList();
    _animateToPoints(points, padding ?? 36);
  }

  /// Moves the map to the bounding box of a trail
  void animateToTrail(List<TrailLocation> locations, [double padding = 36]) {
    final points = locations.map((location) => location.coordinates).toList();
    _animateToPoints(points, padding ?? 36);
  }
}
