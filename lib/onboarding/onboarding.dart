import '../library.dart';

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
              child: Stack(
                children: <Widget>[
                  PageView.builder(
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return OnboardingPageOne();
                      else if (index == 1) return OnboardingPageTwo();
                      return Center(
                        child: Text(index.toString()),
                      );
                    },
                    itemCount: 3,
                  ),
                  OnboardingAnimationWidget(
                    pageController: _pageController,
                  ),
                ],
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

class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.asset(
            'assets/images/app_logo/default.png',
            height: 108,
          ),
          Text(
            'Welcome to\nHC Garden!',
            style: Theme.of(context).textTheme.display2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
          ),
          Text('HC Garden is an amazing app!'),
        ],
      ),
    );
  }
}

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.7),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
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
    );
  }
}

class OnboardingAnimationWidget extends StatefulWidget {
  final PageController pageController;
  const OnboardingAnimationWidget({Key key, @required this.pageController})
      : super(key: key);

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
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height - topPadding - 45;
    final page = widget.pageController.page ?? 0.0;
    final scale = page;
    final Widget homePageImage = Container(
      height: 200,
      // width: 200,
      color: Colors.green,
    );
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(screenWidth - screenWidth * page, 180),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: homePageImage,
                ),
              ),
            ),
            // Transform.translate(
            //   offset: Offset(0, 200),
            //   child: Transform.scale(scale: scale, child: homePageImage),
            // ),
          ],
        ),
      ),
    );
  }
}
