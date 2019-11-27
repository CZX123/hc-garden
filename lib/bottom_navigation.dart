import 'library.dart';

class BottomSheetFooter extends StatelessWidget {
  final ValueNotifier<int> pageIndex;
  const BottomSheetFooter({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: max(Sizes.hBottomBarHeight, Sizes.kBottomBarHeight) +
          MediaQuery.of(context).viewInsets.bottom,
      child: Stack(
        children: <Widget>[
          CustomBottomAppBar(),
          CustomBottomNavBar(
            pageIndex: pageIndex,
          ),
        ],
      ),
    );
  }
}

/// Bottom Navigation on the home screen for [HistoryPage], [MapWidget] and [AboutPage]
class CustomBottomNavBar extends StatefulWidget {
  final ValueNotifier<int> pageIndex;
  const CustomBottomNavBar({Key key, @required this.pageIndex})
      : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  bool _init = false;

  /// Whether navbar should be hidden because user is on another screen
  bool _hideNavBar = false;
  AppNotifier _appNotifier;
  BottomSheetNotifier _bottomSheetNotifier;
  AnimationController _animationController;

  /// Offset of navbar
  Animation<Offset> _offset;

  void stateListener() {
    if (_hideNavBar == _appNotifier.routes.isNotEmpty) return;
    _hideNavBar = _appNotifier.routes.isNotEmpty;
    if (_hideNavBar) {
      if (_animationController.value != 1)
        _animationController.animateTo(
          1,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 400),
        );
    } else {
      if (_bottomSheetNotifier.animation.value >=
          _bottomSheetNotifier.snappingPositions.value[1]) {
        if (_animationController.value != 0)
          _animationController.animateTo(0, curve: Curves.fastOutSlowIn);
      }
    }
  }

  void animListener() {
    if (!_hideNavBar) {
      final newValue = _bottomSheetNotifier.animTween
          .evaluate(_bottomSheetNotifier.animation);
      if (newValue > 1) return;
      _animationController.value = 1 - newValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, Sizes.hBottomBarHeight * 2),
    ).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _appNotifier = Provider.of<AppNotifier>(context, listen: false)
        ..addListener(stateListener);
      _bottomSheetNotifier =
          Provider.of<BottomSheetNotifier>(context, listen: false)
            ..animation.addListener(animListener);
      _init = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _appNotifier.removeListener(stateListener);
    _bottomSheetNotifier.animation.removeListener(animListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: Sizes.hBottomBarHeight,
      child: ValueListenableBuilder<Offset>(
        valueListenable: _offset,
        builder: (context, value, child) {
          return Visibility(
            visible: _animationController.value < .6,
            maintainState: true,
            child: Transform.translate(
              offset: value,
              child: child,
            ),
          );
        },
        child: ValueListenableBuilder<int>(
          valueListenable: widget.pageIndex,
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
                    _bottomSheetNotifier
                      ..draggingDisabled = false
                      ..animateTo(
                          _bottomSheetNotifier.snappingPositions.value[1]);
                  } else {
                    _bottomSheetNotifier
                      ..animateTo(
                        _bottomSheetNotifier.snappingPositions.value.last,
                        const Duration(milliseconds: 240),
                      )
                      ..draggingDisabled = true;
                  }
                  widget.pageIndex.value = index;
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
    );
  }
}

