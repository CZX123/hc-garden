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
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.decelerate,
      )),
      child: Material(
        color: Colors.black,
        clipBehavior: Clip.hardEdge,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -.97),
            end: Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.decelerate,
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
    );
  }
}

class ZoomableImage extends StatefulWidget {
  final String image;
  const ZoomableImage({Key key, this.image}) : super(key: key);

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

enum ScaleDirection { inward, outward }

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  // bool _ended = false;
  AnimationController _animationController;
  double _startingScale = 1.0;
  // ScaleDirection _scaleDirection;
  final _minScale = 1.0;
  // final _maxScale = 5.0; TODO
  final _maxScale = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      lowerBound: _minScale,
      upperBound: _maxScale,
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
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      // onScaleStart: (details) {
      //   _ended = false;
      // },
      onScaleUpdate: (details) {
        final _newValue = _startingScale * details.scale;
        // if (_animationController.value < _newValue) {
        //   _scaleDirection = ScaleDirection.inward;
        // } else {
        //   _scaleDirection = ScaleDirection.outward;
        // }
        _animationController.value = _newValue;
      },
      onScaleEnd: (details) {
        // print(_scaleDirection);
        // if (_ended) return;
        // _ended = true;
        // final simulation = BoundedFrictionSimulation(
        //   0.135,
        //   _animationController.value,
        //   (_scaleDirection == ScaleDirection.inward ? -1 : 1) *
        //       details.velocity.pixelsPerSecond.distance /
        //       width,
        //   _minScale,
        //   _maxScale,
        // );
        // _startingScale = simulation.finalX;
        // _animationController.animateWith(simulation);
        _startingScale = _animationController.value;
      },
      child: ValueListenableBuilder(
        valueListenable: _animationController.view,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: CustomImage(
          widget.image,
          fit: BoxFit.contain,
          placeholderColor: Theme.of(context).dividerColor,
          saveInCache: false,
        ),
      ),
    );
  }
}
