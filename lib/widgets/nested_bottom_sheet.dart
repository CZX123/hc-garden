import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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
  void Function(double) animateTo,
  ValueNotifier<bool> isScrolledNotifier,
);

typedef NestedBottomSheetBodyBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  TabController tabController,
  List<ScrollController> scrollControllers,
  void Function(double) animateTo,
);

class NestedBottomSheet extends StatefulWidget {
  final double height;
  final ShapeBorder shape;
  final Color color;
  final List<double> snappingPositions;
  final double initialPosition;
  final int tablength;
  final int initialTabIndex;
  final NestedBottomSheetHeaderBuilder headerBuilder;
  final NestedBottomSheetBodyBuilder bodyBuilder;
  final NestedBottomSheetHeaderBuilder footerBuilder;
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
    @required this.headerBuilder,
    @required this.bodyBuilder,
    this.footerBuilder,
    this.endCorrection = 0,
  }) : super(key: key);

  @override
  _NestedBottomSheetState createState() => _NestedBottomSheetState();
}

class _NestedBottomSheetState extends State<NestedBottomSheet>
    with TickerProviderStateMixin {
  List<double> _sortedPositions;
  AnimationController _animationController;
  List<ScrollController> _scrollControllers;
  TabController _tabController;
  Drag _scrollDrag;
  ScrollHoldController _scrollHold;
  bool _scrolling;
  int _activeIndex;
  ValueNotifier<bool> _isScrolledNotifier = ValueNotifier(false);

  void animateTo(double end) {
    assert(
      _sortedPositions.contains(end),
      'Value to animate to should be one of the snapping positions',
    );
    if (_scrollControllers[_activeIndex].hasClients &&
        _scrollControllers[_activeIndex].position.maxScrollExtent > 0) {
      _scrollControllers[_activeIndex].jumpTo(0);
    }
    final start = _animationController.value;
    final simulation = ScrollSpringSimulation(spring, start, end, 0);
    _animationController.animateWith(simulation);
  }

  void tabListener() {
    final _newIndex = _tabController.index;
    if (_activeIndex != _newIndex) {
      dragCancel();
      _activeIndex = _newIndex;
      _isScrolledNotifier.value = _scrollControllers[_activeIndex].hasClients &&
          _scrollControllers[_activeIndex].offset > 5;
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
    _animationController.value = _animationController.value;

    // Check if the scroll view is scrollable in the first place
    if (_scrollControllers[_activeIndex].hasClients &&
        _scrollControllers[_activeIndex].position.maxScrollExtent > 0) {
      // simulate a hold on the scroll view
      _scrollHold = _scrollControllers[_activeIndex].position.hold(removeHold);
    }
  }

  // User has just started to drag
  void dragStart(DragStartDetails details) {
    // Check if the [SingleChildScrollView] is scrollable in the first place
    if (_scrollControllers[_activeIndex].hasClients &&
        _scrollControllers[_activeIndex].position.maxScrollExtent > 0) {
      // simulate a scroll on the [SingleChildScrollView]
      _scrollDrag =
          _scrollControllers[_activeIndex].position.drag(details, removeDrag);
    }
  }

  // User is in the process of dragging
  void dragUpdate(DragUpdateDetails details) {
    // Scrolling the inner scroll view
    if (_scrollControllers[_activeIndex].hasClients &&
        _animationController.value == _sortedPositions.first &&
        (details.primaryDelta < 0 ||
            _scrollControllers[_activeIndex].offset > 0)) {
      if (_scrollDrag == null) {
        _scrollDrag = _scrollControllers[_activeIndex].position.drag(
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
      if (_scrollControllers[_activeIndex].hasClients)
        _scrollControllers[_activeIndex].jumpTo(0);
      _scrolling = false;
      if (_animationController.value < _sortedPositions[1]) {
        final range = _sortedPositions[1] - _sortedPositions.first;
        _animationController.value +=
            (widget.endCorrection / range + 1) * details.primaryDelta;
      } else {
        _animationController.value += details.primaryDelta;
      }
    }
  }

  // user has finished dragging
  void dragEnd(DragEndDetails details) {
    // Bunch of physics going on
    final velocity = details.primaryVelocity;
    final start = _animationController.value;
    if (!_scrolling && velocity == 0) {
      final end = closestValue(_sortedPositions, start);
      final simulation = ScrollSpringSimulation(spring, start, end, velocity);
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
      final simulation = ScrollSpringSimulation(spring, start, end, velocity);
      _animationController.animateWith(simulation);
    } else {
      _scrolling = false;
      _scrollDrag.end(details);
    }
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialTabIndex;
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
      upperBound: _sortedPositions.last,
      value: _initialPosition,
    );
    _scrollControllers = [
      for (int i = 0; i < widget.tablength; i++) ScrollController(),
    ];
    _tabController = TabController(
      initialIndex: _activeIndex,
      length: widget.tablength,
      vsync: this,
    )..addListener(tabListener);
  }

  @override
  void didUpdateWidget(NestedBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snappingPositions != widget.snappingPositions) {
      final newSortedPositions = widget.snappingPositions;
      newSortedPositions.sort();
      assert(
        _sortedPositions.first == newSortedPositions.first &&
            _sortedPositions.last == newSortedPositions.last,
        'Cannot change to new snapping positions with different end points',
      );
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
    return GestureDetector(
      onVerticalDragDown: dragDown,
      onVerticalDragStart: dragStart,
      onVerticalDragUpdate: dragUpdate,
      onVerticalDragEnd: dragEnd,
      onVerticalDragCancel: dragCancel,
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
                      shape: _animationController.value < _sortedPositions[1]
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
    );
  }
}
