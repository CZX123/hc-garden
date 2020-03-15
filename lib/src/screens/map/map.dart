import 'package:hc_garden/src/library.dart';

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
    _mapController.setMapStyle(mapStyle);
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
              mapType: mapNotifier.mapType,
              rotateGesturesEnabled: false,
              onMapCreated: _onMapCreated,
              onCameraMove: (position) {
                mapNotifier.cameraPosition = position;
              },
              initialCameraPosition: _initialCameraPosition,
              markers: mapNotifier.markers.values.toSet(),
              polygons: mapNotifier.polygons,
            ),
    );
  }
}

/// Updates default markers and polygons of [MapNotifier] by listening to the firebase data stream
class MapDataWidget extends StatefulWidget {
  final Stream<FirebaseData> firebaseDataStream;
  final Widget child;
  const MapDataWidget({
    Key key,
    @required this.firebaseDataStream,
    @required this.child,
  }) : super(key: key);

  @override
  _MapDataWidgetState createState() => _MapDataWidgetState();
}

class _MapDataWidgetState extends State<MapDataWidget> {
  bool _init = false;
  StreamSubscription<FirebaseData> _streamSubscription;

  void _markerOnTap({
    BuildContext context,
    TrailLocation location,
  }) {
    final appNotifier = Provider.of<AppNotifier>(
      context,
      listen: false,
    );
    if (appNotifier.routes.isNotEmpty &&
        appNotifier.routes.last.dataKey is TrailLocationKey &&
        appNotifier.routes.last.dataKey == location.key) {
      Provider.of<BottomSheetNotifier>(
        context,
        listen: false,
      ).animateTo(0);
    } else {
      appNotifier.push(
        context: context,
        routeInfo: RouteInfo(
          name: location.name,
          dataKey: location.key,
          route: CrossFadePageRoute(
            builder: (context) {
              return Material(
                color: Theme.of(context).bottomAppBarColor,
                child: TrailLocationOverviewPage(
                  trailLocationKey: location.key,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Marker _generateMarker({
    BuildContext context,
    TrailLocation location,
  }) {
    final mapNotifier = Provider.of<MapNotifier>(context, listen: false);
    final markerId = MarkerId('${location.key.trailKey.id} ${location.key.id}');
    return Marker(
      onTap: () {
        mapNotifier.activeMarker = markerId;
        _markerOnTap(context: context, location: location);
      },
      markerId: markerId,
      position: location.coordinates,
      infoWindow: InfoWindow(
        title: location.name,
        onTap: () {
          _markerOnTap(context: context, location: location);
        },
      ),
      icon: mapNotifier.markerIcons[location.key.trailKey.id],
    );
  }

  void onData(FirebaseData data, {bool notify = true}) {
    final mapNotifier = context.provide<MapNotifier>(listen: false);
    Map<MarkerId, Marker> mapMarkers = {};
    data?.trails?.forEach((trailKey, locations) {
      locations.forEach((key, value) {
        mapMarkers[MarkerId('${trailKey.id} ${key.id}')] = _generateMarker(
          context: context,
          location: value,
        );
      });
    });
    if (mapMarkers.isNotEmpty) {
      mapNotifier.setDefaultMarkers(
        mapMarkers,
        notify: notify,
      );
    }
    mapNotifier.setPolygons(data?.mapPolygons, notify: notify);
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
