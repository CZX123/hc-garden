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
  const ExploreBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {}
}
