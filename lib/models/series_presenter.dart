// ignore_for_file: library_prefixes

import 'dart:io';

import 'package:flutter/widgets.dart' hide Image;
import 'package:collection/collection.dart';

import '../manager.dart';
import '../services/file_system/cache.dart';
import '../utils/color.dart' as colorUtils;
import '../utils/logging.dart';
import '../utils/path.dart';
import '../enums.dart';
import 'episode.dart';
import 'series.dart';

/// Handles all image resolution, color computation, and display logic for a [Series]
class SeriesPresenter {
  final Series _series;

  /// Cached dominant color from poster image
  Color? _localPosterDominantColor;

  /// Cached dominant color from banner image
  Color? _localBannerDominantColor;

  /// Preferred source for the Poster
  ImageSource? preferredPosterSource;

  /// Preferred source for the Banner
  ImageSource? preferredBannerSource;

  /// Cached URL for Anilist Poster
  String? _anilistPosterUrl;

  /// Cached URL for Anilist Banner
  String? _anilistBannerUrl;

  /// Poster path for the series from the File System
  PathString? localPosterPath;

  /// Banner path for the series from the File System
  PathString? localBannerPath;

  SeriesPresenter(
    this._series, {
    Color? posterColor,
    Color? bannerColor,
    this.preferredPosterSource,
    this.preferredBannerSource,
    String? anilistPosterUrl,
    String? anilistBannerUrl,
    this.localPosterPath,
    this.localBannerPath,
  })  : _localPosterDominantColor = posterColor,
        _localBannerDominantColor = bannerColor,
        _anilistPosterUrl = anilistPosterUrl,
        _anilistBannerUrl = anilistBannerUrl;

  // Serialization support
  /// Raw stored poster color
  /// May be null even when [localPosterColor] isn't
  Color? get rawPosterColor => _localPosterDominantColor;

  /// Raw stored banner color
  /// May be null even when [localBannerColor] isn't
  Color? get rawBannerColor => _localBannerDominantColor;

  /// Raw stored Anilist poster URL
  /// May be null even when [anilistPosterUrl] isn't
  String? get rawAnilistPosterUrl => _anilistPosterUrl;

  /// Raw stored Anilist banner URL
  /// May be null even when [anilistBannerUrl] isn't
  String? get rawAnilistBannerUrl => _anilistBannerUrl;

  /// Update the cached Anilist image URLs
  void updateAnilistUrls({String? poster, String? banner}) {
    _anilistPosterUrl = poster;
    _anilistBannerUrl = banner;
  }

