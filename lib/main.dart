import 'package:bottom_sheet/library.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (context) => DebugNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => AppNotifier(),
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

class _MyHomePageState extends State<MyHomePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();

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
    final state = Provider.of<AppNotifier>(context).state;
    Function(double) _animateTo;
    return WillPopScope(
      onWillPop: () async {
        if (_navigatorKey.currentState.canPop()) {
          _navigatorKey.currentState.pop();
          Provider.of<AppNotifier>(context, listen: false).updateState(0, null);
          return false;
        } else if (!Provider.of<AppNotifier>(context, listen: false)
            .sheetMinimised) {
          _animateTo(height - 382);
          return false;
        }
        return true;
      },
      child: Scaffold(
        endDrawer: DebugDrawer(),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            if (height != 0)
              NestedBottomSheet(
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
                  animateTo,
                ) {
                  return BottomSheetBody(
                    animation: animation,
                    tabController: tabController,
                    scrollControllers: scrollControllers,
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
              ),
          ],
        ),
      ),
    );
  }
}

class BottomSheetFooter extends StatelessWidget {
  final Animation<double> animation;
  final Function(double) animateTo;
  const BottomSheetFooter({
    Key key,
    @required this.animation,
    @required this.animateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);
    final indexNotifier = ValueNotifier(1);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              Offset offset;
              if (appNotifier.state != 0) {
                offset = Offset(0, 128);
              } else if (animation.value > height - 382) {
                offset = Offset(0, 0);
              } else {
                offset =
                    Offset(0, 128 - animation.value / (height - 382) * 128);
              }
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: ValueListenableBuilder(
                valueListenable: indexNotifier,
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: kElevationToShadow[8],
                    ),
                    child: BottomNavigationBar(
                      elevation: 0,
                      currentIndex: value,
                      onTap: (index) {
                        if (index == 1) animateTo(height - 382);
                        indexNotifier.value = index;
                      },
                      items: [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.history),
                          title: Text('History'),
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.map),
                          title: Text('Explore'),
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.info),
                          title: Text('About'),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        SizedBox(
          height: 76,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              Offset offset;
              if (animation.value > height - 382) {
                offset = Offset(0, 152);
              } else {
                offset = Offset(0, animation.value / (height - 382) * 152);
              }
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: PhysicalShape(
                    elevation: 8,
                    color: Theme.of(context).canvasColor,
                    clipper: BottomAppBarClipper(windowWidth: width),
                    child: SizedBox(
                      height: 48,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.maybePop(context),
                              tooltip: 'Back',
                            ),
                            IconButton(
                              icon: const Icon(Icons.sort),
                              onPressed: () {},
                              tooltip: 'Sort',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: FloatingActionButton(
                    child: const Icon(Icons.search),
                    onPressed: () {},
                    tooltip: 'Search',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BottomAppBarClipper extends CustomClipper<Path> {
  final double windowWidth;
  final double notchMargin;
  const BottomAppBarClipper({
    @required this.windowWidth,
    this.notchMargin = 4,
  })  : assert(windowWidth != null),
        assert(notchMargin != null);

  @override
  Path getClip(Size size) {
    final Rect button = Rect.fromCircle(
      center: Offset(windowWidth / 2, 0),
      radius: 28,
    );
    return CircularNotchedRectangle()
        .getOuterPath(Offset.zero & size, button.inflate(notchMargin));
  }

  @override
  bool shouldReclip(BottomAppBarClipper oldClipper) {
    return oldClipper.windowWidth != windowWidth ||
        oldClipper.notchMargin != notchMargin;
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
    return Consumer<AppNotifier>(
      builder: (context, appNotifier, child) {
        return AnimatedOpacity(
          opacity: appNotifier.state == 0 ? 1 : 0,
          duration: Duration(milliseconds: appNotifier.state == 0 ? 400 : 300),
          curve: appNotifier.state == 0
              ? Interval(0.5, 1, curve: Curves.ease)
              : Curves.ease,
          child: child,
        );
      },
      child: Stack(
        children: <Widget>[
          Column(
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, topPadding + 8, 0, 0),
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
  final Function(double) animateTo;
  final GlobalKey<NavigatorState> navigatorKey;
  const BottomSheetBody({
    Key key,
    @required this.animation,
    @required this.tabController,
    @required this.scrollControllers,
    @required this.animateTo,
    @required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
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
                    Consumer<AppNotifier>(
                      builder: (context, appNotifier, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[0],
                          entityList: appNotifier.floraList,
                        );
                      },
                    ),
                    Consumer<AppNotifier>(
                      builder: (context, appNotifier, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[1],
                          entityList: appNotifier.faunaList,
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white.withOpacity(0)],
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

class EntityListPage extends StatelessWidget {
  final ScrollController scrollController;
  final List<Entity> entityList;
  const EntityListPage({
    Key key,
    @required this.scrollController,
    @required this.entityList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);
    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 72),
        controller:
            appNotifier.state == 0 ? scrollController : ScrollController(),
        physics: NeverScrollableScrollPhysics(),
        itemCount: entityList.length,
        itemBuilder: (context, index) {
          final key = GlobalKey();
          return Container(
            key: key,
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 32,
                      backgroundImage:
                          NetworkImage(entityList[index].smallImage),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            entityList[index].name,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          Text(
                            entityList[index].description,
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  height: 1.5,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Provider.of<AppNotifier>(context)
                    .updateState(1, entityList[index]);
                final oldChild = Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 80,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              entityList[index].name,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            Text(
                              entityList[index].description,
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        height: 1.5,
                                      ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                final persistentOldChild = Padding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            NetworkImage(entityList[index].smallImage),
                      ),
                    ],
                  ),
                );
                Navigator.of(context).push(
                  ExpandPageRoute<void>(
                    builder: (context) => DetailsPage(
                      entity: entityList[index],
                      scrollController: scrollController,
                    ),
                    sourceKey: key,
                    oldChild: oldChild,
                    persistentOldChild: persistentOldChild,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
