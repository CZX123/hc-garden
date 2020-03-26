import 'package:hc_garden/src/library.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  double get page {
    return _pageController.hasClients ? (_pageController.page ?? 0) : 0;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion(
      value: (isDark
              ? ThemeNotifier.darkOverlayStyle
              : ThemeNotifier.lightOverlayStyle)
          .copyWith(
        statusBarColor: Theme.of(context).canvasColor.withOpacity(
              isDark ? .5 : .8,
            ),
        systemNavigationBarColor: Theme.of(context).canvasColor,
      ),
      child: Material(
        child: Column(
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ChangeNotifierProvider(
                    create: (context) => OnboardingLayoutDetails(
                      pageController: _pageController,
                      animationController: _animationController,
                      maxWidth: screenWidth,
                      maxHeight: constraints.maxHeight - topPadding,
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
                },
              ),
            ),
            Divider(
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: Stack(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _BottomBarButton(
                            prefixIcon: Icon(
                              page < 0.5 ? Icons.redo : Icons.chevron_left,
                            ),
                            title: page < 0.5 ? 'Skip' : 'Back',
                            onTap: page < 0.5
                                ? Navigator.of(context).pop
                                : () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Cubic(.3, 0, .2, 1),
                                    );
                                  },
                          ),
                          _BottomBarButton(
                            suffixIcon: Icon(
                              page < 4.5 ? Icons.chevron_right : Icons.check,
                            ),
                            title: page < 4.5 ? 'Next' : 'Done',
                            onTap: page < 4.5
                                ? () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Cubic(.3, 0, .2, 1),
                                    );
                                  }
                                : Navigator.of(context).pop,
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    top: 21,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 6,
                        effect: WormEffect(
                          dotWidth: 6,
                          dotHeight: 6,
                          spacing: 3,
                          dotColor: Theme.of(context).dividerColor,
                          activeDotColor: Theme.of(context).accentColor,
                          strokeWidth: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BottomPadding(),
          ],
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final Icon prefixIcon;
  final String title;
  final Icon suffixIcon;
  final VoidCallback onTap;

  const _BottomBarButton({
    Key key,
    this.prefixIcon,
    @required this.title,
    this.suffixIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.display2.color;
    return Theme(
      data: ThemeData(
        fontFamily: 'Manrope',
        accentColor: color,
        buttonTheme: ButtonThemeData(
          minWidth: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textTheme: ButtonTextTheme.accent,
        ),
        iconTheme: IconThemeData(
          color: color ?? Theme.of(context).accentColor,
          size: 20,
        ),
      ),
      child: CustomAnimatedSwitcher(
        alignment:
            prefixIcon != null ? Alignment.centerLeft : Alignment.centerRight,
        child: Builder(
          key: ValueKey(title),
          builder: (context) {
            return FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (prefixIcon != null) prefixIcon,
                  // Skip icon is much wider, so need to hardcode more padding
                  SizedBox(width: title == 'Skip' ? 6 : 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: color,
                          height: 1.3,
                        ),
                  ),
                  SizedBox(width: 4),
                  if (suffixIcon != null)
                    suffixIcon,
                ],
              ),
              onPressed: onTap,
            );
          },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.subhead,
                  children: [
                    TextSpan(text: 'Swipe to learn more'),
                    WidgetSpan(
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
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
              height: 0.08 * layoutDetails.maxHeight,
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
              height: 0.08 * layoutDetails.maxHeight,
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
                OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: 5000,
                  child: Transform.translate(
                    offset: layoutDetails.homePageScreenshot.offset,
                    child: Transform.scale(
                      alignment: Alignment.topCenter,
                      scale: layoutDetails.homePageScreenshot.scale,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: (layoutDetails.page < 5.0) ? 1 : 0,
                          child: HomePageScreenshot(),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: layoutDetails.pageFiveText.offset,
                  child: FadeTransition(
                    opacity: layoutDetails.pageFiveText.opacity,
                    child: _PageFiveText(),
                  ),
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
      padding:
          EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.04 * layoutDetails.maxHeight),
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

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          // Shadows generated at https://brumm.af/shadows
          BoxShadow(
            offset: Offset(0, .7),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.039),
          ),
          BoxShadow(
            offset: Offset(0, 1.6),
            blurRadius: 2.7,
            color: Colors.black.withOpacity(0.057),
          ),
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.07),
          ),
          BoxShadow(
            offset: Offset(0, 5.4),
            blurRadius: 8.9,
            color: Colors.black.withOpacity(0.083),
          ),
          BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 16.7,
            color: Colors.black.withOpacity(0.101),
          ),
          BoxShadow(
            offset: Offset(0, 24),
            blurRadius: 40,
            color: Colors.black.withOpacity(0.14),
          ),
        ],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(.24)
            : Colors.black.withOpacity(.72),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
            width: layoutDetails.homePageScreenshot.borderWidth,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: layoutDetails.homePageScreenshot.width,
          padding: EdgeInsets.all(layoutDetails.homePageScreenshot.borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              24 - layoutDetails.homePageScreenshot.borderWidth,
            ),
            child: Image.asset(
              "assets/images/screenshots/homepage.png",
            ),
          ),
        ),
      ),
    );
  }
}

