import '../../library.dart';

class EntityDetailsPage extends StatefulWidget {
  final ValueNotifier<Offset> endContentOffset;
  final Entity entity;
  const EntityDetailsPage({
    Key key,
    this.endContentOffset,
    @required this.entity,
  }) : super(key: key);

  @override
  _EntityDetailsPageState createState() => _EntityDetailsPageState();
}

class _EntityDetailsPageState extends State<EntityDetailsPage> {
  bool _init = false;

  /// Whether page should slide up when going to a new route. Only applies when going to image gallery.
  bool _slideUp = false;
  final _scrollController = ScrollController();

  List<Widget> locations(
    BuildContext context,
    Map<Trail, List<TrailLocation>> trails,
  ) {
    final height = MediaQuery.of(context).size.height;
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
        leading: Icon(Icons.location_on),
        title: Text(
          '${location.name}',
          style: Theme.of(context).textTheme.body1.copyWith(
                height: 1.3,
              ),
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
          ).animateTo(height - Sizes.kCollapsedHeight);
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
      _init = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    final newImages = widget.entity.images.map(lowerRes).toList();
    final child = SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: Provider.of<BottomSheetNotifier>(
              context,
              listen: false,
            ).animation,
            builder: (context, value, child) {
              double h = 0;
              if (value < height - Sizes.kBottomHeight) {
                h = (1 - value / (height - Sizes.kBottomHeight)) * topPadding;
                if (value > 1)
                  widget.endContentOffset?.value = Offset(0, h + 16);
              }
              return SizedBox(
                height: h,
              );
            },
          ),
          Container(
            height: Sizes.kInfoRowHeight,
            padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: CustomImage(
                    widget.entity.smallImage,
                    height: 64,
                    width: 64,
                    placeholderColor: Theme.of(context).dividerColor,
                    fadeInDuration: null,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.entity.name,
                        style: Theme.of(context).textTheme.subhead.copyWith(
                              fontSize: 18,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        widget.entity.sciName,
                        style: Theme.of(context).textTheme.overline,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                    ],
                  ),
                ),
              ],
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
                            saveInCache: false,
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
                                    route: PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, _, __) {
                                        return ImageGallery(
                                          images: newImages,
                                          initialImage: image,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 340),
                                    ),
                                    routeInfo: RouteInfo(name: 'Gallery'),
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
            height: 64,
          ),
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
