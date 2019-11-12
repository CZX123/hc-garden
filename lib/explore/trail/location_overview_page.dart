import '../../library.dart';

class TrailLocationOverviewPage extends StatefulWidget {
  final Trail trail;
  final TrailLocation trailLocation;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trail,
    @required this.trailLocation,
  }) : super(key: key);

  @override
  _TrailLocationOverviewPageState createState() =>
      _TrailLocationOverviewPageState();
}

class _TrailLocationOverviewPageState extends State<TrailLocationOverviewPage> {
  final _scrollController = ScrollController();
  double aspectRatio;
  static const double sizeScaling = 550;

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
    final orientation = MediaQuery.of(context).orientation;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      // bottomNavigationBar: BottomAppBar(
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       IconButton(
      //         icon: const Icon(Icons.arrow_back),
      //         onPressed: () {
      //           SystemChrome.setPreferredOrientations(
      //               [DeviceOrientation.portraitUp]);
      //           return Navigator.maybePop(context);
      //         },
      //         tooltip: 'Back',
      //       ),
      //       Expanded(
      //         child: Text(
      //           widget.trailLocation.name,
      //           textAlign: TextAlign.center,
      //           overflow: TextOverflow.ellipsis,
      //           maxLines: 1,
      //         ),
      //       ),
      //       SizedBox(width: 48),
      //     ],
      //   ),
      // ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(
            top: orientation == Orientation.landscape ? 0 : topPadding,
          ),
          constraints: BoxConstraints(
            minHeight: height - 48,
          ),
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              CustomImage(
                lowerRes(widget.trailLocation.image),
                fit: BoxFit.contain,
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
                  child: InkWell(
                    child: AnimatedPulseCircle(),
                    onTap: () {
                      Provider.of<AppNotifier>(context, listen: false)
                          .changeState(
                        context,
                        1,
                      );
                      final newTopPadding = ValueNotifier(topPadding + 16);
                      Navigator.of(context).push(
                        FadingPageRoute(
                          builder: (context) => EntityDetailsPage(
                            newTopPadding: newTopPadding,
                            entity: entityPosition.entity,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedPulseCircle extends StatefulWidget {
  AnimatedPulseCircle({Key key}) : super(key: key);

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.lightGreenAccent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
