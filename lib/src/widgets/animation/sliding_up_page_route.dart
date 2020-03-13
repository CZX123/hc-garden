import 'package:hc_garden/src/library.dart';

/// A page route that expands from a row in the previous screen into the new screen.
///
/// This is inspired from the parent-child hierarchical transition in material design:
/// https://material.io/design/navigation/navigation-transitions.html#hierarchical-transitions

class SlidingUpPageRoute<T> extends PageRoute<T> {
  /// Getter function for the top offset of the element in the previous screen
  final double Function() getSourceTop;

  /// Height of the element in the previous screen, i.e. the "source"
  final double sourceHeight;

  /// Change in the content offset when transition from previous to next screen
  /// i.e. change in position of the [Hero] in both screens relative to
  /// top of source in previous screen, and top of screen in next screen.
  /// In the case of this app, it is usually is around the value of `topPadding`.
  final double Function() getContentOffset;

  final WidgetBuilder builder;

  SlidingUpPageRoute({
    @required this.getSourceTop,
    @required this.sourceHeight,
    @required this.getContentOffset,
    @required this.builder,
    this.transitionDuration = const Duration(milliseconds: 340),
    this.opaque = false,
  });

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
    return SlidingUpPageRouteTransition(
      getSourceTop: getSourceTop,
      sourceHeight: sourceHeight,
      getContentOffset: getContentOffset,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  final bool opaque;

  @override
  final Duration transitionDuration;
}

class SlidingUpPageRouteTransition extends StatelessWidget {
  final double Function() getSourceTop;
  final double sourceHeight;
  final double Function() getContentOffset;
  final Animation animation;
  final Animation secondaryAnimation;
  final Widget child;
  const SlidingUpPageRouteTransition({
    Key key,
    @required this.getSourceTop,
    @required this.sourceHeight,
    @required this.getContentOffset,
    @required this.animation,
    @required this.secondaryAnimation,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    // fast out slow in curve
    final Animation<double> positionAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastOutSlowIn,
      // reverseCurve: Curves.fastOutSlowIn.flipped,
    );

    // position of the entire page, animated from source
    final Animation<RelativeRect> itemPosition = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
        0,
        getSourceTop() ?? 500,
        0,
        height - (getSourceTop() ?? 500) - sourceHeight,
      ),
      end: RelativeRect.fill,
    ).animate(positionAnimation);

    // opacity of the material background
    final Animation<double> fadeMaterialBackground = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.4, curve: Curves.ease),
    );

    // offset of the content within the page, to account for top padding
    final Animation<Offset> contentOffsetAnim = Tween<Offset>(
      // begin: Offset(0, -topPadding - 8),
      begin: Offset(0, -getContentOffset()),
      end: Offset.zero,
    ).animate(positionAnimation);

    final Animation<double> contentFade = Tween(
      begin: -1.0,
      end: 1.0,
    ).animate(positionAnimation);

    final Animation<double> contentFadeSecondary = Tween(
      begin: 1.0,
      end: -1.0,
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.ease));

    return Stack(
      children: <Widget>[
        PositionedTransition(
          rect: itemPosition,
          child: FadeTransition(
            opacity: getSourceTop() == null
                ? contentFade
                : AlwaysStoppedAnimation(1),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minHeight: height,
                maxHeight: height,
                child: AnimatedBuilder(
                  animation: contentOffsetAnim,
                  child: FadeTransition(
                    opacity: fadeMaterialBackground,
                    child: Material(
                      color: Theme.of(context).bottomAppBarColor,
                      elevation: 2,
                      child: FadeTransition(
                        opacity: contentFade,
                        child: FadeTransition(
                          opacity: contentFadeSecondary,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: contentOffsetAnim.value,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
