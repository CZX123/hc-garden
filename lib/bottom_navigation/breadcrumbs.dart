import '../library.dart';

class BreadcrumbNavigation extends StatefulWidget {
  const BreadcrumbNavigation({Key key}) : super(key: key);
  static const duration = Duration(milliseconds: 340);
  static Widget removeItemBuilder(
    BuildContext context,
    Animation<double> animation,
    String name,
  ) {
    return SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: CurvedAnimation(
        curve: Interval(0, .8, curve: Curves.fastOutSlowIn),
        parent: animation,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          curve: Interval(.7, 1),
          parent: animation,
        ),
        child: Breadcrumb(
          title: name,
          index: null,
        ),
      ),
    );
  }

  @override
  _BreadcrumbNavigationState createState() => _BreadcrumbNavigationState();
}

class _BreadcrumbNavigationState extends State<BreadcrumbNavigation> {
  /// [Duration] of breadcrumb addition and removal animation
  double _width;
  double _startPadding;

  double _getWidth(String text) {
    if (text.length > 24) text = text.substring(0, 24) + '…';
    final TextSpan span = TextSpan(
      style: Theme.of(context).textTheme.subtitle,
      text: text,
    );
    final TextPainter painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + 16;
  }

  double _getEndPadding(List<RouteInfo> routes) {
    if (routes.isEmpty) return _startPadding;
    return (_width - _getWidth(routes.last.name) - 128) / 2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    if (_width != width) {
      _width = width;
      _startPadding = (_width - _getWidth('Home') - 128) / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 64,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            controller: appNotifier.animatedListScrollController,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: _startPadding,
                ),
                AnimatedList(
                  key: appNotifier.animatedListKey,
                  initialItemCount: appNotifier.routes.length + 1,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemBuilder: (context, index, animation) {
                    if (index == appNotifier.routes.length) {
                      return Breadcrumb(
                        title: 'Home',
                        index: -1,
                        hasChevron: false,
                      );
                    }
                    return SizeTransition(
                      axis: Axis.horizontal,
                      sizeFactor: CurvedAnimation(
                        curve: Interval(0, .8, curve: Curves.fastOutSlowIn),
                        parent: animation,
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          curve: Interval(.7, 1),
                          parent: animation,
                        ),
                        child: Breadcrumb(
                          title: appNotifier
                              .routes[appNotifier.routes.length - index - 1]
                              .name,
                          index: appNotifier.routes.length - index - 1,
                        ),
                      ),
                    );
                  },
                ),
                Consumer<AppNotifier>(
                  builder: (context, appNotifier, child) {
                    return AnimatedContainer(
                      duration: BreadcrumbNavigation.duration,
                      curve: appNotifier.justPopped
                          ? Interval(.2, 1, curve: Curves.fastOutSlowIn)
                          : Interval(0, .8, curve: Curves.fastOutSlowIn),
                      width: _getEndPadding(appNotifier.routes),
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GradientWidget(
              color: Theme.of(context).bottomAppBarColor,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GradientWidget(
              color: Theme.of(context).bottomAppBarColor,
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  final String title;
  final int index;
  final bool hasChevron;
  const Breadcrumb({
    Key key,
    @required this.title,
    @required this.index,
    this.hasChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _title = title;
    if (title.length > 24) _title = title.substring(0, 24) + '…';
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (hasChevron)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right,
              color: Theme.of(context).hintColor,
            ),
          ),
        Align(
          alignment: Alignment.center,
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child:
                    Text(_title, style: Theme.of(context).textTheme.subtitle),
              ),
              onTap: () {
                Provider.of<AppNotifier>(context, listen: false)
                    .popUntil(context, index);
              },
            ),
          ),
        ),
      ],
    );
  }
}
