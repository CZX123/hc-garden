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
        final locations = trails.values.reduce((a, b) => a + b);
        return CustomAnimatedSwitcher(
          crossShrink: false,
          child: trails.isEmpty
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                  ),
                )
              : GoogleMap(
                  cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                    northeast: northEastBound,
                    southwest: southWestBound,
                  )),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 17,
                  ),
                  polygons: polygons,
                ),
        );
      },
    );
  }
}

class MapNotifier extends ChangeNotifier {
  GoogleMapController mapController;
  Set<Marker> markers;
}
