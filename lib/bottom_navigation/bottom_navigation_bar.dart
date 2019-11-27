import '../library.dart';

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
