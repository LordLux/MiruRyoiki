import 'dart:async';
import 'package:flutter/material.dart';

import 'logging.dart';

Future<Size> getImageDimensions(ImageProvider? imageProvider) async {
  if (imageProvider == null) return const Size(0, 0); // Default size if no image provider

  final Completer<Size> completer = Completer<Size>();

  late ImageStreamListener listener;
  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  
  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      if (completer.isCompleted == false) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }
      
      // Delaying the listener removal prevents Flutter's internal ImageStream 
      // from throwing StateErrors caused by modifying listeners during iteration.
      scheduleMicrotask(() {
        stream.removeListener(listener);
      });
    },
    onError: (exception, stackTrace) {
      logErr('Error loading image for dimension retrieval', exception, stackTrace);
      if (completer.isCompleted == false) {
        completer.complete(const Size(230, 326)); // Default size on error
      }
      
      scheduleMicrotask(() {
        stream.removeListener(listener);
      });
    },
  );

  stream.addListener(listener);

  return completer.future;
}