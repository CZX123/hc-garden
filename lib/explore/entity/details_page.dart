import '../../library.dart';

class EntityDetailsPage extends StatefulWidget {
  final ValueNotifier<double> newTopPadding;
  final Entity entity;
  const EntityDetailsPage({
    Key key,
    @required this.newTopPadding,
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
      final trailId = loc.keys.first;
      final locationId = loc.values.first;
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
    if (Provider.of<AppNotifier>(context, listen: false).state == 1)
      Provider.of<BottomSheetNotifier>(context, listen: false)
          .activeScrollController = _scrollController;
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
    List<String> newImages = [];
    for (var image in widget.entity.images) {
      var split = image.split('.');
      final end = '.' + split.removeLast();
      newImages.add(split.join('.') + 'h' + end);
    }
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.depth == 0) {
          widget.newTopPadding.value -= notification.scrollDelta;
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable:
                  Provider.of<BottomSheetNotifier>(context, listen: false)
                      .animation,
              builder: (context, value, child) {
                double h = 0;
                if (value < height - bottomHeight) {
                  h = (1 - value / (height - bottomHeight)) * topPadding;
                  if (value > 1) widget.newTopPadding.value = h + 16;
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.entity.name,
                        style: Theme.of(context).textTheme.display1,
                      ),
                      Text(
                        widget.entity.sciName,
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 216,
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
                              height: 216,
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
      ),
    );
  }
}
