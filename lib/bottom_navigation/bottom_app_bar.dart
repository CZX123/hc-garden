import '../library.dart';

/// Bottom Navigation on for the rest of the pages: [TrailDetailsPage],
/// [EntityDetailsPage] and [TrailLocationOverviewPage]
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    _offset = Tween<Offset>(
      begin: Offset(0, (Sizes.kBottomBarHeight + bottomPadding) * 2),
      end: Offset.zero,
    ).animate(_animationController);
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: Sizes.kBottomBarHeight + bottomPadding,
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
        child: Consumer<AppNotifier>(
          builder: (context, appNotifier, child) {
            final hideDivider =
                appNotifier.routes.isEmpty || appNotifier.state == 2;
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
                  elevation: hideDivider ? 12 : 0,
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
                            duration:
                                Duration(milliseconds: hideDivider ? 400 : 200),
                            curve:
                                hideDivider ? Interval(.5, 1) : Curves.linear,
                            decoration: BoxDecoration(
                              color: hideDivider
                                  ? null
                                  : Theme.of(context).dividerColor,
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
          child: Padding(
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
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
                Positioned.fill(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isHome,
                    builder: (context, value, child) {
                      return IgnorePointer(
                        ignoring: value,
                        ignoringSemantics: value,
                        child: AnimatedOpacity(
                          opacity: value ? 0 : 1,
                          duration: Duration(milliseconds: value ? 200 : 400),
                          curve: value ? Curves.linear : Interval(.5, 1),
                          child: child,
                        ),
                      );
                    },
                    child: BreadcrumbNavigation(),
                  ),
                ),
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
              ],
            ),
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
                    vertical: (Sizes.kBottomBarHeight - 36) / 2,
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
