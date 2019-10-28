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
        // TODO: Add a StreamProvider for Firebase Database
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _state = ValueNotifier(0);
  StreamSubscription<List<Entity>> stream;

  void onData(List<Entity> list) {
    List<Flora> floraList = [];
    List<Fauna> faunaList = [];
    for (var entity in list) {
      if (entity is Flora) {
        floraList.add(entity);
      } else {
        final fauna = entity as Fauna;
        faunaList.add(fauna);
      }
    }
    floraList.sort((a, b) => a.name.compareTo(b.name));
    faunaList.sort((a, b) => a.name.compareTo(b.name));
    Provider.of<AppNotifier>(context, listen: false)
        .updateLists(floraList, faunaList);
  }

  @override
  void initState() {
    super.initState();
    // TODO: offline indicator if user opens app when offline, and old contents show instead
    // Maybe can reduce code duplication
    rootBundle.loadString('assets/data/data.json').then((contents) {
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
    });
    stream = FirebaseDatabase.instance
        .reference()
        .child('flora&fauna')
        .onValue
        .map((event) {
      if (event?.snapshot?.value == null) {
        throw Exception('List of entities is empty!');
      }
      final parsedJson = Map<String, dynamic>.from(event.snapshot.value);
      var list = parsedJson
          .map((key, value) {
            if (key.contains('flora')) {
              return MapEntry(Flora.fromJson(key, value), 0);
            } else {
              return MapEntry(Fauna.fromJson(key, value), 0);
            }
          })
          .keys
          .toList();
      return list;
    }).listen(onData);
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
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
                      return ExploreBody(
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
