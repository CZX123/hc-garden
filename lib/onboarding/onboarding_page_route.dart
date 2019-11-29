import '../library.dart';

class OnboardingPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Color _barrierColor;
  final String _barrierLabel;
  final bool _opaque;
  @override
  final Duration transitionDuration;

  OnboardingPageRoute({
    @required this.builder,
    this.transitionDuration = const Duration(milliseconds: 250),
    Color barrierColor = Colors.black45,
    String barrierLabel,
    bool opaque = false,
    RouteSettings settings,
  })  : assert(builder != null),
        assert(transitionDuration != null),
        _barrierColor = barrierColor,
        _barrierLabel = barrierLabel,
        _opaque = opaque,
        super(settings: settings);

  @override
  bool get opaque => _opaque;

  @override
  Color get barrierColor => _barrierColor;

  @override
  String get barrierLabel => _barrierLabel;

  @override
  bool get maintainState => false;

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) => false;

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
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: .7,
          end: 1,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastLinearToSlowEaseIn,
        )),
        child: child,
      ),
    );
  }
}
