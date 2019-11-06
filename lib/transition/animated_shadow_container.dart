import 'package:flutter/material.dart';

class AnimatedShadowContainer extends ImplicitlyAnimatedWidget {
  final Color color;
  final BorderRadius borderRadius;
  final List<BoxShadow> boxShadow;
  final Widget child;
  AnimatedShadowContainer({
    Key key,
    this.color,
    this.borderRadius,
    @required this.boxShadow,
    @required this.child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) : super(key: key, duration: duration, curve: curve);

  @override
  _AnimatedShadowContainerState createState() =>
      _AnimatedShadowContainerState();
}

class _AnimatedShadowContainerState
    extends ImplicitlyAnimatedWidgetState<AnimatedShadowContainer> {
  List<BoxShadow> _oldShadows;
  List<BoxShadow> _shadows;

  @override
  void forEachTween(TweenVisitor visitor) {
    _oldShadows = widget.boxShadow;
    _shadows = widget.boxShadow;
    print(_shadows);
  }

  @override
  void didUpdateWidget(AnimatedShadowContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _oldShadows = oldWidget.boxShadow;
    _shadows = widget.boxShadow;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: animation,
      builder: (context, value, child) {
        print(value);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
            boxShadow: BoxShadow.lerpList(
              _oldShadows,
              _shadows,
              value,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
