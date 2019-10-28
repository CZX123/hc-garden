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
            ),
            value: FirebaseDatabase.instance.reference().onValue.map((event) {
              if (event.snapshot.value == null) {
                throw Exception('List of entities is empty!');
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

              return FirebaseData(
                floraList: floraList,
                faunaList: faunaList,
                trails: trails,
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

  @override
  Widget build(BuildContext context) {
    final _navigatorKey = GlobalKey<NavigatorState>();
    final _state = ValueNotifier(0);
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    Function(double) _animateTo;
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        _state.value = state;
        return WillPopScope(
          onWillPop: () async {
            final appNotifier =
                Provider.of<AppNotifier>(context, listen: false);
            final searchNotifier =
                Provider.of<SearchNotifier>(context, listen: false);
            if (searchNotifier.isSearching && appNotifier.state == 0) {
              Future.delayed(const Duration(milliseconds: 400), () {
                return searchNotifier.keyboardAppear = false;
              });
              searchNotifier.isSearching = false;
              searchNotifier.searchTerm = '';
              return false;
            }
            if (_navigatorKey.currentState.canPop()) {
              _navigatorKey.currentState.pop();
              appNotifier.updateState(0, null);
              _animateTo(0);
              if (searchNotifier.searchTerm.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 280), () {
                  return searchNotifier.isSearching = true;
                });
              }
              return false;
            }
            if (!appNotifier.sheetMinimised) {
              _animateTo(height - bottomHeight);
              return false;
            }
            return true;
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
                          .animation = animation;
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 62,
                            child: MapWidget(),
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
                      _animateTo = animateTo;
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
                      return BottomSheetBody(
                        animation: animation,
                        tabController: tabController,
                        scrollControllers: scrollControllers,
                        extraScrollControllers: extraScrollControllers,
                        animateTo: animateTo,
                        navigatorKey: _navigatorKey,
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
                        animation: animation,
                        animateTo: animateTo,
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

class BottomSheetBody extends StatelessWidget {
  final Animation<double> animation;
  final TabController tabController;
  final List<ScrollController> scrollControllers;
  final List<ScrollController> extraScrollControllers;
  final Function(double) animateTo;
  final GlobalKey<NavigatorState> navigatorKey;
  const BottomSheetBody({
    Key key,
    @required this.animation,
    @required this.tabController,
    @required this.scrollControllers,
    @required this.extraScrollControllers,
    @required this.animateTo,
    @required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final color = Theme.of(context).canvasColor;
    final initialRoute = FadeOutPageRoute<void>(
      builder: (context) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            print(animation.value);
            Offset offset;
            if (animation.value > height - bottomHeight)
              offset = Offset(
                0,
                bottomHeight -
                    bottomBarHeight -
                    entityButtonHeightCollapsed -
                    16 -
                    topPadding,
              );
            else
              offset = Offset(
                0,
                animation.value *
                    (bottomHeight -
                        bottomBarHeight -
                        entityButtonHeightCollapsed -
                        16 -
                        topPadding) /
                    (height - bottomHeight),
              );
            return Transform.translate(
              offset: offset,
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.only(top: topPadding + 72),
            height: height + 128,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                TabBarView(
                  controller: tabController,
                  children: <Widget>[
                    Selector<FirebaseData, List<Flora>>(
                      selector: (context, firebaseData) => firebaseData.floraList,
                      builder: (context, floraList, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[0],
                          extraScrollController: extraScrollControllers[0],
                          entityList: floraList,
                        );
                      },
                    ),
                    Selector<FirebaseData, List<Fauna>>(
                      selector: (context, firebaseData) => firebaseData.faunaList,
                      builder: (context, faunaList, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[1],
                          extraScrollController: extraScrollControllers[0],
                          entityList: faunaList,
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color,
                              color.withOpacity(.738),
                              color.withOpacity(.541),
                              color.withOpacity(.382),
                              color.withOpacity(.278),
                              color.withOpacity(.194),
                              color.withOpacity(.126),
                              color.withOpacity(.075),
                              color.withOpacity(.042),
                              color.withOpacity(.021),
                              color.withOpacity(.008),
                              color.withOpacity(.002),
                              color.withOpacity(0),
                            ],
                            stops: [
                              0,
                              .19,
                              .34,
                              .45,
                              .565,
                              .65,
                              .73,
                              .802,
                              .861,
                              .91,
                              .952,
                              .982,
                              1,
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) return initialRoute;
        return null;
      },
    );
  }
}
