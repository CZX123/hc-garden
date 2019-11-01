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
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FirebaseData, Map<Trail, List<TrailLocation>>>(
      selector: (context, firebaseData) => firebaseData.trails,
      builder: (context, trails, child) {
        if (trails.isNotEmpty) {
          final length = trails.values.reduce((a, b) => a + b).length;
          var markers = Provider.of<MapNotifier>(
            context,
            listen: false,
          ).markers;
          Set<Marker> newMarkers = {};
          if (markers.isEmpty) {
            for (var trail in trails.keys) {
              for (var location in trails[trail]) {
                fetchImage(
                  context: context,
                  url:
                      (location.smallImage.split('.')..removeLast()).join('.') +
                          's.png',
                ).then((bytes) {
                  newMarkers.add(Marker(
                    markerId: MarkerId('${trail.id} ${location.id}'),
                    position: location.coordinates,
                    infoWindow: InfoWindow(
                      title: location.name,
                      onTap: () {},
                    ),
                    icon: BitmapDescriptor.fromBytes(bytes),
                  ));
                  if (newMarkers.length == length) {
                    Provider.of<MapNotifier>(context).markers = newMarkers;
                  }
                });
              }
            }
          }
        }
        return Selector<MapNotifier, Set<Marker>>(
          selector: (context, mapNotifier) => mapNotifier.markers,
          builder: (context, markers, child) {
            return CustomAnimatedSwitcher(
              crossShrink: false,
              child: trails.isEmpty || markers.isEmpty
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    )
                  : GoogleMap(
                      rotateGesturesEnabled: false,
                      myLocationEnabled: true,
                      cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                        northeast: northEastBound,
                        southwest: southWestBound,
                      )),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: bottomSheetCenter,
                        zoom: 17,
                      ),
                      polygons: polygons,
                      markers: markers,
                    ),
            );
          },
        );
      },
    );
  }
}

class MapNotifier extends ChangeNotifier {
  GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;
  set markers(Set<Marker> markers) {
    _markers = markers;
    print(_markers);
    notifyListeners();
  }
  void animateToLocation(TrailLocation location) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(location.coordinates, 18));
  }
}
