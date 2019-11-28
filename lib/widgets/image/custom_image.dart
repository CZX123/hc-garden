import 'dart:ui' as ui show Codec;
import '../../library.dart';

/// This is a mixture of [FileImage] and [NetworkImage].
/// It will download the image from the url once, save it locally in the file system,
/// and then use it from there in the future.
///
/// In more detail:
///
/// Given a file and url of an image, it first tries to read it from the local file.
/// It decodes the given [File] object as an image, associating it with the given scale.
///
/// However, if the image doesn't yet exist as a local file, it fetches the given URL
/// from the network, associating it with the given scale, and then saves it to the local file.
/// The image will be cached regardless of cache headers from the server.
///
/// Notes:
///
/// - If the provided url is null or empty, [NetworkToFileImage] will default
/// to [FileImage]. It will read the image from the local file, and won't try to
/// download it from the network.
///
/// - If the provided file is null, [NetworkToFileImage] will default
/// to [NetworkImage]. It will download the image from the network, and won't
/// save it locally.
///
/// - If you make debug=true it will print to the console whether the image was
/// read from the file or fetched from the network.
class NetworkToFileImage extends ImageProvider<NetworkToFileImage> {
  const NetworkToFileImage({
    @required this.file,
    @required this.url,
    this.scale = 1.0,
    this.headers,
    this.debug = false,
  })  : assert(file != null || url != null),
        assert(scale != null);

  final File file;
  final String url;
  final double scale;
  final Map<String, String> headers;
  final bool debug;

  @override
  Future<NetworkToFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkToFileImage>(this);
  }

  @override
  ImageStreamCompleter load(NetworkToFileImage key) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: () sync* {
          yield ErrorDescription('Image provider: $this');
          yield ErrorDescription('File: ${file?.path}');
          yield ErrorDescription('Url: $url');
        });
  }

  Future<ui.Codec> _loadAsync(NetworkToFileImage key) async {
    assert(key == this);
    // ---

    Uint8List bytes;

    // // Runs both futures in parallel, and which ever one completes faster provides the bytes.
    // bytes = await Future.any<Uint8List>([
    //   // Reads from the local file.
    //   if (file != null && _ifFileExistsLocally()) _readFromTheLocalFile(),
    //   // Reads from the network and saves it to the local file.
    //   if (url != null && url.isNotEmpty) _downloadFromTheNetworkAndSaveToTheLocalFile(),
    // ]);

    // Reads from the local file.
    if (file != null && _ifFileExistsLocally()) {
      bytes = await _readFromTheLocalFile();
    }

    // Reads from the network and saves it to the local file.
    else if (url != null && url.isNotEmpty) {
      bytes = await _downloadFromTheNetworkAndSaveToTheLocalFile();
    }

    // ---

    // Empty file.
    if ((bytes != null) && (bytes.lengthInBytes == 0)) bytes = null;

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  bool _ifFileExistsLocally() => file.existsSync();

  Future<Uint8List> _readFromTheLocalFile() async {
    if (debug) print("Reading image file: ${file?.path}");
    return await file.readAsBytes();
  }

  static final HttpClient _httpClient = HttpClient();

  Future<Uint8List> _downloadFromTheNetworkAndSaveToTheLocalFile() async {
    assert(url != null && url.isNotEmpty);
    if (debug) print("Fetching image from: $url");
    // ---

    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw Exception('HTTP request failed, '
          'statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) {
      throw Exception('NetworkImage is an empty file: $resolved');
    }

    if (file != null) saveImageToTheLocalFile(bytes);

    return bytes;
  }

  void saveImageToTheLocalFile(Uint8List bytes) async {
    if (debug) print("Saving image to file: ${file?.path}");
    file.writeAsBytes(bytes, flush: true);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkToFileImage typedOther = other;
    return url == typedOther.url &&
        file?.path == typedOther.file?.path &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, file?.path, scale);

  @override
  String toString() => '$runtimeType("${file?.path}", "$url", scale: $scale)';
}

class CustomImage extends StatefulWidget {
  final String url;
  final Uint8List fallbackMemoryImage;
  final Color placeholderColor;
  final Duration timeout;
  final BoxFit fit;
  final double width;
  final double height;
  final Duration fadeInDuration;
  final bool saveInCache;
  final void Function(double aspectRatio) onLoad;
  CustomImage(
    this.url, {
    Key key,
    this.fallbackMemoryImage,
    this.placeholderColor,
    this.timeout: const Duration(seconds: 10),
    this.fit: BoxFit.cover,
    this.width,
    this.height,
    this.fadeInDuration: const Duration(milliseconds: 200),
    this.saveInCache,
    this.onLoad,
  }) : super(key: key);

  @override
  _CustomImageState createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  bool _init = false;
  ImageProvider _imageProvider;
  String _dirPath;
  bool _isFadingIn;

  void _resolveImage([Duration _]) {
    _imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((image, synchronousCall) {
        if (mounted) widget.onLoad(image.image.width / image.image.height);
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _dirPath = Provider.of<Directory>(context)?.path;
      if (_dirPath == null) return;
      final filePath = widget.url.split('/').last;
      final file = File('$_dirPath/$filePath');
      _isFadingIn =
          (widget?.fadeInDuration ?? Duration.zero) != Duration.zero &&
              !file.existsSync();
      _imageProvider = NetworkToFileImage(
        file: file,
        url: widget.url,
      );
      if (widget.onLoad != null)
        WidgetsBinding.instance.addPostFrameCallback(_resolveImage);
      _init = true;
    }
  }

  @override
  void didUpdateWidget(CustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      final filePath = widget.url.split('/').last;
      final file = File('$_dirPath/$filePath');
      _isFadingIn =
          (widget?.fadeInDuration ?? Duration.zero) != Duration.zero &&
              !file.existsSync();
      _imageProvider = NetworkToFileImage(
        file: file,
        url: widget.url,
      );
      if (widget.onLoad != null)
        WidgetsBinding.instance.addPostFrameCallback(_resolveImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.placeholderColor,
      width: widget.width,
      height: widget.height,
      child: _dirPath == null
          ? null
          : _isFadingIn
              ? FadeInImage(
                  fadeInDuration: widget.fadeInDuration,
                  placeholder: MemoryImage(kTransparentImage),
                  image: _imageProvider,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                )
              : Image(
                  gaplessPlayback: true,
                  image: _imageProvider,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                ),
    );
  }
}
