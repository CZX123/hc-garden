import 'library.dart';

const spacing = 4 * 8 + 2 * 16 + 4.0;
const imageHeight = 28.0;
const headingHeight = 28.0;
const trailButtonHeight = 80.0;
const entityButtonHeight = 108.0;
const entityButtonHeightCollapsed = 64.0;
const bottomBarHeight = 62.0;
const bottomHeight = spacing +
    headingHeight +
    imageHeight +
    trailButtonHeight +
    entityButtonHeight +
    bottomBarHeight;
const offsetTranslation = bottomHeight -
    16 -
    entityButtonHeight -
    bottomBarHeight; // without topPadding

class ExploreHeader extends StatelessWidget {
  final Animation<double> animation;
  final TabController tabController;
  final Function(double) animateTo;
  final ValueNotifier<bool> isScrolledNotifier;
  const ExploreHeader({
    Key key,
    @required this.animation,
    @required this.tabController,
    @required this.animateTo,
    @required this.isScrolledNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _trails = ['Jing Xian Trail', 'Kong Chian Trail', 'Kah Kee Trail'];
    final _colors = [Colors.amber[600], Colors.pink, Colors.lightBlue];
    final height = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final totalTranslation = offsetTranslation - topPadding;
    final anim = Tween<double>(begin: 0, end: 1 / (height - bottomHeight))
        .animate(animation);
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        return AnimatedOpacity(
          opacity: state == 0 ? 1 : 0,
          duration: Duration(milliseconds: state == 0 ? 400 : 200),
          curve:
              state == 0 ? Interval(0.5, 1, curve: Curves.ease) : Curves.ease,
          child: child,
        );
      },
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 8),
            height: 12,
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0,
                end: (height - bottomHeight) / topPadding,
              ).animate(anim),
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
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              Offset offset;
              if (animation.value > height - bottomHeight) {
                offset = Offset(0, 0);
                Provider.of<AppNotifier>(context, listen: false)
                    .sheetMinimised = true;
              } else {
                offset = Offset(
                  0,
                  (animation.value / (height - bottomHeight) - 1) *
                      totalTranslation,
                );
                Provider.of<AppNotifier>(context, listen: false)
                    .sheetMinimised = false;
              }
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16 + 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FadeTransition(
                    opacity: Tween<double>(
                      begin: 16 / 12 - totalTranslation / 12,
                      end: 16 / 12,
                    ).animate(anim),
                    child: Image.asset(
                      'assets/images/hci.png',
                      height: imageHeight,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  FadeTransition(
                    opacity: Tween<double>(
                      begin: (24 + imageHeight) / 12 - totalTranslation / 12,
                      end: (24 + imageHeight) / 12,
                    ).animate(anim),
                    child: Text(
                      'Explore HC Garden',
                      style: Theme.of(context).textTheme.title.copyWith(
                            height: headingHeight / 20,
                          ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  FadeTransition(
                    opacity: Tween<double>(
                      begin: (40 + imageHeight + headingHeight) / 40 -
                          totalTranslation / 40,
                      end: (40 + imageHeight + headingHeight) / 40,
                    ).animate(anim),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < _trails.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FlatButton(
                                  colorBrightness: Brightness.dark,
                                  color: _colors[i],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    height: trailButtonHeight,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _trails[i].toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Material(
                    color: Theme.of(context).canvasColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < 2; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        i == 0
                                            ? 'assets/images/flora.jpg'
                                            : 'assets/images/fauna.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FlatButton(
                                    colorBrightness: Brightness.dark,
                                    color: Colors.black38,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        double cardHeight = entityButtonHeight;
                                        if (animation.value <
                                            height - bottomHeight) {
                                          cardHeight = entityButtonHeightCollapsed +
                                              (entityButtonHeight -
                                                      entityButtonHeightCollapsed) *
                                                  animation.value /
                                                  (height - bottomHeight);
                                        }
                                        return Container(
                                          height: cardHeight,
                                          alignment: Alignment.center,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        i == 0 ? 'FLORA' : 'FAUNA',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (animation.value <
                                          height - bottomHeight)
                                        tabController.animateTo(i);
                                      else {
                                        tabController.animateTo(
                                          i,
                                          duration: const Duration(
                                            milliseconds: 1,
                                          ),
                                        );
                                      }
                                      animateTo(0);
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: Tween<double>(
                      begin: 12 / 12 - totalTranslation / 12,
                      end: 12 / 12,
                    ).animate(anim),
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreBody extends StatelessWidget {
  final Animation<double> animation;
  final TabController tabController;
  final List<ScrollController> scrollControllers;
  final List<ScrollController> extraScrollControllers;
  final Function(double) animateTo;
  final GlobalKey<NavigatorState> navigatorKey;
  const ExploreBody({
    Key key,
    @required this.animation,
    @required this.tabController,
    @required this.scrollControllers,
    @required this.extraScrollControllers,
    @required this.animateTo,
    @required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final initialRoute = FadeOutPageRoute<void>(
      builder: (context) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            print(animation.value);
            Offset offset;
            if (animation.value > height - bottomHeight)
              offset = Offset(
                0,
                bottomHeight -
                    bottomBarHeight -
                    entityButtonHeightCollapsed -
                    16 -
                    topPadding,
              );
            else
              offset = Offset(
                0,
                animation.value *
                    (bottomHeight -
                        bottomBarHeight -
                        entityButtonHeightCollapsed -
                        16 -
                        topPadding) /
                    (height - bottomHeight),
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
                    Selector<AppNotifier, List<Flora>>(
                      selector: (context, appNotifier) => appNotifier.floraList,
                      builder: (context, floraList, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[0],
                          extraScrollController: extraScrollControllers[0],
                          entityList: floraList,
                        );
                      },
                    ),
                    Selector<AppNotifier, List<Fauna>>(
                      selector: (context, appNotifier) => appNotifier.faunaList,
                      builder: (context, faunaList, child) {
                        return EntityListPage(
                          scrollController: scrollControllers[1],
                          extraScrollController: extraScrollControllers[0],
                          entityList: faunaList,
                        );
                      },
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: WhiteGradient(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == Navigator.defaultRouteName) return initialRoute;
        return null;
      },
    );
  }
}

class WhiteGradient extends StatelessWidget {
  const WhiteGradient({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).canvasColor;
    return Container(
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
    );
  }
}
