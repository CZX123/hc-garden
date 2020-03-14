import 'package:hc_garden/src/library.dart';

// const northEastBound = const LatLng(1.328278, 103.807815);
// const southWestBound = const LatLng(1.324095, 103.800954);
const center = const LatLng(1.326580, 103.805239);
Set<Polygon> polygons = {
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("salt centre"),
    points: [
      LatLng(1.327181, 103.801500),
      LatLng(1.327493, 103.801061),
      LatLng(1.328082, 103.801477),
      LatLng(1.327769, 103.801919)
    ],
    fillColor: Color(0x7fffecb3),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs staffroom"),
    points: [
      LatLng(1.327135, 103.801910),
      LatLng(1.327170, 103.801874),
      LatLng(1.326918, 103.801663),
      LatLng(1.326718, 103.801910),
      LatLng(1.326962, 103.802115),
      LatLng(1.327088, 103.801959),
      LatLng(1.327108, 103.802307),
      LatLng(1.326964, 103.802179),
      LatLng(1.326758, 103.802424),
      LatLng(1.327016, 103.802649),
      LatLng(1.327214, 103.802399),
      LatLng(1.327158, 103.802352)
    ],
    fillColor: Color(0x7fffe082),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs block e"),
    points: [
      LatLng(1.327964, 103.802615),
      LatLng(1.327964, 103.802514),
      LatLng(1.327277, 103.802541),
      LatLng(1.327206, 103.802577),
      LatLng(1.326733, 103.803155),
      LatLng(1.326815, 103.803218),
      LatLng(1.327284, 103.802641)
    ],
    fillColor: Color(0x7fffd54f),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs block b"),
    points: [
      LatLng(1.326797, 103.802578),
      LatLng(1.326707, 103.802499),
      LatLng(1.326335, 103.802943),
      LatLng(1.326440, 103.803026)
    ],
    fillColor: Color(0x7fffca28),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs block c"),
    points: [
      LatLng(1.326579, 103.801651),
      LatLng(1.326450, 103.801658),
      LatLng(1.326504, 103.802319),
      LatLng(1.326228, 103.802637),
      LatLng(1.326128, 103.802549),
      LatLng(1.326080, 103.802602),
      LatLng(1.326080, 103.802602),
      LatLng(1.326037, 103.802567),
      LatLng(1.325962, 103.802665),
      LatLng(1.326104, 103.802782),
      LatLng(1.326146, 103.802732),
      LatLng(1.326234, 103.802808),
      LatLng(1.326635, 103.802350)
    ],
    fillColor: Color(0x7fffc107),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("clock tower"),
    points: [
      LatLng(1.326689, 103.803328),
      LatLng(1.326608, 103.803262),
      LatLng(1.326266, 103.803678),
      LatLng(1.326348, 103.803745)
    ],
    fillColor: Color(0x7fffb300),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("kkh"),
    points: [
      LatLng(1.325646, 103.803081),
      LatLng(1.325930, 103.802790),
      LatLng(1.325648, 103.802556),
      LatLng(1.325629, 103.802573),
      LatLng(1.325603, 103.802550),
      LatLng(1.325559, 103.802595),
      LatLng(1.325529, 103.802571),
      LatLng(1.325378, 103.802748),
      LatLng(1.325423, 103.802787),
      LatLng(1.325373, 103.802848)
    ],
    fillColor: Color(0x7fffa000),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("heritage bldg"),
    points: [
      LatLng(1.326228, 103.803928),
      LatLng(1.326145, 103.803869),
      LatLng(1.325917, 103.804204),
      LatLng(1.326004, 103.804265)
    ],
    fillColor: Color(0x7fff8f00),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("com labs"),
    points: [
      LatLng(1.326048, 103.803808),
      LatLng(1.325953, 103.803739),
      LatLng(1.325735, 103.804075),
      LatLng(1.325823, 103.804137)
    ],
    fillColor: Color(0x7fff6f00),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs labs"),
    points: [
      LatLng(1.326011, 103.803515),
      LatLng(1.325926, 103.803445),
      LatLng(1.325963, 103.803400),
      LatLng(1.325881, 103.803330),
      LatLng(1.325843, 103.803374),
      LatLng(1.325804, 103.803340),
      LatLng(1.325679, 103.803490),
      LatLng(1.325733, 103.803536),
      LatLng(1.325645, 103.803649),
      LatLng(1.325589, 103.803602),
      LatLng(1.325470, 103.803751),
      LatLng(1.325508, 103.803784),
      LatLng(1.325476, 103.803825),
      LatLng(1.325553, 103.803887),
      LatLng(1.325591, 103.803837),
      LatLng(1.325692, 103.803918)
    ],
    fillColor: Color(0x7fef6c00),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("ep3 shed"),
    points: [
      LatLng(1.325689, 103.804031),
      LatLng(1.325576, 103.803955),
      LatLng(1.325433, 103.804165),
      LatLng(1.325547, 103.804240)
    ],
    fillColor: Color(0x7fe65100),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("admin centre"),
    points: [
      LatLng(1.325853, 103.804453),
      LatLng(1.325786, 103.804404),
      LatLng(1.325710, 103.804520),
      LatLng(1.325452, 103.804345),
      LatLng(1.325366, 103.804486),
      LatLng(1.325492, 103.804573),
      LatLng(1.325535, 103.804501),
      LatLng(1.325665, 103.804590),
      LatLng(1.325588, 103.804710),
      LatLng(1.325656, 103.804756),
      LatLng(1.325734, 103.804640),
      LatLng(1.325785, 103.804677),
      LatLng(1.325832, 103.804608),
      LatLng(1.325775, 103.804570)
    ],
    fillColor: Color(0x7fd84315),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("src"),
    points: [
      LatLng(1.325468, 103.804206),
      LatLng(1.325312, 103.804096),
      LatLng(1.325096, 103.804412),
      LatLng(1.325116, 103.804426),
      LatLng(1.325096, 103.804458),
      LatLng(1.325137, 103.804676),
      LatLng(1.325174, 103.804702),
      LatLng(1.325159, 103.804727),
      LatLng(1.325536, 103.804973),
      LatLng(1.325640, 103.804817),
      LatLng(1.325551, 103.804753),
      LatLng(1.325569, 103.804726),
      LatLng(1.325496, 103.804677),
      LatLng(1.325480, 103.804700),
      LatLng(1.325327, 103.804603),
      LatLng(1.325339, 103.804582),
      LatLng(1.325317, 103.804474),
      LatLng(1.325302, 103.804463)
    ],
    fillColor: Color(0x7f002171),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("oth"),
    points: [
      LatLng(1.326524, 103.803362),
      LatLng(1.326264, 103.803146),
      LatLng(1.326106, 103.803360),
      LatLng(1.326351, 103.803565)
    ],
    fillColor: Color(0x7ffbc02d),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("hs canteen"),
    points: [
      LatLng(1.326021, 103.802587),
      LatLng(1.325951, 103.802528),
      LatLng(1.326000, 103.802465),
      LatLng(1.326048, 103.802508),
      LatLng(1.326089, 103.802460),
      LatLng(1.326143, 103.802505),
      LatLng(1.326216, 103.802412),
      LatLng(1.326164, 103.802367),
      LatLng(1.326199, 103.802322),
      LatLng(1.326150, 103.802276),
      LatLng(1.326191, 103.802229),
      LatLng(1.326146, 103.802190),
      LatLng(1.326203, 103.802118),
      LatLng(1.326232, 103.802142),
      LatLng(1.326291, 103.802069),
      LatLng(1.326268, 103.802049),
      LatLng(1.326318, 103.801977),
      LatLng(1.326297, 103.801796),
      LatLng(1.326114, 103.801642),
      LatLng(1.326025, 103.801771),
      LatLng(1.326124, 103.801858),
      LatLng(1.326126, 103.801938),
      LatLng(1.326005, 103.802073),
      LatLng(1.325944, 103.802020),
      LatLng(1.325899, 103.802073),
      LatLng(1.325797, 103.801991),
      LatLng(1.325639, 103.802178),
      LatLng(1.325730, 103.802266),
      LatLng(1.325649, 103.802351),
      LatLng(1.325809, 103.802486),
      LatLng(1.325768, 103.802536),
      LatLng(1.325830, 103.802586),
      LatLng(1.325866, 103.802539),
      LatLng(1.325896, 103.802564),
      LatLng(1.325835, 103.802636),
      LatLng(1.325927, 103.802705)
    ],
    fillColor: Color(0x7ffdd835),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college block a"),
    points: [
      LatLng(1.325897, 103.806353),
      LatLng(1.325679, 103.806077),
      LatLng(1.325378, 103.805945),
      LatLng(1.325238, 103.805889),
      LatLng(1.325209, 103.805961),
      LatLng(1.325109, 103.806109),
      LatLng(1.325047, 103.806160),
      LatLng(1.325330, 103.806484),
      LatLng(1.325362, 103.806513),
      LatLng(1.325692, 103.806640),
      LatLng(1.325736, 103.806534),
      LatLng(1.325424, 103.806413),
      LatLng(1.325382, 103.806370),
      LatLng(1.325360, 103.806301),
      LatLng(1.325470, 103.806127),
      LatLng(1.325535, 103.806140),
      LatLng(1.325602, 103.806161),
      LatLng(1.325819, 103.806423)
    ],
    fillColor: Color(0x7f1e88e5),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("colleege block b part 1"),
    points: [
      LatLng(1.324993, 103.806103),
      LatLng(1.325260, 103.805722),
      LatLng(1.325308, 103.805754),
      LatLng(1.325462, 103.805523),
      LatLng(1.325520, 103.805550),
      LatLng(1.325561, 103.805442),
      LatLng(1.325555, 103.805312),
      LatLng(1.325447, 103.805343),
      LatLng(1.325431, 103.805284),
      LatLng(1.325515, 103.805245),
      LatLng(1.325469, 103.805172),
      LatLng(1.325390, 103.805115),
      LatLng(1.325268, 103.805070),
      LatLng(1.325243, 103.805255),
      LatLng(1.325302, 103.805283),
      LatLng(1.325336, 103.805314),
      LatLng(1.325355, 103.805367),
      LatLng(1.325353, 103.805433),
      LatLng(1.325184, 103.805689),
      LatLng(1.325141, 103.805656),
      LatLng(1.324877, 103.806039)
    ],
    fillColor: Color(0x7f1976d2),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("colleege block b part 2"),
    points: [
      LatLng(1.325215, 103.805220),
      LatLng(1.325194, 103.805046),
      LatLng(1.325113, 103.805068),
      LatLng(1.325030, 103.805105),
      LatLng(1.325125, 103.805254),
      LatLng(1.325175, 103.805229)
    ],
    fillColor: Color(0x7f1976d2),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("colleege block b part 3"),
    points: [
      LatLng(1.325083, 103.805220),
      LatLng(1.324951, 103.805110),
      LatLng(1.324853, 103.805235),
      LatLng(1.324985, 103.805345)
    ],
    fillColor: Color(0x7f1976d2),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college block c"),
    points: [
      LatLng(1.325507, 103.806809),
      LatLng(1.325450, 103.806812),
      LatLng(1.325344, 103.806589),
      LatLng(1.325318, 103.806585),
      LatLng(1.325271, 103.806576),
      LatLng(1.325204, 103.806578),
      LatLng(1.324959, 103.806959),
      LatLng(1.325029, 103.807134),
      LatLng(1.325218, 103.807150),
      LatLng(1.325246, 103.807127),
      LatLng(1.325438, 103.806859),
      LatLng(1.325509, 103.806857)
    ],
    fillColor: Color(0x7f42a5f5),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college block d"),
    points: [
      LatLng(1.325669, 103.807502),
      LatLng(1.325330, 103.807282),
      LatLng(1.325298, 103.807304),
      LatLng(1.325202, 103.807437),
      LatLng(1.325496, 103.807622),
      LatLng(1.325509, 103.807604),
      LatLng(1.325574, 103.807647)
    ],
    fillColor: Color(0x7f64b5f6),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college block e"),
    points: [
      LatLng(1.326049, 103.805718),
      LatLng(1.325945, 103.805682),
      LatLng(1.325927, 103.805723),
      LatLng(1.325770, 103.805664),
      LatLng(1.325739, 103.805633),
      LatLng(1.325705, 103.805611),
      LatLng(1.325801, 103.805331),
      LatLng(1.325709, 103.805294),
      LatLng(1.325608, 103.805579),
      LatLng(1.325534, 103.805584),
      LatLng(1.325469, 103.805606),
      LatLng(1.325496, 103.805659),
      LatLng(1.325443, 103.805706),
      LatLng(1.325409, 103.805770),
      LatLng(1.325400, 103.805860),
      LatLng(1.325416, 103.805911),
      LatLng(1.325680, 103.806077),
      LatLng(1.325756, 103.806048),
      LatLng(1.325854, 103.806076),
      LatLng(1.325865, 103.806041),
      LatLng(1.325847, 103.805998),
      LatLng(1.325957, 103.805938)
    ],
    fillColor: Color(0x7f1565c0),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college staffroom"),
    points: [
      LatLng(1.324993, 103.806103),
      LatLng(1.324878, 103.806038),
      LatLng(1.324616, 103.806007),
      LatLng(1.324488, 103.806175),
      LatLng(1.324578, 103.806370),
      LatLng(1.324807, 103.806387)
    ],
    fillColor: Color(0x7f2196f3),
  ),
  Polygon(
    strokeWidth: 4,
    strokeColor: Colors.black38,
    polygonId: PolygonId("college block f"),
    points: [
      LatLng(1.325095, 103.805490),
      LatLng(1.324974, 103.805390),
      LatLng(1.324666, 103.805823),
      LatLng(1.324792, 103.805911)
    ],
    fillColor: Color(0x7f0d47a1),
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
    "featureType": "poi.government",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]''';
