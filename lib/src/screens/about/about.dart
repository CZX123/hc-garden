import 'package:hc_garden/src/library.dart';

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
        child: Selector<FirebaseData, List<AboutPageData>>(
          selector: (context, firebaseData) => firebaseData.aboutPageDataList,
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
                        aboutPageDataObject[index].isExpanded = !isExpanded;
                      });
                    },
                    children: aboutPageDataObject.map((aboutPageData) {
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
                                  child: (aboutPageData.quote != null)
                                      ? Text(
                                          aboutPageData.quote,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : null,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    24,
                                    aboutPageData.quote != null ? 8 : 0,
                                    24,
                                    0,
                                  ),
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
                                if (aboutPageData.dropdowns != null)
                                  Column(
                                    children: <Widget>[
                                      for (final dropdown
                                          in aboutPageData.dropdowns)
                                        _DropdownWidget(dropdown: dropdown),
                                    ],
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

class _DropdownWidget extends StatefulWidget {
  final AboutPageDropdown dropdown;
  const _DropdownWidget({Key key, @required this.dropdown}) : super(key: key);

  @override
  __DropdownWidgetState createState() => __DropdownWidgetState();
}

class __DropdownWidgetState extends State<_DropdownWidget>
    with SingleTickerProviderStateMixin {
  bool _expand = false;

  @override
  Widget build(BuildContext context) {
    final rotation = _expand ? 0.0 : -pi / 2;
    final heightFactor = _expand ? 1.0 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                TweenAnimationBuilder(
                  tween: Tween(begin: rotation, end: rotation),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  builder: (context, rotation, child) {
                    return Transform.rotate(
                      angle: rotation,
                      child: child,
                    );
                  },
                  child: Icon(Icons.arrow_drop_down),
                ),
                Text(
                  widget.dropdown.title,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _expand = !_expand;
            });
          },
        ),
        ClipRect(
          child: TweenAnimationBuilder(
            tween: Tween(begin: heightFactor, end: heightFactor),
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            builder: (context, heightFactor, child) {
              return Align(
                heightFactor: heightFactor,
                alignment: Alignment.centerLeft,
                child: AnimatedOpacity(
                  opacity: _expand ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  curve: _expand
                      ? Interval(.6, 1, curve: Curves.ease)
                      : Interval(0, .2, curve: Curves.ease),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
              child: Text(
                widget.dropdown.body,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
