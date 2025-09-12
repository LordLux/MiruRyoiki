import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:miruryoiki/main.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/services/file_system/cache.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/utils/path_utils.dart';
import 'package:miruryoiki/utils/time_utils.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/utils/color_utils.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Calculate dominant color', () async {
    // Initialize the app
    rootIsolateToken = RootIsolateToken.instance;

    // Create a test series with both poster and banner
    final testSeries = Series(
      name: 'A Place Further Than The Universe',
      path: PathString(r'M:\Videos\Series\A Place Further Than The Universe'),
      seasons: [],
      anilistBanner: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/99426-KsFVCSwVC3x3.jpg',
      anilistPoster: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx99426-ti5BL69Ip3kZ.png',
      anilistMappings: [
        AnilistMapping(
          anilistId: 99426,
          localPath: PathString(r'M:\Videos\Series\A Place Further Than The Universe'),
          anilistData: AnilistAnime(id: 99426, title: AnilistTitle(romaji: 'Sora yori mo Tooi Basho', english: 'A Place Further Than The Universe', native: '宇宙よりも遠い場所')),
          title: 'A Place Further Than The Universe',
          lastSynced: now,
        ),
      ],
      primaryAnilistId: 99426,
    );

    await _calculateDominantColor(testSeries, true);
    await _calculateDominantColor(testSeries, false);
  });
}

Future<void> _calculateDominantColor(Series series, bool isPoster) async {
  // Test the calculateDominantColorsWithProgress function
  print('Testing color calculation with ${isPoster ? "Poster" : "Banner"} source...: ${await ImageCacheService().getCachedImagePath(series.anilistBannerUrl ?? '')}');

  final results = await calculateDominantColorsWithProgress(
    series: [series],
    forceRecalculate: true,
    dominantColorSourceIndex: isPoster ? DominantColorSource.poster.index : DominantColorSource.banner.index,
    onStart: () => print('Starting calculation...'),
    onProgress: (processed, total) => print('Progress: $processed/$total'),
  );

  final seriesName = results.isNotEmpty ? results.entries.first.key : 'No series';
  final colorString = results.isNotEmpty ? Color(results.entries.first.value.entries.first.value).toHex(leadingHashSign: false) : null;
  final color = Color("0xFF$colorString".toInt());
  final wasChanges = results.isNotEmpty ? results.entries.first.value.entries.last.value : false;
  logMulti([
    ['Series: $seriesName, new color: '],
    [' #$colorString ', determineTextColor(color), color],
    [' was changed: $wasChanges']
  ]);
}