class CustomBottomAppBar extends StatefulWidget {
  const CustomBottomAppBar({Key key}) : super(key: key);

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar>
    with SingleTickerProviderStateMixin {
  bool _init = false;

  /// Whether app is at home page
  final _isHome = ValueNotifier(true);
  AppNotifier _appNotifier;
  BottomSheetNotifier _bottomSheetNotifier;
  AnimationController _animationController;

  /// Offset of appbar
  Animation<Offset> _offset;
  bool _themeIsChanging = true;

  void stateListener() {
    if (_appNotifier.state == 2) _themeIsChanging = false;
    if (_isHome.value == _appNotifier.routes.isEmpty) return;
    _isHome.value = _appNotifier.routes.isEmpty;
    if (_isHome.value) {
      if (_bottomSheetNotifier.animation.value >=
              _bottomSheetNotifier.snappingPositions.value[1] &&
          _animationController.value != 0)
        _animationController.animateTo(0, curve: Curves.fastOutSlowIn);
    } else if (_animationController.value != 1) {
      _animationController.animateTo(1, curve: Curves.fastOutSlowIn);
    }
  }

  void animListener() {
    if (_isHome.value) {
      final newValue = _bottomSheetNotifier.animTween
          .evaluate(_bottomSheetNotifier.animation);
      if (newValue > 1) return;
      _animationController.value = 1 - newValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offset = Tween<Offset>(
      begin: Offset(0, Sizes.kBottomBarHeight * 2),
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _appNotifier = Provider.of<AppNotifier>(context, listen: false)
        ..addListener(stateListener);
      _bottomSheetNotifier =
          Provider.of<BottomSheetNotifier>(context, listen: false)
            ..animation.addListener(animListener);
      _init = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _appNotifier.removeListener(stateListener);
    _bottomSheetNotifier.animation.removeListener(animListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _themeIsChanging = true;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: Sizes.kBottomBarHeight,
      child: ValueListenableBuilder<Offset>(
        valueListenable: _offset,
        builder: (context, value, child) {
          return Visibility(
            visible: _animationController.value > .4,
            maintainState: true,
            child: Transform.translate(
              offset: value,
              child: child,
            ),
          );
        },
        child: Selector<AppNotifier, bool>(
          selector: (context, appNotifier) =>
              appNotifier.routes.isEmpty || appNotifier.state == 2,
          builder: (context, value, child) {
            return AnimatedTheme(
              data: _appNotifier.state == 2 ||
                      Provider.of<ThemeNotifier>(context).value
                  ? darkThemeData
                  : themeData,
              duration: _themeIsChanging
                  ? kThemeAnimationDuration
                  : const Duration(milliseconds: 300),
              child: Builder(builder: (context) {
                return Material(
                  elevation: value ? 12 : 0,
                  color: Theme.of(context).bottomAppBarColor,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      child,
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        height: 1,
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: value ? 400 : 200),
                            curve: value ? Interval(.5, 1) : Curves.linear,
                            decoration: BoxDecoration(
                              color:
                                  value ? null : Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Row(
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _isHome,
                    builder: (context, value, child) {
                      return IgnorePointer(
                        ignoring: !value,
                        ignoringSemantics: !value,
                        child: AnimatedOpacity(
                          opacity: value ? 1 : 0,
                          duration: Duration(milliseconds: value ? 400 : 200),
                          curve: value ? Interval(.5, 1) : Curves.linear,
                          child: child,
                        ),
                      );
                    },
                    child: Tooltip(
                      message: 'Filter',
                      preferBelow: false,
                      child: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          if (_isHome.value) {
                            Scaffold.of(context).openEndDrawer();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 6,
                left: 64,
                right: 64,
                bottom: 6,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isHome,
                  builder: (context, value, child) {
                    return IgnorePointer(
                      ignoring: !value,
                      ignoringSemantics: !value,
                      child: AnimatedOpacity(
                        opacity: value ? 1 : 0,
                        duration: Duration(milliseconds: value ? 400 : 200),
                        curve: value ? Interval(.5, 1) : Curves.linear,
                        child: child,
                      ),
                    );
                  },
                  child: SearchBar(),
                ),
              ),
            ],
          ),
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
  bool _init = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  SearchNotifier _searchNotifier;

  void searchListener() {
    if (_controller.text != _searchNotifier.searchTerm)
      _controller.text = _searchNotifier.searchTerm;
  }

  void onTextChange() {
    _searchNotifier.searchTerm = _controller.text;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(onTextChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _searchNotifier = Provider.of<SearchNotifier>(context, listen: false)
        ..addListener(searchListener);
      _init = true;
    }
  }

  @override
  void dispose() {
    _searchNotifier.removeListener(searchListener);
    _controller.removeListener(onTextChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SearchNotifier>(context, listen: false).focusNode = _focusNode;
    return AnimatedTheme(
      data: Provider.of<ThemeNotifier>(context).value
          ? darkThemeData.copyWith(
              dividerColor: Colors.grey[800],
            )
          : themeData.copyWith(
              dividerColor: Colors.grey[100],
            ),
      child: Builder(builder: (context) {
        return Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(Sizes.kBottomBarHeight / 2 - 6),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).dividerColor,
          child: Stack(
            children: <Widget>[
              TextField(
                focusNode: _focusNode,
                controller: _controller,
                style: Theme.of(context).textTheme.body1,
                cursorColor: Theme.of(context).accentColor,
                decoration: InputDecoration(
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),
                  border: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.body1.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                  hintText: 'Search',
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: Sizes.kBottomBarHeight - 12,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    return IgnorePointer(
                      ignoring: value.text.isEmpty,
                      child: Material(
                        type: MaterialType.transparency,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: Tooltip(
                          message: 'Clear',
                          preferBelow: false,
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            iconSize: 20,
                            color: Theme.of(context).disabledColor,
                            disabledColor: Colors.transparent,
                            onPressed:
                                value.text.isEmpty ? null : _controller.clear,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class SearchNotifier extends ChangeNotifier {
  FocusNode focusNode;
  void unfocus() {
    focusNode?.unfocus();
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();
  }
}
