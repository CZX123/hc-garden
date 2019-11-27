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

class CustomBottomSheet extends StatefulWidget {
  final ShapeBorder shape;
  final Color color;
  final double initialPosition;
  final Widget header;
  final Widget body;
  final Widget footer;
  final Widget background;

  const CustomBottomSheet({
    Key key,
    this.shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    )),
    this.color,
    @required this.initialPosition,
    this.header,
    @required this.body,
    this.footer,
    this.background,
  }) : super(key: key);

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _init = false;
  BottomSheetNotifier _bottomSheetNotifier;
  Tolerance _tolerance = Tolerance(distance: 1, time: 1, velocity: 1);
  List<double> _sortedPositions;
  AnimationController _animationController;
  Drag _scrollDrag;
  ScrollHoldController _scrollHold;
  bool _scrolling;

  void animateTo(double end, [Duration duration]) {
    if (end == _animationController?.value ?? end) return;
    assert(
      _sortedPositions.contains(end),
      'Value to animate to should be one of the snapping positions',
    );
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

  void removeHold() {
    _scrollHold = null;
  }

  void removeDrag() {
    _scrollDrag = null;
  }

  void cancelScrollDragHold() {
    _scrollHold?.cancel();
    _scrollDrag?.cancel();
    removeHold();
    removeDrag();
  }

  void dragCancel() {
    cancelScrollDragHold();
    if (!_sortedPositions.contains(_animationController.value)) {
      animateTo(closestValue(_sortedPositions, _animationController.value));
    }
  }

  // User has touched the screen and may begin to drag
  void dragDown(DragDownDetails details) {
    final controller = _bottomSheetNotifier.activeScrollController;
    // Fix bottom sheet position if it is animating
    if (_animationController.isAnimating) {
      _animationController.value = _animationController.value;
    }

    // Check if the scroll view is scrollable in the first place
    if (controller != null &&
        controller.hasClients &&
        controller.position.maxScrollExtent > 0) {
      // simulate a hold on the scroll view
      _scrollHold = controller.position.hold(removeHold);
    }
  }

  // User has just started to drag
  void dragStart(DragStartDetails details) {
    Provider.of<SearchNotifier>(context, listen: false).unfocus();
    final controller = _bottomSheetNotifier.activeScrollController;
    // Check if the [SingleChildScrollView] is scrollable in the first place
    if (controller != null &&
        controller.hasClients &&
        controller.position.maxScrollExtent > 0) {
      // simulate a scroll on the [SingleChildScrollView]
      _scrollDrag = controller.position.drag(details, removeDrag);
    }
  }

  // User is in the process of dragging
  void dragUpdate(DragUpdateDetails details) {
    final controller = _bottomSheetNotifier.activeScrollController;
    // Scrolling the inner scroll view
    if (controller != null &&
        controller.hasClients &&
        _animationController.value == _sortedPositions.first &&
        (details.primaryDelta < 0 || controller.offset > 0)) {
      if (_scrollDrag == null) {
        _scrollDrag = controller.position.drag(
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
      cancelScrollDragHold();
      //if (_activeScrollController.hasClients) _activeScrollController.jumpTo(0);
      _scrolling = false;
      if (_animationController.value < _sortedPositions[1]) {
        final range = _sortedPositions[1] - _sortedPositions.first;
        _animationController.value +=
            (range / (range - _bottomSheetNotifier.endCorrection)) *
                details.primaryDelta;
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
      if (velocity < 0) {
        end = closestValue(_sortedPositions, start, strictlySmaller: true);
      } else {
        end = closestValue(_sortedPositions, start, strictlyBigger: true);
      }
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

  void listener() {
    final newSortedPositions = _bottomSheetNotifier.snappingPositions.value;
    newSortedPositions.sort();
    if (listEquals(_sortedPositions, newSortedPositions)) return;
    if (!newSortedPositions.contains(_animationController.value)) {
      if (_animationController.value == _sortedPositions.last) {
        _sortedPositions = newSortedPositions;
        if (_bottomSheetNotifier.draggingDisabled) {
          _animationController.value = _sortedPositions.last;
        } else {
          animateTo(_sortedPositions.last);
        }
      } else if (_sortedPositions.length == 3 &&
          newSortedPositions.length == 3 &&
          _animationController.value == _sortedPositions[1]) {
        _sortedPositions = newSortedPositions;
        animateTo(_sortedPositions[1]);
      } else {
        _sortedPositions = newSortedPositions;
        animateTo(closestValue(_sortedPositions, _animationController.value));
      }
    } else {
      _sortedPositions = newSortedPositions;
    }
    // Assume begin is always 0
    _bottomSheetNotifier.animTween..end = 1 / _sortedPositions[1];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    if (MediaQuery.of(context).orientation == Orientation.landscape &&
        appNotifier.routes.isNotEmpty &&
        appNotifier.routes.last.data is TrailLocationOverviewPage) {
      animateTo(0);
    }
    if (!_init) {
      final height = MediaQuery.of(context).size.height;
      if (height == 0) return;
      _sortedPositions = _bottomSheetNotifier.snappingPositions.value;
      _sortedPositions.sort();
      final _initialPosition = widget.initialPosition ?? _sortedPositions.first;
      assert(
        _sortedPositions.contains(_initialPosition),
        'Initial position should be one of the snapping positions',
      );
      _animationController = AnimationController(
        vsync: this,
        lowerBound: _sortedPositions.first,
        upperBound: double.infinity,
        value: _initialPosition,
      );
      _bottomSheetNotifier
        ..animation = _animationController.view
        ..animTween.end = 1 / _sortedPositions[1]
        ..animateTo = animateTo;
      _bottomSheetNotifier.snappingPositions.addListener(listener);
      _init = true;
    }
  }

  @override
  void dispose() {
    _bottomSheetNotifier.snappingPositions.removeListener(listener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final range = _sortedPositions.last - _sortedPositions.first;
    final position = Tween<Offset>(
      begin: Offset(0, _sortedPositions.first / height / range),
      end: Offset(0, _sortedPositions.last / height / range),
    ).animate(_animationController);
    return Stack(
      children: <Widget>[
        if (widget.background != null) widget.background,
        Selector<BottomSheetNotifier, bool>(
          selector: (context, bottomSheetNotifier) =>
              bottomSheetNotifier.draggingDisabled,
          builder: (context, draggingDisabled, child) {
            return GestureDetector(
              onVerticalDragDown: draggingDisabled ?? false ? null : dragDown,
              onVerticalDragStart: draggingDisabled ?? false ? null : dragStart,
              onVerticalDragUpdate:
                  draggingDisabled ?? false ? null : dragUpdate,
              onVerticalDragEnd: draggingDisabled ?? false ? null : dragEnd,
              onVerticalDragCancel:
                  draggingDisabled ?? false ? null : dragCancel,
              onHorizontalDragDown: draggingDisabled ?? false ? null : (_) {},
              onHorizontalDragStart: draggingDisabled ?? false ? null : (_) {},
              onHorizontalDragUpdate: draggingDisabled ?? false ? null : (_) {},
              onHorizontalDragEnd: draggingDisabled ?? false ? null : (_) {},
              onHorizontalDragCancel: draggingDisabled ?? false ? null : () {},
              child: child,
            );
          },
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTapDown: (_) {
                  Provider.of<SearchNotifier>(context, listen: false).unfocus();
                },
                child: SlideTransition(
                  position: position,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: kElevationToShadow[6],
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final shape = ShapeBorderTween(
                          begin: RoundedRectangleBorder(),
                          end: widget.shape.scale(1 / _sortedPositions[1]),
                        ).animate(_animationController);
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
                                    _bottomSheetNotifier
                                            .isScrolledNotifier.value ==
                                        true) {
                                  _bottomSheetNotifier
                                      .isScrolledNotifier.value = false;
                                } else if (notification.metrics.pixels > 5 &&
                                    _bottomSheetNotifier
                                            .isScrolledNotifier.value ==
                                        false)
                                  _bottomSheetNotifier
                                      .isScrolledNotifier.value = true;
                              }
                              return null;
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: height,
                              child: widget.body,
                            ),
                          ),
                          if (widget.header != null) widget.header,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.footer != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: widget.footer,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottomSheetNotifier extends ChangeNotifier {
  /// Default bottom sheet animation. Has values ranging from 0 to window Height
  Animation<double> animation;

  /// Tween that goes from 0 to 1, from the bottom sheet's 0 to 2nd snapping position.
  final animTween = Tween<double>(
    // Assume begin is always 0
    begin: 0,
  );
  void Function(double, [Duration])
      animateTo; // animateTo function for bottom sheet
  ScrollController activeScrollController;
  ValueNotifier<bool> isScrolledNotifier = ValueNotifier(false);
  ValueNotifier<List<double>> snappingPositions = ValueNotifier(null);
  double endCorrection = 0;

  bool _draggingDisabled = false;
  bool get draggingDisabled => _draggingDisabled;
  set draggingDisabled(bool draggingDisabled) {
    if (_draggingDisabled != draggingDisabled) {
      _draggingDisabled = draggingDisabled;
      notifyListeners();
    }
  }
}
