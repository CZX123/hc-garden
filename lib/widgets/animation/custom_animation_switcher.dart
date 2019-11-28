import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Widget Function(Widget, Animation<double>) transitionBuilder;
  final bool crossShrink;
  final bool fadeIn;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  const CustomAnimatedSwitcher({
    Key key,
    @required this.child,
    this.transitionBuilder,
    this.crossShrink = true,
    this.fadeIn = false,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve,
    this.switchOutCurve,
  }) : super(key: key);

  static Widget layoutBuilder(
    Widget currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
      alignment: Alignment.center,
    );
  }

  Widget defaultTransitionBuilder(Widget child, Animation<double> animation) {
    final element = FadeTransition(
      opacity: animation,
      child: child,
    );
    if (crossShrink) {
      return ScaleTransition(
        scale: Tween<double>(begin: .97, end: 1).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
          reverseCurve: Threshold(0),
        )),
        child: element,
      );
    }
    return element;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: transitionBuilder ?? defaultTransitionBuilder,
      layoutBuilder: layoutBuilder,
      switchInCurve:
          switchInCurve ?? Interval(fadeIn ? .1 : .5, 1, curve: Curves.ease),
      switchOutCurve: switchOutCurve ??
          Interval(fadeIn ? .1 : .5, 1, curve: Curves.decelerate),
      duration: duration,
      child: child,
    );
  }
}
