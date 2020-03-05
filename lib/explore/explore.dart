import '../library.dart';

class ExploreBody extends StatefulWidget {
  final TabController tabController;
  final List<ScrollController> scrollControllers;
  const ExploreBody({
    Key key,
    @required this.tabController,
    @required this.scrollControllers,
  }) : super(key: key);

  @override
  _ExploreBodyState createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<ExploreBody> {
  HeroController _heroController;
  List<NavigatorObserver> _navigatorObservers = [];

  RectTween _createRectTween(Rect begin, Rect end) {
    return FastOutSlowInRectTween(begin: begin, end: end);
  }

  @override
  void initState() {
    super.initState();
    _heroController = HeroController(createRectTween: _createRectTween);
    _navigatorObservers.add(_heroController);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final animation = bottomSheetNotifier.animation;
    final animTween = bottomSheetNotifier.animTween;
    final initialRoute = CrossFadePageRoute<void>(
      builder: (context) {
        return ExplorePage(
          tabController: widget.tabController,
          scrollControllers: widget.scrollControllers,
        );
      },
    );
    return Stack(
      children: <Widget>[
        Navigator(
          key: Provider.of<AppNotifier>(context, listen: false).navigatorKey,
          onGenerateRoute: (settings) {
            if (settings.isInitialRoute) return initialRoute;
            return null;
          },
          observers: _navigatorObservers,
        ),
        Selector<AppNotifier, bool>(
          selector: (context, appNotifier) => appNotifier.state == 0,
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: value ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
          child: BottomSheetHandle(
            opacity: Tween<double>(
              begin: 0,
              end: 5,
            ).animate(animTween.animate(animation)),
          ),
        ),
      ],
    );
  }
}

class ExplorePage extends StatelessWidget {
  final TabController tabController;
  final List<ScrollController> scrollControllers;
  const ExplorePage({
    Key key,
    @required this.tabController,
    @required this.scrollControllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final animation = bottomSheetNotifier.animation;
    final animTween = bottomSheetNotifier.animTween;
    final topPadding = MediaQuery.of(context).padding.top;
    final totalTranslation = Sizes.hOffsetTranslation - topPadding;
    final height = MediaQuery.of(context).size.height;
    return Material(
      color: Theme.of(context).canvasColor,
      child: Stack(
        children: <Widget>[
          FadeTransition(
            opacity: Tween<double>(
              begin: totalTranslation / 12,
              end: 0,
            ).animate(animTween.animate(animation)),
            child: ValueListenableBuilder(
              valueListenable: animTween.animate(animation),
              builder: (context, value, child) {
                Offset offset;
                if (value > 1)
                  offset = Offset(
                    0,
                    Sizes.kBottomHeight -
                        Sizes.hBottomBarHeight -
                        Sizes.hEntityButtonHeightCollapsed -
                        16 -
                        topPadding,
                  );
                else
                  offset = Offset(
                    0,
                    value *
                        (Sizes.kBottomHeight -
                            Sizes.hBottomBarHeight -
                            Sizes.hEntityButtonHeightCollapsed -
                            16 -
                            topPadding),
                  );
                return Transform.translate(
                  offset: offset,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.only(top: topPadding + 72),
                height: height + 128,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    TabBarView(
                      controller: tabController,
                      children: <Widget>[
                        EntityListPage(
                          isFlora: true,
                          scrollController: scrollControllers[0],
                        ),
                        EntityListPage(
                          isFlora: false,
                          scrollController: scrollControllers[1],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: GradientWidget(
                        color: Theme.of(context).canvasColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ExploreHeader(
            tabController: tabController,
          ),
        ],
      ),
    );
  }
}

class BottomSheetHandle extends StatelessWidget {
  final Animation<double> opacity;
  final EdgeInsets padding;
  const BottomSheetHandle({
    Key key,
    @required this.opacity,
    this.padding = const EdgeInsets.only(top: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: padding,
        child: FadeTransition(
          opacity: opacity,
          child: Container(
            alignment: Alignment.center,
            height: 4,
            child: Container(
              height: 4,
              width: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
