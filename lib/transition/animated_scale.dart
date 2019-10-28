import 'package:flutter/material.dart';

class AnimatedScale extends ImplicitlyAnimatedWidget {
  final double scale;
  final double opacity;
  final Alignment alignment;
  final Widget child;
  AnimatedScale({
    Key key,
    @required this.scale,
    this.opacity = 1,
    this.alignment = Alignment.center,
    @required this.child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  })  : assert(scale != null),
        assert(opacity != null),
        assert(alignment != null),
        assert(child != null),
        super(key: key, duration: duration, curve: curve);

  @override
  AnimatedScaleState createState() => AnimatedScaleState();
}

class AnimatedScaleState extends ImplicitlyAnimatedWidgetState<AnimatedScale> {
  Tween<double> _scaleTween;
  Tween<double> _opacityTween;
  @override
  void forEachTween(TweenVisitor visitor) {
    _scaleTween = visitor(
      _scaleTween,
      widget.scale,
      (dynamic value) => Tween<double>(begin: value),
    );
    _opacityTween = visitor(
      _opacityTween,
      widget.opacity,
      (dynamic value) => Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleTween.animate(animation),
      alignment: widget.alignment,
      child: FadeTransition(
        opacity: _opacityTween.animate(animation),
        child: widget.child,
      ),
    );
  }
}
