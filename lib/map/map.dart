import '../library.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  bool _init = false;
  GoogleMapController _mapController;
  CameraPosition _initialCameraPosition;
  static const _initialZoom = 16.4;

  /// When map is first built, it does not have the top padding, so the initial camera position will also have to account for [topPaddingAdjustment]
  double get topPaddingAdjustment {
    final topPadding = MediaQuery.of(context).padding.top;
    const circumference = 2 * pi * 6378137;
    final metresPerPixel =
        156543.03392 * cos(center.latitude * pi / 180) / pow(2, _initialZoom);
    final _height = topPadding / 2 * metresPerPixel;
    return _height / circumference * 360;
  }

  void rebuild() {
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    final mapNotifier = Provider.of<MapNotifier>(context, listen: false);
    _mapController = controller;
    mapNotifier.mapController = _mapController;
    _mapController.setMapStyle(
        mapNotifier.mapType == CustomMapType.dark ? darkMapStyle : mapStyle);
    // Needed to correctly apply padding
    rebuild();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Needed because of a bug with Google Maps not showing, after going back from recents
      // Don't know if this works consistently, 1s randomly chosen
      Future.delayed(const Duration(seconds: 1), rebuild);
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
    if (!_init) {
      final mapNotifier = Provider.of<MapNotifier>(context);
      final adjustAmount = mapNotifier.getAdjustAmount(_initialZoom);
      _initialCameraPosition = CameraPosition(
        target: LatLng(
          center.latitude - adjustAmount + topPaddingAdjustment,
          center.longitude,
        ),
        zoom: _initialZoom,
      );
      mapNotifier.cameraPosition = CameraPosition(
        target: LatLng(
          center.latitude - adjustAmount,
          center.longitude,
        ),
        zoom: _initialZoom,
      );
      _init = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapNotifier = Provider.of<MapNotifier>(context);
    return CustomAnimatedSwitcher(
      fadeIn: true,
      child: mapNotifier.markers?.isEmpty ?? true
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
              ),
            )
          : GoogleMap(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              myLocationEnabled: true,
              mapType: mapNotifier.mapType == CustomMapType.satellite
                  ? MapType.hybrid
                  : MapType.normal,
              rotateGesturesEnabled: false,
              onMapCreated: _onMapCreated,
              onCameraMove: (position) {
                mapNotifier.cameraPosition = position;
              },
              initialCameraPosition: _initialCameraPosition,
              markers: mapNotifier.markers.values.toSet(),
            ),
    );
  }
}

/// Updates default markers of [MapNotifier] by listening to the firebase data stream
class MarkerDataWidget extends StatefulWidget {
  final Stream<FirebaseData> firebaseDataStream;
  final Widget child;
  const MarkerDataWidget({
    Key key,
    @required this.firebaseDataStream,
    @required this.child,
  }) : super(key: key);

  @override
  _MarkerDataWidgetState createState() => _MarkerDataWidgetState();
}

class _MarkerDataWidgetState extends State<MarkerDataWidget> {
  bool _init = false;
  StreamSubscription<FirebaseData> _streamSubscription;

  Marker _generateMarker({
    BuildContext context,
    Trail trail,
    TrailLocation location,
  }) {
    final mapNotifier = Provider.of<MapNotifier>(context, listen: false);
    return Marker(
      onTap: () {
        final appNotifier = Provider.of<AppNotifier>(
          context,
          listen: false,
        );
        if (appNotifier.routes.isNotEmpty &&
            appNotifier.routes.last.data is TrailLocation &&
            appNotifier.routes.last.data == location) {
          Provider.of<BottomSheetNotifier>(
            context,
            listen: false,
          ).animateTo(0);
        } else {
          appNotifier.push(
            context: context,
            routeInfo: RouteInfo(
              name: location.name,
              data: location,
              route: CrossFadePageRoute(
                builder: (context) {
                  return Material(
                    color: Theme.of(context).bottomAppBarColor,
                    child: TrailLocationOverviewPage(
                      trailLocation: location,
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
      markerId: MarkerId('${trail.id} ${location.id}'),
      position: location.coordinates,
      infoWindow: InfoWindow(
        title: location.name,
        onTap: () {
          final appNotifier = Provider.of<AppNotifier>(
            context,
            listen: false,
          );
          if (appNotifier.routes.isNotEmpty &&
              appNotifier.routes.last.data is TrailLocation &&
              appNotifier.routes.last.data == location) {
            Provider.of<BottomSheetNotifier>(
              context,
              listen: false,
            ).animateTo(0);
          } else {
            appNotifier.push(
              context: context,
              routeInfo: RouteInfo(
                name: location.name,
                data: location,
                route: CrossFadePageRoute(
                  builder: (context) {
                    return Material(
                      color: Theme.of(context).bottomAppBarColor,
                      child: TrailLocationOverviewPage(
                        trailLocation: location,
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
      icon: mapNotifier.mapType == CustomMapType.dark
          ? mapNotifier.darkThemeMarkerIcons[trail.id - 1]
          : mapNotifier.lightThemeMarkerIcons[trail.id - 1],
    );
  }

  void onData(FirebaseData data, {bool notify = true}) {
    Map<MarkerId, Marker> mapMarkers = {};
    data.trails.forEach((trail, locations) {
      for (var location in locations) {
        mapMarkers[MarkerId('${trail.id} ${location.id}')] = _generateMarker(
          context: context,
          trail: trail,
          location: location,
        );
      }
    });
    if (data.trails.isNotEmpty) {
      Provider.of<MapNotifier>(context, listen: false).setDefaultMarkers(
        mapMarkers,
        notify: notify,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _streamSubscription = widget.firebaseDataStream.listen(onData);
      onData(Provider.of<FirebaseData>(context, listen: false), notify: false);
      _init = true;
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum CustomMapType {
  normal,
  satellite,
  dark,
}
