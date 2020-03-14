import 'package:hc_garden/src/library.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                            else if (index == 2) return SizedBox.shrink();
                            return Center(
                              child: Text(index.toString()),
                            );
                          },
                          itemCount: 4,
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
                vertical: 4,
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
                    child: FlatButton(
                      child: const Text('Cancel'),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 0,
                    child: FlatButton(
                      textTheme: ButtonTextTheme.accent,
                      child: const Text('Next'),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
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
                  child: Opacity(
                      opacity: layoutDetails.pageThreeText.opacity,
                      child: _PageThreeText()),
                ),
                Transform.translate(
                  offset: layoutDetails.homePageScreenshot.offset,
                  child: Transform.scale(
                    alignment: Alignment.topCenter,
                    scale: layoutDetails.homePageScreenshot.scale,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: HomePageScreenshot(),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: layoutDetails.homePageCover.offset,
                  child: HomePageCover(),
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
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          alignment: Alignment.bottomCenter,
          height: layoutDetails.pageThreeText.containerHeight,
          padding: EdgeInsets.only(bottom: 0.04 * layoutDetails.screenHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Explore our",
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
              Text(
                "school with Google Maps!",
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

class HomePageCover extends StatelessWidget {
  const HomePageCover({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 10.0, spreadRadius: 0.0, color: Colors.black45),
        ],
        color: Colors.white,
      ),
      child: Container(
        height: layoutDetails.screenHeight,
        width: layoutDetails.screenWidth,
      ),
    );
  }
}

class OnboardingLayoutDetails extends ChangeNotifier {
  final PageController pageController;
  double get page => pageController.page ?? 0;
  final double screenWidth, screenHeight;

  HomePageScreenshotLayoutDetails _homePageScreenshot;
  HomePageScreenshotLayoutDetails get homePageScreenshot => _homePageScreenshot;
  PageThreeTextLayoutDetails _pageThreeText;
  PageThreeTextLayoutDetails get pageThreeText => _pageThreeText;
  HomePageCoverLayoutDetails _homePageCover;
  HomePageCoverLayoutDetails get homePageCover => _homePageCover;

  OnboardingLayoutDetails({
    @required this.pageController,
    @required this.screenWidth,
    @required this.screenHeight,
  }) {
    _homePageScreenshot = HomePageScreenshotLayoutDetails(this);
    _pageThreeText = PageThreeTextLayoutDetails(this);
    _homePageCover = HomePageCoverLayoutDetails(this);
    pageController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    pageController.removeListener(notifyListeners);
    super.dispose();
  }

  double _lerp(double startX, double endX, double startY, double endY) {
    assert(startX <= page);
    assert(page <= endX);
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
  static const imageWidthRatio = 0.85;

  double get width => imageWidthRatio * parent.screenWidth + 2 * borderWidth;
  // 0.19 is the height ratio of the text and 0.04 is the height ratio
  // of the padding between the text and screenshot
  double get page2Y => (0.19 + 0.04) * parent.screenHeight;
  // 0.73 is the height ratio of the screenshot of the homepage
  double get page2Scale => 0.73 * parent.screenHeight / (width / aspectRatio);
  // page3AspectRatio is the aspect ratio of the top map portion of the screenshot
  double get page3Y => parent.screenHeight - width / page3AspectRatio;
  // page4AspectRatio is the aspect ratio of the bottom portion of the screenshot
  double get page4Y => width / page4AspectRatio - width / aspectRatio;

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
    return Offset(0, 0);
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
  const PageThreeTextLayoutDetails(this.parent);

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

  double get opacity {
    // Text only starts appearing when the page controller is 1.5
    if (parent.page > 1.5 && parent.page <= 2.0)
      return parent._lerp(1.5, 2.0, 0, 1.0);
    // Text disappears rapidly when the page controller is from 2.0 to 2.3
    else if (parent.page > 2.0 && parent.page <= 2.3)
      return parent._lerp(2.0, 2.3, 1.0, 0);
    return 0;
  }
}

class HomePageCoverLayoutDetails {
  final OnboardingLayoutDetails parent;
  const HomePageCoverLayoutDetails(this.parent);

  double get page4Y => parent.homePageScreenshot.width/HomePageScreenshotLayoutDetails.page4AspectRatio - parent.homePageScreenshot.width/HomePageScreenshotLayoutDetails.bottomBarAspectRatio;

  Offset get offset {
    if (parent.page <= 2.0)
      return Offset(0, parent.screenHeight);
    else if (parent.page > 2.0 && parent.page <= 3.0)
      return Offset(0, parent._lerp(2.0, 3.0, parent.screenHeight, page4Y));
    return Offset(0, 0);
  }
}
