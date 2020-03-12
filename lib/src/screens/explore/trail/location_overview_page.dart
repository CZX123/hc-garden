import 'package:hc_garden/src/library.dart';

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
  double _aspectRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      context.provide<AppNotifier>(listen: false).updateScrollController(
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
    final bottomSheetNotifier =
        context.provide<BottomSheetNotifier>(listen: false);

    final trailLocation = FirebaseData.getTrailLocation(
      context: context,
      key: widget.trailLocationKey,
    );

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder(
              valueListenable: bottomSheetNotifier.animation,
              builder: (context, value, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - value,
                  ),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const TopPaddingSpace(),
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
                      subtitleStyle:
                          Theme.of(context).textTheme.caption.copyWith(
                                fontSize: 13.5,
                              ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: OverflowBox(
                            minHeight: _aspectRatio == null
                                ? null
                                : constraints.maxWidth / _aspectRatio,
                            child: Stack(
                              children: <Widget>[
                                TrailLocationImageWidget(
                                  trailLocation: trailLocation,
                                  height: _aspectRatio == null
                                      ? null
                                      : constraints.maxWidth / _aspectRatio,
                                  width: constraints.maxWidth,
                                  onLoad: (double aspectRatio) {
                                    setState(() {
                                      _aspectRatio = aspectRatio;
                                    });
                                  },
                                ),
                                // CustomImage(
                                //   lowerRes(trailLocation.image),
                                //   width: double.infinity,
                                //   onLoad: (double aspectRatio) {
                                //     setState(() {
                                //       _aspectRatio = aspectRatio;
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // ValueListenableBuilder<double>(
                  //   valueListenable: bottomSheetNotifier.animation,
                  //   builder: (context, value, child) {
                  //     return Container(
                  //       alignment: Alignment.center,
                  //       constraints: BoxConstraints(
                  //         minHeight: isLandscape && maxImageHeight < width / aspectRatio
                  //             ? maxImageHeight
                  //             : max(
                  //                 height -
                  //                     value -
                  //                     Sizes.kBottomBarHeight -
                  //                     bottomPadding -
                  //                     Sizes.kInfoRowHeight -
                  //                     (1 - value / paddingBreakpoint) * topPadding,
                  //                 0,
                  //               ),
                  //       ),
                  //       child: child,
                  //     );
                  //   },
                  //   child: Stack(
                  //     children: <Widget>[
                  //       CustomImage(
                  //         lowerRes(trailLocation.image),
                  //         fit: BoxFit.contain,
                  //         onLoad: (double aspectRatio) {
                  //           setState(() {
                  //             this.aspectRatio = aspectRatio;
                  //           });
                  //         },
                  //       ),
                  //       if (aspectRatio != null)
                  //         for (var entityPosition in trailLocation.entityPositions)
                  //           EntityPositionWidget(
                  //             entityPosition: entityPosition,
                  //             aspectRatio: aspectRatio,
                  //           ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: Sizes.kBottomBarHeight),
                  const BottomPadding(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrailLocationImageWidget extends StatelessWidget {
  final TrailLocation trailLocation;
  final double height;
  final double width;
  final void Function(double) onLoad;

  const TrailLocationImageWidget({
    Key key,
    @required this.trailLocation,
    @required this.height,
    @required this.width,
    @required this.onLoad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomImage(
          lowerRes(trailLocation.image),
          width: double.infinity,
          onLoad: onLoad,
        ),
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: height != null && width != null ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            child: Stack(
              children: <Widget>[
                if (height != null && width != null)
                  for (var entityPosition in trailLocation.entityPositions)
                    EntityPositionWidget(
                      entityPosition: entityPosition,
                      imageHeight: height,
                      imageWidth: width,
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EntityPositionWidget extends StatelessWidget {
  final EntityPosition entityPosition;
  final double imageHeight;
  final double imageWidth;

  const EntityPositionWidget({
    Key key,
    @required this.entityPosition,
    @required this.imageHeight,
    @required this.imageWidth,
  }) : super(key: key);

  static const double sizeScaling = 500;

  void _onTap(BuildContext context, Entity entity) {
    context.provide<AppNotifier>(listen: false).push(
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
    final size = (entityPosition.size / sizeScaling) * width;
    return Positioned(
      left: entityPosition.left * imageWidth - size / 2,
      top: entityPosition.top * imageHeight - size / 2,
      width: size,
      height: size,
      child: AnimatedEntityPulseCircle(
        entity: entity,
        size: size,
        onTap: () => _onTap(context, entity),
      ),
    );
  }
}

class AnimatedEntityPulseCircle extends StatefulWidget {
  final Entity entity;
  final double size;
  final VoidCallback onTap;
  AnimatedEntityPulseCircle({
    Key key,
    @required this.entity,
    @required this.onTap,
    @required this.size,
  }) : super(key: key);

  @override
  _AnimatedEntityPulseCircleState createState() =>
      _AnimatedEntityPulseCircleState();
}

class _AnimatedEntityPulseCircleState extends State<AnimatedEntityPulseCircle>
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
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color.value,
                        width: widget.size *
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
              child: ValueListenableBuilder(
                valueListenable: _isPressed,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: value ? .38 : 1,
                    duration: Duration(milliseconds: value ? 100 : 300),
                    curve: Curves.ease,
                    child: child,
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: min(widget.size * .05, 3),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  elevation: widget.entity.key.category == 'flora' ? 0 : 4,
                  child: widget.entity.key.category == 'flora'
                      ? null
                      : CustomImage(
                          widget.entity.smallImage,
                          fit: BoxFit.cover,
                        ),
                ),
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
      onTap: () {
        final appNotifier = context.provide<AppNotifier>(listen: false);
        appNotifier.push(
          context: context,
          routeInfo: RouteInfo(
            name: widget.entity.name,
            dataKey: widget.entity.key,
            route: CrossFadePageRoute(
              builder: (context) => Material(
                color: Theme.of(context).bottomAppBarColor,
                child: EntityDetailsPage(
                  entityKey: widget.entity.key,
                ),
              ),
            ),
          ),
        );
      },
      onTapCancel: () {
        _isPressed.value = false;
      },
    );
  }
}
