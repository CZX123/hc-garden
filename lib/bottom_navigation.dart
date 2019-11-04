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
    // final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(context, listen: false);
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
      child: Selector<AppNotifier, int>(
        selector: (context, appNotifier) => appNotifier.state,
        builder: (context, state, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              Offset offset = Offset(0, 0);
              if (state == 0) {
                if (animation.value > height - 382) {
                  offset = Offset(0, 152);
                } else {
                  offset = Offset(0, animation.value / (height - 382) * 152);
                }
              }
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
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
                child: Selector<AppNotifier, int>(
                  selector: (context, appNotifier) => appNotifier.state,
                  builder: (context, state, child) {
                    return AnimatedNotchedShape(
                      elevation: state == 1 ? 0 : 12,
                      color: Theme.of(context).canvasColor,
                      notchMargin: state == 0 ? 4 : 0,
                      fabRadius: state == 0 ? 28 : 0,
                      child: child,
                    );
                  },
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
                          Selector<AppNotifier, int>(
                            selector: (context, appNotifier) =>
                                appNotifier.state,
                            builder: (context, state, child) {
                              return IgnorePointer(
                                ignoring: state != 0,
                                ignoringSemantics: state != 0,
                                child: AnimatedOpacity(
                                  opacity: state == 0 ? 1 : 0,
                                  duration: const Duration(milliseconds: 280),
                                  child: child,
                                ),
                              );
                            },
                            child: IconButton(
                              icon: const Icon(Icons.sort),
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              tooltip: 'Sort',
                            ),
                          ),
                        ],
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
              bottom: 47,
              child: IgnorePointer(
                child: Selector<AppNotifier, bool>(
                  selector: (context, appNotifier) => appNotifier.state == 1,
                  builder: (context, value, child) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: value ? 1 : 0,
                      child: child,
                    );
                  },
                  child: Container(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
            Selector<SearchNotifier, bool>(
              selector: (context, searchNotifier) => searchNotifier.isSearching,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: value ? 0 : width / 2 - 28,
                  bottom: value ? 0 : 20,
                  width: value ? width : 56,
                  height: value ? 48 : 56,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Selector<AppNotifier, bool>(
                    selector: (context, appNotifier) => appNotifier.state == 0,
                    builder: (context, hasSearch, child) {
                      return AnimatedScale(
                        scale: hasSearch ? 1 : 0,
                        child: child,
                      );
                    },
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
                  ),
                );
              },
            ),
            Selector<SearchNotifier, bool>(
              selector: (context, searchNotifier) => searchNotifier.isSearching,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: width / 2 - 28,
                  bottom: value ? -4 : 20,
                  width: 56,
                  height: 56,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: Selector<AppNotifier, bool>(
                    selector: (context, appNotifier) => appNotifier.state == 0,
                    builder: (context, hasSearch, child) {
                      return AnimatedScale(
                        scale: hasSearch ? 1 : 0,
                        child: child,
                      );
                    },
                    child: IgnorePointer(
                      ignoring: value,
                      ignoringSemantics: value,
                      child: AnimatedOpacity(
                        opacity: value ? 0 : 1,
                        duration: Duration(milliseconds: value ? 80 : 300),
                        child: child,
                      ),
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
                  Provider.of<SearchNotifier>(context, listen: false)
                      .isSearching = true;
                  Future.delayed(const Duration(milliseconds: 400), () {
                    Provider.of<SearchNotifier>(context, listen: false)
                        .keyboardAppear = true;
                  });
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
