import '../library.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final secondaryAnimation = ModalRoute.of(context).secondaryAnimation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topExtent = topPadding + 96;
    final scale = Tween<double>(
      begin: 1,
      end: .8,
    ).animate(_animationController);
    final opacity = Tween<double>(
      begin: 2,
      end: 0,
    ).animate(_animationController);
    return AnnotatedRegion(
      value: (isDark
              ? ThemeNotifier.darkOverlayStyle
              : ThemeNotifier.lightOverlayStyle)
          .copyWith(
        statusBarColor:
            Theme.of(context).canvasColor.withOpacity(isDark ? .5 : .8),
        systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
      ),
      child: Material(
        child: SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: Offset(0, -.01),
          ).animate(secondaryAnimation),
          child: FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
            child: NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  if (notification.metrics.pixels < topExtent) {
                    _animationController.value =
                        notification.metrics.pixels / topExtent;
                  } else if (_animationController.value != 1) {
                    _animationController.value = 1;
                  }
                }
                return false;
              },
              child: Selector<FirebaseData, List<HistoricalData>>(
                selector: (context, firebaseData) =>
                    firebaseData.historicalDataList,
                builder: (context, historicalData, child) {
                  final newImages = historicalData.map((h) {
                    return lowerRes(h.image);
                  }).toList();
                  return ListView.builder(
                    padding: EdgeInsets.only(top: topPadding),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(16, 96, 16, 16),
                          child: ScaleTransition(
                            scale: scale,
                            child: FadeTransition(
                              opacity: opacity,
                              child: Text(
                                'Historical Photos',
                                style: Theme.of(context).textTheme.display2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }
                      final i = index - 1;
                      final height = width *
                          historicalData[i].height /
                          historicalData[i].width;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (newImages[i].isNotEmpty)
                            Stack(
                              children: <Widget>[
                                BeforeAfter(
                                  imageHeight: height,
                                  imageWidth: width,
                                  beforeImage: CustomImage(
                                    newImages[i],
                                    placeholderColor:
                                        Theme.of(context).dividerColor,
                                  ),
                                  afterImage: CustomImage(
                                    newImages[i],
                                    placeholderColor:
                                        Theme.of(context).dividerColor,
                                  ),
                                ),
                                // Positioned.fill(
                                //   child: Material(
                                //     type: MaterialType.transparency,
                                //     child: InkWell(
                                //       onTap: () async {
                                //         SystemChrome.setPreferredOrientations([
                                //           DeviceOrientation.portraitUp,
                                //           DeviceOrientation.landscapeLeft,
                                //           DeviceOrientation.landscapeRight,
                                //         ]);
                                //         await Navigator.push(
                                //           context,
                                //           PageRouteBuilder(
                                //             opaque: false,
                                //             pageBuilder: (context, _, __) {
                                //               return ImageGallery(
                                //                 images:
                                //                     newImages.where((image) {
                                //                   return image.isNotEmpty;
                                //                 }).toList(),
                                //                 initialImage: newImages[i],
                                //                 title: 'Historical Photos',
                                //                 fasterNavBarColourChange: true,
                                //               );
                                //             },
                                //             transitionDuration: const Duration(
                                //                 milliseconds: 300),
                                //           ),
                                //         );
                                //         SystemChrome.setPreferredOrientations([
                                //           DeviceOrientation.portraitUp,
                                //         ]);
                                //       },
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          if (historicalData[i].description != '')
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              child: Text(
                                historicalData[i].description,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                        ],
                      );
                    },
                    itemCount: historicalData.length + 1,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
