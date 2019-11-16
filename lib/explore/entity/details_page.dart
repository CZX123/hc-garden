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
          ).animateTo(height - 48 - 96);
          Provider.of<MapNotifier>(
            context,
            listen: false,
          ).animateToLocation(location);
        },
      ));
    }
    return children;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appNotifier = Provider.of<AppNotifier>(context, listen: false);
    if (appNotifier.state == 1 &&
        appNotifier.location == null &&
        appNotifier.entity == null) {
      appNotifier.changeState(
        context,
        1,
        entity: widget.entity,
        activeScrollController: _scrollController,
        rebuild: false,
      );
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
              if (value < height - 378) {
                h = (1 - value / (height - 378)) * topPadding;
                if (value > 1)
                  widget.endContentOffset?.value = Offset(0, h + 16);
              }
              return SizedBox(
                height: h,
              );
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 16, 14, 16),
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 218,
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
                            height: 218,
                            width: newImages.length == 1 ? width - 32 : 324,
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
                                  ).changeState(context, 2);
                                  Provider.of<BottomSheetNotifier>(
                                    context,
                                    listen: false,
                                  )
                                    ..draggingDisabled = true
                                    ..animateTo(
                                      0,
                                      const Duration(milliseconds: 340),
                                    );
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, _, __) {
                                        return ImageGallery(
                                          images: newImages,
                                          initialImage: image,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 340),
                                    ),
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
    return Material(
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
    );
  }
}
