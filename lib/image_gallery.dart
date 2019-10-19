// TODO: Image gallery screen for images in details page
import 'library.dart';

class ImageGallery extends StatelessWidget {
  const ImageGallery({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: null,
      onScaleStart: (details) {
        print(details.localFocalPoint);
      },
      onScaleUpdate: null,
      onScaleEnd: null,

    );
  }
}
