import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

Future<Size> getImageDimensions(ImageProvider? imageProvider) async {
  if (imageProvider == null) return const Size(0, 0); // Default size if no image provider

  final Completer<Size> completer = Completer<Size>();

  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  final ImageStreamListener listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    },
    onError: (exception, stackTrace) {
      completer.complete(const Size(230, 326)); // Default size on error
    },
  );

  stream.addListener(listener);

  // Make sure to remove the listener when done
  return completer.future.then((size) {
    stream.removeListener(listener);
    return size;
  });
}