class PageFourBottomSheet extends StatelessWidget {
  const PageFourBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final layoutDetails = context.provide<OnboardingLayoutDetails>();
    final containerHeight =
        layoutDetails.maxHeight - layoutDetails.pageFourBottomSheet.page4Y;
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
      width: layoutDetails.maxWidth,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            24.0, 0.06 * layoutDetails.maxHeight, 24.0, 0.0),
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
      padding:
          EdgeInsets.fromLTRB(24.0, 0.06 * layoutDetails.maxHeight, 24.0, 0.0),
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
          const SizedBox(height: 1),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1.5,
            width: 24,
            color: Theme.of(context).dividerColor,
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

  /// An [AnimationController] that is perfectly in sync with the pageController,
  /// for use in animation widgets like [FadeTransition]
  final AnimationController _animationController;
  Animation<double> get animation => _animationController.view;

  /// The width & height of the [OnboardingAnimationWidget]
  final double maxWidth, maxHeight;

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
    @required this.maxWidth,
    @required this.maxHeight,
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

  /// Linearly interpolates between 2 points, based on the `currentX` value,
  /// which by default is the `page` property of the [PageController]
  double _lerp(
    double startX,
    double endX,
    double startY,
    double endY, [
    double currentX,
  ]) {
    currentX ??= page;
    return startY + ((currentX - startX) / (endX - startX)) * (endY - startY);
  }

  /// An [Animation] equivalent to [_lerp], with the same arguments as [_lerp].
  Animation<double> _lerpAnim(
    double startX,
    double endX,
    double startY,
    double endY,
  ) {
    return animation.drive(Tween(
      begin: _lerp(startX, endX, startY, endY, 0),
      end: _lerp(startX, endX, startY, endY, 1),
    ));
  }
}

class HomePageScreenshotLayoutDetails {
  /// Width of screenshot as a ratio to screen width
  static const imageWidthRatio = 0.85;

  /// Width of border as a ratio to screen width
  static const borderWidthRatio = 0.018;
  static const imageAspectRatio = 1440 / 2960;

  /// Ratio of width of bottom nav bar in the image compared to height
  static const bottomBarAspectRatio = 1440 / 283;

  /// Ratio of the width of the top portion of the screenshot to its height
  static const page3AspectRatio = 1440 / 1904;

  /// Ratio of the width of the bottom portion of the screenshot to its height.
  /// It goes from somewhere in the middle of the map, all the way down to the bottom.
  static const page4AspectRatio = 1440 / 2336;

  /// Ratio of the width of the bottom visible portion of the screenshot to its height
  /// It goes from slightly before the top of bottom sheet, all the way down.
  static const page5AspectRatio = 1440 / 1702;

  /// Needed for getting the page attribute, and use of the `_lerp` or `_lerpAnim` functions
  final OnboardingLayoutDetails _parent;

  /// Physical width of the screenshot in pixels, inclusive of the border
  final double width;

  /// Border width in pixels
  final double borderWidth;

  /// Physical height of the screenshot in pixels, inclusive of the border
  final double height;

  /// Y-offset of the screenshot in pixels, from the top of the layout, in page 2
  final double page2Y;

  /// Scale of the screenshot in page 2. It is scaled down to fit the entire screenshot on screen.
  final double page2Scale;

  /// Y-offset of the screenshot in pixels, from the top of the layout, in page 3.
  ///
  /// Used to showcase the map in the screenshot.
  final double page3Y;

  /// Y-offset of the screenshot in pixels, from the top of the layout, in page 4.
  ///
  /// Used to showcase the trails, flora & fauna in the bottom sheet
  final double page4Y;

  /// Y-offset of the screenshot in pixels, from the top of the layout, in page 5.
  ///
  /// Used to showcase the menu and the bottom navigation bar.
  final double page5Y;

