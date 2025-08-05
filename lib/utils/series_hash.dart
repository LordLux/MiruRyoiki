import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/series.dart';

String computeSeriesHash(Series s) {
  final minimal = {
    'name': s.name,
    'path': s.path.path,
    'seasons': s.seasons
        .map((se) => {
              'name': se.name,
              'path': se.path.path,
                'eps': se.episodes
                  .map((e) => {
                    'path': e.path.path,
                    'watchedPercentage': e.watchedPercentage,
                    'watched': e.watched,
                    'thumbnailUnavailable': e.thumbnailUnavailable,
                    'thumbnailPath': e.thumbnailPath,
                    'name': e.name,
                    'metadata': e.metadata?.toJson(),
                    'mkvMetadata': e.mkvMetadata?.toJson(),
                    }) //TODO should be fixed now after adding metadata to hash: it was skipping saving because series was 'not dirty' as metadata was not included in the hash
                  .toList(),
            })
        .toList(),
    'mappings': s.anilistMappings
        .map((m) => {
              'local': m.localPath.path,
              'id': m.anilistId,
            })
        .toList(),
  };
  final jsonStr = jsonEncode(minimal);
  return sha256.convert(utf8.encode(jsonStr)).toString();
}
