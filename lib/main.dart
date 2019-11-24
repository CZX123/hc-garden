import 'library.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(HcGardenApp());
}

class HcGardenApp extends StatefulWidget {
  @override
  _HcGardenAppState createState() => _HcGardenAppState();
}

class _HcGardenAppState extends State<HcGardenApp> {
  final _location = Location();
  final _themeNotifier = ThemeNotifier(null);
  final _mapNotifier = MapNotifier();
  bool _firstTime = false;

  void checkPermission() async {
    var granted = await _location.hasPermission();
    if (!granted) {
      granted = await _location.requestPermission();
    }
    _mapNotifier.permissionEnabled = granted;
    if (granted) {
      checkGPS();
    }
  }

  void checkGPS() async {
    var isOn = await _location.serviceEnabled();
    if (!isOn) {
      isOn = await _location.requestService();
    }
    _mapNotifier.gpsOn = isOn;
    if (isOn) _mapNotifier.rebuildMap();
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    SharedPreferences.getInstance().then((prefs) {
      final isDark = prefs.getBool('isDark');
      _firstTime = isDark == null;
      _themeNotifier.value = isDark ?? false;
      _mapNotifier.mapType = CustomMapType.values[prefs.getInt('mapType') ?? 0];
    });
    final markerColors = ['yellow', 'pink', 'blue', 'green'];
    Future.wait<BitmapDescriptor>(
      markerColors.map((color) {
        return BitmapDescriptor.fromAssetImage(
          ImageConfiguration(),
          'assets/images/google_maps/${color}_marker.png',
        );
      }),
    ).then((bitmapList) {
      _mapNotifier.darkThemeMarkerIcons = bitmapList;
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    _mapNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Custom cache for all images in the app
        Provider<Map<String, Uint8List>>.value(
          value: {},
        ),
        FutureProvider.value(
          value: getApplicationDocumentsDirectory(),
        ),
        ChangeNotifierProvider.value(
          value: _themeNotifier,
        ),
        ChangeNotifierProvider.value(
          value: _mapNotifier,
        ),
        ChangeNotifierProvider(
          builder: (context) => DebugNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => AppNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => BottomSheetNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => SearchNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => FilterNotifier(),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          if (themeNotifier.value == null) return const SizedBox.shrink();
          // TODO: Onboarding: Make use of the _firstTime variable to show different screens
          return Consumer<DebugNotifier>(
            builder: (context, debugInfo, child) {
              return MaterialApp(
                title: 'HC Garden',
                theme:
                    (themeNotifier.value ? darkThemeData : themeData).copyWith(
                  platform: debugInfo.isIOS
                      ? TargetPlatform.iOS
                      : TargetPlatform.android,
                ),
                onGenerateRoute: (settings) {
                  if (settings.isInitialRoute) {
                    return PageRouteBuilder(
                      pageBuilder: (context, _, __) {
                        return const FirebaseDataWidget(
                          child: const MyHomePage(),
                        );
                      },
                    );
                  }
                  return null;
                },
                showPerformanceOverlay: debugInfo.showPerformanceOverlay,
              );
            },
          );
        },
      ),
    );
  }
}

class FirebaseDataWidget extends StatefulWidget {
  final Widget child;
  const FirebaseDataWidget({Key key, @required this.child}) : super(key: key);

  @override
  _FirebaseDataWidgetState createState() => _FirebaseDataWidgetState();
}

