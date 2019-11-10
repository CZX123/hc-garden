import '../library.dart';

const northEastBound = const LatLng(1.328278, 103.807815);
const southWestBound = const LatLng(1.324095, 103.800954);
const center = const LatLng(1.326580, 103.804453);
const bottomSheetCenter = const LatLng(1.325080, 103.804453);
const kktrail = const LatLng(1.326987, 103.80295);
const kctrail = const LatLng(1.326026, 103.80420);
const jxtrail = const LatLng(1.325317, 103.80672);
Set<Polygon> polygons = {
  Polygon(
    polygonId: PolygonId("salt centre"),
    points: [
      const LatLng(1.327181, 103.801500),
      const LatLng(1.327493, 103.801061),
      const LatLng(1.328082, 103.801477),
      const LatLng(1.327769, 103.801919),
    ],
    fillColor: const Color(0x7fff5722),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("hs staffroom"),
    points: [
      const LatLng(1.327135, 103.801910),
      const LatLng(1.327170, 103.801874),
      const LatLng(1.326918, 103.801663),
      const LatLng(1.326718, 103.801910),
      const LatLng(1.326962, 103.802115),
      const LatLng(1.327088, 103.801959),
      const LatLng(1.327108, 103.802307),
      const LatLng(1.326964, 103.802179),
      const LatLng(1.326758, 103.802424),
      const LatLng(1.327016, 103.802649),
      const LatLng(1.327214, 103.802399),
      const LatLng(1.327158, 103.802352),
    ],
    fillColor: const Color(0x7ff5b041),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("hs block e"),
    points: [
      const LatLng(1.327964, 103.802615),
      const LatLng(1.327964, 103.802514),
      const LatLng(1.327277, 103.802541),
      const LatLng(1.327206, 103.802577),
      const LatLng(1.326733, 103.803155),
      const LatLng(1.326815, 103.803218),
      const LatLng(1.327284, 103.802641),
    ],
    fillColor: const Color(0x7ff9e79f),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("hs block b"),
    points: [
      const LatLng(1.326797, 103.802578),
      const LatLng(1.326707, 103.802499),
      const LatLng(1.326335, 103.802943),
      const LatLng(1.326440, 103.803026),
    ],
    fillColor: const Color(0x7f6e2c00),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("hs block c"),
    points: [
      const LatLng(1.326579, 103.801651),
      const LatLng(1.326450, 103.801658),
      const LatLng(1.326504, 103.802319),
      const LatLng(1.326228, 103.802637),
      const LatLng(1.326128, 103.802549),
      const LatLng(1.326080, 103.802602),
      const LatLng(1.326080, 103.802602),
      const LatLng(1.326037, 103.802567),
      const LatLng(1.325962, 103.802665),
      const LatLng(1.326104, 103.802782),
      const LatLng(1.326146, 103.802732),
      const LatLng(1.326234, 103.802808),
      const LatLng(1.326635, 103.802350),
    ],
    fillColor: const Color(0x7fe74c3c),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("clock tower"),
    points: [
      const LatLng(1.326689, 103.803328),
      const LatLng(1.326608, 103.803262),
      const LatLng(1.326266, 103.803678),
      const LatLng(1.326348, 103.803745),
    ],
    fillColor: const Color(0x7fe74c3c),
    strokeWidth: 0,
  ),
  Polygon(
    polygonId: PolygonId("kkh"),
    points: [
      const LatLng(1.325646, 103.803081),
      const LatLng(1.325930, 103.802790),
      const LatLng(1.325648, 103.802556),
      const LatLng(1.325629, 103.802573),
      const LatLng(1.325603, 103.802550),
      const LatLng(1.325559, 103.802595),
      const LatLng(1.325529, 103.802571),
      const LatLng(1.325378, 103.802748),
      const LatLng(1.325423, 103.802787),
      const LatLng(1.325373, 103.802848),
    ],
    fillColor: const Color(0x7f6e2c00),
    strokeWidth: 0,
  ),
};
const mapStyle = '''[
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
]''';
const darkMapStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "lightness": 10
      },
      {
        "weight": 1
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]''';
