import 'package:flutter_anitomy/flutter_anitomy.dart';

import '../utils/units.dart';

part 'knaben/knaben_release.dart';
part 'sonarr/sonarr_release.dart';

/// Common surface for torrent search results, regardless of provider
///
/// `Knaben` and `Sonarr` both return torrent releases but with different field
/// names (e.g. Knaben's `bytes` vs Sonarr's `size`)
///
/// This base normalizes the shared subset for UI code; provider-specific extras
/// (magnet URLs, Sonarr rejections, virus scores, ...) stay on the subclasses
sealed class TorrentRelease {
  TorrentRelease();

  String get title;
  String get quality;
  int get seeders;
  int get bytes;
  int get peers;
  String get tracker;

  /// Whether the release is likely a multi-episode / season pack
  ///
  /// Uses the Anitomy parser instead of a hand-written regex so we benefit
  /// from its tokenizer's understanding of bracket context, keyword boundaries,
  /// and episode-range expansion
  ///
  /// Detection rules:
  /// - Anitomy emits a `ReleaseInformation` element with `Batch`/`Complete`
  /// - Anitomy emits multiple `Episode` elements (range like `01-12`)
  /// - Anitomy emits a `Season` element with no `Episode` (whole-season pack)
  ///
  /// Cached so we only pay the FFI cost once per instance
  late final bool isLikelyBatch = _computeIsLikelyBatch();

  bool _computeIsLikelyBatch() {
    try {
      final parsed = FlutterAnitomy().parse(title);

      for (final info in parsed.getAll(ElementKind.releaseInformation)) {
        final l = info.toLowerCase();
        if (l.contains('batch') || l.contains('complete')) return true;
      }

      final episodes = parsed.getAll(ElementKind.episode);
      if (episodes.length >= 2) return true;

      final hasSeason = parsed.getAll(ElementKind.season).isNotEmpty;
      return hasSeason && episodes.isEmpty;
    } catch (_) {
      // Anitomy's native library can be unavailable (unit tests, or a failed
      // plugin load at runtime). Fall back to a title heuristic instead of
      // letting batch detection throw.
      return _heuristicIsLikelyBatch();
    }
  }

  bool _heuristicIsLikelyBatch() {
    if (RegExp(r'\b(batch|complete)\b', caseSensitive: false).hasMatch(title)) return true;
    // Episode range, e.g. "01-12" / "01~12".
    if (RegExp(r'\b\d{1,4}\s*[-~]\s*\d{1,4}\b').hasMatch(title)) return true;
    // A season marker with no single-episode marker reads as a whole-season pack.
    final hasSeason = RegExp(r'(\bS\d{1,2}\b|\bseason\s+\d+)', caseSensitive: false).hasMatch(title);
    final hasSingleEpisode = RegExp(r'(\bS\d{1,2}E\d{1,4}\b|\bE\d{1,4}\b|\bepisode\s+\d+)', caseSensitive: false).hasMatch(title);
    return hasSeason && !hasSingleEpisode;
  }
}
