import '../../library.dart';

class TrailLocationOverviewPage extends StatefulWidget {
  final TrailLocation trailLocation;
  final ValueNotifier<Offset> endContentOffset;
  final bool hideInfoRowOnExpand;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trailLocation,
    this.endContentOffset,
    this.hideInfoRowOnExpand = false,
  }) : super(key: key);

  @override
  _TrailLocationOverviewPageState createState() =>
      _TrailLocationOverviewPageState();
}

class _TrailLocationOverviewPageState extends State<TrailLocationOverviewPage> {
  bool _init = false;
  final _scrollController = ScrollController();
  double aspectRatio;
  final _aspectRatio = ValueNotifier<double>(null);
  static const double sizeScaling = 500;
  final hidden = ValueNotifier(false);
  Animation<double> animation;

  void listener() {
    if (animation.value < 1) {
      hidden.value = true;
    } else if (animation.isCompleted) {
      hidden.value = false;
    }
  }

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
      if (widget.hideInfoRowOnExpand ?? false) {
        animation = ModalRoute.of(context).animation..addListener(listener);
        hidden.value = true;
      }
      _init = true;
    }
  }

  @override
  void dispose() {
    animation?.removeListener(listener);
    _aspectRatio.dispose();
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
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    final maxImageHeight = height - Sizes.kBottomBarHeight - bottomPadding;
    final child = Stack(
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
                    if (value > 1)
                      widget.endContentOffset?.value = Offset(0, h + 16);
                  }
                  return SizedBox(
                    height: h,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: hidden,
                builder: (context, value, child) {
                  return Visibility(
                    visible: !value,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: child,
                  );
                },
                child: InfoRow(
                  image: widget.trailLocation.smallImage,
                  title: widget.trailLocation.name,
                  subtitle: (widget.trailLocation.entityPositions
                          .where((position) => position.entity != null)
                          .toList()
                            ..sort((a, b) {
                              return a.left.compareTo(b.left);
                            }))
                      .map((position) => position.entity.name)
                      .toList()
                      .join(', '),
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: bottomSheetNotifier.animation,
                builder: (context, value, child) {
                  return Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(
                      minHeight: isLandscape &&
                              maxImageHeight < width / aspectRatio
                          ? maxImageHeight
                          : max(
                              height -
                                  value -
                                  Sizes.kBottomBarHeight -
                                  bottomPadding -
                                  Sizes.kInfoRowHeight -
                                  (1 - value / paddingBreakpoint) * topPadding,
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
                      fit: BoxFit.contain,
                      onLoad: (double aspectRatio) {
                        _aspectRatio.value = aspectRatio;
                        setState(() {
                          this.aspectRatio = aspectRatio;
                        });
                      },
                    ),
                    for (var entityPosition
                        in widget.trailLocation.entityPositions)
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
                                height:
                                    (entityPosition.size / sizeScaling) * width,
                                onTap: () => _onTap(entityPosition.entity),
                              )
                            : AnimatedPulseCircle(
                                height:
                                    (entityPosition.size / sizeScaling) * width,
                                onTap: () => _onTap(entityPosition.entity),
                              ),
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
        // ValueListenableBuilder<double>(
        //   valueListenable: bottomSheetNotifier.animation,
        //   builder: (context, value, child) {
        //     return Positioned(
        //       right: 16,
        //       bottom: Sizes.kBottomBarHeight + bottomPadding + 16 + value,
        //       height: 48,
        //       width: 48,
        //       child: child,
        //     );
        //   },
        //   child: Material(
        //     type: MaterialType.circle,
        //     color: Colors.black45,
        //     clipBehavior: Clip.antiAlias,
        //     child: IconButton(
        //       icon: Icon(Icons.zoom_in),
        //       color: Colors.white,
        //       onPressed: () {},
        //     ),
        //   ),
        // ),
      ],
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

class FaunaCircle extends StatefulWidget {
  final Fauna fauna;
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

