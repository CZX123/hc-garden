import '../../library.dart';

final HttpClient _httpClient = HttpClient();

void saveImageInCache(BuildContext context, String url, Uint8List bytes) {
  var imageMap = Provider.of<Map<String, Uint8List>>(context, listen: false);
  var size = 0;
  imageMap.forEach((key, value) {
    size += value.lengthInBytes;
  });
  while (size > 10000000) {
    size -= imageMap.values.toList()[0].lengthInBytes;
    imageMap.remove(imageMap.keys.toList()[0]);
  }
  imageMap.addAll({url: bytes});
}

Future<Uint8List> fetchImage({
  @required BuildContext context,
  @required String url,
  bool saveInCache = true,
  bool retry = false,
}) async {
  final String filePath = url.replaceAll('/', '-');
  final Directory dir = Provider.of<Directory>(context, listen: false);
  final File file = File('${dir.path}/$filePath');
  if (file.existsSync()) {
    final bytes = file.readAsBytesSync();
    if (saveInCache) saveImageInCache(context, url, bytes);
    _fetchImageFromNetwork(context, url, file, saveInCache, false);
    return bytes;
  }
  return _fetchImageFromNetwork(context, url, file, saveInCache, retry);
}

Future<Uint8List> _fetchImageFromNetwork(
  BuildContext context,
  String url,
  File file,
  bool saveInCache,
  bool retry,
) async {
  while (true) {
    try {
      final Uri resolved = Uri.base.resolve(url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          'HTTP request failed, statusCode: ${response?.statusCode}, $resolved',
        );
      }
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }
      if (saveInCache) saveImageInCache(context, url, bytes);
      file.writeAsBytes(bytes);
      return bytes;
    } catch (e) {
      if (retry) await Future.delayed(const Duration(seconds: 2));
    }
  }
}

// Custom FirebaseImage widget that can be reused for all images in the app
class CustomImage extends StatefulWidget {
  final String url;
  final Uint8List fallbackMemoryImage;
  final Color placeholderColor;
  final Duration timeout;
  final BoxFit fit;
  final double width;
  final double height;
  final Duration fadeInDuration;
  final bool keepAlive;
  final bool saveInCache;
  final void Function(double) onLoad;
  CustomImage(
    this.url, {
    Key key,
    this.fallbackMemoryImage,
    this.placeholderColor,
    this.timeout: const Duration(seconds: 10),
    this.fit: BoxFit.cover,
    this.width,
    this.height,
    this.fadeInDuration: const Duration(milliseconds: 400),
    this.keepAlive: false,
    this.saveInCache: true,
    this.onLoad,
  }) : super(key: key);

  _CustomImageState createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage>
    with AutomaticKeepAliveClientMixin {
  static final HttpClient _httpClient = HttpClient();
  MemoryImage _imageProvider;
  bool networkError = false;
  bool didUpdate = false;
  bool fadeIn = false;
  //int rebuildCount= 0;

  void fetchImageFromStorage(Map<String, Uint8List> imageMap) async {
    final String filePath = widget.url.replaceAll('/', '-');
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$filePath');
    if (file.existsSync()) {
      Uint8List bytes = file.readAsBytesSync();
      if (mounted && (_imageProvider == null || networkError)) {
        setState(() {
          networkError = false;
          fadeIn = false;
          _imageProvider = MemoryImage(bytes);
        });
        onLoadCallback();
      }
      if (widget.saveInCache) {
        var size = 0;
        imageMap.forEach((key, value) {
          size += value.length;
        });
        while (size > 10000000) {
          size -= imageMap.values.toList()[0].length;
          imageMap.remove(imageMap.keys.toList()[0]);
        }
        imageMap.addAll({widget.url: bytes});
      }
    }
  }

  void fetchImageFromNetwork(Map<String, Uint8List> imageMap) async {
    try {
      final Uri resolved = Uri.base.resolve(widget.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception('HTTP request failed, '
            'statusCode: ${response?.statusCode}, $resolved');
      }
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }
      if (mounted && _imageProvider == null) {
        setState(() {
          fadeIn = true;
          _imageProvider = MemoryImage(bytes);
        });
        onLoadCallback();
      }
      if (widget.saveInCache) {
        var size = 0;
        imageMap.forEach((key, value) {
          size += value.lengthInBytes;
        });
        while (size > 10000000) {
          size -= imageMap.values.toList()[0].lengthInBytes;
          imageMap.remove(imageMap.keys.toList()[0]);
        }
        imageMap.addAll({widget.url: bytes});
      }
      final Directory dir = await getApplicationDocumentsDirectory();
      final String filePath = widget.url.replaceAll('/', '-');
      final File file = File('${dir.path}/$filePath');
      file.writeAsBytes(bytes);
    } catch (e) {
      if (mounted && _imageProvider == null) {
        setState(() {
          fadeIn = true;
          networkError = true;
          _imageProvider =
              MemoryImage(widget.fallbackMemoryImage ?? kTransparentImage);
        });
        onLoadCallback();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, Uint8List> imageMap =
        Provider.of<Map<String, Uint8List>>(context);
    if (widget.url == null) {
      _imageProvider =
          MemoryImage(widget.fallbackMemoryImage ?? kTransparentImage);
      onLoadCallback();
    } else if (imageMap.containsKey(widget.url)) {
      // If the provider already has the image associated with
      _imageProvider = MemoryImage(imageMap[widget.url]);
      onLoadCallback();
    } else {
      // These 2 functions below runs in parallel
      fetchImageFromStorage(imageMap);
      fetchImageFromNetwork(imageMap);
    }
  }

  void onLoadCallback() {
    if (widget.onLoad != null) {
      decodeImageFromList(_imageProvider.bytes).then((image) {
        if (mounted) {
          widget.onLoad(image.width / image.height);
        }
      });
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _imageProvider = null;
      if (widget.url == null) {
        _imageProvider =
            MemoryImage(widget.fallbackMemoryImage ?? kTransparentImage);
        onLoadCallback();
      } else {
        didUpdate = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (didUpdate) {
      Map<String, Uint8List> imageMap =
          Provider.of<Map<String, Uint8List>>(context);
      if (imageMap.containsKey(widget.url)) {
        _imageProvider = MemoryImage(imageMap[widget.url]);
        onLoadCallback();
      } else {
        fetchImageFromStorage(imageMap);
        fetchImageFromNetwork(imageMap);
      }
      didUpdate = false;
    }
    super.build(context);
    //rebuildCount += 1;
    //print('Rebuilt: ${widget.url} $rebuildCount times');
    return _imageProvider == null
        ? Container(
            width: widget.width ?? widget.height,
            height: widget.height ?? widget.width,
            decoration: BoxDecoration(
              color: widget.placeholderColor,
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: widget.placeholderColor,
            ),
            child: Image(
              gaplessPlayback: true,
              image: _imageProvider,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              frameBuilder: (context, child, frames, wasSynchronouslyLoaded) {
                if (fadeIn &&
                    !wasSynchronouslyLoaded &&
                    widget.fadeInDuration != null &&
                    widget.fadeInDuration != Duration.zero) {
                  return AnimatedOpacity(
                    opacity: frames == null ? 0 : 1,
                    child: child,
                    duration: widget.fadeInDuration,
                    curve: Curves.easeIn,
                  );
                }
                return child;
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
