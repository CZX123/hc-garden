import 'package:flutter/material.dart';

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

// The clipper for clipping the bottom app bar for the notched search fab
class BottomAppBarClipper extends CustomClipper<Path> {
  final double windowWidth;
  final double notchMargin;
  final double radius;
  const BottomAppBarClipper({
    @required this.windowWidth,
    this.notchMargin = 4,
    this.radius = 28,
  })  : assert(windowWidth != null),
        assert(notchMargin != null),
        assert(radius != null);

  @override
  Path getClip(Size size) {
    final Rect button = Rect.fromCircle(
      center: Offset(windowWidth / 2, 0),
      radius: radius,
    );
    return CircularNotchedRectangle()
        .getOuterPath(Offset.zero & size, button.inflate(radius == 0 ? 0 : notchMargin));
  }

  @override
  bool shouldReclip(BottomAppBarClipper oldClipper) {
    return oldClipper.windowWidth != windowWidth ||
        oldClipper.notchMargin != notchMargin ||
        oldClipper.radius != radius;
  }
}
