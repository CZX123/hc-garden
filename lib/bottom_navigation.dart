import 'library.dart';

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
    final indexNotifier = ValueNotifier(1);
    final height = MediaQuery.of(context).size.height;
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
                child: child,
              ),
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
            },
          ),
        ),
        // Notched Bottom App Bar for Entity List Page
        NotchedAppBar(animation: animation),
      ],
    );
  }
}

class NotchedAppBar extends StatelessWidget {
  final Animation<double> animation;
  const NotchedAppBar({Key key, @required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
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
          overflow: Overflow.visible,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                type: MaterialType.transparency,
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
            ),
            Selector<AppNotifier, bool>(
              selector: (context, appNotifier) => appNotifier.isSearching,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: value ? 0 : width / 2 - 28,
                  bottom: value ? 0 : 20,
                  width: value ? width : 56,
                  height: value ? 48 : 56,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(value ? 0 : 28),
                      boxShadow: kElevationToShadow[4].map((shadow) {
                        return BoxShadow(
                          color: shadow.color
                              .withOpacity(shadow.color.opacity / 2),
                          offset: shadow.offset,
                          blurRadius: shadow.blurRadius,
                          spreadRadius: shadow.spreadRadius,
                        );
                      }).toList(),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: AnimatedOpacity(
                      opacity: value ? 1 : 0,
                      duration: Duration(milliseconds: value ? 300 : 80),
                      child: SearchBar(
                        isSearching: value,
                      ),
                    ),
                  ),
                );
              },
            ),
            Selector<AppNotifier, bool>(
              selector: (context, appNotifier) => appNotifier.isSearching,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: width / 2 - 28,
                  bottom: value ? -4 : 20,
                  width: 56,
                  height: 56,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: IgnorePointer(
                    ignoring: value,
                    child: AnimatedOpacity(
                      opacity: value ? 0 : 1,
                      duration: Duration(milliseconds: value ? 80 : 300),
                      child: child,
                    ),
                  ),
                );
              },
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: const Icon(Icons.search),
                elevation: 0,
                highlightElevation: 0,
                onPressed: () {
                  Provider.of<AppNotifier>(context, listen: false).isSearching =
                      true;
                },
                tooltip: 'Search',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final bool isSearching;
  const SearchBar({Key key, @required this.isSearching}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  void onTextChange() {
    // search
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(onTextChange);
  }

  @override
  void dispose() {
    controller.removeListener(onTextChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSearching) {
      Future.delayed(
        const Duration(milliseconds: 400),
        () => focusNode.requestFocus(),
      );
    } else {
      Future.delayed(
        const Duration(milliseconds: 400),
        () => focusNode.unfocus(),
      );
    }
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
    return CircularNotchedRectangle()
        .getOuterPath(Offset.zero & size, button.inflate(notchMargin));
  }

  @override
  bool shouldReclip(BottomAppBarClipper oldClipper) {
    return oldClipper.windowWidth != windowWidth ||
        oldClipper.notchMargin != notchMargin;
  }
}
