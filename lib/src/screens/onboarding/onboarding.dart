import 'package:hc_garden/src/library.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double get page =>
      _pageController.hasClients ? (_pageController.page ?? 0) : 0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        child: Column(
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                //print(MediaQuery.of(context).size.height);
                //print(constraints.maxHeight);
                return ChangeNotifierProvider(
                  create: (context) => OnboardingLayoutDetails(
                    pageController: _pageController,
                    animationController: _animationController,
                    screenWidth: screenWidth,
                    screenHeight: constraints.maxHeight - topPadding,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: PageView.builder(
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            if (index == 0)
                              return _OnboardingPageOne();
                            else if (index == 1)
                              return _OnboardingPageTwo();
                            else if (index == 5) return _OnboardingPageSix();
                            return SizedBox.shrink();
                          },
                          itemCount: 6,
                        ),
                      ),
                      OnboardingAnimationWidget(),
                    ],
                  ),
                );
              }),
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 56,
                horizontal: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Theme(
                    data: ThemeData(
                      fontFamily: 'Manrope',
                      accentColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Color(0xFFF5730F)
                              : Color(0xFF7A3735),
                      buttonTheme: ButtonThemeData(
                        minWidth: 0,
                        textTheme: ButtonTextTheme.accent,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        return FlatButton(
                          child: CustomAnimatedSwitcher(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              page < 0.5 ? 'Cancel' : 'Previous',
                              key: ValueKey((page < 0.5).toString()),
                            ),
                          ),
                          onPressed: page < 1
                              ? Navigator.of(context).pop
                              : () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                },
                        );
                      },
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 0,
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        return FlatButton(
                          textTheme: ButtonTextTheme.accent,
                          child: CustomAnimatedSwitcher(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              page < 4.5 ? 'Next' : 'Done',
                            ),
                            key: ValueKey(page < 4.5),
                          ),
                          onPressed: page < 4.5
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                }
                              : Navigator.of(context).pop,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageOne extends StatelessWidget {
  const _OnboardingPageOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox.shrink(),
          Image.asset(
            'assets/images/app_logo/app_logo.png',
            height: 216,
          ),
          Text(
            'Welcome to\nHC Garden!',
            style: Theme.of(context).textTheme.display2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          Text(
            'Swipe right to learn more ->',
            style: Theme.of(context).textTheme.subhead,
          ),
          SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _OnboardingPageTwo extends StatelessWidget {
  const _OnboardingPageTwo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: FractionallySizedBox(
          heightFactor: 0.19,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "This is the homepage!",
                  style: Theme.of(context).textTheme.display1,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "You'll see it everytime you open HC Garden.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageSix extends StatelessWidget {
  const _OnboardingPageSix({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: FadeTransition(
        // Opacity changes from 0 to 1.0 as the pageController changes from 4.5 to 5.0
        opacity: (layoutDetails.page > 4.5 && layoutDetails.page <= 5.0)
            ? Tween(begin: -9.0, end: -7.0).animate(layoutDetails.animation)
            : AlwaysStoppedAnimation(0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 0.08 * layoutDetails.screenHeight,
            ),
            Image.asset(
              'assets/images/app_logo/app_logo.png',
              height: 216,
            ),
            Text(
              'Start your\nHC Garden\njourney now!',
              style: Theme.of(context).textTheme.display2.copyWith(
                    color: Theme.of(context).accentColor,
                    fontSize: 26,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 0.08 * layoutDetails.screenHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingAnimationWidget extends StatelessWidget {
  const OnboardingAnimationWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(
              children: <Widget>[
                Transform.translate(
                  offset: layoutDetails.pageThreeText.offset,
                  child: FadeTransition(
                    opacity: layoutDetails.pageThreeText.opacity,
                    child: _PageThreeText(),
                  ),
                ),
                Transform.translate(
                  offset: layoutDetails.homePageScreenshot.offset,
                  child: Transform.scale(
                    alignment: Alignment.topCenter,
                    scale: layoutDetails.homePageScreenshot.scale,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Opacity(
                          opacity: (layoutDetails.page < 5.0) ? 1 : 0,
                          child: HomePageScreenshot()),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: layoutDetails.pageFiveText.offset,
                  child: FadeTransition(
                      opacity: layoutDetails.pageFiveText.opacity,
                      child: _PageFiveText()),
                ),
                Transform.translate(
                  offset: layoutDetails.pageFourBottomSheet.offset,
                  child: PageFourBottomSheet(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageThreeText extends StatelessWidget {
  const _PageThreeText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    return Container(
      alignment: Alignment.bottomCenter,
      height: layoutDetails.pageThreeText.containerHeight,
      padding: EdgeInsets.fromLTRB(
          24.0, 0.0, 24.0, 0.04 * layoutDetails.screenHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Explore our school",
            style: Theme.of(context).textTheme.display1,
            textAlign: TextAlign.center,
          ),
          Text(
            "with Google Maps!",
            style: Theme.of(context).textTheme.display1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HomePageScreenshot extends StatelessWidget {
  const HomePageScreenshot({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    return Material(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black.withOpacity(0.78),
            width: HomePageScreenshotLayoutDetails.borderWidth,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          width: layoutDetails.homePageScreenshot.width,
          padding:
              const EdgeInsets.all(HomePageScreenshotLayoutDetails.borderWidth),
          child: Image.asset(
            "assets/images/screenshots/homepage.png",
          ),
        ));
  }
}

class PageFourBottomSheet extends StatelessWidget {
  const PageFourBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    final containerHeight =
        layoutDetails.screenHeight - layoutDetails.pageFourBottomSheet.page4Y;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, 1.0),
            blurRadius: 10.0,
            spreadRadius: 0.0,
            color: Colors.black45,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Theme.of(context).canvasColor,
      ),
      height: containerHeight,
      width: layoutDetails.screenWidth,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24.0, 0.06 * layoutDetails.screenHeight, 24.0, 0.0),
        alignment: Alignment.topCenter,
        height: containerHeight,
        child: FadeTransition(
          opacity: layoutDetails.pageFourBottomSheet.opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Check out our nature trails,",
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
              Text(
                "and discover our school's vibrant wildlife!",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageFiveText extends StatelessWidget {
  const _PageFiveText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    return Container(
      alignment: Alignment.topCenter,
      height: layoutDetails.pageFiveText.containerHeight,
      padding: EdgeInsets.fromLTRB(
          24.0, 0.06 * layoutDetails.screenHeight, 24.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Customise your preferences",
            style: Theme.of(context).textTheme.display1,
            textAlign: TextAlign.center,
          ),
          Text(
            "by tapping on the menu icon, ",
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "&",
              style: Theme.of(context).textTheme.display1.copyWith(
                    fontFamily: "Roboto",
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "Learn about our history",
            style: Theme.of(context).textTheme.display1,
            textAlign: TextAlign.center,
          ),
          Text(
            "by tapping on the history icon!",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingLayoutDetails extends ChangeNotifier {
  final PageController pageController;
  double get page => pageController.page ?? 0;
  final AnimationController _animationController;
  Animation<double> get animation => _animationController.view;
  final double screenWidth, screenHeight;

  HomePageScreenshotLayoutDetails _homePageScreenshot;
  HomePageScreenshotLayoutDetails get homePageScreenshot => _homePageScreenshot;
  PageThreeTextLayoutDetails _pageThreeText;
  PageThreeTextLayoutDetails get pageThreeText => _pageThreeText;
  PageFourBottomSheetLayoutDetails _pageFourBottomSheet;
  PageFourBottomSheetLayoutDetails get pageFourBottomSheet =>
      _pageFourBottomSheet;
  PageFiveTextLayoutDetails _pageFiveText;
  PageFiveTextLayoutDetails get pageFiveText => _pageFiveText;

  OnboardingLayoutDetails({
    @required this.pageController,
    @required AnimationController animationController,
    @required this.screenWidth,
    @required this.screenHeight,
  }) : _animationController = animationController {
    _homePageScreenshot = HomePageScreenshotLayoutDetails(this);
    _pageThreeText = PageThreeTextLayoutDetails(this);
    _pageFourBottomSheet = PageFourBottomSheetLayoutDetails(this);
    _pageFiveText = PageFiveTextLayoutDetails(this);
    pageController.addListener(pageControllerListener);
  }

  void pageControllerListener() {
    _animationController.value = page;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.removeListener(pageControllerListener);
    super.dispose();
  }

  double _lerp(double startX, double endX, double startY, double endY) {
    // assert(startX <= page);
    // assert(page <= endX);
    return startY + ((page - startX) / (endX - startX)) * (endY - startY);
  }
}

class HomePageScreenshotLayoutDetails {
  final OnboardingLayoutDetails parent;
  const HomePageScreenshotLayoutDetails(this.parent);

  static const borderWidth = 6.0;
  static const aspectRatio =
      (1440.0 + 2 * borderWidth) / (2960.0 + 2 * borderWidth);
  static const bottomBarAspectRatio =
      (1440.0 + 2 * borderWidth) / (336.0 + borderWidth);
  static const page3AspectRatio =
      (1440.0 + 2 * borderWidth) / (1896.0 + borderWidth);
  static const page4AspectRatio =
      (1440.0 + 2 * borderWidth) / (2336.0 + borderWidth);
  static const page5AspectRatio =
      (1440.0 + 2 * borderWidth) / (1702.0 + borderWidth);
  static const imageWidthRatio = 0.85;

  double get width => imageWidthRatio * parent.screenWidth + 2 * borderWidth;
  double get height => width / aspectRatio;
  // 0.19 is the height ratio of the text and 0.04 is the height ratio
  // of the padding between the text and screenshot
  double get page2Y => (0.19 + 0.04) * parent.screenHeight;
  // 0.73 is the height ratio of the screenshot of the homepage
  double get page2Scale => 0.73 * parent.screenHeight / height;
  // page3AspectRatio is the aspect ratio of the top map portion of the screenshot
  double get page3Y => parent.screenHeight - width / page3AspectRatio;
  // page4AspectRatio is the aspect ratio of the bottom portion of the screenshot
  double get page4Y => width / page4AspectRatio - height;
  // page5AspectRatio is the aspect ratio of the bottom sheet portion of the screenshot
  double get page5Y => width / page5AspectRatio - height;

  Offset get offset {
    if (parent.page <= 1.0)
      return Offset(parent._lerp(0, 1.0, parent.screenWidth, 0), page2Y);
    // Image only moves when the page controller is from 1.0 to 1.7
    else if (parent.page > 1.0 && parent.page <= 1.7)
      return Offset(0, parent._lerp(1.0, 1.7, page2Y, page3Y));
    else if (parent.page > 1.7 && parent.page <= 2.0)
      return Offset(0, page3Y);
    else if (parent.page > 2.0 && parent.page <= 3.0)
      return Offset(0, parent._lerp(2.0, 3.0, page3Y, page4Y));
    else if (parent.page > 3.0 && parent.page <= 4.0)
      return Offset(0, parent._lerp(3.0, 4.0, page4Y, page5Y));
    // Image only moves when the page controller is from 4.0 to 4.6
    // so that it moves more quickly
    // Movement of an additional 60 pixels upwards to move past status bar (top padding)
    else if (parent.page > 4.0 && parent.page <= 4.6)
      return Offset(0, parent._lerp(4.0, 4.6, page5Y, -height - 80.0));
    return Offset(0, -height - 80.0);
  }

  double get scale {
    if (parent.page <= 1)
      return page2Scale;
    else if (parent.page > 1 && parent.page <= 1.9)
      return parent._lerp(1, 1.9, page2Scale, 1);
    return 1;
  }
}

class PageThreeTextLayoutDetails {
  final OnboardingLayoutDetails parent;

  Animation<double> _page2To3Opacity, _page3To4Opacity;
  PageThreeTextLayoutDetails(this.parent) {
    // Opacity changes from 0 to 1.0 as the pageController changes from 1.5 to 2.0
    _page2To3Opacity = Tween(begin: -3.0, end: -1.0).animate(parent.animation);
    // Opacity changes from 1.0 to 0 as the pageController changes from 2.0 ro 2.3
    _page3To4Opacity = Tween(
      begin: 23 / 3,
      end: 13 / 3,
    ).animate(parent.animation);
  }

  double get containerHeight => parent.homePageScreenshot.page3Y;
  // 0.19 is the height ratio of the text
  double get page2Y => 0.19 * parent.screenHeight - containerHeight;
  // page4Y is double of page2Y to increase the speed of upward translation
  double get page4Y => 2 * page2Y;

  Offset get offset {
    if (parent.page > 1.0 && parent.page <= 2.0)
      return Offset(0, parent._lerp(1.0, 2.0, page2Y, 0));
    else if (parent.page > 2.0 && parent.page <= 3.0)
      return Offset(0, parent._lerp(2.0, 3.0, 0, page4Y));
    return Offset(0, 0);
  }

  Animation<double> get opacity {
    // Text only starts appearing when the page controller is 1.5
    if (parent.page > 1.5 && parent.page <= 2.0)
      return _page2To3Opacity;
    // Text disappears rapidly when the page controller is from 2.0 to 2.3
    else if (parent.page > 2.0 && parent.page <= 2.3) return _page3To4Opacity;
    return const AlwaysStoppedAnimation(0.0);
  }
}

class PageFourBottomSheetLayoutDetails {
  final OnboardingLayoutDetails parent;

  Animation<double> _page3To4TextOpacity, _page4To5TextOpacity;
  PageFourBottomSheetLayoutDetails(this.parent) {
    // Opacity changes from 0 to 1.0 as the pageController changes from 2.5 to 3.0
    _page3To4TextOpacity =
        Tween(begin: -5.0, end: -3.0).animate(parent.animation);
    // Opacity changes from 1.0 to 0 as the pageController changes from 3.0 to 3.3
    _page4To5TextOpacity = Tween(
      begin: 11.0,
      end: 23 / 3,
    ).animate(parent.animation);
  }

  double get page4Y =>
      parent.homePageScreenshot.width /
          HomePageScreenshotLayoutDetails.page4AspectRatio -
      parent.homePageScreenshot.width /
          HomePageScreenshotLayoutDetails.bottomBarAspectRatio;

  Offset get offset {
    // Initial y-coordinate is more than screenHeight in order to hide the shadow
    if (parent.page <= 2.0)
      return Offset(0, parent.screenHeight + 20);
    else if (parent.page > 2.0 && parent.page <= 3.0)
      return Offset(
          0, parent._lerp(2.0, 3.0, parent.screenHeight + 20, page4Y));
    // Material only moves when the pageController changes from 3.0 to 3.6
    else if (parent.page > 3.0 && parent.page <= 3.6)
      return Offset(
          0, parent._lerp(3.0, 3.6, page4Y, parent.screenHeight + 20));
    else if (parent.page > 3.6 && parent.page <= 4.0)
      return Offset(0, parent.screenHeight + 20);
    return Offset(0, parent.screenHeight + 20);
  }

  Animation<double> get opacity {
    if (parent.page > 2.5 && parent.page <= 3.0)
      return _page3To4TextOpacity;
    else if (parent.page > 3.0 && parent.page <= 3.3)
      return _page4To5TextOpacity;
    return const AlwaysStoppedAnimation(0.0);
  }
}

class PageFiveTextLayoutDetails {
  final OnboardingLayoutDetails parent;

  Animation<double> _page4To5TextOpacity, _page5To6TextOpacity;
  PageFiveTextLayoutDetails(this.parent) {
    // Opacity changes from 0 to 1.0 as the pageController changes from 3.5 to 4.0
    _page4To5TextOpacity =
        Tween(begin: -7.0, end: -5.0).animate(parent.animation);
    // Opacity changes from 1.0 to 0 as the pageController changes from 4.0 to 4.3
    _page5To6TextOpacity = Tween(
      begin: 43 / 3,
      end: 11.0,
    ).animate(parent.animation);
  }

  double get page5Y =>
      parent.homePageScreenshot.page5Y + parent.homePageScreenshot.height;
  double get containerHeight => parent.screenHeight - page5Y;

  Offset get offset {
    if (parent.page <= 3.0)
      return Offset(0, parent.screenHeight);
    else if (parent.page > 3.0 && parent.page <= 4.0)
      return Offset(0, parent._lerp(3.0, 4.0, parent.screenHeight, page5Y));
    else if (parent.page > 4.0 && parent.page <= 4.6)
      return Offset(0, parent._lerp(4.0, 4.6, page5Y, parent.screenHeight));
    return Offset(0, parent.screenHeight);
  }

  Animation<double> get opacity {
    if (parent.page > 3.5 && parent.page <= 4.0)
      return _page4To5TextOpacity;
    else if (parent.page > 4.0 && parent.page <= 4.3)
      return _page5To6TextOpacity;
    return AlwaysStoppedAnimation(0.0);
  }
}
