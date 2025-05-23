import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide Image;
import 'dart:typed_data';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_custom_cursor/cursor_manager.dart';
import 'package:flutter_custom_cursor/flutter_custom_cursor.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img2;

late String systemMouseCursorGrab;
late String systemMouseCursorGrabbing;

Future<void> initSystemMouseCursor() async {
  systemMouseCursorGrab = await _loadCustomMouseCursor("assets/system/grab.png");
  systemMouseCursorGrabbing = await _loadCustomMouseCursor("assets/system/grabbing.png");
}

Future<void> disposeSystemMouseCursor() async {
  await CursorManager.instance.deleteCursor(systemMouseCursorGrab);
  await CursorManager.instance.deleteCursor(systemMouseCursorGrabbing);
}

Future<String> _loadCustomMouseCursor(String cursorImagePath) async {
  final name = basename(cursorImagePath).split('.').first;

  final byte = await rootBundle.load(cursorImagePath);
  final Uint8List memoryCursorDataRawPNG = byte.buffer.asUint8List();
  final img2.Image img = img2.decodePng(memoryCursorDataRawPNG)!;
  final Uint8List memoryCursorDataRawBGRA = _decodeBGRA(img);

  return await CursorManager.instance.registerCursor(
    CursorData()
      ..name = name
      ..buffer = Platform.isWindows ? memoryCursorDataRawBGRA : memoryCursorDataRawPNG
      ..height = img.height
      ..width = img.width
      ..hotX = img.width / 3
      ..hotY = img.height / 3,
  );
}

Uint8List _decodeBGRA(img2.Image img) {
  final Uint8List memoryCursorDataRawBGRA = Uint8List(img.width * img.height * 4);
  int index = 0;
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      final pixel = img.getPixel(x, y);
      // Extract RGBA components
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt();

      // Write as BGRA
      memoryCursorDataRawBGRA[index++] = b; // Blue
      memoryCursorDataRawBGRA[index++] = g; // Green
      memoryCursorDataRawBGRA[index++] = r; // Red
      memoryCursorDataRawBGRA[index++] = a; // Alpha
    }
  }
  return memoryCursorDataRawBGRA;
}
