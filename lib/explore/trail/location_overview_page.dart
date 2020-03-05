import '../../library.dart';

class TrailLocationOverviewPage extends StatefulWidget {
  final TrailLocationKey trailLocationKey;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trailLocationKey,
  }) : super(key: key);

  @override
  _TrailLocationOverviewPageState createState() =>
      _TrailLocationOverviewPageState();
}

class _TrailLocationOverviewPageState extends State<TrailLocationOverviewPage> {
  bool _init = false;
  final _scrollController = ScrollController();
  double aspectRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      Provider.of<AppNotifier>(context, listen: false).updateScrollController(
        context: context,
        dataKey: widget.trailLocationKey,
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final trailLocation = FirebaseData.getTrailLocation(
      context: context,
      key: widget.trailLocationKey,
    );
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    final maxImageHeight = height - Sizes.kBottomBarHeight - bottomPadding;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          SingleChildScrollView(
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
                    }
                    return SizedBox(
                      height: h,
                    );
                  },
                ),
                Hero(
                  tag: widget.trailLocationKey,
                  child: InfoRow(
                    image: trailLocation.smallImage,
                    title: trailLocation.name,
                    subtitle: trailLocation.entityPositions
                        .map((position) {
                          return FirebaseData.getEntity(
                            context: context,
                            key: position.entityKey,
                          )?.name;
                        })
                        .where((name) => name != null)
                        .join(', '),
                    subtitleStyle: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: 13.5,
                        ),
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: bottomSheetNotifier.animation,
                  builder: (context, value, child) {
                    return Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                        minHeight:
                            isLandscape && maxImageHeight < width / aspectRatio
                                ? maxImageHeight
                                : max(
                                    height -
                                        value -
                                        Sizes.kBottomBarHeight -
                                        bottomPadding -
                                        Sizes.kInfoRowHeight -
                                        (1 - value / paddingBreakpoint) *
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
                        lowerRes(trailLocation.image),
                        fit: BoxFit.contain,
                        onLoad: (double aspectRatio) {
                          setState(() {
                            this.aspectRatio = aspectRatio;
                          });
                        },
                      ),
                      if (aspectRatio != null)
                        for (var entityPosition
                            in trailLocation.entityPositions)
                          EntityPositionWidget(
                            entityPosition: entityPosition,
                            aspectRatio: aspectRatio,
                          ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Sizes.kBottomBarHeight + bottomPadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EntityPositionWidget extends StatelessWidget {
  final EntityPosition entityPosition;
  final double aspectRatio;
  const EntityPositionWidget({
    Key key,
    @required this.entityPosition,
    @required this.aspectRatio,
  }) : super(key: key);

  static const double sizeScaling = 500;

  void _onTap(BuildContext context, Entity entity) {
    Provider.of<AppNotifier>(context, listen: false).push(
      context: context,
      routeInfo: RouteInfo(
        name: entity.name,
        dataKey: entity.key,
        route: CrossFadePageRoute(
          builder: (context) => Material(
            color: Theme.of(context).bottomAppBarColor,
            child: EntityDetailsPage(
              entityKey: entity.key,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final entity = FirebaseData.getEntity(
      context: context,
      key: entityPosition.entityKey,
    );
    return Positioned(
      left: entityPosition.left * width -
          (entityPosition.size / sizeScaling) * width / 2,
      top: entityPosition.top * (width / aspectRatio) -
          (entityPosition.size / sizeScaling) * width / 2,
      width: (entityPosition.size / sizeScaling) * width,
      height: (entityPosition.size / sizeScaling) * width,
      child: entityPosition.entityKey.category == 'flora'
          ? AnimatedPulseCircle(
              height: (entityPosition.size / sizeScaling) * width,
              onTap: () => _onTap(context, entity),
            )
          : FaunaCircle(
              fauna: entity,
              height: (entityPosition.size / sizeScaling) * width,
              onTap: () => _onTap(context, entity),
            ),
    );
  }
}

class FaunaCircle extends StatefulWidget {
  final Entity fauna;
  final double height;
  final VoidCallback onTap;
  const FaunaCircle({
    Key key,
    @required this.fauna,
    @required this.height,
    @required this.onTap,
  }) : super(key: key);

  @override
  _FaunaCircleState createState() => _FaunaCircleState();
}

class _FaunaCircleState extends State<FaunaCircle> {
  final _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
        color: Colors.transparent,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isPressed,
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: value ? .5 : 1,
              duration: Duration(milliseconds: value ? 100 : 300),
              child: child,
            );
          },
          child: Material(
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: widget.height * .04,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: CustomImage(
              widget.fauna.smallImage,
              fit: BoxFit.cover,
            ),
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
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
                        width:
                            height * .4 * curve.transform(value) / scale.value,
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
                      border: Border.all(
                        color: value
                            ? Colors.white38
                            : Colors.white.withOpacity(.8),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
          ],
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
