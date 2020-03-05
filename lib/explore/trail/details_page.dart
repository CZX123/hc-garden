import '../../library.dart';

class TrailDetailsPage extends StatefulWidget {
  final TrailKey trailKey;
  const TrailDetailsPage({
    Key key,
    @required this.trailKey,
  }) : super(key: key);

  @override
  _TrailDetailsPageState createState() => _TrailDetailsPageState();
}

class _TrailDetailsPageState extends State<TrailDetailsPage> {
  bool _init = false;
  AppNotifier _appNotifier;
  final _scrollController = ScrollController();

  void stateListener() {
    if (context != null &&
        _appNotifier.state == 0 &&
        _appNotifier.routes.isNotEmpty) {
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
    _appNotifier = Provider.of<AppNotifier>(context, listen: false)
      ..addListener(stateListener);
    if (!_init) {
      _appNotifier.updateScrollController(
        context: context,
        dataKey: widget.trailKey,
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
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final trailLocations = FirebaseData.getTrail(
      context: context,
      key: widget.trailKey,
    ).values.toList()
      ..sort((a, b) {
        return a.name.compareTo(b.name);
      });
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    return Padding(
      padding: EdgeInsets.only(
        bottom: Sizes.kBottomBarHeight + MediaQuery.of(context).padding.bottom,
      ),
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
                    padding: EdgeInsets.only(top: h),
                    child: child,
                  );
                },
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                    child: Text(
                      FirebaseData.trailNames[widget.trailKey.id],
                      style: Theme.of(context).textTheme.display1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    if (bottomSheetNotifier.animation.value < 8) {
                      bottomSheetNotifier.animateTo(
                        bottomSheetNotifier.snappingPositions.value.last,
                      );
                    } else {
                      bottomSheetNotifier.animateTo(
                        bottomSheetNotifier.snappingPositions.value.first,
                      );
                    }
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              sliver: SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return LocationListRow(
                      location: trailLocations[index],
                      index: index,
                      scrollController: _scrollController,
                    );
                  },
                  childCount: trailLocations.length,
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
  static const _rowHeight = 84.0;
  Animation<double> _bottomSheetAnimation;
  Tween<double> _topSpaceTween;
  Tween<double> _contentOffsetTween;

  double _getSourceTop() {
    return _topSpaceTween.evaluate(_bottomSheetAnimation) +
        _rowHeight * widget.index -
        widget.scrollController.offset;
  }

  double _getContentOffset() {
    return _contentOffsetTween.evaluate(_bottomSheetAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;

    _bottomSheetAnimation = Tween<double>(
      begin: 0,
      end: 1 / (height - Sizes.kBottomHeight),
    ).animate(
      Provider.of<BottomSheetNotifier>(context, listen: false).animation,
    );
    _topSpaceTween = Tween<double>(
      begin: 72 + topPadding,
      end: 72,
    );
    _contentOffsetTween = Tween(
      begin: topPadding + 16 - (_rowHeight - 64) / 2,
      end: 16 - (_rowHeight - 64) / 2,
    );

    final List<String> names = [];
    for (final position in widget.location.entityPositions) {
      final entity =
          FirebaseData.getEntity(context: context, key: position.entityKey);
      if (entity != null) names.add(entity.name);
    }
    return InkWell(
      child: Hero(
        tag: widget.location.key,
        child: InfoRow(
          height: _rowHeight,
          image: widget.location.smallImage,
          title: widget.location.name,
          subtitle: names.join(', '),
          subtitleStyle: Theme.of(context).textTheme.caption.copyWith(
                fontSize: 13.5,
              ),
          tapToAnimate: false,
        ),
      ),
      onTap: () {
        Provider.of<AppNotifier>(context, listen: false).push(
          context: context,
          routeInfo: RouteInfo(
            name: widget.location.name,
            dataKey: widget.location.key,
            route: SlidingUpPageRoute(
              getSourceTop: _getSourceTop,
              sourceHeight: _rowHeight,
              getContentOffset: _getContentOffset,
              builder: (context) {
                return TrailLocationOverviewPage(
                  trailLocationKey: widget.location.key,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
