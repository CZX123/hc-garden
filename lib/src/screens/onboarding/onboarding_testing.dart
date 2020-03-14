import 'package:hc_garden/src/library.dart';

class OnboardingTestPage extends StatelessWidget {
  const OnboardingTestPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textList = ['one', 'two', 'three'];
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: <Widget>[
                    PageView(
                      children: <Widget>[
                        for (final t in textList)
                          Center(
                            child: Text(t),
                          ),
                      ],
                    ),
                    _OnboardingAnimationWidget(
                      maxHeight: constraints.maxHeight - topPadding,
                    ),
                  ],
                );
              },
            ),
          ),
          Material(
            color: Colors.purple.withOpacity(.2),
            child: SizedBox(
              height: 216,
              // height: 56,
              width: double.infinity,
            ),
          ),
          BottomPadding(),
        ],
      ),
    );
  }
}

class _OnboardingAnimationWidget extends StatelessWidget {
  final double maxHeight;
  const _OnboardingAnimationWidget({Key key, this.maxHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;

    final imageWidth = width * 0.85;
    final aspectRatio = 9 / 18.5;
    final imageHeight = (imageWidth - 12.0) / aspectRatio + 12.0;

    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.5,
              child: FractionallySizedBox(
                heightFactor: 0.19,
                child: Container(
                  color: Colors.green,
                ),
              ),
            ),
            Opacity(
              opacity: 0.5,
              child: Container(
                margin: EdgeInsets.only(top: 0.19 * maxHeight),
                height: 0.19 * maxHeight,
                color: Colors.red,
              ),
            ),
            OverflowBox(
              maxHeight: 50000,
              child: Center(
                child: Transform.scale(
                  scale: 0.62 * maxHeight / imageHeight,
                  child: Container(
                    alignment: Alignment.center,
                    child: HomePageScreenshot(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageScreenshot extends StatelessWidget {
  const HomePageScreenshot({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final layoutDetails = context.provide<OnboardingLayoutDetails>();
    final width = MediaQuery.of(context).size.width;
    return Material(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black.withOpacity(0.8),
          width: 6.0,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Container(
        width: width * 0.85,
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          "assets/images/screenshots/homepage.png",
        ),
      ),
    );
  }
}
