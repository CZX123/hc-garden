import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final bool crossShrink;
  final Duration duration;
  const CustomAnimatedSwitcher({
    Key key,
    @required this.child,
    this.crossShrink = true,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  static Widget layoutBuilder(
    Widget currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      children: <Widget>[
        ...previousChildren.map((child) {
          return IgnorePointer(
            child: child,
          );
        }).toList(),
        if (currentChild != null) currentChild,
      ],
      alignment: Alignment.center,
    );
  }

  Widget transitionBuilder(Widget child, Animation<double> animation) {
    final element = FadeTransition(
      opacity: animation,
      child: child,
    );
    if (crossShrink) {
      return ScaleTransition(
        scale: Tween<double>(begin: .97, end: 1).animate(animation),
        child: element,
      );
    }
    return element;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      switchInCurve: Interval(crossShrink ? .5 : .1, 1, curve: Curves.ease),
      switchOutCurve:
          Interval(crossShrink ? .5 : .1, 1, curve: Curves.decelerate),
      duration: duration,
      child: child,
    );
  }
}
