import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

typedef Widget CustomBottomSheetHeaderBuilder(
  BuildContext context,
  VoidCallback viewSheet,
);
typedef Widget CustomBottomSheetContentBuilder(
  BuildContext context,
  ScrollController scrollController,
);

class CustomBottomSheet extends StatefulWidget {
  final double windowHeight;
  final double headerHeight;
  final CustomBottomSheetHeaderBuilder headerBuilder;
  final CustomBottomSheetContentBuilder contentBuilder;
  CustomBottomSheet({
    @required this.windowHeight,
    @required this.headerBuilder,
    @required this.contentBuilder,
    this.headerHeight = 56,
    Key key,
  }) : super(key: key);

  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  double initialY;
  final SpringDescription defaultSpring = SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100,
    ratio: 1.1,
  );
  AnimationController animationController;
  ScrollController scrollController = ScrollController();
  Animation<Offset> animationValue;
  Animation<double> oldContentsFade;
  Animation<double> newContentsFade;
  ScrollHoldController scrollHold;
  Drag scrollDrag;
  bool scrolling = false;
  LocalHistoryEntry localHistoryEntry;
  bool localHistoryEntryAdded = false;
  bool disablePopAnimation = false;

  // user has touched the screen and may begin to drag
  void dragDown(DragDownDetails details) {
    // This line here is to stop the bottom sheet from moving and hold it in place should the user tap on the bottom sheet again while it is shifting
    animationController.value = animationController.value;

    // Check if the [SingleChildScrollView] is scrollable in the first place
    if (scrollController.hasClients &&
        scrollController.position.maxScrollExtent > 0)
      // simulate a hold on the [SingleChildScrollView]
      scrollHold = scrollController.position.hold(disposeScrollHold);
    // I don't really know if this is needed, but it is best to mimic and simulate actual scrolling on the [SingleChildScrollView] as close as possible, and that included holding
  }

  // user has just started to drag
  void dragStart(DragStartDetails details) {
    // Check if the [SingleChildScrollView] is scrollable in the first place
    if (scrollController.hasClients &&
        scrollController.position.maxScrollExtent > 0) {
      // simulate a scroll on the [SingleChildScrollView]
      scrollDrag = scrollController.position.drag(details, disposeScrollDrag);
    }
  }

  // user is in the process of dragging
  void dragUpdate(DragUpdateDetails details) {
    if (scrollDrag != null &&
        animationController.value == 0 &&
        (details.primaryDelta < 0 || scrollController.offset > 0)) {
      scrolling = true;
      scrollDrag.update(details);
    } else {
      scrolling = false;
      animationController.value += details.primaryDelta / initialY;
    }
  }

  // user has finished dragging
  void dragEnd(DragEndDetails details) {
    scrollHold?.cancel();
    if (scrolling)
      scrollDrag.end(details);
    else {
      scrollDrag?.cancel();
      if (scrollController.hasClients && scrollController.offset < 0) {
        scrollController.jumpTo(0);
      }
      if (details.primaryVelocity == 0) {
        animationController.animateWith(
          ScrollSpringSimulation(
            defaultSpring,
            animationController.value,
            animationController.value > 0.5 ? 1.0 : 0.0,
            0,
          ),
        );
        if (animationController.value > 0.5) {
          if (localHistoryEntryAdded) {
            disablePopAnimation = true;
            Navigator.pop(context);
          }
        } else if (!localHistoryEntryAdded) {
          ModalRoute.of(context).addLocalHistoryEntry(localHistoryEntry);
          localHistoryEntryAdded = true;
        }
      } else {
        animationController.animateWith(
          ScrollSpringSimulation(
            defaultSpring,
            animationController.value,
            details.primaryVelocity > 0 ? 1.0 : 0.0,
            details.primaryVelocity / widget.windowHeight,
          ),
        );
        if (details.primaryVelocity > 0) {
          if (localHistoryEntryAdded) {
            disablePopAnimation = true;
            Navigator.pop(context);
          }
        } else if (!localHistoryEntryAdded) {
          ModalRoute.of(context).addLocalHistoryEntry(localHistoryEntry);
          localHistoryEntryAdded = true;
        }
      }
    }
  }

  // something unexpected happened that cause user to suddenly stopped dragging
  // e.g. random popup or dialog
  void dragCancel() {
    scrollHold?.cancel();
    scrollDrag?.cancel();
  }

  void disposeScrollHold() {
    scrollHold = null;
  }

  void disposeScrollDrag() {
    scrollDrag = null;
  }

  void onPop() {
    if (!disablePopAnimation)
      animationController.animateWith(
        ScrollSpringSimulation(
          defaultSpring,
          animationController.value,
          1.0,
          0,
        ),
      );
    disablePopAnimation = false;
    localHistoryEntryAdded = false;
  }

  void viewSheet() {
    animationController.animateWith(
      ScrollSpringSimulation(
        defaultSpring,
        animationController.value,
        0,
        0,
      ),
    );
    if (!localHistoryEntryAdded)
      ModalRoute.of(context).addLocalHistoryEntry(localHistoryEntry);
    localHistoryEntryAdded = true;
  }

  @override
  void initState() {
    super.initState();
    localHistoryEntry = LocalHistoryEntry(
      onRemove: onPop,
    );
    initialY = widget.windowHeight - widget.headerHeight;
    animationController = AnimationController(
      vsync: this,
      value:
          1, // value of 1 means sheet is at the bottom, value of 0 means sheet is fully expanded
    );
    animationValue = Tween<Offset>(
      begin: Offset(0, 0), // sheet is fully expanded
      end: Offset(
          0, initialY / widget.windowHeight), // sheet is hidden at bottom
    ).animate(animationController);
    oldContentsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.8, 1),
      ),
    );
    newContentsFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 0.8),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // See: https://github.com/flutter/flutter/issues/25827
  // Below is required to update the windowHeight from 0 to the actual height
  @override
  void didUpdateWidget(CustomBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windowHeight != widget.windowHeight) {
      initialY = widget.windowHeight - widget.headerHeight;
      animationValue = Tween<Offset>(
        begin: Offset(0, 0), // sheet is fully expanded
        end: Offset(
            0, initialY / widget.windowHeight), // sheet is hidden at bottom
      ).animate(animationController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: dragDown,
      onVerticalDragStart: dragStart,
      onVerticalDragUpdate: dragUpdate,
      onVerticalDragEnd: dragEnd,
      onVerticalDragCancel: dragCancel,
      child: SlideTransition(
        position: animationValue,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            boxShadow: kElevationToShadow[4],
          ),
          height: widget.windowHeight,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              FadeTransition(
                opacity: newContentsFade,
                child: SizedBox(
                  height: widget.windowHeight,
                  width: MediaQuery.of(context).size.width,
                  child: widget.contentBuilder(context, scrollController),
                ),
              ),
              FadeTransition(
                opacity: oldContentsFade,
                child: widget.headerBuilder(context, viewSheet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
