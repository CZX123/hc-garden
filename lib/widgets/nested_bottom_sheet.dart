import '../library.dart';

// Returns an element from the sorted list which is closest to the given value
double closestValue(
  List<double> list,
  double value, {
  bool strictlySmaller = false,
  bool strictlyBigger = false,
}) {
  final l = list.length;
  var low = -1, high = l;
  // Exclusive binary search
  while (low < high - 1) {
    final mid = (low + high) ~/ 2;
    if (value > list[mid])
      low = mid;
    else
      high = mid;
  }
  if (low < 0) return list.first;
  if (high >= l) return list.last;
  if (strictlyBigger) return list[high];
  if (strictlySmaller) return list[low];
  final lowDiff = (value - list[low]).abs();
  final highDiff = (list[high] - value).abs();
  if (lowDiff < highDiff)
    return list[low];
  else
    return list[high];
}

final SpringDescription spring = SpringDescription.withDampingRatio(
  mass: 0.5,
  stiffness: 100,
  ratio: 1.1,
);

typedef NestedBottomSheetHeaderBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  TabController tabController,
  void Function(double, [Duration]) animateTo,
  ValueNotifier<bool> isScrolledNotifier,
);

typedef NestedBottomSheetBodyBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  TabController tabController,
  List<ScrollController> scrollControllers,
  List<ScrollController> extraScrollControllers,
  void Function(double, [Duration]) animateTo,
);

typedef NestedBottomSheetBackgroundBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  TabController tabController,
  void Function(double, [Duration]) animateTo,
);

class NestedBottomSheet extends StatefulWidget {
  final double height;
  final ShapeBorder shape;
  final Color color;
  final List<double> snappingPositions;
  final double initialPosition;
  final int tablength;
  final int initialTabIndex;
  final int extraScrollControllers;
  final ValueNotifier<int>
      state; // 0: original scroll controllers, 1: extraScrollControllers[0], 2: ...
  final NestedBottomSheetHeaderBuilder headerBuilder;
  final NestedBottomSheetBodyBuilder bodyBuilder;
  final NestedBottomSheetHeaderBuilder footerBuilder;
  final NestedBottomSheetBackgroundBuilder backgroundBuilder;
  final double endCorrection; // Only from 0 to first snapping position

  const NestedBottomSheet({
    Key key,
    this.height,
    this.shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    )),
    this.color,
    @required this.snappingPositions,
    @required this.initialPosition,
    @required this.tablength,
    this.initialTabIndex = 0,
    this.extraScrollControllers = 0,
    this.state,
    @required this.headerBuilder,
    @required this.bodyBuilder,
    this.footerBuilder,
    this.backgroundBuilder,
    this.endCorrection = 0,
  }) : super(key: key);

  @override
  _NestedBottomSheetState createState() => _NestedBottomSheetState();
}

