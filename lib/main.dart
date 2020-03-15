import 'src/library.dart';

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
      _mapNotifier.mapType = MapType.values[prefs.getInt('mapType') ?? 1];
    });

    // Handle firebase data
    _stream = FirebaseDatabase.instance.reference().onValue.map((event) {
      if (event.snapshot.value == null) {
        throw Exception('Value is empty!');
      }
      final Map data = event.snapshot.value;
      return FirebaseData.fromJson(data);
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
        ChangeNotifierProvider(
          create: (context) => FilterNotifier(),
        ),
        // Provider for all data from Firebase
        StreamProvider.value(
          value: _stream,
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          if (themeNotifier.value == null) return const SizedBox.shrink();
          return Consumer<DebugNotifier>(
            builder: (context, debugInfo, child) {
              return Container(
                color: themeNotifier.value
                    ? darkThemeData.canvasColor
                    : themeData.canvasColor,
                child: MaterialApp(
                  title: 'HC Garden',
                  theme: (themeNotifier.value ? darkThemeData : themeData)
                      .copyWith(
                    platform: debugInfo.isIOS
                        ? TargetPlatform.iOS
                        : TargetPlatform.android,
                  ),
                  onGenerateRoute: (settings) {
                    if (settings.isInitialRoute) {
                      return PageRouteBuilder(
                        pageBuilder: (context, _, secondaryAnimation) {
                          final fadeOut = secondaryAnimation.drive(Tween(
                            begin: 1.0,
                            end: -1.0,
                          ));
                          return MapDataWidget(
                            firebaseDataStream: _stream,
                            child: FadeTransition(
                              opacity: fadeOut,
                              child: MyHomePage(
                                firstTime: _firstTime,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return null;
                  },
                  showPerformanceOverlay: debugInfo.showPerformanceOverlay,
                ),
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
    final appNotifier = context.provide<AppNotifier>(listen: false);
    final bottomSheetNotifier =
        context.provide<BottomSheetNotifier>(listen: false);
    final filterNotifier = context.provide<FilterNotifier>(listen: false);
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
      if (FocusScope.of(context).focusedChild ==
              filterNotifier.searchBarFocusNode ||
          filterNotifier.searchTerm.isNotEmpty) {
        filterNotifier.unfocusSearchBar();
        filterNotifier.searchTerm = '';
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
    final appNotifier = context.provide<AppNotifier>(listen: false);
    appNotifier.tabIndex = _tabController.index;
    context.provide<BottomSheetNotifier>(listen: false).activeScrollController =
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
    final appNotifier = context.provide<AppNotifier>(listen: false);
    if (!_init) {
      if (widget.firstTime) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(CrossFadePageRoute(
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
    final appNotifier = context.provide<AppNotifier>(listen: false);

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
