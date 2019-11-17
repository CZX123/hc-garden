import '../../library.dart';

// todo:
// Make images easier to zoom
// Investigate why zoomed in images, when pressing back are very laggy
// Add some flinging upon translation

class ImageGallery extends StatelessWidget {
  final String initialImage;
  final List<String> images;
  const ImageGallery({
    Key key,
    @required this.initialImage,
    @required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context).animation;
    final disableScroll = ValueNotifier(false);
    return FadeTransition(
      opacity: Tween(
        begin: 0.0,
        end: 3.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, .3),
          end: Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )),
        child: Material(
          color: Colors.black,
          clipBehavior: Clip.hardEdge,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -.25),
              end: Offset(0, 0),
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            )),
            child: FadeTransition(
              opacity: Tween(
                begin: -1.0,
                end: 2.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              )),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: images.length == 1
                        ? ZoomableImage(
                            image: initialImage,
                          )
                        : ValueListenableBuilder(
                            valueListenable: disableScroll,
                            builder: (context, value, child) {
                              return PageView(
                                controller: PageController(
                                  initialPage: images.indexOf(initialImage),
                                ),
                                physics: value
                                    ? NeverScrollableScrollPhysics()
                                    : ScrollPhysics(),
                                children: <Widget>[
                                  for (var image in images)
                                    ZoomableImage(
                                      image: image,
                                      disableScroll: disableScroll,
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                  Theme(
                    data: darkThemeData,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: kElevationToShadow[8],
                      ),
                      child: Builder(
                        builder: (context) {
                          return Material(
                            elevation: 0,
                            color: Theme.of(context).bottomAppBarColor,
                            child: SizedBox(
                              height: 48,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.maybePop(context),
                                  tooltip: 'Back',
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomableImage extends StatefulWidget {
  final String image;
  final double maxScale;
  final ValueNotifier<bool> disableScroll;
  const ZoomableImage({
    Key key,
    @required this.image,
    this.maxScale = 5,
    this.disableScroll,
  }) : super(key: key);

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  double _viewportHeight;
  double _viewportWidth;
  double _imageHeight;
  double _imageWidth;
  final _key = GlobalKey();
  final _matrix = ValueNotifier(Matrix4.identity());
  AnimationController _animationController;
  double _startingScale = 1.0;
  Matrix4Tween _matrixTween;
  Timer _zoomTextDisappearTimer;
  final _zoomTextAppear = ValueNotifier(false);

  void animListener() {
    _zoomTextDisappearTimer?.cancel();
    if (_zoomTextAppear.value)
      _zoomTextDisappearTimer = Timer(const Duration(seconds: 1), () {
        _zoomTextAppear.value = false;
      });
    _matrix.value = _matrixTween.evaluate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn.flipped,
    ));
    _startingScale = _matrix.value.getMaxScaleOnAxis();
  }

  void onDoubleTap() {
    _matrixTween = Matrix4Tween(
      begin: Matrix4.identity(),
    );
    _zoomTextAppear.value = true;
    if (_matrix.value.getMaxScaleOnAxis() <= 1.001) {
      widget.disableScroll?.value = true;
      _matrixTween.end = Matrix4.identity()
        ..setEntry(0, 0, 3)
        ..setEntry(1, 1, 3)
        ..setTranslationRaw(
          -_viewportWidth,
          -_viewportHeight,
          0,
        );
      _animationController.value = 0;
      _animationController.forward();
    } else {
      widget.disableScroll?.value = false;
      _matrixTween.end = _matrix.value;
      _animationController.value = 1;
      _animationController.reverse();
    }
  }

  _ValueUpdater<Offset> translationUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal - oldVal,
  );
  _ValueUpdater<double> scaleUpdater = _ValueUpdater(
    onUpdate: (oldVal, newVal) => newVal / oldVal,
  );

  void onScaleStart(ScaleStartDetails details) {
    translationUpdater.value = details.focalPoint;
    scaleUpdater.value = 1.0;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_animationController.isAnimating) {
      _animationController.value = _animationController.value;
    }
    var matrix = _matrix.value;

    Offset translationDelta = translationUpdater.update(details.focalPoint);
    final translationDeltaMatrix = _translate(translationDelta);
    matrix = translationDeltaMatrix * matrix;

    double scaleDelta = scaleUpdater.update(
      min(
        widget.maxScale / _startingScale,
        max(details.scale, 1 / _startingScale),
      ),
    );
    if (scaleDelta != 1) {
      _zoomTextAppear.value = true;
      _zoomTextDisappearTimer?.cancel();
      if (_zoomTextAppear.value)
        _zoomTextDisappearTimer = Timer(const Duration(seconds: 1), () {
          _zoomTextAppear.value = false;
        });
    }
    final scaleDeltaMatrix = _scale(scaleDelta, details.localFocalPoint);
    matrix = scaleDeltaMatrix * matrix;

    final scale = scaleUpdater.value * _startingScale;
    if (scale > 1.001) {
      widget.disableScroll?.value = true;
    } else {
      widget.disableScroll?.value = false;
    }
    final differenceX = _viewportWidth - _imageWidth * scale;
    final differenceY = _viewportHeight - _imageHeight * scale;
    final maxX = differenceX > 0
        ? _viewportWidth / 2 * (1 - scale)
        : (_imageWidth - _viewportWidth) * scale / 2;
    final maxY = differenceY > 0
        ? _viewportHeight / 2 * (1 - scale)
        : (_imageHeight - _viewportHeight) * scale / 2;
    final minX = min(differenceX, 0.0) + maxX;
    final minY = min(differenceY, 0.0) + maxY;
    double x = matrix.getTranslation().x;
    double y = matrix.getTranslation().y;
    x = min(maxX, max(x, minX));
    y = min(maxY, max(y, minY));
    matrix.setTranslationRaw(x, y, 0);

    _matrix.value = matrix;
  }

  void onScaleEnd(ScaleEndDetails details) {
    _startingScale = _matrix.value.getMaxScaleOnAxis();
  }

  Matrix4 _translate(Offset translation) {
    var dx = translation.dx;
    var dy = translation.dy;
    return Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  Matrix4 _scale(double scale, Offset focalPoint) {
    var dx = (1 - scale) * focalPoint.dx;
    var dy = (1 - scale) * focalPoint.dy;
    return Matrix4(scale, 0, 0, 0, 0, scale, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(animListener);
  }

  @override
  void dispose() {
    _matrix.dispose();
    _animationController
      ..removeListener(animListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: GestureDetector(
          onDoubleTap: onDoubleTap,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          child: ValueListenableBuilder<Matrix4>(
            valueListenable: _matrix,
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(
                    child: Transform(
                      transform: value,
                      alignment: Alignment.topLeft,
                      child: child,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ValueListenableBuilder(
                      valueListenable: _zoomTextAppear,
                      builder: (context, value, child) {
                        return AnimatedOpacity(
                          opacity: value ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.black45,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        width: 48,
                        child: Text(
                          value.getMaxScaleOnAxis().toStringAsFixed(1) + '×',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: CustomImage(
              widget.image,
              key: _key,
              fit: BoxFit.contain,
              saveInCache: false,
              onLoad: (ratio) {
                _viewportHeight = _key.currentContext.size.height;
                _viewportWidth = _key.currentContext.size.width;
                final viewportRatio = _viewportWidth / _viewportHeight;
                if (ratio > viewportRatio) {
                  // Image is wider
                  _imageWidth = _viewportWidth;
                  _imageHeight = _viewportWidth / ratio;
                } else {
                  _imageHeight = _viewportHeight;
                  _imageWidth = _viewportHeight * ratio;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

typedef _OnUpdate<T> = T Function(T oldValue, T newValue);

class _ValueUpdater<T> {
  final _OnUpdate<T> onUpdate;
  T value;

  _ValueUpdater({this.onUpdate});

  T update(T newValue) {
    T updated = onUpdate(value, newValue);
    value = newValue;
    return updated;
  }
}
