import '../../library.dart';

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
            // child: PhotoViewGallery.builder(
            //   builder: (context, index) {
            //     return PhotoViewGalleryPageOptions(
            //       imageProvider: NetworkImage(images[index]),
            //       minScale: PhotoViewComputedScale.contained,
            //       maxScale: PhotoViewComputedScale.covered,
            //     );
            //   },
            //   itemCount: images.length,
            // ),
            child: FadeTransition(
              opacity: Tween(
                begin: -1.0,
                end: 2.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              )),
              child: PageView(
                controller: PageController(
                  initialPage: images.indexOf(initialImage),
                ),
                children: <Widget>[
                  for (var image in images) ZoomableImage(image: image),
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
  const ZoomableImage({
    Key key,
    this.image,
    this.maxScale = 5,
  }) : super(key: key);

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

enum ScaleDirection { inward, outward }

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  double _viewportHeight;
  double _viewportWidth;
  double _imageHeight;
  double _imageWidth;
  final _key = GlobalKey();
  final _matrix = ValueNotifier(Matrix4.identity());
  AnimationController _animationController;

  void onDoubleTap() {
    // TODO: double tap to zoom
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _matrix.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      shouldRotate: false,
      onMatrixUpdate: (m, tm, sm, rm) {
        if (_viewportWidth == null) {
          m.setIdentity();
          return;
        }
        if (m.getMaxScaleOnAxis() == 1) {
          m.splatDiagonal(1);
        } else if (m.getMaxScaleOnAxis() > widget.maxScale) {
          m.setEntry(0, 0, widget.maxScale);
          m.setEntry(1, 1, widget.maxScale);
          m.setTranslation(_matrix.value.getTranslation());
        }
        final scale = m.getMaxScaleOnAxis();
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
        double x = m.getTranslation().x;
        double y = m.getTranslation().y;
        x = min(maxX, max(x, minX));
        y = min(maxY, max(y, minY));
        m.setTranslationRaw(x, y, 0);
        _matrix.value = m;
      },
      child: ValueListenableBuilder<Matrix4>(
        valueListenable: _matrix,
        builder: (context, value, child) {
          return Transform(
            transform: value,
            child: child,
          );
        },
        child: CustomImage(
          widget.image,
          key: _key,
          fit: BoxFit.contain,
          placeholderColor: Theme.of(context).dividerColor,
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
    );
  }
}
