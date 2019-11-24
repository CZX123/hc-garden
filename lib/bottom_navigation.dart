import 'library.dart';

class BottomSheetFooter extends StatelessWidget {
  final ValueNotifier<int> pageIndex;
  const BottomSheetFooter({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

  double _getPaddingBreakPoint(BottomSheetNotifier bottomSheetNotifier) {
    return bottomSheetNotifier.snappingPositions.value[1];
  }

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final anim = Tween<double>(
      begin: 0,
      end: 1 / _getPaddingBreakPoint(bottomSheetNotifier),
    ).animate(bottomSheetNotifier.animation);
    return Stack(
      children: <Widget>[
        // Notched Bottom App Bar for Entity List Page
        AnimatedNotchedAppBar(bottomSheetAnimation: anim),
        // 3 Button Bottom Navigation
        Selector<AppNotifier, int>(
          selector: (context, appNotifier) => appNotifier.state,
          builder: (context, state, child) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: Sizes.hBottomBarHeight,
              child: ValueListenableBuilder<double>(
                valueListenable: anim,
                builder: (context, value, child) {
                  Offset offset;
                  if (state != 0) {
                    offset = Offset(0, Sizes.hBottomBarHeight * 2);
                  } else if (value > 1) {
                    offset = Offset(0, 0);
                  } else {
                    offset = Offset(
                        0,
                        Sizes.hBottomBarHeight *
                            2 *
                            (1 - value));
                  //print('$value, $paddingBreakpoint, $offset');
                  }
                  return Transform.translate(
                    offset: offset,
                    child: child,
                  );
                },
                child: child,
              ),
            );
          },
          child: Selector<AppNotifier, bool>(
            selector: (context, appNotifier) => appNotifier.routes.isNotEmpty,
            builder: (context, value, child) {
              return AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                  0,
                  value ? Sizes.hBottomBarHeight * 2 : 0,
                  0,
                ),
                child: child,
              );
            },
            child: ValueListenableBuilder(
              valueListenable: pageIndex,
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: kElevationToShadow[8],
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Theme.of(context).bottomAppBarColor,
                    elevation: 0,
                    currentIndex: value,
                    onTap: (index) {
                      if (index == 1) {
                        bottomSheetNotifier
                          ..draggingDisabled = false
                          ..animateTo(bottomSheetNotifier.snappingPositions.value[1]);
                      } else {
                        bottomSheetNotifier
                          ..animateTo(
                            bottomSheetNotifier.snappingPositions.value.last,
                            const Duration(milliseconds: 240),
                          )
                          ..draggingDisabled = true;
                      }
                      pageIndex.value = index;
                    },
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.dvr),
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
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedNotchedAppBar extends StatefulWidget {
  final Animation<double> bottomSheetAnimation;
  const AnimatedNotchedAppBar({
    Key key,
    @required this.bottomSheetAnimation,
  }) : super(key: key);

  @override
  _AnimatedNotchedAppBarState createState() => _AnimatedNotchedAppBarState();
}

class _AnimatedNotchedAppBarState extends State<AnimatedNotchedAppBar>
    with TickerProviderStateMixin {
  bool init = false;
  AppNotifier _appNotifier;
  int _state = 0;
  SearchNotifier _searchNotifier;
  bool _isSearching = false;
  bool _themeIsChanging = true;
  AnimationController _animationController;
  AnimationController _fabPressController;

  void stateListener() {
    if (_appNotifier.state == 1) {
      _animationController.animateTo(
        1,
        duration: Duration(
          milliseconds: _searchNotifier.isSearching ? 350 : 250,
        ),
        curve: Curves.fastOutSlowIn,
      );
    } else if (_appNotifier.state == 0) {
      if (_appNotifier.routes.isNotEmpty) {
        _animationController.animateTo(
          1,
          duration: Duration(milliseconds: 50),
          curve: Curves.fastOutSlowIn,
        );
      } else if (_searchNotifier.searchTerm.isEmpty) {
        final height = MediaQuery.of(context).size.height;
        final hidden = Provider.of<BottomSheetNotifier>(
              context,
              listen: false,
            ).animation.value >
            (height - Sizes.kBottomHeight) / 2;
        _animationController.animateTo(
          0.5,
          duration: Duration(milliseconds: 250),
          curve: hidden ? Interval(.5, 1) : Curves.fastOutSlowIn,
        );
      } else {
        final height = MediaQuery.of(context).size.height;
        final hidden = Provider.of<BottomSheetNotifier>(
              context,
              listen: false,
            ).animation.value >
            (height - Sizes.kBottomHeight) / 2;
        _animationController.animateTo(
          0,
          duration: Duration(milliseconds: 350),
          curve: hidden ? Interval(.5, 1) : Curves.fastOutSlowIn,
        );
      }
    } else {
      _themeIsChanging = false;
    }
    _state = _appNotifier.state;
  }

  void searchListener() {
    if (_isSearching == _searchNotifier.isSearching) return;
    if (!_searchNotifier.isSearching && _appNotifier.state == 0) {
      _animationController
          .animateTo(
        0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      )
          .then((_) {
        _searchNotifier.keyboardAppear = false;
      });
    }
    _isSearching = _searchNotifier.isSearching;
  }

  @override
  void initState() {
    super.initState();
    // 0: Search bar
    // 0.5: Normal search fab, default value
    // 15 / 16: Search fab fully minimised, still with some bottom notch
    // 1: Notch fully minimised
    _animationController = AnimationController(
      value: 0.5,
      vsync: this,
    );
    // 0: Not pressed
    // 1: Pressed
    _fabPressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeIsChanging = true;
    if (!init) {
      _appNotifier = Provider.of<AppNotifier>(
        context,
        listen: false,
      )..addListener(stateListener);
      _searchNotifier = Provider.of<SearchNotifier>(
        context,
        listen: false,
      )..addListener(searchListener);
      init = true;
      stateListener();
      searchListener();
    }
  }

  @override
  void dispose() {
    _appNotifier.removeListener(stateListener);
    _searchNotifier.removeListener(searchListener);
    _animationController.dispose();
    _fabPressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final rectTween = MaterialRectArcTween(
      begin: Rect.fromLTWH(0, 28, _width, Sizes.kBottomBarHeight),
      end: Rect.fromCircle(
        center: Offset(_width / 2, 28),
        radius: 28,
      ),
    );
    return SizedBox(
      height: Sizes.kBottomBarHeight + 28,
      child: Selector<AppNotifier, bool>(
        selector: (context, appNotifier) => appNotifier.routes.isNotEmpty,
        builder: (context, appear, child) {
          return ValueListenableBuilder(
            valueListenable: widget.bottomSheetAnimation,
            builder: (context, value, child) {
              Duration d = const Duration(milliseconds: 300);
              double y = 0;
              if (!appear && _state == 0) {
                if (value >= .5) {
                  y = Sizes.kBottomBarHeight + 28;
                } else {
                  d = Duration.zero;
                  y = value * (Sizes.kBottomBarHeight + 28) * 2;
                }
              }
              return AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: d,
                transform: Matrix4.translationValues(0, y, 0),
                child: child,
              );
            },
            child: child,
          );
        },
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Selector2<AppNotifier, ThemeNotifier, bool>(
              selector: (context, appNotifier, themeNotifier) {
                return appNotifier.state == 2 || themeNotifier.value;
              },
              builder: (context, value, child) {
                return AnimatedTheme(
                  data: value ? darkThemeData : themeData,
                  duration: _themeIsChanging
                      ? kThemeAnimationDuration
                      : const Duration(milliseconds: 300),
                  child: child,
                );
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  type: MaterialType.transparency,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _animationController,
                    builder: (context, value, child) {
                      double elevation = 12;
                      double radius = 28;
                      double margin = 4;
                      if (value > 0.5) {
                        elevation = 24 * (1 - value);
                        if (value < 15 / 16) {
                          radius = 60 - 64 * value;
                        } else {
                          radius = 0;
                          margin = 64 * (1 - value);
                        }
                      }
                      return PhysicalShape(
                        color: Theme.of(context).bottomAppBarColor,
                        elevation: elevation,
                        clipper: BottomAppBarClipper(
                          windowWidth: _width,
                          notchMargin: margin,
                          radius: radius,
                        ),
                        child: child,
                      );
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: SizedBox(
                        height: Sizes.kBottomBarHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Tooltip(
                              message: 'Back',
                              preferBelow: false,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.maybePop(context),
                              ),
                            ),
                            FadeTransition(
                              opacity: Tween(
                                begin: 2.5,
                                end: -0.5,
                              ).animate(_animationController),
                              child: ValueListenableBuilder(
                                valueListenable: _animationController,
                                builder: (context, value, child) {
                                  return IgnorePointer(
                                    ignoring: value > .5,
                                    ignoringSemantics: value > .5,
                                    child: child,
                                  );
                                },
                                child: Tooltip(
                                  message: 'Filter',
                                  preferBelow: false,
                                  child: IconButton(
                                    icon: const Icon(Icons.filter_list),
                                    onPressed: () {
                                      if (Provider.of<AppNotifier>(context,
                                              listen: false)
                                          .routes
                                          .isEmpty)
                                        Scaffold.of(context).openEndDrawer();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              height: 1,
              bottom: Sizes.kBottomBarHeight - 1,
              child: Selector<AppNotifier, bool>(
                selector: (context, appNotifier) => appNotifier.state != 2,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  );
                },
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: Tween(
                      begin: -1.0,
                      end: 1.0,
                    ).animate(_animationController),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _animationController,
              builder: (context, value, child) {
                double scale = 0;
                double radius = 28;
                if (value < 0.5) {
                  scale = 1;
                  radius = 56 * value;
                } else if (value < 15 / 16) {
                  scale = 15 / 7 - 16 / 7 * value;
                }
                return Positioned.fromRect(
                  rect: rectTween.transform(min(value * 2, 1)),
                  child: Transform.scale(
                    scale: scale,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ValueListenableBuilder(
                        valueListenable: _fabPressController,
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(radius),
                              boxShadow: BoxShadow.lerpList(
                                kElevationToShadow[6],
                                kElevationToShadow[12],
                                value,
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: <Widget>[
                  FadeTransition(
                    opacity: Tween(
                      begin: 1.0,
                      end: -2.0,
                    ).animate(_animationController),
                    child: const SearchBar(),
                  ),
                  FadeTransition(
                    opacity: Tween(
                      begin: -0.5,
                      end: 2.5,
                    ).animate(_animationController),
                    child: ValueListenableBuilder(
                      valueListenable: _animationController,
                      builder: (context, value, child) {
                        return IgnorePointer(
                          ignoring: value < .25,
                          ignoringSemantics: value < .25,
                          child: child,
                        );
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Tooltip(
                            message: 'Search',
                            preferBelow: false,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                height: 56,
                                width: 56,
                                alignment: Alignment.center,
                                child: Consumer<ThemeNotifier>(
                                  builder: (context, themeNotifier, child) {
                                    return AnimatedSwitcher(
                                      duration: kThemeAnimationDuration,
                                      child: Icon(
                                        Icons.search,
                                        key: ValueKey(themeNotifier.value),
                                        color: themeNotifier.value
                                            ? Theme.of(context).accentColor
                                            : Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onTapDown: (_) {
                                _fabPressController.forward();
                              },
                              onTap: () {
                                _fabPressController.reverse();
                                if (_state != 0) return;
                                _animationController
                                    .animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.fastOutSlowIn,
                                )
                                    .then((_) {
                                  Provider.of<SearchNotifier>(
                                    context,
                                    listen: false,
                                  ).keyboardAppear = true;
                                });
                                Provider.of<SearchNotifier>(
                                  context,
                                  listen: false,
                                ).isSearching = true;
                              },
                              onTapCancel: () {
                                _fabPressController.reverse();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  void onTextChange() {
    Provider.of<SearchNotifier>(context, listen: false).searchTerm =
        controller.text;
  }

  void onFocus() {
    Provider.of<SearchNotifier>(context, listen: false)
        .keyboardAppearFromFocus();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onTextChange);
    focusNode.addListener(onFocus);
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocus);
    controller.removeListener(onTextChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SearchNotifier>(context, listen: false).focusNode = focusNode;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            bottom: 0,
            height: Sizes.kBottomBarHeight,
            width: 48,
            child: Tooltip(
              message: 'Back',
              preferBelow: false,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  Navigator.maybePop(context);
                  controller.clear();
                },
              ),
            ),
          ),
          Positioned(
            left: 96,
            right: 96,
            bottom: 0,
            height: Sizes.kBottomBarHeight,
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              cursorColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            height: Sizes.kBottomBarHeight,
            width: 48,
            child: Tooltip(
              message: 'Clear',
              preferBelow: false,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    color: Theme.of(context).colorScheme.onPrimary,
                    disabledColor:
                        Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
                    onPressed: value.text.isEmpty ? null : controller.clear,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchNotifier extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool isSearching) {
    if (isSearching == _isSearching) return;
    _isSearching = isSearching;
    notifyListeners();
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();
  }

  FocusNode focusNode;

  bool _keyboardAppear = false;
  bool get keyboardAppear => _keyboardAppear;
  set keyboardAppear(bool keyboardAppear) {
    if (_keyboardAppear == keyboardAppear) return;
    _keyboardAppear = keyboardAppear;
    if (focusNode == null) return;
    if (keyboardAppear)
      focusNode.requestFocus();
    else
      focusNode.unfocus();
    notifyListeners();
  }

  void keyboardAppearFromFocus() {
    _keyboardAppear = focusNode.hasFocus;
  }
}

// The clipper for clipping the bottom app bar for the notched search fab
class BottomAppBarClipper extends CustomClipper<Path> {
  final double windowWidth;
  final double notchMargin;
  final double radius;
  const BottomAppBarClipper({
    @required this.windowWidth,
    this.notchMargin = 4,
    this.radius = 28,
  })  : assert(windowWidth != null),
        assert(notchMargin != null),
        assert(radius != null);

  @override
  Path getClip(Size size) {
    final Rect button = Rect.fromCircle(
      center: Offset(windowWidth / 2, 0),
      radius: radius,
    );
    return CircularNotchedRectangle().getOuterPath(
      Offset.zero & size,
      button.inflate(notchMargin),
    );
  }

  @override
  bool shouldReclip(BottomAppBarClipper oldClipper) {
    return oldClipper.windowWidth != windowWidth ||
        oldClipper.notchMargin != notchMargin ||
        oldClipper.radius != radius;
  }
}
