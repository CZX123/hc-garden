import 'library.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(HcGardenApp());
}

class HcGardenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Custom cache for all images in the app
        Provider<Map<String, Uint8List>>.value(
          value: {},
        ),
        // All Firebase data
        StreamProvider.value(
          initialData: FirebaseData(
            floraList: [],
            faunaList: [],
            trails: {},
            historicalDataList: [],
            aboutPageDataList: [],
          ),
          value: FirebaseDatabase.instance.reference().onValue.map(
            (event) {
              if (event.snapshot.value == null) {
                throw Exception('Value is empty!');
              }

              // Add list of entities
              final parsedJson =
                  Map<String, dynamic>.from(event.snapshot.value);
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

              // Add trails and locations
              Map<Trail, List<TrailLocation>> trails = {};
              parsedJson['map'].forEach((key, value) {
                final trail = Trail.fromJson(key, value);
                trails[trail] = [];
                value['route'].forEach((key, value) {
                  trails[trail].add(TrailLocation.fromJson(
                    key,
                    value,
                    floraList: floraList,
                    faunaList: faunaList,
                  ));
                });
              });

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
            },
          ),
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
          builder: (context) => SortNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => MapNotifier(),
        ),
        FutureProvider.value(
          value: getApplicationDocumentsDirectory(),
        ),
      ],
      child: Consumer<DebugNotifier>(
        builder: (context, debugInfo, child) {
          return MaterialApp(
            title: 'Nested Bottom Sheet',
            theme: ThemeData(
              platform:
                  debugInfo.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
              fontFamily: 'Manrope',
              primarySwatch: Colors.green,
            ),
            home: MyHomePage(title: 'Nested Bottom Sheet'),
            debugShowMaterialGrid: debugInfo.debugShowMaterialGrid,
            showPerformanceOverlay: debugInfo.showPerformanceOverlay,
            checkerboardRasterCacheImages:
                debugInfo.checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: debugInfo.checkerboardOffscreenLayers,
            showSemanticsDebugger: debugInfo.showSemanticsDebugger,
            debugShowCheckedModeBanner: debugInfo.debugShowCheckedModeBanner,
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _location = Location();
  final _pageIndex = ValueNotifier(1);
  TabController _tabController;
  final _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  double topPadding;
  double height;

  // TODO: offline indicator if user opens app when offline, and old contents show instead
  // Maybe can reduce code duplication
  /* rootBundle.loadString('assets/data/data.json').then((contents) {
    List<Flora> floraList = [];
    List<Fauna> faunaList = [];
    final parsedJson = jsonDecode(contents);
    parsedJson['flora&fauna'].forEach((key, value) {
      if (key.contains('flora')) {
        floraList.add(Flora.fromJson(key, value));
      } else if (key.contains('fauna')) {
        faunaList.add(Fauna.fromJson(key, value));
      }
    });
    floraList.sort((a, b) => a.name.compareTo(b.name));
    faunaList.sort((a, b) => a.name.compareTo(b.name));
    Map<Trail, List<TrailLocation>> trails = {};
    parsedJson['map'].forEach((key, value) {
      final trail = Trail.fromJson(key, value);
      trails[trail] = [];
      value['route'].forEach((key, value) {
        trails[trail].add(TrailLocation.fromJson(
          key,
          value,
          floraList: floraList,
          faunaList: faunaList,
        ));
      });
    });
    Provider.of<AppNotifier>(context, listen: false)
        .updateBackupLists(floraList, faunaList);
    Provider.of<AppNotifier>(context, listen: false).trails = trails;
  }); */

  Future<bool> onBack(BuildContext context) async {
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    final searchNotifier = Provider.of<SearchNotifier>(context, listen: false);
    final animation = bottomSheetNotifier.animation;
    final state = appNotifier.state;
    final navigatorKey = appNotifier.navigatorKey;
    if (state == 0) {
      if (navigatorKey.currentState.canPop()) {
        // If something wrong happens
        navigatorKey.currentState.pop();
        return false;
      }
      if (searchNotifier.isSearching) {
        searchNotifier
          ..isSearching = false
          ..searchTerm = '';
        return false;
      } else if (animation.value < height - bottomHeight) {
        bottomSheetNotifier.animateTo(height - bottomHeight);
        return false;
      }
      return true;
    } else if (state == 1) {
      if (animation.value > 10) {
        bottomSheetNotifier.animateTo(0);
      } else if (navigatorKey.currentState.canPop()) {
        navigatorKey.currentState.pop();
        appNotifier.changeState(
          context,
          0,
          activeScrollController: _scrollControllers[_tabController.index],
        );
        if (searchNotifier.searchTerm.isNotEmpty) searchNotifier.isSearching = true;
      }
      return false;
    } else if (state == 2) {
      // TODO: Replace with list of callbacks
      if (navigatorKey.currentState.canPop()) {
        navigatorKey.currentState.pop();
        appNotifier.changeState(context, 1);
        bottomSheetNotifier.draggingDisabled = false;
        return false;
      }
    }
    return true;
  }

  void checkPermission() async {
    var granted = await _location.hasPermission();
    if (!granted) {
      granted = await _location.requestPermission();
    }
    Provider.of<MapNotifier>(context, listen: false).permissionEnabled =
        granted;
    if (granted) {
      checkGPS();
    }
  }

  void checkGPS() async {
    var isOn = await _location.serviceEnabled();
    if (!isOn) {
      isOn = await _location.requestService();
    }
    if (isOn) setState(() {});
    Provider.of<MapNotifier>(context, listen: false).gpsOn = isOn;
  }

  void tabListener() {
    if (Provider.of<AppNotifier>(context, listen: false).state == 0)
      Provider.of<BottomSheetNotifier>(context, listen: false)
          .activeScrollController = _scrollControllers[_tabController.index];
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
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
    if (Provider.of<AppNotifier>(context, listen: false).state == 0)
      Provider.of<BottomSheetNotifier>(context, listen: false)
        ..snappingPositions.value = [
          0,
          height - bottomHeight,
          height - bottomBarHeight,
        ]
        ..endCorrection = topPadding - offsetTranslation
        ..activeScrollController ??= _scrollControllers[_tabController.index];
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
    return WillPopScope(
      onWillPop: () {
        return onBack(context);
      },
      child: Scaffold(
        drawer: DebugDrawer(),
        endDrawer: SortingDrawer(),
        body: CustomAnimatedSwitcher(
          crossShrink: false,
          child: height != 0
              ? NestedBottomSheet(
                  initialPosition: height - bottomHeight,
                  background: Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: bottomBarHeight,
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
                  header: ExploreHeader(
                    tabController: _tabController,
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
  }
}
