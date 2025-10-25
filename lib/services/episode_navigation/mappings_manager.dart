
import 'package:collection/collection.dart';

import '../../models/anilist/mapping.dart';
import '../../models/season.dart';
import '../../models/series.dart';

class MappingsManager {
  static MappingsManager? _instance;
  static MappingsManager get instance => _instance ??= MappingsManager._internal();
  MappingsManager._internal();

  static AnilistMapping? getMappingFromSeason(Season season, Series series) {
    return series.anilistMappings.firstWhereOrNull((mapping) => mapping.localPath.path == season.path.path);
  }
}