import '../library.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  void _onMapCreated(GoogleMapController controller) {
    Provider.of<MapNotifier>(
      context,
      listen: false,
    ).mapController = controller;
    setState(() {}); // Needed to apply padding to map
    controller.setMapStyle('''[
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry",
        "stylers": [
          {
            "saturation": 20
          },
          {
            "weight": 1
          }
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "lightness": -15
          }
        ]
      },
      {
        "featureType": "poi.school",
        "elementType": "geometry",
        "stylers": [
          {
            "saturation": 20
          },
          {
            "lightness": 30
          }
        ]
      },
      {
        "featureType": "poi.school",
        "elementType": "labels.icon",
        "stylers": [
          {
            "color": "#009688"
          }
        ]
      },
      {
        "featureType": "poi.school",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#009688"
          }
        ]
      },
      {
        "featureType": "poi.business",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]''');
  }

  @override
  Widget build(BuildContext context) {
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
                42.0,
                340.0,
                199.0,
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
                          MaterialPageRoute(builder: (context) => TrailLocationOverviewPage(
                            trail: trail, trailLocation: location
                          )),
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
              : GoogleMap(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  myLocationEnabled: true,
                  // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                  //   northeast: northEastBound,
                  //   southwest: southWestBound,
                  // )),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: bottomSheetCenter,
                    zoom: 17,
                  ),
                  // polygons: polygons,
                  markers: markers,
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
