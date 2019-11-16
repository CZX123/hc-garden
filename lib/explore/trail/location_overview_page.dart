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
  final _scrollController = ScrollController();
  double aspectRatio;
  static const double sizeScaling = 500;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    if (appNotifier.state == 1 &&
        appNotifier.entity == null &&
        appNotifier.location == null) {
      appNotifier.changeState(
        context,
        1,
        location: widget.trailLocation,
        activeScrollController: _scrollController,
        rebuild: false,
      );
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
    final animation =
        Provider.of<BottomSheetNotifier>(context, listen: false).animation;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final child = SingleChildScrollView(
      controller: _scrollController,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          ValueListenableBuilder<double>(
            valueListenable: animation,
            builder: (context, value, child) {
              double h = 0;
              if (value < height - 378) {
                h = (1 - value / (height - 378)) * topPadding;
                if (value > 1)
                  widget.endContentOffset?.value = Offset(0, h + 16);
              }
              return SizedBox(
                height: h,
              );
            },
          ),
          Container(
            height: 96,
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
                          widget.trailLocation.entityPositions
                              .map((position) => position.entity?.name)
                              .where((name) => name != null)
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
            valueListenable: animation,
            builder: (context, value, child) {
              return Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  minHeight: max(
                    height -
                        value -
                        48 -
                        96 -
                        (1 - value / (height - 378)) * topPadding,
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
                    child: AnimatedPulseCircle(
                      onTap: () {
                        Provider.of<AppNotifier>(context, listen: false)
                            .changeState(
                          context,
                          1,
                        );
                        Navigator.push(
                          context,
                          CrossFadePageRoute(
                            builder: (context) => Material(
                              color: Theme.of(context).bottomAppBarColor,
                              child: EntityDetailsPage(
                                entity: entityPosition.entity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 48,
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

class AnimatedPulseCircle extends StatefulWidget {
  final VoidCallback onTap;
  AnimatedPulseCircle({Key key, @required this.onTap}) : super(key: key);

  @override
  _AnimatedPulseCircleState createState() => _AnimatedPulseCircleState();
}

class _AnimatedPulseCircleState extends State<AnimatedPulseCircle>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  void listener(AnimationStatus status) {
    if (status == AnimationStatus.completed)
      controller.reverse();
    else if (status == AnimationStatus.dismissed) controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this)
      ..addStatusListener(listener);
    animation = Tween<double>(begin: 0.85, end: 1).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutQuad,
    ));
    controller.forward();
  }

  @override
  void dispose() {
    // @TS, remember to dispose!
    controller
      ..removeStatusListener(listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Material(
        color: Colors.black.withOpacity(.2),
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.lightGreenAccent,
            width: 2.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
