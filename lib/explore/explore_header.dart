import '../library.dart';

// TODO: Cater to smaller screens by removing/shifting some elements of the ExploreHeader, like the app logo
class ExploreHeader extends StatelessWidget {
  final TabController tabController;
  const ExploreHeader({
    Key key,
    @required this.tabController,
  }) : super(key: key);

  double _getPaddingBreakPoint(BottomSheetNotifier bottomSheetNotifier) {
    return bottomSheetNotifier.snappingPositions.value[1];
  }

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier = Provider.of<BottomSheetNotifier>(
      context,
      listen: false,
    );
    final topPadding = MediaQuery.of(context).padding.top;
    final totalTranslation = Sizes.hOffsetTranslation - topPadding;
    final anim = Tween<double>(
      begin: 0,
      end: 1 / _getPaddingBreakPoint(bottomSheetNotifier),
    ).animate(bottomSheetNotifier.animation);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion(
      value: (isDark
              ? ThemeNotifier.darkOverlayStyle
              : ThemeNotifier.lightOverlayStyle)
          .copyWith(
        statusBarColor:
            Theme.of(context).canvasColor.withOpacity(isDark ? .5 : .8),
        systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
      ),
      child: ValueListenableBuilder(
        valueListenable: anim,
        builder: (context, value, child) {
          Offset offset;
          if (value > 1) {
            offset = Offset(0, 0);
          } else {
            offset = Offset(
              0,
              (value - 1) * totalTranslation,
            );
          }
          return Transform.translate(
            offset: offset,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20 + 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppLogo(
                opacity: Tween<double>(
                  begin: 16 / 12 - totalTranslation / 12,
                  end: 16 / 12,
                ).animate(anim),
              ),
              const SizedBox(
                height: 8,
              ),
              FadeTransition(
                opacity: Tween<double>(
                  begin: (24 + Sizes.hLogoHeight) / 12 - totalTranslation / 12,
                  end: (24 + Sizes.hLogoHeight) / 12,
                ).animate(anim),
                child: Text(
                  'Explore HC Garden',
                  style: Theme.of(context).textTheme.display1.copyWith(
                        height: Sizes.hHeadingHeight / 20,
                      ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TrailButtonsRow(
                opacity: Tween<double>(
                  begin: (40 + Sizes.hLogoHeight + Sizes.hHeadingHeight) / 40 -
                      totalTranslation / 40,
                  end: (40 + Sizes.hLogoHeight + Sizes.hHeadingHeight) / 40,
                ).animate(anim),
              ),
              const SizedBox(
                height: 8,
              ),
              FloraFaunaTabBar(
                animateTo: bottomSheetNotifier.animateTo,
                animation: anim,
                tabController: tabController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final Animation<double> opacity;
  const AppLogo({Key key, @required this.opacity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/hci.png',
            height: Sizes.hLogoHeight,
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Hwa Chong'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Text(
                'Institution'.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  letterSpacing: 0.15,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 12,
          ),
          Transform.scale(
            scale: 1.1,
            child: Image.asset(
              'assets/images/app_logo/default.png',
              height: Sizes.hLogoHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class TrailButtonsRow extends StatelessWidget {
  final Animation<double> opacity;
  const TrailButtonsRow({Key key, @required this.opacity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _trails = ['Kah Kee\nTrail', 'Kong Chian\nTrail', 'Jing Xian\nTrail'];
    final _colors = [Colors.lightBlue, Colors.pink, Colors.amber[700]];
    final _textColors = [
      Color(0xFF00C3FF),
      Color(0xFFFF668C),
      Color(0xFFFFBF00),
    ];

    return FadeTransition(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            for (int i = 0; i < _trails.length; i++)
              TrailButton(
                color: _colors[i],
                textColor: _textColors[i],
                trailName: _trails[i],
                onPressed: () {
                  final firebaseData =
                      Provider.of<FirebaseData>(context, listen: false);
                  final trail = firebaseData.trails.keys.firstWhere((trail) {
                    return trail.name.contains(_trails[i].substring(0, 5));
                  });
                  Provider.of<AppNotifier>(context).push(
                    context: context,
                    route: CrossFadePageRoute(
                      builder: (context) {
                        final firebaseData = Provider.of<FirebaseData>(context);
                        final trailLocations = firebaseData.trails[trail];
                        return TrailDetailsPage(
                          trail: trail,
                          trailLocations: trailLocations,
                        );
                      },
                    ),
                    routeInfo: RouteInfo(
                      name: trail.name,
                      data: trail,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TrailButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String trailName;
  final VoidCallback onPressed;
  const TrailButton({
    Key key,
    @required this.color,
    @required this.textColor,
    @required this.trailName,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            final textStyle = TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.bold,
            );
            return AnimatedTheme(
              data: themeNotifier.value
                  ? darkThemeData.copyWith(
                      buttonColor: Color(0xFF383838),
                      textTheme: TextTheme(
                        body1: textStyle.copyWith(
                          color: textColor,
                        ),
                      ),
                    )
                  : themeData.copyWith(
                      buttonColor: color,
                      textTheme: TextTheme(
                        body1: textStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
              child: child,
            );
          },
          child: Builder(builder: (context) {
            return FlatButton(
              colorBrightness: Brightness.dark,
              color: Theme.of(context).buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                height: Sizes.hTrailButtonHeight,
                alignment: Alignment.center,
                child: Text(
                  trailName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
              onPressed: onPressed,
            );
          }),
        ),
      ),
    );
  }
}

class FloraFaunaTabBar extends StatelessWidget {
  final Function(double) animateTo;
  final Animation<double> animation;
  final TabController tabController;
  const FloraFaunaTabBar({
    Key key,
    @required this.animateTo,
    @required this.animation,
    @required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final tabIndicatorWidth = 72.0;
    final firstTabOffset = (width - 24) / 4 + 8 - tabIndicatorWidth / 2;
    final secondTabOffset = (width - 24) / 4 * 3 + 16 - tabIndicatorWidth / 2;
    return Material(
      color: Theme.of(context).canvasColor,
      child: Stack(
        children: <Widget>[
          Padding(
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
                          child: ValueListenableBuilder(
                            valueListenable: animation,
                            builder: (context, value, child) {
                              double y = 0;
                              double cardHeight = Sizes.hEntityButtonHeight;
                              if (value < 1) {
                                cardHeight = Sizes
                                        .hEntityButtonHeightCollapsed +
                                    (Sizes.hEntityButtonHeight -
                                            Sizes
                                                .hEntityButtonHeightCollapsed) *
                                        value;
                                y = (value - 1) * 3;
                              }
                              return Container(
                                height: cardHeight,
                                alignment: Alignment.center,
                                child: Transform.translate(
                                  offset: Offset(0, y),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              i == 0 ? 'FLORA' : 'FAUNA',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headline.copyWith(
                                        color: Colors.white,
                                      ),
                            ),
                          ),
                          onPressed: () {
                            if (animation.value <
                                height - Sizes.kBottomHeight) {
                              tabController.animateTo(i);
                            } else {
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
          Positioned(
            left: 0,
            bottom: 18,
            height: 2,
            width: tabIndicatorWidth,
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 1,
                end: -1,
              ).animate(animation),
              child: IgnorePointer(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(firstTabOffset / tabIndicatorWidth, 0),
                    end: Offset(secondTabOffset / tabIndicatorWidth, 0),
                  ).animate(tabController.animation),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: kElevationToShadow[1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
