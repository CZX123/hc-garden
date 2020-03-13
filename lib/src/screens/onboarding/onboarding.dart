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
            SizedBox(height: topPadding),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                //print(MediaQuery.of(context).size.height);
                //print(constraints.maxHeight);
                return Stack(
                  children: <Widget>[
                    PageView.builder(
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        if (index == 0)
                          return _OnboardingPageOne();
                        else if (index == 1) return _OnboardingPageTwo();
                        else if (index == 2) return _OnboardingPageThree(
                          height: constraints.maxHeight,
                        );
                        return Center(
                          child: Text(index.toString()),
                        );
                      },
                      itemCount: 4,
                    ),
                    OnboardingAnimationWidget(
                      pageController: _pageController,
                      height: constraints.maxHeight,
                    ),
                  ],
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
                          duration: const Duration(milliseconds: 280),
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
          Text('Swipe right to learn more!! ->->'),
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

class _OnboardingPageThree extends StatelessWidget {
  final double height;
  const _OnboardingPageThree({Key key, @required this.height}) : super(key: key);

  static const borderWidth = 6.0;
  static const mapAspectRatio =
      (1440.0 + 2 * borderWidth) / (1523.0 + borderWidth);
    static const imageWidthRatio = 0.85;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = height - (imageWidthRatio * screenWidth + 2 * borderWidth) / mapAspectRatio;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          alignment: Alignment(0, 0.5),
          height: containerHeight,
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

class OnboardingAnimationWidget extends StatefulWidget {
  final PageController pageController;
  final double height;
  
  const OnboardingAnimationWidget({
    Key key,
    @required this.pageController,
    @required this.height,
  }) : super(key: key);

  @override
  _OnboardingAnimationWidgetState createState() =>
      _OnboardingAnimationWidgetState();
}

class _OnboardingAnimationWidgetState extends State<OnboardingAnimationWidget> {
  void listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(listener);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final page = widget.pageController.page ?? 0.0;
    return Positioned.fill(
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            children: <Widget>[
              Transform.translate(
                offset: HomePageImage.getImageOffset(
                  page: page,
                  screenWidth: screenWidth,
                  screenHeight: widget.height,
                ),
                child: Transform.scale(
                  alignment: Alignment.topCenter,
                  scale: HomePageImage.getImageScale(
                    page: page,
                    screenWidth: screenWidth,
                    screenHeight: widget.height,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: HomePageImage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageImage extends StatelessWidget {
  const HomePageImage({Key key}) : super(key: key);

  static const borderWidth = 6.0;
  static const aspectRatio =
      (1440.0 + 2 * borderWidth) / (2960.0 + 2 * borderWidth);
  static const mapAspectRatio =
      (1440.0 + 2 * borderWidth) / (1523.0 + borderWidth);
  static const imageWidthRatio = 0.85;

  static Offset getImageOffset(
      {double page, double screenWidth, double screenHeight}) {
    // 0.19 is the height ratio of the text and 0.04 is the height ratio
    // of the padding between the text and screenshot
    if (page <= 1)
      return Offset(screenWidth - screenWidth * page,
          0.19 * screenHeight + 0.04 * screenHeight);
    // mapAspectRatio is the aspect ratio of the map portion of the image
    else if (page > 1 && page <= 2)
      return Offset(
          0,
          0.23 * screenHeight +
              (page - 1) *
                  ((screenHeight -
                          ((imageWidthRatio * screenWidth + 2 * borderWidth) /
                              mapAspectRatio)) -
                      0.23 * screenHeight));
  }

  static double getImageScale(
      {double page, double screenWidth, double screenHeight}) {
    // 0.73 is the height ratio of the screenshot
    final smallScaleRatio = 0.73 *
        screenHeight /
        ((imageWidthRatio * screenWidth + 2 * borderWidth) / aspectRatio);
    if (page <= 1)
      return smallScaleRatio;
    else if (page > 1 && page <= 2)
      return 1.0 - (1.0 - smallScaleRatio) * (1 - (page - 1));
    else if (page > 2 && page <= 3) return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final key = GlobalKey();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print(key.currentContext.size.width);
    // });
    // print(screenWidth);
    return Material(
      elevation: 4,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black.withOpacity(0.78),
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          width: imageWidthRatio * screenWidth + 2 * borderWidth,
          padding: const EdgeInsets.all(borderWidth),
          child: Image.asset(
            "assets/images/screenshots/homepage.png",
          // key: key,
          ),
        ));
  }
}
