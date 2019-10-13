import 'package:flutter/material.dart';

class ExpandPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final GlobalKey sourceKey;
  final Widget oldChild;
  final Widget persistentOldChild;

  ExpandPageRoute({
    @required this.builder,
    this.transitionDuration = const Duration(milliseconds: 360),
    @required this.sourceKey,
    this.oldChild,
    this.persistentOldChild,
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

  Rect _sourceRect;
  Widget _oldChild;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_sourceRect == null) {
      final RenderBox box = sourceKey.currentContext.findRenderObject();
      _sourceRect = box.localToGlobal(Offset.zero) & box.size;
    }
    _oldChild = oldChild;
    if (_oldChild == null) {
      _oldChild = sourceKey.currentWidget;
      if (_oldChild is ListTile) {
        final widget = _oldChild as ListTile;
        _oldChild = Material(
          type: MaterialType.transparency,
          child: ListTile(
            onTap: () => null,
            trailing: widget.trailing,
            title: widget.title,
            contentPadding: widget.contentPadding,
            isThreeLine: widget.isThreeLine,
            subtitle: widget.subtitle,
            leading: widget.leading,
            dense: widget.dense,
            enabled: widget.enabled,
            onLongPress: () => null,
            selected: widget.selected,
          ),
        );
      } else if (_oldChild is Container) {
        final widget = _oldChild as Container;
        _oldChild = Container(
          alignment: widget.alignment,
          padding: widget.padding,
          decoration: widget.decoration,
          foregroundDecoration: widget.foregroundDecoration,
          width: _sourceRect.width,
          height: _sourceRect.height,
          constraints: widget.constraints,
          margin: widget.margin,
          transform: widget.transform,
          child: widget.child,
        );
      }
    }
    return ExpandItemPageTransition(
      sourceKey: sourceKey,
      sourceRect: _sourceRect,
      oldChild: _oldChild,
      persistentOldChild: persistentOldChild,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;
}

// Borrowed from https://github.com/flschweiger/reply
class ExpandItemPageTransition extends StatelessWidget {
  const ExpandItemPageTransition({
    Key key,
    @required this.sourceKey,
    @required this.sourceRect,
    @required this.oldChild,
    this.persistentOldChild,
    @required this.animation,
    @required this.secondaryAnimation,
    @required this.child,
  }) : super(key: key);

  final GlobalKey sourceKey;
  final Rect sourceRect;
  final Widget oldChild;
  final Widget persistentOldChild;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = ModalRoute.of(context).animation;
    final double topPadding = MediaQuery.of(context).padding.top;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Animation<double> positionAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        final Animation<RelativeRect> itemPosition = RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            0,
            sourceRect.top,
            0,
            constraints.biggest.height - sourceRect.bottom,
          ),
          end: RelativeRect.fill,
        ).animate(positionAnimation);

        final Animation<double> fadeMaterialBackground = CurvedAnimation(
          parent: animation,
          curve: const Interval(0, .2, curve: Curves.ease),
        );

        final Animation<double> fadeOldContent = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0, .3, curve: Curves.ease),
          ),
        );

        //final double distanceToAvatar = topPadding + _calculateHeaderHeight(context, title) - 16;
        final topDistance = topPadding - 2;
        //final topDistance = 270.0;

        final Animation<Offset> contentOffset = Tween<Offset>(
          begin: Offset(0, -topDistance),
          end: Offset.zero,
        ).animate(positionAnimation);

        final Animation<Offset> oldChildOffset = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(0, topDistance),
        ).animate(positionAnimation);

        final Animation<double> fadeContent = CurvedAnimation(
          parent: animation,
          curve: const Interval(.1, .8, curve: Curves.ease),
        );

        return Stack(
          children: <Widget>[
            PositionedTransition(
              rect: itemPosition,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: contentOffset,
                        child: Material(
                          elevation: 8,
                          child: FadeTransition(
                            opacity: fadeContent,
                            child: child,
                          ),
                        ),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: contentOffset.value,
                            child: child,
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: oldChildOffset,
                            child: FadeTransition(
                              opacity: fadeOldContent,
                              child: oldChild,
                            ),
                            builder: (context, child) {
                              return Transform.translate(
                                offset: oldChildOffset.value,
                                child: child,
                              );
                            },
                          ),
                        ),
                      ),
                      if (persistentOldChild != null) Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: oldChildOffset,
                            child: persistentOldChild,
                            builder: (context, child) {
                              if (oldChildOffset.value.dy == topDistance) return SizedBox.shrink();
                              return Transform.translate(
                                offset: oldChildOffset.value,
                                child: child,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
