import 'library.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TODO: Add a StreamProvider for Firebase Database
        ChangeNotifierProvider(
          builder: (context) => DebugNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => AppNotifier(),
        ),
        Provider<Map<String, Uint8List>>.value(
          value: {},
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
            checkerboardRasterCacheImages: debugInfo.checkerboardRasterCacheImages,
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

class _MyHomePageState extends State<MyHomePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _state = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    // TODO: Change to Firebase Database
    rootBundle.loadString('assets/data/data.json').then((contents) {
      List<Flora> floraList = [];
      List<Fauna> faunaList = [];
      final parsedJson = jsonDecode(contents);
      parsedJson['flora&fauna'].forEach((key, value) {
        if (key.contains('flora')) {
          floraList.add(Flora.fromJson(value));
        } else if (key.contains('fauna')) {
          faunaList.add(Fauna.fromJson(value));
        }
      });
      floraList.sort((a, b) => a.name.compareTo(b.name));
      faunaList.sort((a, b) => a.name.compareTo(b.name));
      Provider.of<AppNotifier>(context, listen: false)
          .updateLists(floraList, faunaList);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            if (appNotifier.isSearching && appNotifier.state == 0) {
              appNotifier.isSearching = false;
              return false;
            }
            if (_navigatorKey.currentState.canPop()) {
              _navigatorKey.currentState.pop();
              appNotifier.updateState(0, null);
              return false;
            }
            if (!appNotifier.sheetMinimised) {
              _animateTo(height - 382);
              return false;
            }
            return true;
          },
          child: Scaffold(
            endDrawer: DebugDrawer(),
            body: height != 0
                ? NestedBottomSheet(
                    endCorrection: topPadding - 206,
                    height: height,
                    snappingPositions: state == 0
                        ? [0, height - 382, height - 56]
                        : [
                            0,
                            (height - 56) / 3,
                            2 * (height - 56) / 3,
                            height - 56,
                          ],
                    initialPosition: height - 382,
                    tablength: 2,
                    extraScrollControllers: 1,
                    state: _state,
                    backgroundBuilder:
                        (context, animation, tabController, animateTo) {
                      return MapWidget();
                    },
                    headerBuilder: (
                      context,
                      animation,
                      tabController,
                      animateTo,
                      isScrolledNotifier,
                    ) {
                      _animateTo = animateTo;
                      return BottomSheetHeader(
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

class BottomSheetHeader extends StatelessWidget {
  final Animation<double> animation;
  final TabController tabController;
  final Function(double) animateTo;
  final ValueNotifier<bool> isScrolledNotifier;
  const BottomSheetHeader({
    Key key,
    @required this.animation,
    @required this.tabController,
    @required this.animateTo,
    @required this.isScrolledNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _trails = ['Jing Xian Trail', 'Kong Chian Trail', 'Kah Kee Trail'];
    final _colors = [Colors.amber[600], Colors.pink, Colors.lightBlue];
    final height = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final anim =
        Tween<double>(begin: 0, end: 1 / (height - 56)).animate(animation);
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        return AnimatedOpacity(
          opacity: state == 0 ? 1 : 0,
          duration: Duration(milliseconds: state == 0 ? 400 : 200),
          curve:
              state == 0 ? Interval(0.5, 1, curve: Curves.ease) : Curves.ease,
          child: child,
        );
      },
      child: Stack(
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: animation,
            builder: (context, value, child) {
              return IgnorePointer(
                ignoring: value < height - 382,
                child: child,
              );
            },
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                FadeTransition(
                  opacity: Tween(
                    begin: (239 - height / 2) / 48,
                    end: (height / 2 + 183) / 48,
                  ).animate(anim),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 4,
                        width: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Explore HC Garden',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                FadeTransition(
                  opacity: Tween(
                    begin: (406 - height) / 24,
                    end: 14.58,
                  ).animate(anim),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: <Widget>[
                        for (var i = 0; i < 3; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FlatButton(
                                colorBrightness: Brightness.dark,
                                color: _colors[i],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  height: 96,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _trails[i].toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                        ),
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              Offset offset;
              if (animation.value > height - 382) {
                offset = Offset(0, 174 - topPadding);
                Provider.of<AppNotifier>(context, listen: false)
                    .sheetMinimised = true;
              } else {
                offset = Offset(
                    0, animation.value / (height - 382) * (174 - topPadding));
                Provider.of<AppNotifier>(context, listen: false)
                    .sheetMinimised = false;
              }
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: topPadding + 8),
              color: Theme.of(context).canvasColor,
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Row(
                children: <Widget>[
                  for (var i = 0; i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(i == 0
                                  ? 'assets/images/flora.jpg'
                                  : 'assets/images/fauna.jpg'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FlatButton(
                            colorBrightness: Brightness.dark,
                            color: Colors.black38,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                double cardHeight = 128;
                                if (animation.value < height - 382) {
                                  cardHeight = 64 +
                                      64 *
                                          animation.value /
                                          height *
                                          height /
                                          (height - 382);
                                }
                                return Container(
                                  height: cardHeight,
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
                              child: Text(
                                i == 0 ? 'FLORA' : 'FAUNA',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (animation.value < height - 382)
                                tabController.animateTo(i);
                              else {
                                tabController.animateTo(
                                  i,
                                  duration: const Duration(
                                    milliseconds: 1,
                                  ),
                                );
                              }
                              animateTo(0);
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            Offset offset;
            if (animation.value > height - 382)
              offset = Offset(0, 238 - topPadding);
            else
              offset = Offset(
                  0,
                  animation.value /
                      height *
                      (238 - topPadding) *
                      height /
                      (height - 382));
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
                    Selector<AppNotifier, List<Flora>>(
                      selector: (context, appNotifier) => appNotifier.floraList,
                      builder: (context, floraList, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[0],
                          extraScrollController: extraScrollControllers[0],
                          entityList: floraList,
                        );
                      },
                    ),
                    Selector<AppNotifier, List<Fauna>>(
                      selector: (context, appNotifier) => appNotifier.faunaList,
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
