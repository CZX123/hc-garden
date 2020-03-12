import 'package:hc_garden/src/library.dart';

/// A simple cross-fade animation between 2 screens, with some subtle scaling.
///
/// This is inspired from the top-level peer transition in material design:
/// https://material.io/design/navigation/navigation-transitions.html#peer-transitions

class CrossFadePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  @override
  final Duration transitionDuration;

  CrossFadePageRoute({
    @required this.builder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = false,
    RouteSettings settings,
  })  : assert(builder != null),
        assert(transitionDuration != null),
        super(settings: settings);

  @override
  final bool opaque;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

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
    return CrossFadeTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class CrossFadeTransition extends StatelessWidget {
  const CrossFadeTransition({
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
    final Animation<double> scaleIn = Tween(
      begin: .94,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
    ));
    final Animation<double> opacityIn = Tween(
      begin: -1.0,
      end: 1.0,
    ).animate(animation);

    return ValueListenableBuilder(
      valueListenable: secondaryAnimation,
      builder: (context, value, child) {
        return Visibility(
          visible: value < 1,
          maintainState: true,
          child: child,
        );
      },
      child: ScaleTransition(
        scale: scaleIn,
        child: FadeTransition(
          opacity: opacityIn,
          child: FadeTransition(
            opacity: Tween(
              begin: 1.0,
              end: -1.0,
            ).animate(secondaryAnimation),
            child: child,
          ),
        ),
      ),
    );
  }
}
