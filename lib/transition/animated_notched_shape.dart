import '../library.dart';

class AnimatedNotchedShape extends ImplicitlyAnimatedWidget {
  final double elevation;
  final Color color;
  final double notchMargin;
  final double fabRadius;
  final Widget child;
  AnimatedNotchedShape({
    Key key,
    this.elevation,
    this.color,
    this.notchMargin,
    @required this.fabRadius,
    @required this.child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) : super(key: key, duration: duration, curve: curve);

  @override
  AnimatedNotchedShapeState createState() => AnimatedNotchedShapeState();
}

class AnimatedNotchedShapeState
    extends ImplicitlyAnimatedWidgetState<AnimatedNotchedShape> {
  Tween<double> _radiusTween;
  Tween<double> _marginTween;
  @override
  void forEachTween(TweenVisitor visitor) {
    _radiusTween = visitor(
      _radiusTween,
      widget.fabRadius,
      (dynamic value) => Tween<double>(begin: value),
    );
    if (widget.notchMargin != null) _marginTween = visitor(
      _marginTween,
      widget.notchMargin,
      (dynamic value) => Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return PhysicalShape(
          color: widget.color,
          elevation: widget.elevation,
          clipper: BottomAppBarClipper(
            windowWidth: width,
            notchMargin: _marginTween?.evaluate(animation) ?? 4,
            radius: _radiusTween.evaluate(animation),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