  const HomePageScreenshotLayoutDetails._(
    this._parent,
    this.width,
    this.borderWidth,
    this.height,
    this.page2Y,
    this.page2Scale,
    this.page3Y,
    this.page4Y,
    this.page5Y,
  );

  factory HomePageScreenshotLayoutDetails(OnboardingLayoutDetails parent) {
    final width = imageWidthRatio * parent.maxWidth;
    final borderWidth = borderWidthRatio * parent.maxWidth;
    // Width of image without the borders
    final _imageWidth = width - 2 * borderWidth;
    final height = _imageWidth / imageAspectRatio + 2 * borderWidth;

    // 0.19 is the height ratio of the top text in page 2.
    // 0.04 is the height ratio of the padding between the text and screenshot.
    final page2Y = (0.19 + 0.04) * parent.maxHeight;
    // 0.71 is the height ratio of the screenshot in page 2, compared to max height.
    // 0.71 = 1 - 0.19 - 0.04 - 0.06
    final page2Scale = 0.71 * parent.maxHeight / height;
    // Image is displayed from the bottom of the screen, so page3Y starts from the bottom,
    // i.e. parent.maxHeight and the visible area is subtracted from it.
    final page3Y =
        parent.maxHeight - (_imageWidth / page3AspectRatio + borderWidth);
    // Image is displayed from the top of the screen, so resulting value is negative
    // to hide the non visible areas of the image
    final page4Y = (_imageWidth / page4AspectRatio + borderWidth) - height;
    // Simlar as above
    final page5Y = (_imageWidth / page5AspectRatio + borderWidth) - height;

    return HomePageScreenshotLayoutDetails._(parent, width, borderWidth, height,
        page2Y, page2Scale, page3Y, page4Y, page5Y);
  }

  Offset get offset {
    if (_parent.page <= 1.0)
      return Offset(_parent._lerp(0, 1.0, _parent.maxWidth, 0), page2Y);
    // Image only moves when the page controller is from 1.0 to 1.7
    else if (_parent.page > 1.0 && _parent.page <= 1.8)
      return Offset(0, _parent._lerp(1.0, 1.8, page2Y, page3Y));
    else if (_parent.page > 1.8 && _parent.page <= 2.0)
      return Offset(0, page3Y);
    else if (_parent.page > 2.0 && _parent.page <= 3.0)
      return Offset(0, _parent._lerp(2.0, 3.0, page3Y, page4Y));
    else if (_parent.page > 3.0 && _parent.page <= 4.0)
      return Offset(0, _parent._lerp(3.0, 4.0, page4Y, page5Y));
    // Image only moves when the page controller is from 4.0 to 4.6
    // so that it moves more quickly
    // Movement of an additional 60 pixels upwards to move past status bar (top padding)
    else if (_parent.page > 4.0 && _parent.page <= 4.6)
      return Offset(0, _parent._lerp(4.0, 4.6, page5Y, -height - 80.0));
    return Offset(0, -height - 80.0);
  }

  double get scale {
    if (_parent.page <= 1)
      return page2Scale;
    else if (_parent.page > 1 && _parent.page <= 1.9)
      return _parent._lerp(1, 1.9, page2Scale, 1);
    return 1;
  }
}

class PageThreeTextLayoutDetails {
  final OnboardingLayoutDetails parent;
  final Animation<double> _page2To3Opacity, _page3To4Opacity;

  PageThreeTextLayoutDetails(this.parent)
      : // Opacity changes from 0 to 1.0 as the pageController changes from 1.5 to 2.0
        _page2To3Opacity = parent._lerpAnim(1.5, 2, 0, 1),
        // Opacity changes from 1.0 to 0 as the pageController changes from 2.0 ro 2.3
        _page3To4Opacity = parent._lerpAnim(2, 2.3, 1, 0);

  double get containerHeight => parent.homePageScreenshot.page3Y;
  // 0.19 is the height ratio of the text
  double get page2Y => 0.19 * parent.maxHeight - containerHeight;
  // page4Y is double of page2Y to increase the speed of upward translation
  // from page 3 to page 4
  double get page4Y => 2 * page2Y;

  Offset get offset {
    if (parent.page > 1.0 && parent.page <= 2.0)
      return Offset(0, parent._lerp(1.0, 2.0, page2Y, 0));
    else if (parent.page > 2.0 && parent.page <= 3.0)
      return Offset(0, parent._lerp(2.0, 3.0, 0, page4Y));
    return Offset(0, 0);
  }

