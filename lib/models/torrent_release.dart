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
    final parsed = FlutterAnitomy().parse(title);

    for (final info in parsed.getAll(ElementKind.releaseInformation)) {
      final l = info.toLowerCase();
      if (l.contains('batch') || l.contains('complete')) return true;
    }

    final episodes = parsed.getAll(ElementKind.episode);
    if (episodes.length >= 2) return true;

    final hasSeason = parsed.getAll(ElementKind.season).isNotEmpty;
    return hasSeason && episodes.isEmpty;
  }
}
