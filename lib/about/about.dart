import '../library.dart';

// Needed for the selector to correctly compare between 2 different lists of about page data
class AboutPageDataObject {
  final List<AboutPageData> value;
  const AboutPageDataObject(this.value);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AboutPageDataObject && listEquals(value, other.value);
  }

  @override
  int get hashCode => hashList(value);
}

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topExtent = topPadding + 96;
    final scale = Tween<double>(
      begin: 1,
      end: .8,
    ).animate(_animationController);
    final opacity = Tween<double>(
      begin: 2,
      end: 0,
    ).animate(_animationController);
    return AnnotatedRegion(
      value: (isDark
              ? ThemeNotifier.darkOverlayStyle
              : ThemeNotifier.lightOverlayStyle)
          .copyWith(
        statusBarColor: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(isDark ? .5 : .8),
        systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
      ),
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels < topExtent) {
              _animationController.value =
                  notification.metrics.pixels / topExtent;
            } else if (_animationController.value != 1) {
              _animationController.value = 1;
            }
          }
          return false;
        },
        child: Selector<FirebaseData, AboutPageDataObject>(
          selector: (context, firebaseData) =>
              AboutPageDataObject(firebaseData.aboutPageDataList),
          builder: (context, aboutPageDataObject, child) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(0, topPadding, 0, 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 96, 16, 16),
                    child: ScaleTransition(
                      scale: scale,
                      child: FadeTransition(
                        opacity: opacity,
                        child: Text(
                          'About',
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return AnnotatedRegion(
                  value: (isDark
                          ? ThemeNotifier.darkOverlayStyle
                          : ThemeNotifier.lightOverlayStyle)
                      .copyWith(
                    statusBarColor: Theme.of(context)
                        .canvasColor
                        .withOpacity(isDark ? .5 : .8),
                    systemNavigationBarColor:
                        Theme.of(context).bottomAppBarColor,
                  ),
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        aboutPageDataObject.value[index].isExpanded =
                            !isExpanded;
                      });
                    },
                    children: aboutPageDataObject.value.map((aboutPageData) {
                      final List<String> bodyStrings =
                          aboutPageData.body.split('\n');
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 24),
                            child: Text(
                              aboutPageData.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        body: Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 8),
                                  child: Text(
                                    aboutPageData.quote,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 8, 24, 0),
                                  child: Column(
                                    children: <Widget>[
                                      for (var bodyString in bodyStrings)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: Text(
                                            bodyString,
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                            textAlign: aboutPageData.title ==
                                                    'References'
                                                ? TextAlign.left
                                                : TextAlign.justify,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        isExpanded: aboutPageData.isExpanded,
                      );
                    }).toList(),
                  ),
                );
              },
              itemCount: 2,
            );
          },
        ),
      ),
    );
  }
}