  /// Serialize presenter state to JSON
  Map<String, dynamic> toJson() => {
        'posterPath': localPosterPath?.pathMaybe,
        'bannerPath': localBannerPath?.pathMaybe,
        'posterColor': _localPosterDominantColor?.value,
        'bannerColor': _localBannerDominantColor?.value,
        'anilistPosterUrl': _anilistPosterUrl ?? _series.anilistData?.posterImage,
        'anilistBannerUrl': _anilistBannerUrl ?? _series.anilistData?.bannerImage,
        'preferredPosterSource': preferredPosterSource?.name_,
        'preferredBannerSource': preferredBannerSource?.name_,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeriesPresenter) return false;
    return other._localPosterDominantColor == _localPosterDominantColor && //
        other._localBannerDominantColor == _localBannerDominantColor &&
        other.preferredPosterSource == preferredPosterSource &&
        other.preferredBannerSource == preferredBannerSource &&
        other._anilistPosterUrl == _anilistPosterUrl &&
        other._anilistBannerUrl == _anilistBannerUrl &&
        other.localPosterPath == localPosterPath &&
        other.localBannerPath == localBannerPath;
  }

  @override
  int get hashCode => Object.hash(
        _localPosterDominantColor,
        _localBannerDominantColor,
        preferredPosterSource,
        preferredBannerSource,
        _anilistPosterUrl,
        _anilistBannerUrl,
        localPosterPath,
        localBannerPath,
      );

  //Display
  /// Official title from Anilist, with season indicators removed
  /// Falls back to the series folder name
  /// TODO see if this could be skipped to show more information to the user
  String get displayTitle {
    // Helper: Remove season indicators in various languages/scripts
    String removeSeasonIndicators(String input) {
      // Patterns for season indicators in English, Japanese, Romaji, etc.
      final patterns = [
        RegExp(r'(?:Season|S|Seasons?|Part|Cour|Vol(?:ume)?|Chapter|Ch)\s*\d+', caseSensitive: false),
        RegExp(r'(?:第\s*\d+\s*(?:期|シーズン|部|章|クール|巻))'), // Japanese: 第1期, 第2部, etc.
        RegExp(r'(?:シーズン|クール|パート|章|巻)\s*\d+'), // Japanese: シーズン2, クール1, etc.
        RegExp(r'(?:kikaku|ki|bu|shou|kuru|kan)\s*\d+', caseSensitive: false), // Romaji
        RegExp(r'(?:\d+\s*(?:期|シーズン|部|章|クール|巻))'), // Japanese: 2期, 3部, etc.
        RegExp(r'[\(\[]\s*(?:Season|S|Seasons?|Part|Cour|Vol(?:ume)?|Chapter|Ch|第\d+期|シーズン\d+|クール\d+|パート\d+|章\d+|巻\d+)\s*[\)\]]', caseSensitive: false),
      ];

      String result = input;
      for (final pattern in patterns) {
        result = result.replaceAll(pattern, '');
      }
      // Remove extra whitespace and trailing punctuation
      result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
      result = result.replaceAll(RegExp(r'[\-–—:：,;]+$'), '').trim();
      return result;
    }

    final title = (_series.currentAnilistData?.title.userPreferred ?? _series.currentAnilistData?.title.english ?? _series.currentAnilistData?.title.romaji ?? _series.name);

    return removeSeasonIndicators(title);
  }

  /// Banner image URL from Anilist
  String? get bannerImage => _series.currentAnilistData?.bannerImage;

  /// Poster image URL from Anilist
  String? get posterImage => _series.currentAnilistData?.posterImage;

  // Color
  /// Get primary color from the series poster image
  /// Falls back to Anilist dominant color if locally calculated color is unavailable
  Color? get localPosterColor {
    if (_localPosterDominantColor != null) return _localPosterDominantColor;

    // Fall back to Anilist color if locally calculated color is not available
    return _series.anilistData?.dominantColor?.fromHex();
  }

  /// Get primary color from the series banner image
  /// Falls back to Anilist dominant color if locally calculated color is unavailable
  Color? get localBannerColor {
    if (_localBannerDominantColor != null) return _localBannerDominantColor;

    // Fall back to Anilist color if locally calculated color is not available
    return _series.anilistData?.dominantColor?.fromHex();
  }

  Future<void> calculateLocalPosterDominantColor({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(_series, forceRecalculate: forceRecalculate);
    if (result.$2 == true) _localPosterDominantColor = result.$1?.$1 ?? _localPosterDominantColor; // override if new, othewise keep old
  }

  Future<void> calculateLocalBannerDominantColor({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(_series, forceRecalculate: forceRecalculate);
    if (result.$2 == true) _localBannerDominantColor = result.$1?.$2 ?? _localBannerDominantColor; // override if new, othewise keep old
  }

  Future<void> calculateLocalDominantColors({bool forceRecalculate = false}) async {
    final result = await colorUtils.calculateLocalDominantColors(_series, forceRecalculate: forceRecalculate);
    if (result.$2 == true) {
      _localPosterDominantColor = result.$1?.$1 ?? _localPosterDominantColor; // override if new, othewise keep old
      _localBannerDominantColor = result.$1?.$2 ?? _localBannerDominantColor; // override if new, othewise keep old
    }
  }

  Future<void> clearCachedDominantColors() async {
    _localPosterDominantColor = null;
    _localBannerDominantColor = null;
  }

  // Image URLs
  /// Get the Anilist poster URL
  String? get anilistPosterUrl => _anilistPosterUrl ?? _series.anilistData?.posterImage;

  /// Get the Anilist banner URL
  String? get anilistBannerUrl => _anilistBannerUrl ?? _series.anilistData?.bannerImage;

  // Poster image resolution
  /// Get the effective poster path based on source preference
  String? get effectivePosterPath {
    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = anilistPosterUrl != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local poster is preferred but not available, fall back to Anilist poster if it exists
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? anilistPosterUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist poster is preferred but not available, fall back to local poster if it exists
        return hasAnilistPoster ? anilistPosterUrl : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image as an ImageProvider
  Future<ImageProvider?> getPosterImage({int? targetWidthPx}) async {
    final path = effectivePosterPath;

    if (path == null) return null;
    if (isLocalPosterBeingUsed) return FileImage(File(path));
    if (isAnilistPosterBeingUsed) return await ImageCacheService().getImageProvider(_anilistCoverVariant(path, targetWidthPx));
    return null;
  }

  /// AniList serves cover images at fixed sizes embedded in the URL path:
  /// `/cover/small/` (100x141), `/cover/medium/` (230x325) and
  /// `/cover/large/` (460x650) — there is no `/cover/extraLarge/` (the
  /// GraphQL `extraLarge` field itself returns a `/cover/large/` URL, so the
  /// stored poster URL is already the largest that exists). Given the target
  /// display width in physical pixels, swap whichever size segment the URL
  /// has to the smallest one that still covers it. Unknown URL shapes or a
  /// null target are returned unchanged (safe fallback).
  String _anilistCoverVariant(String url, int? targetWidthPx) {
    if (targetWidthPx == null) return url;

    final String desired = targetWidthPx <= 100 ? 'small' : (targetWidthPx <= 230 ? 'medium' : 'large');
    for (final seg in const ['small', 'medium', 'large']) {
      final needle = '/cover/$seg/';
      if (url.contains(needle)) return url.replaceFirst(needle, '/cover/$desired/');
    }
    return url;
  }

  /// Get the effective poster path for a specific episode
  String? getEffectivePosterPathForEpisode(Episode episode) {
    final mapping = _series.getMappingForEpisode(episode);
    if (mapping == null) {
      logWarn('No mapping found for episode ${episode.episodeNumber} in series ${_series.name}');
      return effectivePosterPath;
    } // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;
    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = mapping.anilistData?.posterImage != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local poster is preferred but not available, fall back to Anilist poster if it exists
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? mapping.anilistData!.posterImage : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist poster is preferred but not available, fall back to local poster if it exists
        return hasAnilistPoster ? mapping.anilistData!.posterImage : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image for a specific episode
  Future<ImageProvider?> getEffectivePosterImageForEpisode(Episode episode) async {
    final path = getEffectivePosterPathForEpisode(episode);
    if (path == null) return null;

    // Check if it's a local path or URL
    if (path.startsWith('http://') || path.startsWith('https://')) //
      return await ImageCacheService().getImageProvider(path);
    // Local file
    return FileImage(File(path));
  }

  /// Get the effective poster color for a specific episode
  /// Uses the episode's corresponding AniList mapping if available
  Color? getEffectivePosterColorForEpisode(Episode episode) {
    final mapping = _series.getMappingForEpisode(episode);
    if (mapping == null) return localPosterColor; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local poster is preferred but not available, fall back to Anilist color if it exists
        return _localPosterDominantColor ?? mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex();

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist poster is preferred but not available, fall back to local color if it exists
        return mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex() ?? _localPosterDominantColor;
    }
  }

  /// Get the effective poster path for a specific AniList ID
  String? getEffectivePosterPathForAnilistId(int anilistId) {
    final mapping = _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
    if (mapping == null) return effectivePosterPath; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;
    final bool hasLocalPoster = localPosterPath != null;
    final bool hasAnilistPoster = mapping.anilistData?.posterImage != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local poster is preferred but not available, fall back to Anilist poster if it exists
        return hasLocalPoster ? localPosterPath?.pathMaybe : (hasAnilistPoster ? mapping.anilistData!.posterImage : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist poster is preferred but not available, fall back to local poster if it exists
        return hasAnilistPoster ? mapping.anilistData!.posterImage : (hasLocalPoster ? localPosterPath?.pathMaybe : null);
    }
  }

  /// Get the effective poster image for a specific AniList ID
  Future<ImageProvider?> getEffectivePosterImageForAnilistId(int anilistId) async {
    final path = getEffectivePosterPathForAnilistId(anilistId);
    if (path == null) return null;

    // Check if it's a local path or URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return await ImageCacheService().getImageProvider(path);
    } else {
      return FileImage(File(path));
    }
  }

  /// Get the effective poster color for a specific AniList ID
  Color? getEffectivePosterColorForAnilistId(int anilistId) {
    final mapping = _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId);
    if (mapping == null) return localPosterColor; // Fallback to primary mapping

    final ImageSource effectiveSource = preferredPosterSource ?? Manager.defaultPosterSource;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local poster is preferred but not available, fall back to Anilist color if it exists
        return _localPosterDominantColor ?? mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex();

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist poster is preferred but not available, fall back to local color if it exists
        return mapping.posterColor ?? mapping.anilistData?.dominantColor?.fromHex() ?? _localPosterDominantColor;
    }
  }

  // Banner image resolution
  /// Get the effective banner path based on source preference
  String? get effectiveBannerPath {
    final ImageSource effectiveSource = preferredBannerSource ?? Manager.defaultBannerSource;

    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    switch (effectiveSource) {
      case ImageSource.autoLocal:
      case ImageSource.local:
        // If local banner is preferred but not available, fall back to Anilist banner if it exists
        return hasLocalBanner ? localBannerPath?.pathMaybe : (hasAnilistBanner ? anilistBannerUrl : null);

      case ImageSource.autoAnilist:
      case ImageSource.anilist:
        // If Anilist banner is preferred but not available, fall back to local banner if it exists
        return hasAnilistBanner ? anilistBannerUrl : (hasLocalBanner ? localBannerPath?.pathMaybe : null);
    }
  }

  /// Get the effective banner image as an ImageProvider
  Future<ImageProvider?> getBannerImage() async {
    final path = effectiveBannerPath;

    if (path == null) return null;
    if (isLocalBannerBeingUsed) return FileImage(File(path));
    if (isAnilistBannerBeingUsed) return await ImageCacheService().getImageProvider(path);
    return null;
  }

  // Source detection
  /// Whether the poster currently in use is from Anilist
  bool get isAnilistPosterBeingUsed {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == anilistPosterUrl;
  }

  /// Whether the poster currently in use is from a local file
  bool get isLocalPosterBeingUsed {
    if (effectivePosterPath == null) return false;
    return effectivePosterPath == localPosterPath?.pathMaybe;
  }

  /// Whether the banner currently in use is from Anilist
  bool get isAnilistBannerBeingUsed {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == anilistBannerUrl;
  }

  /// Whether the banner currently in use is from a local file
  bool get isLocalBannerBeingUsed {
    if (effectiveBannerPath == null) return false;
    return effectiveBannerPath == localBannerPath?.pathMaybe;
  }

  // Primary color resolution
  /// Get the effective primary color based on settings and available images
  Future<Color?> effectivePrimaryColor({int? anilistId, bool forceRecalculate = false, bool? overrideIsPoster}) async {
    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // If overrideIsPoster is provided, it takes precedence over the global setting for this specific color retrieval
    if (overrideIsPoster ?? (Manager.settings.dominantColorSource == DominantColorSource.poster)) {
      switch (preferredPosterSource ?? Manager.defaultPosterSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          // If local poster is preferred but not available, fall back to Anilist color if it exists
          return hasLocalBanner ? _localPosterDominantColor : (hasAnilistBanner ? _series.anilistData?.dominantColor?.fromHex() : null);

        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          // If Anilist poster is preferred but not available, fall back to local color if it exists
          final res = _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == (anilistId ?? _series.primaryAnilistId));
          if (forceRecalculate) return await res?.calculatePosterColor();
          return await res?.posterColorFuture;
      }
    } else {
      switch (preferredBannerSource ?? Manager.defaultBannerSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          // If local banner is preferred but not available, fall back to Anilist color if it exists
          return hasLocalBanner ? _localBannerDominantColor : (hasAnilistBanner ? _series.anilistData?.dominantColor?.fromHex() : null);
        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          // If Anilist banner is preferred but not available, fall back to local color if it exists
          final a = _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == (anilistId ?? _series.primaryAnilistId));
          if (forceRecalculate) return await a?.calculateBannerColor();
          return await a?.bannerColorFuture;
      }
    }
  }

  /// Get the effective primary color synchronously
  /// Returns null if the color is not cached
  Color? effectivePrimaryColorSync([int? anilistId]) {
    final bool hasLocalBanner = localBannerPath != null;
    final bool hasAnilistBanner = anilistBannerUrl != null;

    // For synchronous retrieval, we can only return cached colors
    // If the color is not cached, we return null
    if (Manager.settings.dominantColorSource == DominantColorSource.poster) {
      switch (preferredPosterSource ?? Manager.defaultPosterSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localPosterDominantColor : (hasAnilistBanner ? _series.anilistData?.dominantColor?.fromHex() : null);

        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          return _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId)?.posterColor;
      }
    } else {
      switch (preferredBannerSource ?? Manager.defaultBannerSource) {
        case ImageSource.autoLocal:
        case ImageSource.local:
          return hasLocalBanner ? _localBannerDominantColor : (hasAnilistBanner ? _series.anilistData?.dominantColor?.fromHex() : null);
        case ImageSource.autoAnilist:
        case ImageSource.anilist:
          return _series.anilistMappings.firstWhereOrNull((m) => m.anilistId == anilistId)?.bannerColor;
      }
    }
  }
}
