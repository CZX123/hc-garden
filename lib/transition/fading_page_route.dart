import '../library.dart';

class FadingPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  FadingPageRoute({
    @required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    RouteSettings settings,
  })  : assert(builder != null),
        assert(transitionDuration != null),
        super(settings: settings);

  @override
  final Duration transitionDuration;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Builder(builder: builder);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0)
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: child,
    );
  }

  @override
  bool get maintainState => true;
}
