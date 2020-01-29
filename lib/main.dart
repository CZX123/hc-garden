import 'library.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Restrict to only portrait orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Offline access with just one line
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  runApp(HcGardenApp());
}

class HcGardenApp extends StatefulWidget {
  @override
  _HcGardenAppState createState() => _HcGardenAppState();
}

class _HcGardenAppState extends State<HcGardenApp> {
  /// Stream of data from Firebase Realtime Database
  Stream<FirebaseData> _stream;

  /// An instance of [Location]
  final _location = Location();
  final _filterNotifier = FilterNotifier();
  final _themeNotifier = ThemeNotifier(null);
  final _mapNotifier = MapNotifier();
  bool _firstTime = false;

  /// Check if location permission is on
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

  /// Check if GPS itself is turned on
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

    // Get values
    SharedPreferences.getInstance().then((prefs) {
      final isDark = prefs.getBool('isDark');
      _firstTime = isDark == null;
      _themeNotifier.value = isDark ?? false;
      _mapNotifier.mapType = CustomMapType.values[prefs.getInt('mapType') ?? 0];
    });

    // Load and convert all markers to bitmap descriptors
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

    // Handle firebase data
    _stream = FirebaseDatabase.instance.reference().onValue.map((event) {
      if (event.snapshot.value == null) {
        throw Exception('Value is empty!');
      }

      // Add list of entities
      final Map parsedJson = event.snapshot.value;
      Map<int, Flora> floraMap = {};
      Map<int, Fauna> faunaMap = {};
      parsedJson['flora&fauna'].forEach((key, value) {
        if (key.contains('flora')) {
          final flora = Flora.fromJson(key, value);
          if (flora.isValid) floraMap[flora.id] = flora;
        } else {
          final fauna = Fauna.fromJson(key, value);
          if (fauna.isValid) faunaMap[fauna.id] = fauna;
        }
      });

      // Add trails and locations
      Map<Trail, Map<int, TrailLocation>> trails = {};
      parsedJson['map'].forEach((key, value) {
        final trail = Trail.fromJson(key, value);
        print('$key, ${trail.isValid}');
        if (trail.isValid) {
          trails[trail] = {};
          value['route'].forEach((key, value) {
            final location = TrailLocation.fromJson(
              key,
              value,
              trail: trail,
              floraMap: floraMap,
              faunaMap: faunaMap,
            );
            if (location.isValid) trails[trail][location.id] = location;
          });
        }
      });

      // Add historical data
      List<HistoricalData> historicalDataList = [];
      parsedJson['historical'].forEach((key, value) {
        final historicalData = HistoricalData.fromJson(key, value);
        if (historicalData.isValid) historicalDataList.add(historicalData);
      });
      historicalDataList.sort((a, b) => a.id.compareTo(b.id));

      // Add AboutPage data
      List<AboutPageData> aboutPageDataList = [];
      parsedJson['about'].forEach((key, value) {
        final aboutPageData = AboutPageData.fromJson(key, value);
        if (aboutPageData.isValid) aboutPageDataList.add(aboutPageData);
      });
      aboutPageDataList.sort((a, b) => a.id.compareTo(b.id));

      // TODO: handle cases of invalid data
      // i.e. filter those whose data fields are null out
      return FirebaseData(
        floraMap: floraMap,
        faunaMap: faunaMap,
        trails: trails,
        historicalDataList: historicalDataList,
        aboutPageDataList: aboutPageDataList,
      );
    });
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    _themeNotifier.dispose();
    _mapNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Save the directory path into a provider, so later references does not require to wait for a Future
        FutureProvider.value(
          value: getApplicationDocumentsDirectory(),
        ),
        // ThemeNotifier
        ChangeNotifierProvider.value(
          value: _themeNotifier,
        ),
        // MapNotifier
        ChangeNotifierProvider.value(
          value: _mapNotifier,
        ),
        // To be removed
        ChangeNotifierProvider(
          create: (context) => DebugNotifier(),
        ),
        // Main AppNotifier in changed of main app flow
        ChangeNotifierProvider(
          create: (context) => AppNotifier(),
        ),
        // Contains bottom sheet animations, ability to change active scroll controller
        ChangeNotifierProvider(
          create: (context) => BottomSheetNotifier(),
        ),
        // Simple ChangeNotifier for searching flora and fauna
        ChangeNotifierProvider(
          create: (context) => SearchNotifier(),
        ),
        // Simple ChangeNotifier for filtering flora and fauna
        ChangeNotifierProvider.value(
          value: _filterNotifier,
        ),
        // Provider for all data from Firebase
        StreamProvider.value(
          initialData: FirebaseData(
            floraMap: {},
            faunaMap: {},
            trails: {},
            historicalDataList: [],
            aboutPageDataList: [],
          ),
          value: _stream,
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          if (themeNotifier.value == null) return const SizedBox.shrink();
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
                        return MarkerDataWidget(
                          firebaseDataStream: _stream,
                          child: MyHomePage(
                            firstTime: _firstTime,
                          ),
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

class MyHomePage extends StatefulWidget {
  final bool firstTime;
  const MyHomePage({Key key, this.firstTime = false}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // 'init' stand for initialised. Commonly used in didChangeDependencies to fetch values from Providers only for one time.
  bool _init = false;
  final _pageIndex = ValueNotifier(1);
  TabController _tabController;
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
        bottomSheetNotifier.animateTo(paddingBreakpoint);
        return false;
      }
      // If something wrong happens, navigator somehow still can be popped
      if (appNotifier.navigatorKey.currentState.canPop()) {
        appNotifier.navigatorKey.currentState.pop();
        return false;
      }
      final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
      if (FocusScope.of(context).focusedChild == searchNotifier.focusNode ||
          searchNotifier.searchTerm.isNotEmpty) {
        searchNotifier
          ..unfocus()
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
        if (state == 1 && animation.value > paddingBreakpoint) {
          bottomSheetNotifier.animateTo(paddingBreakpoint);
        }
      }
      return false;
    }
  }

  void tabListener() {
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    appNotifier.tabIndex = _tabController.index;
    Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    ).activeScrollController =
        appNotifier.homeScrollControllers[_tabController.index];
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
    if (height == 0) return;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final heightTooSmall = height - Sizes.kBottomHeight < 100;
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    if (!_init) {
      if (widget.firstTime) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).push(OnboardingPageRoute(
            builder: (context) => const OnboardingPage(),
          ));
        });
      }
      Provider.of<BottomSheetNotifier>(context, listen: false)
        ..snappingPositions.value = [
          0,
          if (heightTooSmall)
            height -
                Sizes.kBottomHeight +
                Sizes.hEntityButtonHeight +
                8 -
                bottomPadding
          else
            height - Sizes.kBottomHeight - bottomPadding,
          height - Sizes.hBottomBarHeight - bottomPadding,
        ]
        ..endCorrection = topPadding - Sizes.hOffsetTranslation
        ..activeScrollController ??=
            appNotifier.homeScrollControllers[_tabController.index];
      _init = true;
    } else {
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    return Selector<AppNotifier, bool>(
      selector: (context, appNotifier) => appNotifier.routes.isEmpty,
      builder: (context, routesIsEmpty, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
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
              fadeIn: true,
              child: height != 0
                  ? CustomBottomSheet(
                      initialPosition: height -
                          (heightTooSmall
                              ? Sizes.kBottomHeight -
                                  Sizes.hEntityButtonHeight -
                                  8
                              : Sizes.kBottomHeight) -
                          bottomPadding,
                      background: Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: Sizes.hBottomBarHeight + bottomPadding,
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
                        scrollControllers: appNotifier.homeScrollControllers,
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
