import '../library.dart';

class ExpandPageRoute<T> extends PageRoute<T> {
  final ValueNotifier<double> newTopPadding;
  final ValueNotifier<double> oldTopPadding;
  final WidgetBuilder builder;
  final GlobalKey sourceKey;
  final Widget oldChild;
  final Widget persistentOldChild;

  ExpandPageRoute({
    @required this.newTopPadding,
    @required this.oldTopPadding,
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
      oldTopPadding: oldTopPadding,
      newTopPadding: newTopPadding,
      sourceKey: sourceKey,
      sourceRect: _sourceRect,
      oldChild: _oldChild,
      persistentOldChild: persistentOldChild,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      transitionDuration: transitionDuration,
    );
  }

  @override
  bool get maintainState => true;
}

// Borrowed from https://github.com/flschweiger/reply
class ExpandItemPageTransition extends StatefulWidget {
  const ExpandItemPageTransition({
    Key key,
    @required this.newTopPadding,
    @required this.oldTopPadding,
    @required this.sourceKey,
    @required this.sourceRect,
    @required this.oldChild,
    this.persistentOldChild,
    @required this.animation,
    @required this.secondaryAnimation,
    @required this.child,
    this.transitionDuration,
  }) : super(key: key);

  final ValueNotifier<double> newTopPadding;
  final ValueNotifier<double> oldTopPadding;
  final GlobalKey sourceKey;
  final Rect sourceRect;
  final Widget oldChild;
  final Widget persistentOldChild;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final Duration transitionDuration;

  @override
  _ExpandItemPageTransitionState createState() =>
      _ExpandItemPageTransitionState();
}

class _ExpandItemPageTransitionState extends State<ExpandItemPageTransition> {

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = ModalRoute.of(context).animation;
    final topDistance = widget.newTopPadding.value - widget.oldTopPadding.value;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Animation<double> positionAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        final Animation<RelativeRect> itemPosition = RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            0,
            widget.sourceRect.top,
            0,
            constraints.biggest.height - widget.sourceRect.bottom,
          ),
          end: RelativeRect.fill,
        ).animate(positionAnimation);

        // final Animation<double> fadeMaterialBackground = CurvedAnimation(
        //   parent: animation,
        //   curve: const Interval(0, .2, curve: Curves.ease),
        // );

        final Animation<double> fadeOldContent = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0, .3, curve: Curves.ease),
          ),
        );

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
              child: Stack(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: contentOffset,
                    builder: (context, child) {
                      return Material(
                        elevation:
                            animation.status == AnimationStatus.reverse ||
                                    contentOffset.value.dy == -topDistance
                                ? 0
                                : 3,
                        animationDuration: widget.transitionDuration,
                        child: Transform.translate(
                          offset: contentOffset.value,
                          child: child,
                        ),
                      );
                    },
                    child: FadeTransition(
                      opacity: fadeContent,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.biggest.height,
                        ),
                        child: widget.child,
                      ),
                    ),
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
                          child: widget.oldChild,
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
                  if (widget.persistentOldChild != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: oldChildOffset,
                          child: widget.persistentOldChild,
                          builder: (context, child) {
                            if (oldChildOffset.value.dy == topDistance)
                              return SizedBox.shrink();
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
          ],
        );
      },
    );
  }
}
