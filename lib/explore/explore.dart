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
  // HeroController _heroController;
  // List<NavigatorObserver> _navigatorObservers = [];

  // RectTween _createRectTween(Rect begin, Rect end) {
  //   return MaterialRectArcTween(begin: begin, end: end);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   //_heroController = HeroController(createRectTween: _createRectTween);
  //   //_navigatorObservers.add(_heroController);
  // }

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final anim = Tween<double>(
      begin: 0,
      end: 1 / (height - Sizes.kBottomHeight),
    ).animate(bottomSheetNotifier.animation);

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
            if (settings.isInitialRoute)
              return initialRoute;
            return null;
          },
          //observers: _navigatorObservers,
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
              end: (height - Sizes.kBottomHeight) / topPadding,
            ).animate(anim),
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
    final topPadding = MediaQuery.of(context).padding.top;
    final totalTranslation = Sizes.hOffsetTranslation - topPadding;
    final height = MediaQuery.of(context).size.height;
    final anim = Tween<double>(
      begin: 0,
      end: 1 / (height - Sizes.kBottomHeight),
    ).animate(bottomSheetNotifier.animation);
    return Material(
      color: Theme.of(context).canvasColor,
      child: Stack(
        children: <Widget>[
          FadeTransition(
            opacity: Tween<double>(
              begin: totalTranslation / 12,
              end: 0,
            ).animate(anim),
            child: ValueListenableBuilder(
              valueListenable: anim,
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
                        Selector<FirebaseData, List<Flora>>(
                          selector: (context, firebaseData) =>
                              firebaseData.floraList,
                          builder: (context, floraList, child) {
                            return EntityListPage(
                              entityList: floraList,
                              scrollController: scrollControllers[0],
                            );
                          },
                        ),
                        Selector<FirebaseData, List<Fauna>>(
                          selector: (context, firebaseData) =>
                              firebaseData.faunaList,
                          builder: (context, faunaList, child) {
                            return EntityListPage(
                              entityList: faunaList,
                              scrollController: scrollControllers[1],
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: TopGradient(),
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

// This is just for a much smoother gradient
class TopGradient extends StatelessWidget {
  const TopGradient({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).canvasColor;
    return IgnorePointer(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withOpacity(.738),
              color.withOpacity(.541),
              color.withOpacity(.382),
              color.withOpacity(.278),
              color.withOpacity(.194),
              color.withOpacity(.126),
              color.withOpacity(.075),
              color.withOpacity(.042),
              color.withOpacity(.021),
              color.withOpacity(.008),
              color.withOpacity(.002),
              color.withOpacity(0),
            ],
            stops: [
              0,
              .19,
              .34,
              .45,
              .565,
              .65,
              .73,
              .802,
              .861,
              .91,
              .952,
              .982,
              1,
            ],
          ),
        ),
      ),
    );
  }
}
