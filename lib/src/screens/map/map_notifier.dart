import 'package:hc_garden/src/library.dart';

class MapNotifier extends ChangeNotifier {
  // todo: Do something with these information
  bool permissionEnabled;
  bool gpsOn;
  GoogleMapController mapController;
  final markerIcons = [
    BitmapDescriptor.defaultMarkerWithHue(38),
    BitmapDescriptor.defaultMarkerWithHue(340),
    BitmapDescriptor.defaultMarkerWithHue(199),
    BitmapDescriptor.defaultMarkerWithHue(90),
  ];

  CameraPosition cameraPosition;

  double bottomSheetHeight = Sizes.kBottomHeight - Sizes.hBottomBarHeight;

  /// Translation needed to move the map up if bottom sheet is half expanded. (+ve values)
  double getAdjustAmount(double zoom) {
    const circumference = 2 * pi * 6378137;
    final metresPerPixel =
        156543.03392 * cos(center.latitude * pi / 180) / pow(2, zoom);
    // height of bottom sheet in metres, based on the map
    final height = bottomSheetHeight / 2 * metresPerPixel;
    final angle = height / circumference * 360;
    return angle;
  }

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;
  set mapType(MapType mapType) {
    if (mapType == _mapType) return;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('mapType', MapType.values.indexOf(mapType));
    });
    _mapType = mapType;
    notifyListeners();
  }

  List<MarkerId> greenMarkers = [];
  bool isDefaultMarkers = false;

  Map<MarkerId, Marker> _defaultMarkers;
  Map<MarkerId, Marker> get defaultMarkers => _defaultMarkers;
  void setDefaultMarkers(
    Map<MarkerId, Marker> defaultMarkers, {
    bool notify = true,
  }) {
    _defaultMarkers = defaultMarkers;
    if (_markers == null || isDefaultMarkers) {
      _markers = _defaultMarkers;
      if (notify) notifyListeners();
      isDefaultMarkers = true;
    }
  }

  Map<MarkerId, Marker> _markers;
  Map<MarkerId, Marker> get markers => _markers;

  /// This will also call [notifyListeners]
  set markers(Map<MarkerId, Marker> markers) {
    if (mapEquals(_markers, markers)) return;
    _markers = markers;
    notifyListeners();
  }

  void _replaceWithGreenMarker(
    Map<MarkerId, Marker> markers,
    MarkerId markerId,
  ) {
    isDefaultMarkers = false;
    greenMarkers.add(markerId);
    markers[markerId] = markers[markerId].copyWith(
      iconParam: markerIcons.last,
    );
  }

  void rebuildMap() {
    notifyListeners();
  }

  /// Animate to a specific point
  void _animateToPoint(LatLng point, double zoom, [bool adjusted = false]) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      adjusted
          ? LatLng(
              point.latitude - getAdjustAmount(zoom),
              point.longitude,
            )
          : point,
      zoom,
    ));
  }

  /// Get the correct zoom level of the map from the bounds, and mapSize in pts
  double _getZoomFromBounds(LatLngBounds bounds, Size mapSize) {
    final centerLat =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    const circumference = 2 * pi * 6378137;
    final latAngle = (bounds.northeast.latitude - bounds.southwest.latitude);
    final lngAngle = (bounds.northeast.longitude - bounds.southwest.longitude);
    final height = latAngle * circumference / 360;
    final width = lngAngle * circumference / 360;
    final metresPerPixel = max(width / mapSize.width, height / mapSize.height);
    final zoom =
        log(156543.03392 * cos(centerLat * pi / 180) / metresPerPixel) / log(2);
    return zoom;
  }

  /// Animate to the bounds of a list of points
  void _animateToPoints(
    List<LatLng> points, [
    bool adjusted = false,
    Size mapSize,
  ]) {
    if (points?.isEmpty ?? true)
      return;
    else if (points.length == 1) {
      return _animateToPoint(points.first, 18.5, adjusted);
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
    final bounds = LatLngBounds(
      northeast: LatLng(maxLat, maxLng),
      southwest: LatLng(minLat, minLng),
    );
    final center = LatLng(
      (minLat + maxLat) / 2 + 0.00008,
      (minLng + maxLng) / 2,
    );
    final zoom = min(_getZoomFromBounds(bounds, mapSize) * .98, 19.0);
    _animateToPoint(center, zoom, adjusted);
  }

  /// Animate back to default map of HC Garden
  void animateBackToCenter({bool adjusted = false}) {
    if (!isDefaultMarkers) {
      greenMarkers = [];
      markers = defaultMarkers;
      isDefaultMarkers = true;
    }
    _animateToPoint(center, 16.4, adjusted);
  }

  /// Moves the map to a specific location on a trail
  void animateToLocation({
    TrailLocation location,
    double zoom = 18.5,
    bool adjusted = false,
    bool changeMarkerColor = false,
  }) {
    if (changeMarkerColor) {
      final newMarkers = Map<MarkerId, Marker>.from(defaultMarkers);
      greenMarkers = [];
      final markerId =
          MarkerId('${location.key.trailKey.id} ${location.key.id}');
      _replaceWithGreenMarker(newMarkers, markerId);
      markers = newMarkers;
    }
    // TODO: Focus on the specific marker as well
    // (need to wait for upcoming update for google maps plugin)
    // https://github.com/flutter/flutter/issues/33481
    _animateToPoint(location.coordinates, zoom ?? 18.5, adjusted);
  }

  /// Moves the map to the bounding box of all locations of the entity
  void animateToEntity({
    @required Entity entity,
    @required TrailMap trails,
    @required Size mapSize,
    bool adjusted = false,
  }) {
    greenMarkers = [];
    final newMarkers = Map<MarkerId, Marker>.from(defaultMarkers);
    final points = entity.locations.map((entityLocation) {
      final trailLocationKey = entityLocation.trailLocationKey;
      final markerId =
          MarkerId('${trailLocationKey.trailKey.id} ${trailLocationKey.id}');
      _replaceWithGreenMarker(newMarkers, markerId);
      final location = trails[trailLocationKey.trailKey][trailLocationKey];
      return location.coordinates;
    }).toList();
    markers = newMarkers;
    _animateToPoints(points, adjusted, mapSize);
  }

  /// Moves the map to the bounding box of a trail
  void animateToTrail({
    List<TrailLocation> locations,
    bool adjusted = false,
    Size mapSize,
  }) {
    if (!isDefaultMarkers) {
      greenMarkers = [];
      markers = defaultMarkers;
      isDefaultMarkers = true;
    }
    final points = locations.map((location) => location.coordinates).toList();
    _animateToPoints(points, adjusted, mapSize);
  }

  /// Stop any map movement. This is used when markers are tapped to prevent map from moving to the marker.
  void stopAnimating() {
    mapController?.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
