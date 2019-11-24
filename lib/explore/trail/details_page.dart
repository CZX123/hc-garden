import '../../library.dart';

class TrailDetailsPage extends StatefulWidget {
  final Trail trail;
  final List<TrailLocation> trailLocations;
  const TrailDetailsPage({
    Key key,
    @required this.trail,
    @required this.trailLocations,
  }) : super(key: key);

  @override
  _TrailDetailsPageState createState() => _TrailDetailsPageState();
}

class _TrailDetailsPageState extends State<TrailDetailsPage> {
  bool _init = false;
  AppNotifier _appNotifier;
  final _scrollController = ScrollController();

  void stateListener() {
    if (context != null && _appNotifier.state == 0 && _appNotifier.routes.isNotEmpty) {
      final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
        context,
        listen: false,
      );
      if (_scrollController.hasClients &&
          bottomSheetNotifier.animation.value > 10) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appNotifier = Provider.of<AppNotifier>(context, listen: false)..addListener(stateListener);
    if (!_init) {
      _appNotifier.updateScrollController(
        context: context,
        data: widget.trail,
        scrollController: _scrollController,
      );
      _init = true;
    }
  }

  @override
  void dispose() {
    _appNotifier.removeListener(stateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(context, listen: false);
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.kBottomBarHeight),
      child: Material(
        color: Theme.of(context).bottomAppBarColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: bottomSheetNotifier.animation,
                builder: (context, value, child) {
                  double h = 0;
                  if (value < paddingBreakpoint) {
                    h = (1 - value / paddingBreakpoint) * topPadding;
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: h + 32),
                    child: child,
                  );
                },
                child: Text(
                  widget.trail.name,
                  style: Theme.of(context).textTheme.display1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              sliver: SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return LocationListRow(
                      location: widget.trailLocations[index],
                      index: index,
                      scrollController: _scrollController,
                    );
                  },
                  childCount: widget.trailLocations.length,
                ),
                itemExtent: 84,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationListRow extends StatefulWidget {
  final TrailLocation location;
  final int index;
  final ScrollController scrollController; // For getting scroll position
  const LocationListRow({
    Key key,
    @required this.location,
    @required this.index,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _LocationListRowState createState() => _LocationListRowState();
}

class _LocationListRowState extends State<LocationListRow> {
  final hidden = ValueNotifier(false);
  Animation<double> secondaryAnimation;

  void listener() {
    if (secondaryAnimation.value > 0) {
      hidden.value = true;
    } else if (secondaryAnimation.isDismissed) {
      if (mounted) hidden.value = false;
      secondaryAnimation.removeListener(listener);
    }
  }

  @override
  void dispose() {
    hidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var names = (widget.location.entityPositions
            .where((position) => position.entity != null)
            .toList()
              ..sort((a, b) {
                return a.left.compareTo(b.left);
              }))
        .map((position) => position.entity.name)
        .toList();
    final child = Container(
      height: 84,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 14,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: CustomImage(
              widget.location.smallImage,
              height: 64,
              width: 64,
              placeholderColor: Theme.of(context).dividerColor,
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.location.name,
                  style: Theme.of(context).textTheme.subhead,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    children: <Widget>[
                      // 2 text required, one to ack as the background for the other text, so they will not flicker when going to new screen
                      Text(
                        names.join(', '),
                        style: Theme.of(context).textTheme.caption.copyWith(
                              fontSize: 13.5,
                              color: Theme.of(context).bottomAppBarColor,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        names.join(', '),
                        style: Theme.of(context).textTheme.caption.copyWith(
                              fontSize: 13.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 14,
          ),
        ],
      ),
    );
    return InkWell(
      child: ValueListenableBuilder<bool>(
        valueListenable: hidden,
        builder: (context, value, child) {
          return Visibility(
            visible: !value,
            child: child,
          );
        },
        child: child,
      ),
      onTap: () {
        final sourceRect = Rect.fromLTWH(0, 69, width, 84);
        final anim = Tween<double>(
          begin: 0,
          end: 1 / (height - Sizes.kBottomHeight),
        ).animate(
          Provider.of<BottomSheetNotifier>(context, listen: false).animation,
        );
        final topSpace = Tween<double>(
          begin: 72 + topPadding,
          end: 72,
        ).animate(anim);
        final startContentOffset = ValueNotifier(Offset(0, 10));
        final endContentOffset = ValueNotifier(
          Offset(0, (1 - anim.value) * topPadding + 16),
        );
        secondaryAnimation = ModalRoute.of(context).secondaryAnimation
          ..addListener(listener);
        Provider.of<AppNotifier>(context, listen: false).push(
          context: context,
          route: ExpandPageRoute(
            builder: (context) {
              return TrailLocationOverviewPage(
                trailLocation: widget.location,
                endContentOffset: endContentOffset,
              );
            },
            sourceRect: sourceRect,
            startContentOffset: startContentOffset,
            endContentOffset: endContentOffset,
            rowOffset: 84.0 * widget.index,
            oldScrollController: widget.scrollController,
            topSpace: topSpace,
            persistentOldChild: child,
          ),
          routeInfo: RouteInfo(
            name: widget.location.name,
            data: widget.location,
          ),
        );
      },
    );
  }
}