class _NestedBottomSheetState extends State<NestedBottomSheet>
    with TickerProviderStateMixin {
  Tolerance _tolerance = Tolerance(distance: 1, time: 1, velocity: 1);
  List<double> _sortedPositions;
  AnimationController _animationController;
  List<ScrollController> _scrollControllers;
  List<ScrollController> _extraScrollControllers;
  int _state = 0;
  ScrollController _activeScrollController;
  TabController _tabController;
  Drag _scrollDrag;
  ScrollHoldController _scrollHold;
  bool _scrolling;
  //int _activeIndex;
  ValueNotifier<bool> _isScrolledNotifier = ValueNotifier(false);

  void animateTo(double end, [Duration duration]) {
    // assert(
    //   _sortedPositions.contains(end),
    //   'Value to animate to should be one of the snapping positions',
    // );
    // if (_activeScrollController.hasClients &&
    //     _activeScrollController.position.maxScrollExtent > 0) {
    //   _activeScrollController.jumpTo(0);
    // }
    if (duration == null) {
      final start = _animationController.value;
      final simulation = ScrollSpringSimulation(
        spring,
        start,
        end,
        0,
        tolerance: _tolerance,
      );
      _animationController.animateWith(simulation);
    } else {
      _animationController.animateTo(
        end,
        duration: duration,
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void stateListener() {
    final _newState = widget.state.value;
    if (_newState != 0) {
      if (_newState != _state) {
        dragCancel();
        _state = _newState;
        // TODO: Update state
        _activeScrollController =
            _state == 2 ? null : _extraScrollControllers[_state - 1];
      }
    } else {
      _state = 0;
      tabListener();
    }
  }

  void tabListener() {
    if (_state == 0) {
      final _newScrollController = _scrollControllers[_tabController.index];
      if (_activeScrollController != _newScrollController) {
        dragCancel();
        _activeScrollController = _newScrollController;
        _isScrolledNotifier.value = _activeScrollController.hasClients &&
            _activeScrollController.offset > 5;
      }
    }
  }

  void removeHold() {
    _scrollHold = null;
  }

  void removeDrag() {
    _scrollDrag = null;
  }

  void dragCancel() {
    _scrollHold?.cancel();
    _scrollDrag?.cancel();
    removeHold();
    removeDrag();
  }

  // User has touched the screen and may begin to drag
  void dragDown(DragDownDetails details) {
    // Fix bottom sheet position if it is animating
    if (_animationController.isAnimating) {
      _animationController.value = _animationController.value;
    }

    // Check if the scroll view is scrollable in the first place
    if (_activeScrollController.hasClients &&
        _activeScrollController.position.maxScrollExtent > 0) {
      // simulate a hold on the scroll view
      _scrollHold = _activeScrollController.position.hold(removeHold);
    }
  }

  // User has just started to drag
  void dragStart(DragStartDetails details) {
    // Check if the [SingleChildScrollView] is scrollable in the first place
    if (_activeScrollController.hasClients &&
        _activeScrollController.position.maxScrollExtent > 0) {
      // simulate a scroll on the [SingleChildScrollView]
      _scrollDrag = _activeScrollController.position.drag(details, removeDrag);
    }
  }

  // User is in the process of dragging
  void dragUpdate(DragUpdateDetails details) {
    // Scrolling the inner scroll view
    if (_activeScrollController.hasClients &&
        _animationController.value == _sortedPositions.first &&
        (details.primaryDelta < 0 || _activeScrollController.offset > 0)) {
      if (_scrollDrag == null) {
        _scrollDrag = _activeScrollController.position.drag(
          DragStartDetails(
            sourceTimeStamp: details.sourceTimeStamp,
            globalPosition: details.globalPosition,
          ),
          removeDrag,
        );
      }
      _scrolling = true;
      _scrollDrag.update(details);
    } else {
      // Dragging the outer bottom sheet
      dragCancel();
      //if (_activeScrollController.hasClients) _activeScrollController.jumpTo(0);
      _scrolling = false;
      if (_animationController.value < _sortedPositions[1]) {
        final range = _sortedPositions[1] - _sortedPositions.first;
        _animationController.value +=
            (widget.endCorrection / range + 1) * details.primaryDelta;
      } else {
        if (_animationController.value < _sortedPositions.last ||
            details.primaryDelta.isNegative) {
          _animationController.value += details.primaryDelta;
        } else {
          _animationController.value = _sortedPositions.last;
        }
      }
    }
  }

  // user has finished dragging
  void dragEnd(DragEndDetails details) {
    // Bunch of physics going on
    double velocity = details.primaryVelocity;
    if (_animationController.value >= _sortedPositions.last) velocity = 0;
    final start = _animationController.value;
    if (!_scrolling && velocity == 0) {
      final end = closestValue(_sortedPositions, start);
      final simulation = ScrollSpringSimulation(
        spring,
        start,
        end,
        velocity,
        tolerance: _tolerance,
      );
      _animationController.animateWith(simulation);
    } else if (!_scrolling) {
      double end;
      // if (velocity.abs() < 3200) {
      if (velocity < 0) {
        end = closestValue(_sortedPositions, start, strictlySmaller: true);
      } else {
        end = closestValue(_sortedPositions, start, strictlyBigger: true);
      }
      // } else {
      //   Simulation scrollSimulation;
      //   if (_isIOS) {
      //     scrollSimulation = FrictionSimulation(0.135, start, velocity * 0.91);
      //   } else {
      //     scrollSimulation = ClampingScrollSimulation(
      //       position: _animationController.value,
      //       velocity: velocity,
      //     );
      //   }
      //   final finalX = scrollSimulation.x(double.infinity);
      //   end = closestValue(_sortedPositions, finalX);
      // }
      final simulation = ScrollSpringSimulation(
        spring,
        start,
        end,
        velocity,
        tolerance: _tolerance,
      );
      _animationController.animateWith(simulation);
    } else {
      _scrolling = false;
      _scrollDrag.end(details);
    }
  }

  @override
  void initState() {
    super.initState();
    _sortedPositions = widget.snappingPositions;
    _sortedPositions.sort();
    final _initialPosition = widget.initialPosition ?? _sortedPositions.first;
    assert(
      _sortedPositions.contains(_initialPosition),
      'Initial position should be one of the snapping positions',
    );
    _animationController = AnimationController(
      vsync: this,
      lowerBound: _sortedPositions.first,
      upperBound: widget.height,
      value: _initialPosition,
    );
    _scrollControllers = [
      for (int i = 0; i < widget.tablength; i++) ScrollController(),
    ];
    _extraScrollControllers = [
      for (int i = 0; i < widget.extraScrollControllers; i++)
        ScrollController(),
    ];
    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: widget.tablength,
      vsync: this,
    )..addListener(tabListener);
    if (widget.state != null) {
      widget.state.addListener(stateListener);
    }
    stateListener();
  }

  @override
  void didUpdateWidget(NestedBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snappingPositions != widget.snappingPositions) {
      final newSortedPositions = widget.snappingPositions;
      newSortedPositions.sort();
      // assert(
      //   _sortedPositions.first == newSortedPositions.first &&
      //       _sortedPositions.last == newSortedPositions.last,
      //   'Cannot change to new snapping positions with different end points',
      // );
      _sortedPositions = newSortedPositions;
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  // }

  @override
  void dispose() {
    _tabController.removeListener(tabListener);
    if (widget.state != null) {
      widget.state.removeListener(stateListener);
    }
    _tabController.dispose();
    _scrollControllers.forEach((_scrollController) {
      _scrollController.dispose();
    });
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.of(context).size.height;
    final range = _sortedPositions.last - _sortedPositions.first;
    final position = Tween<Offset>(
      begin: Offset(0, _sortedPositions.first / height / range),
      end: Offset(0, _sortedPositions.last / height / range),
    ).animate(_animationController);
    final shape = ShapeBorderTween(
      begin: RoundedRectangleBorder(),
      end: widget.shape.scale(1 / _sortedPositions[1]),
    ).animate(_animationController);
    return Stack(
      children: <Widget>[
        if (widget.backgroundBuilder != null)
          widget.backgroundBuilder(
            context,
            _animationController.view,
            _tabController,
            animateTo,
          ),
        Selector<AppNotifier, bool>(
          selector: (context, appNotifier) => appNotifier.draggingDisabled,
          builder: (context, draggingDisabled, child) {
            return GestureDetector(
              onVerticalDragDown: draggingDisabled ?? false ? null : dragDown,
              onVerticalDragStart: draggingDisabled ?? false ? null : dragStart,
              onVerticalDragUpdate:
                  draggingDisabled ?? false ? null : dragUpdate,
              onVerticalDragEnd: draggingDisabled ?? false ? null : dragEnd,
              onVerticalDragCancel:
                  draggingDisabled ?? false ? null : dragCancel,
              child: child,
            );
          },
          child: Stack(
            children: <Widget>[
              SlideTransition(
                position: position,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: kElevationToShadow[6],
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return PhysicalShape(
                        color: widget.color ?? Theme.of(context).canvasColor,
                        clipper: ShapeBorderClipper(
                          shape:
                              _animationController.value < _sortedPositions[1]
                                  ? shape.value
                                  : widget.shape,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        NotificationListener(
                          onNotification: (notification) {
                            if (notification is ScrollUpdateNotification &&
                                notification.depth == 1) {
                              if (notification.metrics.pixels <= 5 &&
                                  _isScrolledNotifier.value == true) {
                                _isScrolledNotifier.value = false;
                              } else if (notification.metrics.pixels > 5 &&
                                  _isScrolledNotifier.value == false)
                                _isScrolledNotifier.value = true;
                            }
                            return null;
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: height,
                            child: widget.bodyBuilder(
                              context,
                              _animationController.view,
                              _tabController,
                              _scrollControllers,
                              _extraScrollControllers,
                              animateTo,
                            ),
                          ),
                        ),
                        widget.headerBuilder(
                          context,
                          _animationController.view,
                          _tabController,
                          animateTo,
                          _isScrolledNotifier,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.footerBuilder != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: widget.footerBuilder(
                    context,
                    _animationController.view,
                    _tabController,
                    animateTo,
                    _isScrolledNotifier,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
