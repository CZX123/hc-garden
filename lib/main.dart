import 'library.dart';
import 'package:firebase_database/firebase_database.dart';

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
        StreamProvider.value(
            initialData: FirebaseData(
              floraList: [],
              faunaList: [],
              trails: {},
              historicalDataList: [],
              aboutPageDataList: [],
            ),
            value: FirebaseDatabase.instance.reference().onValue.map((event) {
              if (event.snapshot.value == null) {
                throw Exception('Value is empty!');
              }
              final parsedJson =
                  Map<String, dynamic>.from(event.snapshot.value);
              List<Flora> floraList = [];
              List<Fauna> faunaList = [];
              parsedJson['flora&fauna'].forEach((key, value) {
                if (key.contains('flora'))
                  floraList.add(Flora.fromJson(key, value));
                else
                  faunaList.add(Fauna.fromJson(key, value));
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

              return FirebaseData(
                floraList: floraList,
                faunaList: faunaList,
                trails: trails,
                historicalDataList: historicalDataList,
                aboutPageDataList: aboutPageDataList,
              );
            })),
        ChangeNotifierProvider(
          builder: (context) => DebugNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => AppNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => SearchNotifier(),
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

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

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

  Future<bool> onBack(
    BuildContext context,
    double height,
  ) async {
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final searchNotifier = Provider.of<SearchNotifier>(context, listen: false);
    final animation = appNotifier.animation;
    final state = appNotifier.state;
    final navigatorKey = appNotifier.navigatorKey;
    if (state == 0) {
      if (searchNotifier.isSearching) {
        Future.delayed(const Duration(milliseconds: 400), () {
          return searchNotifier.keyboardAppear = false;
        });
        searchNotifier
          ..isSearching = false
          ..searchTerm = '';
        return false;
      } else if (animation.value < height - bottomHeight) {
        appNotifier.animateTo(height - bottomHeight);
        return false;
      }
      return true;
    } else if (state == 1) {
      if (animation.value > 10) {
        appNotifier.animateTo(0);
      } else if (navigatorKey.currentState.canPop()) {
        navigatorKey.currentState.pop();
        appNotifier
          ..state = 0
          ..entity = null;
        if (searchNotifier.searchTerm.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 280), () {
            searchNotifier.isSearching = true;
          });
        }
      }
      return false;
    } else if (state == 2) {
      // TODO: Replace with list of callbacks
      if (navigatorKey.currentState.canPop()) {
        navigatorKey.currentState.pop();
        appNotifier
          ..state = 1
          ..draggingDisabled = false;
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final _state = ValueNotifier(0);
    final _pageIndex = ValueNotifier(1);
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        _state.value = state;
        return WillPopScope(
          onWillPop: () {
            return onBack(context, height);
          },
          child: Scaffold(
            endDrawer: DebugDrawer(),
            body: height != 0
                ? NestedBottomSheet(
                    endCorrection: state == 0
                        ? topPadding - offsetTranslation
                        : topPadding,
                    height: height,
                    snappingPositions: state == 0
                        ? [0, height - bottomHeight, height - 62]
                        : [
                            0,
                            height - 48 - 96 - 216 - 16,
                            height - 48 - 96,
                          ],
                    initialPosition: height - bottomHeight,
                    tablength: 2,
                    extraScrollControllers: 1,
                    state: _state,
                    backgroundBuilder:
                        (context, animation, tabController, animateTo) {
                      Provider.of<AppNotifier>(context, listen: false)
                        ..animation = animation
                        ..animateTo = animateTo;
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 62,
                            child: ValueListenableBuilder(
                              valueListenable: _pageIndex,
                              builder: (context, pageIndex, child) {
                                return CustomAnimatedSwitcher(
                                  child: pageIndex == 0
                                      ? HistoryPage()
                                      : pageIndex == 2
                                          ? AboutPage()
                                          : child,
                                );
                              },
                              child: MapWidget(),
                            ),
                          ),
                        ],
                      );
                    },
                    headerBuilder: (
                      context,
                      animation,
                      tabController,
                      animateTo,
                      isScrolledNotifier,
                    ) {
                      return ExploreHeader(
                        animation: animation,
                        tabController: tabController,
                        animateTo: animateTo,
                        isScrolledNotifier: isScrolledNotifier,
                      );
                    },
                    bodyBuilder: (
                      context,
                      animation,
                      tabController,
                      scrollControllers,
                      extraScrollControllers,
                      animateTo,
                    ) {
                      return ExploreBody(
                        animation: animation,
                        tabController: tabController,
                        scrollControllers: scrollControllers,
                        extraScrollControllers: extraScrollControllers,
                        animateTo: animateTo,
                      );
                    },
                    footerBuilder: (
                      context,
                      animation,
                      tabController,
                      animateTo,
                      isScrolledNotifier,
                    ) {
                      return BottomSheetFooter(
                        pageIndex: _pageIndex,
                      );
                    },
                  )
                : SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
