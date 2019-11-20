import '../library.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final secondaryAnimation = ModalRoute.of(context).secondaryAnimation;
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: Offset(0, -.01),
      ).animate(secondaryAnimation),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
        child: Selector<FirebaseData, List<HistoricalData>>(
          selector: (context, firebaseData) => firebaseData.historicalDataList,
          builder: (context, historicalDataList, child) {
            final newImages = historicalDataList.map((h) {
              return lowerRes(h.image);
            }).toList();
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: [const SizedBox.shrink()],
                  automaticallyImplyLeading: false,
                  expandedHeight: 96 + topPadding,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      'Historical Photos',
                      style: Theme.of(context).textTheme.display2,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final height = width *
                          historicalDataList[index].height /
                          historicalDataList[index].width;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (newImages[index].isNotEmpty)
                            Stack(
                              children: <Widget>[
                                CustomImage(
                                  newImages[index],
                                  height: height,
                                  width: width,
                                  placeholderColor:
                                      Theme.of(context).dividerColor,
                                ),
                                Positioned.fill(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (context, _, __) {
                                              return ImageGallery(
                                                images:
                                                    newImages.where((image) {
                                                  return image.isNotEmpty;
                                                }).toList(),
                                                initialImage: newImages[index],
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 340),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (historicalDataList[index].description != '')
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              child: Text(
                                historicalDataList[index].description,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                        ],
                      );
                    },
                    childCount: historicalDataList.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
