import 'package:bottom_sheet/library.dart';

class FadeOutPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  FadeOutPageRoute({
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
    return FadeOutTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;
}

// Borrowed from https://github.com/flschweiger/reply
class FadeOutTransition extends StatelessWidget {
  const FadeOutTransition({
    Key key,
    @required this.animation,
    @required this.secondaryAnimation,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {

    final Animation<double> opacityOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(secondaryAnimation);

    return Material(
      child: FadeTransition(
        opacity: animation,
        child: FadeTransition(
          opacity: opacityOut,
          child: child,
        ),
      ),
    );
  }
}
