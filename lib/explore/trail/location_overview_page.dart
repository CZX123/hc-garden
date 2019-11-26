import '../../library.dart';

class TrailLocationOverviewPage extends StatefulWidget {
  final TrailLocation trailLocation;
  final ValueNotifier<Offset> endContentOffset;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trailLocation,
    this.endContentOffset,
  }) : super(key: key);

  @override
  _TrailLocationOverviewPageState createState() =>
      _TrailLocationOverviewPageState();
}

class _TrailLocationOverviewPageState extends State<TrailLocationOverviewPage> {
  bool _init = false;
  final _scrollController = ScrollController();
  double aspectRatio;
  static const double sizeScaling = 500;

  void _onTap(Entity entity) {
    Provider.of<AppNotifier>(context, listen: false).push(
      context: context,
      routeInfo: RouteInfo(
        name: entity.name,
        data: entity,
        route: CrossFadePageRoute(
          builder: (context) => Material(
            color: Theme.of(context).bottomAppBarColor,
            child: EntityDetailsPage(
              entity: entity,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      Provider.of<AppNotifier>(context, listen: false).updateScrollController(
        context: context,
        data: widget.trailLocation,
        scrollController: _scrollController,
      );
      _init = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    final child = SingleChildScrollView(
      controller: _scrollController,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          ValueListenableBuilder<double>(
            valueListenable: bottomSheetNotifier.animation,
            builder: (context, value, child) {
              double h = 0;
              if (value < paddingBreakpoint) {
                h = (1 - value / paddingBreakpoint) * topPadding;
                if (value > 1)
                  widget.endContentOffset?.value = Offset(0, h + 16);
              }
              return SizedBox(
                height: h,
              );
            },
          ),
          Container(
            height: Sizes.kInfoRowHeight,
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 14,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: CustomImage(
                    widget.trailLocation.smallImage,
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
                        widget.trailLocation.name,
                        style: Theme.of(context).textTheme.subhead,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          (widget.trailLocation.entityPositions
                                  .where((position) => position.entity != null)
                                  .toList()
                                    ..sort((a, b) {
                                      return a.left.compareTo(b.left);
                                    }))
                              .map((position) => position.entity.name)
                              .toList()
                              .join(', '),
                          style: Theme.of(context).textTheme.caption.copyWith(
                                fontSize: 13.5,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
          ),
          ValueListenableBuilder<double>(
            valueListenable: bottomSheetNotifier.animation,
            builder: (context, value, child) {
              return Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  minHeight: max(
                    height -
                        value -
                        Sizes.kBottomBarHeight -
                        Sizes.kInfoRowHeight -
                        (1 - value / (height - Sizes.kBottomHeight)) *
                            topPadding,
                    0,
                  ),
                ),
                child: child,
              );
            },
            child: Stack(
              children: <Widget>[
                CustomImage(
                  lowerRes(widget.trailLocation.image),
                  fit: BoxFit.fitWidth,
                  onLoad: (double aspectRatio) {
                    setState(() {
                      this.aspectRatio = aspectRatio;
                    });
                  },
                ),
                for (var entityPosition in widget.trailLocation.entityPositions)
                  new Positioned(
                    left: entityPosition.left * width -
                        (entityPosition.size / sizeScaling) * width / 2,
                    top: aspectRatio == null
                        ? height
                        : entityPosition.top * (width / aspectRatio) -
                            (entityPosition.size / sizeScaling) * width / 2,
                    width: (entityPosition.size / sizeScaling) * width,
                    height: (entityPosition.size / sizeScaling) * width,
                    child: entityPosition.entity is Fauna
                        ? FaunaCircle(
                            fauna: entityPosition.entity,
                            onTap: () => _onTap(entityPosition.entity),
                          )
                        : AnimatedPulseCircle(
                            height: (entityPosition.size / sizeScaling) * width,
                            onTap: () => _onTap(entityPosition.entity),
                          ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: Sizes.kBottomBarHeight,
          ),
        ],
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: widget.endContentOffset != null
          ? NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.depth == 0) {
                  widget.endContentOffset.value -=
                      Offset(0, notification.scrollDelta);
                }
                return false;
              },
              child: child,
            )
          : child,
    );
  }
}

class FaunaCircle extends StatelessWidget {
  final Fauna fauna;
  final VoidCallback onTap;
  const FaunaCircle({
    Key key,
    @required this.fauna,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Stack(
        children: <Widget>[
          CustomImage(
            fauna.smallImage,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPulseCircle extends StatefulWidget {
  final double height;
  final VoidCallback onTap;
  AnimatedPulseCircle({
    Key key,
    @required this.onTap,
    @required this.height,
  }) : super(key: key);

  @override
  _AnimatedPulseCircleState createState() => _AnimatedPulseCircleState();
}

class _AnimatedPulseCircleState extends State<AnimatedPulseCircle>
    with SingleTickerProviderStateMixin {
  final _isPressed = ValueNotifier(false);
  Animation<double> scale;
  Animation<Color> color;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    scale = Tween<double>(begin: 1, end: 1.8).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ));
    color = ColorTween(
      begin: Colors.white54,
      end: null,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ));
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurveTween(curve: Curves.fastOutSlowIn);
    return GestureDetector(
      child: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: .75,
          child: Stack(
            children: <Widget>[
              ScaleTransition(
                scale: scale,
                child: ValueListenableBuilder<double>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    double height = widget.height;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: color.value,
                          width: height *
                              .4 *
                              curve.transform(value) /
                              scale.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isPressed,
                  builder: (context, value, _) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: value ? 100 : 300),
                      decoration: BoxDecoration(
                        color: value ? Colors.white38 : Colors.white70,
                        shape: BoxShape.circle,
                        boxShadow: kElevationToShadow[4],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTapDown: (_) {
        _isPressed.value = true;
      },
      onTapUp: (_) {
        _isPressed.value = false;
      },
      onTap: widget.onTap,
      onTapCancel: () {
        _isPressed.value = false;
      },
    );
  }
}
