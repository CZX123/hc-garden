import '../../library.dart';
import 'dart:ui' as ui;

class SlidingUpPageRoute<T> extends PageRoute<T> {
  final double Function() getSourceTop;
  final double sourceHeight;
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
    );

    // position of the entire page, animated from source
    final Animation<RelativeRect> itemPosition = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
        0,
        getSourceTop(),
        0,
        height - getSourceTop() - sourceHeight,
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
      ],
    );
  }
}

class FastOutSlowInRectTween extends RectTween {
  bool _inverse = false;

  FastOutSlowInRectTween({
    Rect begin,
    Rect end,
  }) : super(begin: begin, end: end);

  FastOutSlowInRectTween.inverse({
    Rect begin,
    Rect end,
  })  : _inverse = true,
        super(begin: begin, end: end);

  @override
  set begin(Rect value) {
    if (value != begin) super.begin = value;
  }

  @override
  set end(Rect value) {
    if (value != end) super.end = value;
  }

  @override
  Rect lerp(double t) {
    if (t == 0.0) return begin;
    if (t == 1.0) return end;
    if (_inverse) {
      return Rect.fromPoints(
        InverseMaterialPointArcTween(
          begin: begin.topLeft,
          end: end.topLeft,
        ).transform(t),
        InverseMaterialPointArcTween(
          begin: begin.bottomRight,
          end: end.bottomRight,
        ).transform(t),
      );
    }
    return Rect.fromPoints(
      MaterialPointArcTween(
        begin: begin.topLeft,
        end: end.topLeft,
      ).transform(t),
      MaterialPointArcTween(
        begin: begin.bottomRight,
        end: end.bottomRight,
      ).transform(t),
    );
  }

  @override
  String toString() {
    return '$runtimeType($begin: $begin, $end: $end)';
  }
}

// How close the begin and end points must be to an axis to be considered
// vertical or horizontal.
const double _kOnAxisDelta = 2.0;

class InverseMaterialPointArcTween extends Tween<Offset> {
  /// Creates a [Tween] for animating [Offset]s along a circular arc.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  InverseMaterialPointArcTween({
    Offset begin,
    Offset end,
  }) : super(begin: begin, end: end);

  bool _dirty = true;

  void _initialize() {
    assert(begin != null);
    assert(end != null);

    // An explanation with a diagram can be found at https://goo.gl/vMSdRg
    final Offset delta = end - begin;
    final double deltaX = delta.dx.abs();
    final double deltaY = delta.dy.abs();
    final double distanceFromAtoB = delta.distance;
    final Offset c = Offset(end.dx, begin.dy);

    double sweepAngle() => 2.0 * asin(distanceFromAtoB / (2.0 * _radius));

    if (deltaX > _kOnAxisDelta && deltaY > _kOnAxisDelta) {
      if (deltaX < deltaY) {
        // _radius = distanceFromAtoB * distanceFromAtoB / (c - begin).distance / 2.0;
        _radius = 0;
        _center = Offset(begin.dx + _radius * (end.dx - begin.dx).sign, begin.dy);
        if (begin.dx > end.dx) {
          _beginAngle = sweepAngle() * (begin.dy - end.dy).sign;
          _endAngle = 0.0;
        } else {
          _beginAngle = pi + sweepAngle() * (end.dy - begin.dy).sign;
          _endAngle = pi;
        }
      } else {
        // _radius = distanceFromAtoB * distanceFromAtoB / (c - end).distance / 2.0;
        _radius = 0;
        _center = Offset(end.dx, end.dy + (begin.dy - end.dy).sign * _radius);
        if (begin.dy > end.dy) {
          _beginAngle = -pi / 2.0;
          _endAngle = _beginAngle + sweepAngle() * (end.dx - begin.dx).sign;
        } else {
          _beginAngle = pi / 2.0;
          _endAngle = _beginAngle + sweepAngle() * (begin.dx - end.dx).sign;
        }
      }
      assert(_beginAngle != null);
      assert(_endAngle != null);
    } else {
      _beginAngle = null;
      _endAngle = null;
    }
    _dirty = false;
  }

  /// The center of the circular arc, null if [begin] and [end] are horizontally or
  /// vertically aligned, or if either is null.
  Offset get center {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _center;
  }

  Offset _center;

  /// The radius of the circular arc, null if [begin] and [end] are horizontally or
  /// vertically aligned, or if either is null.
  double get radius {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _radius;
  }

  double _radius;

  /// The beginning of the arc's sweep in radians, measured from the positive x
  /// axis. Positive angles turn clockwise.
  ///
  /// This will be null if [begin] and [end] are horizontally or vertically
  /// aligned, or if either is null.
  double get beginAngle {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _beginAngle;
  }

  double _beginAngle;

  /// The end of the arc's sweep in radians, measured from the positive x axis.
  /// Positive angles turn clockwise.
  ///
  /// This will be null if [begin] and [end] are horizontally or vertically
  /// aligned, or if either is null.
  double get endAngle {
    if (begin == null || end == null) return null;
    if (_dirty) _initialize();
    return _beginAngle;
  }

  double _endAngle;

  @override
  set begin(Offset value) {
    if (value != begin) {
      super.begin = value;
      _dirty = true;
    }
  }

  @override
  set end(Offset value) {
    if (value != end) {
      super.end = value;
      _dirty = true;
    }
  }

  @override
  Offset lerp(double t) {
    if (_dirty) _initialize();
    if (t == 0.0) return begin;
    if (t == 1.0) return end;
    if (_beginAngle == null || _endAngle == null)
      return Offset.lerp(begin, end, t);
    final double angle = ui.lerpDouble(_beginAngle, _endAngle, t);
    final double x = cos(angle) * _radius;
    final double y = sin(angle) * _radius;
    return _center + Offset(x, y);
  }

  @override
  String toString() {
    return '$runtimeType($begin \u2192 $end; center=$center, radius=$radius, beginAngle=$beginAngle, endAngle=$endAngle)';
  }
}
