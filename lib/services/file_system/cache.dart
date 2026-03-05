import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/logging.dart';
import '../../utils/path.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Cache directory
  Directory? _cacheDir;
  bool _initialized = false;

  /// Track in-flight downloads to prevent duplicate concurrent requests
  /// for the same URL (which can cause partial-write / corrupt-file issues).
  final Map<String, Future<File?>> _inFlightDownloads = {};

  // Initialize cache directory
  Future<void> init() async {
    if (_initialized) return;

    final dir = miruRyoikiSaveDirectory;
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

  // Get cached image as file (validates non-empty)
  Future<File?> getCachedImageFile(String url) async {
    if (!_initialized) await init();
    if (url.isEmpty) return null;

    final filename = _getFilenameFromUrl(url);
    final file = File('${_cacheDir!.path}/$filename');

    if (await file.exists()) {
      // Validate the cached file is not empty / corrupt stub
      final length = await file.length();
      if (length == 0) {
        await file.delete().catchError((_) => file);
        return null;
      }
      return file;
    }

    return null;
  }

  // Get image from cache or download it
  Future<File?> getImage(String url) async {
    if (url.isEmpty) return null;
    final cachedFile = await getCachedImageFile(url);

    if (cachedFile != null) return cachedFile;

    // Download and cache the image
    return await cacheImage(url);
  }

  // Download and cache an image (deduplicates concurrent requests for the same URL)
  Future<File?> cacheImage(String url) async {
    if (!_initialized) await init();
    if (url.isEmpty) return null;

    // If a download for this URL is already in-flight, await it instead of
    // starting a second concurrent write to the same file.
    if (_inFlightDownloads.containsKey(url)) return _inFlightDownloads[url];

    final future = _doCacheImage(url);
    _inFlightDownloads[url] = future;

    try {
      return await future;
    } finally {
      _inFlightDownloads.remove(url);
    }
  }

  Future<File?> _doCacheImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final filename = _getFilenameFromUrl(url);
        final targetFile = File('${_cacheDir!.path}/$filename');

        // Write to a temporary file first, then rename – ensures we never
        // expose a partially-written file to concurrent readers.
        final tmpFile = File('${targetFile.path}.tmp');
        await tmpFile.writeAsBytes(response.bodyBytes, flush: true);
        await tmpFile.rename(targetFile.path);
        return targetFile;
      }
    } catch (e) {
      logErr('Failed to cache image', e);
    }
    return null;
  }

  // Get file path if cached, otherwise null
  Future<String?> getCachedImagePath(String? url) async {
    if (url == null) return null;

    final file = await getCachedImageFile(url);
    return file?.path;
  }

  // Get image provider (either from cache or network)
  Future<ImageProvider?> getImageProvider(String url) async {
    if (url.isEmpty) return null;

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

  // Get cache directory size in bytes
  Future<int> getCacheSize() async {
    if (!_initialized) await init();
    
    int totalSize = 0;
    final files = await _cacheDir!.list().toList();
    for (final file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }
}
