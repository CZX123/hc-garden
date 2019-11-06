import 'library.dart';

class BottomSheetFooter extends StatelessWidget {
  final ValueNotifier<int> pageIndex;
  const BottomSheetFooter({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final animateTo = bottomSheetNotifier.animateTo;
    final animation = bottomSheetNotifier.animation;
    return Stack(
      children: <Widget>[
        // 3 Button Bottom Navigation
        Selector<AppNotifier, int>(
          selector: (context, appNotifier) => appNotifier.state,
          builder: (context, state, child) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  Offset offset;
                  if (state != 0) {
                    offset = Offset(0, 128);
                  } else if (animation.value > height - bottomHeight) {
                    offset = Offset(0, 0);
                  } else {
                    offset = Offset(0,
                        128 - animation.value / (height - bottomHeight) * 128);
                  }
                  if (offset.dy == 128) return const SizedBox.shrink();
                  return Transform.translate(
                    offset: offset,
                    child: child,
                  );
                },
                child: child,
              ),
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
                  elevation: 0,
                  currentIndex: value,
                  onTap: (index) {
                    if (index == 1) {
                      bottomSheetNotifier.draggingDisabled = false;
                      animateTo(height - bottomHeight);
                    } else {
                      bottomSheetNotifier.draggingDisabled = true;
                      animateTo(
                        height - bottomBarHeight,
                        const Duration(milliseconds: 240),
                      );
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
        // Notched Bottom App Bar for Entity List Page
        AnimatedNotchedAppBar(bottomSheetAnimation: animation),
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
  AnimationController _animationController;
  AnimationController _fabPressController;

  void stateListener() {
    if (_state == _appNotifier.state || _appNotifier.state == 2) return;
    if (_appNotifier.state == 1) {
      _animationController.animateTo(
        1,
        duration: Duration(
          milliseconds: _searchNotifier.isSearching ? 350 : 250,
        ),
        curve: Curves.fastOutSlowIn,
      );
    } else if (_appNotifier.state == 0) {
      if (_searchNotifier.searchTerm.isEmpty) {
        _animationController.animateTo(
          0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _animationController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
        );
      }
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
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    final rectTween = MaterialRectArcTween(
      begin: Rect.fromLTWH(0, 28, _width, 48),
      end: Rect.fromCircle(
        center: Offset(_width / 2, 28),
        radius: 28,
      ),
    );
    return SizedBox(
      height: 76,
      child: ValueListenableBuilder(
        valueListenable: widget.bottomSheetAnimation,
        builder: (context, value, child) {
          Offset offset = Offset(0, 0);
          if (_state == 0) {
            if (value > _height - 382) {
              offset = Offset(0, 152);
            } else {
              offset = Offset(0, value / (_height - 382) * 152);
            }
          }
          return Transform.translate(
            offset: offset,
            child: child,
          );
        },
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Align(
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
                      color: Theme.of(context).canvasColor,
                      elevation: elevation,
                      clipper: BottomAppBarClipper(
                        windowWidth: _width,
                        notchMargin: margin,
                        radius: radius,
                      ),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.maybePop(context),
                          tooltip: 'Back',
                        ),
                        FadeTransition(
                          opacity: Tween(
                            begin: 2.5,
                            end: -0.5,
                          ).animate(_animationController),
                          child: IconButton(
                            icon: const Icon(Icons.sort),
                            onPressed: Scaffold.of(context).openEndDrawer,
                            tooltip: 'Sort',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              height: 1,
              bottom: 47,
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
                    child: Align(
                      alignment: Alignment.center,
                      child: Tooltip(
                        message: 'Search',
                        preferBelow: false,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 56,
                            width: 56,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                          onTapDown: (_) {
                            _fabPressController.forward();
                          },
                          onTap: () {
                            _fabPressController.reverse();
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
            height: 48,
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              tooltip: 'Back',
              onPressed: () {
                Navigator.maybePop(context);
                controller.clear();
              },
            ),
          ),
          Positioned(
            left: 96,
            right: 96,
            bottom: 0,
            height: 48,
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              style: TextStyle(
                color: Colors.white,
              ),
              cursorColor: Colors.white30,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.white30,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            height: 48,
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.clear),
              color: Colors.white,
              tooltip: 'Clear',
              onPressed: () {
                controller.clear();
              },
            ),
          ),
        ],
      ),
    );
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
        Offset.zero & size, button.inflate(radius == 0 ? 0 : notchMargin));
  }

  @override
  bool shouldReclip(BottomAppBarClipper oldClipper) {
    return oldClipper.windowWidth != windowWidth ||
        oldClipper.notchMargin != notchMargin ||
        oldClipper.radius != radius;
  }
}
