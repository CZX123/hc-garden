import 'library.dart';

// General Functions

/// Lowers the resolution of full-sized imgur images by appending
/// a 'h' at the end of the link. Returns the correctly resized link.
String lowerRes(String image) {
  if (image.isEmpty) return '';
  var split = image.split('.');
  final end = '.' + split.removeLast();
  return split.join('.') + 'h' + end;
}

// Type Extensions for convenience, more readable and less code

extension BuildContextExtension on BuildContext {

  /// Shorter form of `Provider.of<T>(context)]`
  T provide<T>({bool listen = true}) {
    return Provider.of<T>(this, listen: listen);
  }
}