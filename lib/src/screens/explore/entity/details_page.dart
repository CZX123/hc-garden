import 'package:hc_garden/src/library.dart';

class EntityDetailsPage extends StatefulWidget {
  final EntityKey entityKey;
  const EntityDetailsPage({
    Key key,
    @required this.entityKey,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      context.provide<AppNotifier>(listen: false).updateScrollController(
        context: context,
        dataKey: widget.entityKey,
        scrollController: _scrollController,
      );
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final appNotifier = context.provide<AppNotifier>(listen: false);
    final entity = FirebaseData.getEntity(
      context: context,
      key: widget.entityKey,
    );
    final newImages = entity.images.map(lowerRes).toList();
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
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const TopPaddingSpace(),
              InfoRow(
                heroTag: widget.entityKey,
                image: entity.smallImage,
                title: entity.name,
                subtitle: entity.sciName,
                subtitleStyle: Theme.of(context).textTheme.overline,
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
                                placeholderColor:
                                    Theme.of(context).dividerColor,
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
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
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
              for (var para in entity.description.split('\n'))
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
              EntityLocationsWidget(
                locations: entity.locations,
                scrollController: _scrollController,
              ),
              const SizedBox(
                height: Sizes.kBottomBarHeight + 8,
              ),
              const BottomPadding(),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityLocationsWidget extends StatelessWidget {
  final List<EntityLocation> locations;
  final ScrollController scrollController;
  const EntityLocationsWidget({
    Key key,
    @required this.locations,
    @required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final List<Widget> children = [];
    for (final entityLocation in locations) {
      final trailLocation = FirebaseData.getTrailLocation(
        context: context,
        key: entityLocation.trailLocationKey,
      );
      if (trailLocation != null) {
        children.add(ListTile(
          dense: true,
          leading: Icon(Icons.location_on),
          title: Text(
            '${trailLocation.name}',
            style: Theme.of(context).textTheme.body1,
          ),
          onTap: () {
            scrollController.animateTo(
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
            ).animateToLocation(location: trailLocation);
          },
        ));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