  static const _zeroOpacity = AlwaysStoppedAnimation(0.0);

  Animation<double> get opacity {
    // Text only starts appearing when the page controller is 1.5
    if (parent.page > 1.5 && parent.page <= 2.0)
      return _page2To3Opacity;
    // Text disappears rapidly when the page controller is from 2.0 to 2.3
    else if (parent.page > 2.0 && parent.page <= 2.3) return _page3To4Opacity;
    return _zeroOpacity;
  }
}

class PageFourBottomSheetLayoutDetails {
  final OnboardingLayoutDetails _parent;
  final Animation<double> _page3To4TextOpacity, _page4To5TextOpacity;

  PageFourBottomSheetLayoutDetails(this._parent)
      : // Opacity changes from 0 to 1.0 as the pageController changes from 2.5 to 3.0
        _page3To4TextOpacity = _parent._lerpAnim(2.5, 3, 0, 1),
        // Opacity changes from 1.0 to 0 as the pageController changes from 3.0 to 3.3
        _page4To5TextOpacity = _parent._lerpAnim(3, 3.3, 1, 0);

  double get page4Y =>
      ((_parent.homePageScreenshot.width -
                  2 * _parent.homePageScreenshot.borderWidth) /
              HomePageScreenshotLayoutDetails.page4AspectRatio +
          _parent.homePageScreenshot.borderWidth) -
      ((_parent.homePageScreenshot.width -
                  2 * _parent.homePageScreenshot.borderWidth) /
              HomePageScreenshotLayoutDetails.bottomBarAspectRatio +
          _parent.homePageScreenshot.borderWidth);

  Offset get offset {
    // Initial y-coordinate is more than maxHeight in order to hide the shadow
    if (_parent.page <= 2.0)
      return Offset(0, _parent.maxHeight + 20);
    else if (_parent.page > 2.0 && _parent.page <= 3.0)
      return Offset(0, _parent._lerp(2.0, 3.0, _parent.maxHeight + 20, page4Y));
    // Material only moves when the pageController changes from 3.0 to 3.6
    else if (_parent.page > 3.0 && _parent.page <= 3.6)
      return Offset(0, _parent._lerp(3.0, 3.6, page4Y, _parent.maxHeight + 20));
    else if (_parent.page > 3.6 && _parent.page <= 4.0)
      return Offset(0, _parent.maxHeight + 20);
    return Offset(0, _parent.maxHeight + 20);
  }

  static const _zeroOpacity = AlwaysStoppedAnimation(0.0);

  Animation<double> get opacity {
    if (_parent.page > 2.5 && _parent.page <= 3.0)
      return _page3To4TextOpacity;
    else if (_parent.page > 3.0 && _parent.page <= 3.3)
      return _page4To5TextOpacity;
    return _zeroOpacity;
  }
}

class PageFiveTextLayoutDetails {
  final OnboardingLayoutDetails _parent;
  final Animation<double> _page4To5TextOpacity, _page5To6TextOpacity;

  PageFiveTextLayoutDetails(this._parent)
      : // Opacity changes from 0 to 1.0 as the pageController changes from 3.5 to 4.0
        _page4To5TextOpacity = _parent._lerpAnim(3.5, 4, 0, 1),
        // Opacity changes from 1.0 to 0 as the pageController changes from 4.0 to 4.3
        _page5To6TextOpacity = _parent._lerpAnim(4, 4.3, 1, 0);

  double get page5Y =>
      _parent.homePageScreenshot.page5Y + _parent.homePageScreenshot.height;

  double get containerHeight => _parent.maxHeight - page5Y;

  Offset get offset {
    if (_parent.page <= 3.0)
      return Offset(0, _parent.maxHeight);
    else if (_parent.page > 3.0 && _parent.page <= 4.0)
      return Offset(0, _parent._lerp(3.0, 4.0, _parent.maxHeight, page5Y));
    else if (_parent.page > 4.0 && _parent.page <= 4.6)
      return Offset(0, _parent._lerp(4.0, 4.6, page5Y, _parent.maxHeight));
    return Offset(0, _parent.maxHeight);
  }

  static const _zeroOpacity = AlwaysStoppedAnimation(0.0);

  Animation<double> get opacity {
    if (_parent.page > 3.5 && _parent.page <= 4.0)
      return _page4To5TextOpacity;
    else if (_parent.page > 4.0 && _parent.page <= 4.3)
      return _page5To6TextOpacity;
    return _zeroOpacity;
  }
}
