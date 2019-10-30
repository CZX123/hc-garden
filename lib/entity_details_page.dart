import 'library.dart';

class EntityDetailsPage extends StatelessWidget {
  final ValueNotifier<double> newTopPadding;
  final Entity entity;
  final ScrollController scrollController;
  const EntityDetailsPage({
    Key key,
    @required this.newTopPadding,
    @required this.entity,
    @required this.scrollController,
  }) : super(key: key);

  List<Widget> locations(
    BuildContext context,
    Map<Trail, List<TrailLocation>> trails,
  ) {
    List<Widget> children = [];
    for (var location in entity.locations) {
      final trailId = location.keys.first;
      final locationId = location.values.first;
      final trail = trails.keys.firstWhere((trail) {
        return trail.id == trailId;
      });
      final name = trails[trail].firstWhere((loc) {
        return loc.id == locationId;
      }).name;
      children.add(ListTile(
        leading: Icon(Icons.location_on),
        title: Text(
          '$name',
          style: Theme.of(context).textTheme.subtitle,
        ),
        onTap: () {},
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    List<String> newImages = [];
    for (var image in entity.images) {
      var split = image.split('.');
      final end = '.' + split.removeLast();
      newImages.add(split.join('.') + 'h' + end);
    }
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.depth == 0) {
          newTopPadding.value -= notification.scrollDelta;
        }
        return false;
      },
      child: Selector<AppNotifier, int>(
        selector: (context, appNotifier) => appNotifier.state,
        builder: (context, state, child) {
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            controller: state == 1 ? scrollController : ScrollController(),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable:
                  Provider.of<AppNotifier>(context, listen: false).animation,
              builder: (context, value, child) {
                double h = 0;
                if (value < height - bottomHeight) {
                  h = (1 - value / (height - bottomHeight)) * topPadding;
                  if (value > 1) newTopPadding.value = h + 16;
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
                      entity.smallImage,
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
                        entity.name,
                        style: Theme.of(context).textTheme.title.copyWith(
                              height: 1,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        entity.sciName,
                        style: Theme.of(context).textTheme.subhead.copyWith(
                              height: 1,
                              color: Theme.of(context).hintColor,
                              fontStyle: FontStyle.italic,
                            ),
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
                            Hero(
                              tag: image,
                              flightShuttleBuilder: (
                                flightContext,
                                animation,
                                flightDirection,
                                fromHeroContext,
                                toHeroContext,
                              ) {
                                return Container(
                                  color: Colors.white,
                                  height: 80,
                                  width: 80,
                                );
                              },
                              child: CustomImage(
                                image,
                                height: 216,
                                width: newImages.length == 1 ? width - 32 : 324,
                                fit: BoxFit.cover,
                                placeholderColor:
                                    Theme.of(context).dividerColor,
                                saveInCache: false,
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  onTap: () {
                                    Provider.of<AppNotifier>(
                                      context,
                                      listen: false,
                                    )
                                      ..state = 2
                                      ..draggingDisabled = true;
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, _, __) {
                                          return ImageGallery(
                                            images: newImages,
                                            initialImage: image,
                                          );
                                        },
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                entity.description,
                style: Theme.of(context).textTheme.subtitle,
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
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
