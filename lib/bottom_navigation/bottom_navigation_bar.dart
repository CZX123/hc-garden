import '../library.dart';

/// Bottom Navigation on the home screen for [HistoryPage], [MapWidget] and [AboutPage]
class CustomBottomNavBar extends StatefulWidget {
  final ValueNotifier<int> pageIndex;
  const CustomBottomNavBar({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

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
      begin: Offset.zero,
      end: Offset(0, (Sizes.hBottomBarHeight + bottomPadding) * 2),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: Sizes.hBottomBarHeight + bottomPadding,
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
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[8],
            color: Theme.of(context).bottomAppBarColor,
          ),
          child: CustomNavbar(pageIndex: widget.pageIndex),
          // child: BottomNavigationBar(
          //   backgroundColor: Theme.of(context).bottomAppBarColor,
          //   elevation: 0,
          //   currentIndex: value,
          //   onTap: (index) {
          //     if (index == 1) {
          //       _bottomSheetNotifier
          //         ..draggingDisabled = false
          //         ..animateTo(
          //             _bottomSheetNotifier.snappingPositions.value[1]);
          //     } else {
          //       _bottomSheetNotifier
          //         ..animateTo(
          //           _bottomSheetNotifier.snappingPositions.value.last,
          //           const Duration(milliseconds: 240),
          //         )
          //         ..draggingDisabled = true;
          //     }
          //     widget.pageIndex.value = index;
          //   },
          //   items: [
          //     const BottomNavigationBarItem(
          //       icon: Icon(Icons.dvr),
          //       title: Text('History'),
          //     ),
          //     const BottomNavigationBarItem(
          //       icon: Icon(Icons.map),
          //       title: Text('Explore'),
          //     ),
          //     const BottomNavigationBarItem(
          //       icon: Icon(Icons.info),
          //       title: Text('About'),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}

class CustomNavbar extends StatelessWidget {
  final ValueNotifier<int> pageIndex;
  const CustomNavbar({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            // padding: const EdgeInsets.all(16),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          ValueListenableBuilder<int>(
            valueListenable: pageIndex,
            builder: (context, value, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BottomNavbarButton(
                    active: value == 0,
                    icon: Icon(Icons.dvr),
                    title: 'History',
                    onPressed: () {
                      bottomSheetNotifier
                        ..animateTo(
                          bottomSheetNotifier.snappingPositions.value.last,
                          const Duration(milliseconds: 240),
                        )
                        ..draggingDisabled = true;
                      pageIndex.value = 0;
                    },
                  ),
                  BottomNavbarButton(
                    active: value == 1,
                    icon: Icon(Icons.map),
                    title: 'Explore',
                    onPressed: () {
                      bottomSheetNotifier
                        ..draggingDisabled = false
                        ..animateTo(
                          bottomSheetNotifier.snappingPositions.value[1],
                        );
                      pageIndex.value = 1;
                    },
                  ),
                  BottomNavbarButton(
                    active: value == 2,
                    icon: Icon(Icons.info),
                    title: 'About',
                    onPressed: () {
                      bottomSheetNotifier
                        ..animateTo(
                          bottomSheetNotifier.snappingPositions.value.last,
                          const Duration(milliseconds: 240),
                        )
                        ..draggingDisabled = true;
                      pageIndex.value = 2;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class BottomNavbarButton extends StatelessWidget {
  final bool active;
  final Icon icon;
  final String title;
  final VoidCallback onPressed;
  const BottomNavbarButton({
    Key key,
    this.active = false,
    @required this.icon,
    @required this.title,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: NavbarButtonClipper(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TweenAnimationBuilder<Color>(
                  tween: ColorTween(
                    begin: active
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                    end: active
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  ),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  builder: (context, color, child) {
                    return IconTheme(
                      data: IconThemeData(
                        color: color,
                      ),
                      child: child,
                    );
                  },
                  child: icon,
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                    color: active
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                    fontFamily: 'Manrope',
                    fontSize: active ? 14 : 12,
                    height: active ? 1 : 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  child: Text(title),
                ),
              ],
            ),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class NavbarButtonClipper extends CustomClipper<Path> {
  static const _radius = 40.0;

  @override
  Path getClip(Size size) {
    final path = Path();
    final edgeLength = _radius - sqrt(_radius * _radius - size.height * size.height / 4);
    path.moveTo(edgeLength, 0);
    path.arcToPoint(
      Offset(edgeLength, size.height),
      radius: Radius.circular(_radius),
      clockwise: false,
    );
    path.lineTo(size.width - edgeLength, size.height);
    path.arcToPoint(
      Offset(size.width - edgeLength, 0),
      radius: Radius.circular(_radius),
      clockwise: false,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
