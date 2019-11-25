import '../../library.dart';

class ExpandPageRoute<T> extends PageRoute<T> {
  final ValueNotifier<Offset> startContentOffset;
  final ValueNotifier<Offset> endContentOffset;
  final WidgetBuilder builder;
  final Rect sourceRect;
  final Widget oldChild;
  final Widget persistentOldChild;
  final double rowOffset;
  final ScrollController oldScrollController;
  final ValueListenable<double> topSpace;
  final bool isOpaque;

  ExpandPageRoute({
    @required this.builder,
    @required this.sourceRect,
    this.oldChild,
    this.persistentOldChild,
    @required this.startContentOffset,
    @required this.endContentOffset,
    this.transitionDuration = const Duration(milliseconds: 360),
    @required this.rowOffset,
    @required this.oldScrollController,
    @required this.topSpace,
    this.isOpaque = false,
    RouteSettings settings,
  })  : assert(builder != null),
        assert(transitionDuration != null),
        super(settings: settings);

  @override
  final Duration transitionDuration;

  @override
  bool get opaque => isOpaque;

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

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ExpandItemPageTransition(
      sourceRect: sourceRect,
      oldChild: oldChild,
      persistentOldChild: persistentOldChild,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      startContentOffset: startContentOffset,
      endContentOffset: endContentOffset,
      transitionDuration: transitionDuration,
      rowOffset: rowOffset,
      oldScrollController: oldScrollController,
      topSpace: topSpace,
    );
  }

  @override
  bool get maintainState => true;
}

class ExpandItemPageTransition extends StatefulWidget {
  const ExpandItemPageTransition({
    Key key,
    this.sourceRect,
    this.oldChild,
    this.persistentOldChild,
    this.animation,
    this.secondaryAnimation,
    this.child,
    this.startContentOffset,
    this.endContentOffset,
    this.transitionDuration,
    this.rowOffset,
    this.oldScrollController,
    this.topSpace,
  }) : super(key: key);

  final ValueNotifier<Offset> startContentOffset;
  final ValueNotifier<Offset> endContentOffset;
  final Rect sourceRect;
  final Widget oldChild;
  final Widget persistentOldChild;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final Duration transitionDuration;
  final double rowOffset;
  final ScrollController oldScrollController;
  final ValueListenable<double> topSpace;

  @override
  _ExpandItemPageTransitionState createState() =>
      _ExpandItemPageTransitionState();
}

class _ExpandItemPageTransitionState extends State<ExpandItemPageTransition> {
  @override
  Widget build(BuildContext context) {
    final animation = widget.animation;
    final secondaryAnimation = widget.secondaryAnimation;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.biggest.height;
        final width = constraints.biggest.width;

        final positionAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        );

        final itemPosition = RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            widget.sourceRect.left,
            widget.rowOffset -
                widget.oldScrollController.offset +
                widget.topSpace.value,
            width - widget.sourceRect.right,
            height -
                (widget.rowOffset -
                    widget.oldScrollController.offset +
                    widget.topSpace.value) -
                widget.sourceRect.height,
          ),
          end: RelativeRect.fill,
        ).animate(positionAnimation);

        final fadeOldContent = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0, .3, curve: Curves.ease),
          ),
        );

        final contentOffset = Tween<Offset>(
          begin:
              widget.startContentOffset.value - widget.endContentOffset.value,
          end: Offset.zero,
        ).animate(positionAnimation);

        // final contentPosition = RelativeRectTween(
        //   begin: RelativeRect.fromLTRB(
        //     widget.startContentOffset.value.dx -
        //         widget.endContentOffset.value.dx,
        //     widget.startContentOffset.value.dy -
        //         widget.endContentOffset.value.dy,
        //     RelativeRect.fill.right,
        //     RelativeRect.fill.bottom,
        //   ),
        //   end: RelativeRect.fill,
        // ).animate(positionAnimation);

        final oldChildOffset = Tween<Offset>(
          begin: Offset.zero,
          end: widget.endContentOffset.value - widget.startContentOffset.value,
        ).animate(positionAnimation);

        final fadeContent = CurvedAnimation(
          parent: animation,
          curve: const Interval(.1, .8, curve: Curves.ease),
        );

        final fadeMaterial = CurvedAnimation(
          parent: animation,
          curve: const Interval(0, .4, curve: Curves.ease),
        );

        return ValueListenableBuilder(
          valueListenable: secondaryAnimation,
          builder: (context, value, child) {
            return Visibility(
              visible: value < 1,
              maintainState: true,
              child: child,
            );
          },
          child: Stack(
            children: <Widget>[
              PositionedTransition(
                rect: itemPosition,
                child: Stack(
                  children: <Widget>[
                    FadeTransition(
                      opacity: fadeMaterial,
                      child: Material(
                        color: Theme.of(context).bottomAppBarColor,
                        child: SizedBox(
                          width: width,
                          height: height,
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: contentOffset,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: contentOffset.value,
                          child: child,
                        );
                      },
                      child: FadeTransition(
                        opacity: fadeContent,
                        child: FadeTransition(
                          opacity: Tween(
                            begin: 1.0,
                            end: -1.0,
                          ).animate(secondaryAnimation),
                          child: Container(
                            height: height,
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                    if (widget.oldChild != null)
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: oldChildOffset,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: oldChildOffset.value,
                                child: child,
                              );
                            },
                            child: FadeTransition(
                              opacity: fadeOldContent,
                              child: widget.oldChild,
                            ),
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
                            animation: animation,
                            builder: (context, child) {
                              if (animation.value == 1)
                                return SizedBox.shrink();
                              return Transform.translate(
                                offset: oldChildOffset.value,
                                child: child,
                              );
                            },
                            child: widget.persistentOldChild,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
