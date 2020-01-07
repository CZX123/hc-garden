import '../../library.dart';

class EntityDetailsPage extends StatefulWidget {
  final ValueNotifier<Offset> endContentOffset;
  final Entity entity;
  final bool hideInfoRowOnExpand;
  const EntityDetailsPage({
    Key key,
    this.endContentOffset,
    @required this.entity,
    this.hideInfoRowOnExpand = false,
  }) : super(key: key);

  @override
  _EntityDetailsPageState createState() => _EntityDetailsPageState();
}

class _EntityDetailsPageState extends State<EntityDetailsPage> {
  bool _init = false;

  /// Whether page should slide up when going to a new route. Only applies when going to image gallery.
  bool _slideUp = false;
  final _scrollController = ScrollController();
  final hidden = ValueNotifier(false);
  Animation<double> animation;

  void listener() {
    if (animation.value < 1) {
      hidden.value = true;
    } else if (animation.isCompleted) {
      hidden.value = false;
    }
  }

  List<Widget> locations(
    BuildContext context,
    Map<Trail, List<TrailLocation>> trails,
  ) {
    final height = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    List<Widget> children = [];
    for (var loc in widget.entity.locations) {
      final int trailId = loc[0];
      final int locationId = loc[1];
      final trail = trails.keys.firstWhere((trail) {
        return trail.id == trailId;
      });
      final location = trails[trail].firstWhere((loc) {
        return loc.id == locationId;
      });
      children.add(ListTile(
        dense: true,
        leading: Icon(Icons.location_on),
        title: Text(
          '${location.name}',
          style: Theme.of(context).textTheme.body1,
        ),
        onTap: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
          Provider.of<BottomSheetNotifier>(
            context,
            listen: false,
          ).animateTo(height - Sizes.kCollapsedHeight - bottomPadding);
          Provider.of<MapNotifier>(
            context,
            listen: false,
          ).animateToLocation(location: location);
        },
      ));
    }
    return children;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      Provider.of<AppNotifier>(context, listen: false).updateScrollController(
        context: context,
        data: widget.entity,
        scrollController: _scrollController,
      );
      if (widget.hideInfoRowOnExpand ?? false) {
        animation = ModalRoute.of(context).animation..addListener(listener);
        hidden.value = true;
      }
      _init = true;
    }
  }

  @override
  void dispose() {
    animation?.removeListener(listener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    final paddingBreakpoint = bottomSheetNotifier.snappingPositions.value[1];
    final newImages = widget.entity.images.map(lowerRes).toList();
    final child = SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: bottomSheetNotifier.animation,
            builder: (context, value, child) {
              double h = 0;
              if (value < paddingBreakpoint) {
                h = (1 - value / paddingBreakpoint) * topPadding;
                if (value > 1)
                  widget.endContentOffset?.value = Offset(0, h + 16);
              }
              return SizedBox(
                height: h,
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: hidden,
            builder: (context, value, child) {
              return Visibility(
                visible: !value,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: child,
              );
            },
            child: InfoRow(
              image: widget.entity.smallImage,
              title: widget.entity.name,
              subtitle: widget.entity.sciName,
              italicised: true,
            ),
          ),
          Container(
            height: Sizes.kImageHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (var image in newImages)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: <Widget>[
                          CustomImage(
                            image,
                            height: Sizes.kImageHeight,
                            width: newImages.length == 1
                                ? width - 32
                                : Sizes.kImageHeight / 2 * 3,
                            fit: BoxFit.cover,
                            placeholderColor: Theme.of(context).dividerColor,
                          ),
                          Positioned.fill(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  Provider.of<AppNotifier>(
                                    context,
                                    listen: false,
                                  ).push(
                                    context: context,
                                    routeInfo: RouteInfo(
                                      name: 'Gallery',
                                      route: PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (context, _, __) {
                                          return ImageGallery(
                                            images: newImages,
                                            initialImage: image,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    ),
                                    disableDragging: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          for (var para in widget.entity.description.split('\n'))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                para,
                textAlign: TextAlign.justify,
              ),
            ),
          const SizedBox(
            height: 8,
          ),
          Selector<FirebaseData, Map<Trail, List<TrailLocation>>>(
            selector: (context, firebaseData) => firebaseData.trails,
            builder: (context, trails, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: locations(context, trails),
              );
            },
          ),
          const SizedBox(
            height: Sizes.kBottomBarHeight + 8,
          ),
          const BottomPadding(),
        ],
      ),
    );
    return ValueListenableBuilder<double>(
      valueListenable: ModalRoute.of(context).secondaryAnimation,
      builder: (context, value, child) {
        // Slides the page up when going to image gallery
        // As for other routes, it will not do so
        double y = 0;
        if (_slideUp || appNotifier.state == 2) {
          _slideUp = value != 0;
          y = value * height * -.01;
        }
        return Transform.translate(
          offset: Offset(0, y),
          child: child,
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: widget.endContentOffset != null
            ? NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification &&
                      notification.depth == 0) {
                    widget.endContentOffset.value -=
                        Offset(0, notification.scrollDelta);
                  }
                  return false;
                },
                child: child,
              )
            : child,
      ),
    );
  }
}
