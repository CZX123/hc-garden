import 'package:hc_garden/src/library.dart';

class BreadcrumbNavigation extends StatefulWidget {
  const BreadcrumbNavigation({Key key}) : super(key: key);

  @override
  _BreadcrumbNavigationState createState() => _BreadcrumbNavigationState();
}

class _BreadcrumbNavigationState extends State<BreadcrumbNavigation> {
  int _previousRoutesLength;
  double _width;
  double _startPadding;

  double _getWidth(String text, [bool bold = true]) {
    if (text.length > 24) text = text.substring(0, 24) + '…';
    final TextSpan span = TextSpan(
      style: Theme.of(context).textTheme.subtitle.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
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
    return (_width - _getWidth(routes.last.name) - 120) / 2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    if (_width != width) {
      final appNotifier = Provider.of<AppNotifier>(context);
      _previousRoutesLength = appNotifier.routes.length;
      _width = width;
      _startPadding = (_width - _getWidth('Home', false) - 120) / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appNotifier = Provider.of<AppNotifier>(context);
    bool pushed = appNotifier.routes.length > _previousRoutesLength;
    _previousRoutesLength = appNotifier.routes.length;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60,
      ),
      child: CustomAnimatedSwitcher(
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear,
        transitionBuilder: (child, animation) {
          final offsetCurveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve: Curves.fastOutSlowIn.flipped,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Interval(.3, 1),
              reverseCurve: Interval(.65, 1),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final offsetTween = Tween<Offset>(
                  begin: Offset(
                    pushed ^ (animation.status == AnimationStatus.reverse)
                        ? 16
                        : -16,
                    0,
                  ),
                  end: Offset.zero,
                );
                return Transform.translate(
                  offset: offsetTween.evaluate(offsetCurveAnimation),
                  child: child,
                );
              },
              child: child,
            ),
          );
        },
        child: Stack(
          key: ValueKey(appNotifier.routes.join()),
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: _startPadding,
                  ),
                  Breadcrumb(
                    title: 'Home',
                    index: -1,
                    hasChevron: false,
                  ),
                  for (int i = 0; i < appNotifier.routes.length; i++)
                    Breadcrumb(
                      title: appNotifier.routes[i].name,
                      index: i,
                      active: i == appNotifier.routes.length - 1,
                    ),
                  SizedBox(
                    width: _getEndPadding(appNotifier.routes),
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
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  final String title;
  final int index;
  final bool hasChevron;
  final bool active;
  const Breadcrumb({
    Key key,
    @required this.title,
    @required this.index,
    this.hasChevron = true,
    this.active = false,
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
                child: Text(
                  _title,
                  style: Theme.of(context).textTheme.subtitle.copyWith(
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
                        color: Theme.of(context)
                            .textTheme
                            .subtitle
                            .color
                            .withOpacity(active ? 1 : .7),
                      ),
                ),
              ),
              onTap: () {
                context.provide<AppNotifier>(listen: false)
                    .popUntil(context, index);
                if (index < 0) {
                  final bottomSheetNotifier =
                      Provider.of<BottomSheetNotifier>(context, listen: false);
                  bottomSheetNotifier.animateTo(
                      bottomSheetNotifier.snappingPositions.value[1]);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