class _FirebaseDataWidgetState extends State<FirebaseDataWidget> {
  Stream<FirebaseData> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseDatabase.instance.reference().onValue.map((event) {
      if (event.snapshot.value == null) {
        throw Exception('Value is empty!');
      }

      // Add list of entities
      final parsedJson = Map<String, dynamic>.from(event.snapshot.value);
      List<Flora> floraList = [];
      List<Fauna> faunaList = [];
      parsedJson['flora&fauna'].forEach((key, value) {
        if (key.contains('flora')) {
          floraList.add(Flora.fromJson(key, value));
        } else {
          faunaList.add(Fauna.fromJson(key, value));
        }
      });
      floraList.sort((a, b) => a.name.compareTo(b.name));
      faunaList.sort((a, b) => a.name.compareTo(b.name));

      Map<MarkerId, Marker> mapMarkers = {};

      // Add trails and locations
      Map<Trail, List<TrailLocation>> trails = {};
      parsedJson['map'].forEach((key, value) {
        final trail = Trail.fromJson(key, value);
        trails[trail] = [];
        value['route'].forEach((key, value) {
          final location = TrailLocation.fromJson(
            key,
            value,
            trail: trail,
            floraList: floraList,
            faunaList: faunaList,
          );
          trails[trail].add(location);
          mapMarkers[MarkerId('${trail.id} ${location.id}')] = generateMarker(
            context: context,
            trail: trail,
            location: location,
          );
        });
      });
      Provider.of<MapNotifier>(context, listen: false).defaultMarkers =
          mapMarkers;

      List<HistoricalData> historicalDataList = [];
      parsedJson['historical'].forEach((key, value) {
        historicalDataList.add(HistoricalData.fromJson(key, value));
      });
      historicalDataList.sort((a, b) => a.id.compareTo(b.id));

      List<AboutPageData> aboutPageDataList = [];
      parsedJson['about'].forEach((key, value) {
        aboutPageDataList.add(AboutPageData.fromJson(key, value));
      });
      aboutPageDataList.sort((a, b) => a.id.compareTo(b.id));

      // TODO: handle cases of invalid data
      // i.e. filter those whose data fields are null out

      return FirebaseData(
        floraList: floraList,
        faunaList: faunaList,
        trails: trails,
        historicalDataList: historicalDataList,
        aboutPageDataList: aboutPageDataList,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      initialData: FirebaseData(
        floraList: [],
        faunaList: [],
        trails: {},
        historicalDataList: [],
        aboutPageDataList: [],
      ),
      value: _stream,
      child: widget.child,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _init = false;
  final _location = Location();
  final _pageIndex = ValueNotifier(1);
  TabController _tabController;
  final _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  double topPadding;
  double height;

  Future<bool> onBack(BuildContext context) async {
    final scaffoldState = Scaffold.of(context);
    if (scaffoldState.isEndDrawerOpen || scaffoldState.isDrawerOpen)
      return true;
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final searchNotifier = Provider.of<SearchNotifier>(context, listen: false);
    final animation = bottomSheetNotifier.animation;
    final state = appNotifier.state;
    if (state == 0) {
      if (appNotifier.routes.isNotEmpty) {
        appNotifier.pop(context);
        final paddingBreakpoint =
            bottomSheetNotifier.snappingPositions.value[1];
        bottomSheetNotifier
          ..activeScrollController = _scrollControllers[_tabController.index]
          ..animateTo(paddingBreakpoint);
        return false;
      }
      // If something wrong happens, navigator somehow still can be popped
      if (appNotifier.navigatorKey.currentState.canPop()) {
        appNotifier.navigatorKey.currentState.pop();
        return false;
      }
      final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
      if (searchNotifier.isSearching) {
        searchNotifier
          ..isSearching = false
          ..searchTerm = '';
        return false;
      } else if (animation.value < paddingBreakpoint) {
        bottomSheetNotifier.animateTo(paddingBreakpoint);
        return false;
      }
      if (_pageIndex.value != 1) {
        _pageIndex.value = 1;
        bottomSheetNotifier
          ..draggingDisabled = false
          ..animateTo(paddingBreakpoint);
        return false;
      }
      return true;
    } else {
      appNotifier.pop(context);
      final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
      if (appNotifier.routes.isEmpty) {
        bottomSheetNotifier.activeScrollController =
            _scrollControllers[_tabController.index];
        if (state == 1 && animation.value > paddingBreakpoint) {
          bottomSheetNotifier.animateTo(paddingBreakpoint);
        }
        if (searchNotifier.searchTerm.isNotEmpty)
          searchNotifier.isSearching = true;
      }
      return false;
    }
  }

  void tabListener() {
    if (Provider.of<AppNotifier>(context, listen: false).state == 0)
      Provider.of<BottomSheetNotifier>(context, listen: false)
          .activeScrollController = _scrollControllers[_tabController.index];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    )..addListener(tabListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    topPadding = MediaQuery.of(context).padding.top;
    height = MediaQuery.of(context).size.height;
    final heightTooSmall = height - Sizes.kBottomHeight < 100;
    if (height == 0) return;
    if (!_init) {
      Provider.of<BottomSheetNotifier>(context, listen: false)
        ..snappingPositions.value = [
          0,
          if (heightTooSmall)
            height - Sizes.kBottomHeight + Sizes.hEntityButtonHeight + 8
          else
            height - Sizes.kBottomHeight,
          height - Sizes.hBottomBarHeight,
        ]
        ..endCorrection = topPadding - Sizes.hOffsetTranslation
        ..activeScrollController ??= _scrollControllers[_tabController.index];
      _init = true;
    } else {
      final appNotifier = Provider.of<AppNotifier>(context, listen: false);
      final isHome = appNotifier.routes.isEmpty;
      appNotifier.changeState(
        context: context,
        routeInfo: isHome ? null : appNotifier.routes.last,
        isHome: isHome,
        disableDragging:
            Provider.of<BottomSheetNotifier>(context, listen: false)
                .draggingDisabled,
        notify: false,
      );
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(tabListener)
      ..dispose();
    _pageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightTooSmall = height - Sizes.kBottomHeight < 100;
    return Selector<AppNotifier, bool>(
      selector: (context, appNotifier) => appNotifier.routes.isEmpty,
      builder: (context, routesIsEmpty, child) {
        return Scaffold(
          drawer: SettingsDrawer(),
          endDrawer: routesIsEmpty ? FilterDrawer() : null,
          body: child,
        );
      },
      child: Builder(builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion(
          value: (isDark
                  ? ThemeNotifier.darkOverlayStyle
                  : ThemeNotifier.lightOverlayStyle)
              .copyWith(
            statusBarColor: Theme.of(context)
                .bottomAppBarColor
                .withOpacity(isDark ? .5 : .8),
            systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
          ),
          child: WillPopScope(
            onWillPop: () {
              return onBack(context);
            },
            child: CustomAnimatedSwitcher(
              crossShrink: false,
              child: height != 0
                  ? NestedBottomSheet(
                      initialPosition: height -
                          (heightTooSmall
                              ? Sizes.kBottomHeight -
                                  Sizes.hEntityButtonHeight -
                                  8
                              : Sizes.kBottomHeight),
                      background: Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: Sizes.hBottomBarHeight,
                        child: ValueListenableBuilder(
                          valueListenable: _pageIndex,
                          builder: (context, pageIndex, child) {
                            return CustomAnimatedSwitcher(
                              child: pageIndex == 0
                                  ? HistoryPage()
                                  : pageIndex == 2 ? AboutPage() : child,
                            );
                          },
                          child: MapWidget(),
                        ),
                      ),
                      body: ExploreBody(
                        tabController: _tabController,
                        scrollControllers: _scrollControllers,
                      ),
                      footer: BottomSheetFooter(
                        pageIndex: _pageIndex,
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        );
      }),
    );
  }
}
