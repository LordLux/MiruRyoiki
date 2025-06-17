import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/logging.dart';
import '../../utils/path_utils.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Cache directory
  Directory? _cacheDir;
  bool _initialized = false;

  // Initialize cache directory
  Future<void> init() async {
    if (_initialized) return;

    final dir = miruRyoiokiSaveDirectory;
    _cacheDir = Directory('${dir.path}/image_cache');

    if (!await _cacheDir!.exists()) //
      await _cacheDir!.create(recursive: true);

    _initialized = true;
  }

  // Generate a filename from URL using MD5 hash
  String _getFilenameFromUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    final extension = url.split('.').last.split('?').first;

    return '${digest.toString()}.$extension';
  }

  // Check if image is cached
  Future<bool> isCached(String url) async {
    if (!_initialized) await init();

    final filename = _getFilenameFromUrl(url);
    final file = File('${_cacheDir!.path}/$filename');

    return await file.exists();
  }

  // Get cached image as file
  Future<File?> getCachedImageFile(String url) async {
    if (!_initialized) await init();

    final filename = _getFilenameFromUrl(url);
    final file = File('${_cacheDir!.path}/$filename');

    if (await file.exists()) return file;

    return null;
  }

  // Get image from cache or download it
  Future<File?> getImage(String url) async {
    final cachedFile = await getCachedImageFile(url);

    if (cachedFile != null) return cachedFile;

    // Download and cache the image
    return await cacheImage(url);
  }

  // Download and cache an image
  Future<File?> cacheImage(String url) async {
    if (!_initialized) await init();

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final filename = _getFilenameFromUrl(url);
        final file = File('${_cacheDir!.path}/$filename');

        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      logErr('Failed to cache image', e);
    }
    return null;
  }

  // Get file path if cached, otherwise null
  Future<String?> getCachedImagePath(String url) async {
    final file = await getCachedImageFile(url);
    return file?.path;
  }

  // Get image provider (either from cache or network)
  Future<ImageProvider> getImageProvider(String url) async {
    final cachedFile = await getCachedImageFile(url);

    if (cachedFile != null) return FileImage(cachedFile);

    // Start caching in background but return network image for immediate display
    cacheImage(url);
    return CachedNetworkImageProvider(url, errorListener: (error) => logWarn('Failed to load image from network: $error'));
  }

  // Clear cache
  Future<void> clearCache() async {
    if (!_initialized) await init();

    final files = await _cacheDir!.list().toList();
    for (final file in files) {
      if (file is File) //
        await file.delete();
    }
  }
}
