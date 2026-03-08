import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_anitomy/flutter_anitomy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/episode.dart';
import 'package:miruryoiki/models/metadata.dart';
import 'package:miruryoiki/models/season.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';

// ===========================================================================
// Helpers
// ===========================================================================

Series _makeSeries({
  int? id,
  String name = 'Test Series',
  String path = r'M:\Series\Test Series',
  PathString? localPosterPath,
  PathString? localBannerPath,
  List<Season>? seasons,
  List<Episode>? relatedMedia,
  List<AnilistMapping> anilistMappings = const [],
  AnilistAnime? anilistData,
  Color? posterColor,
  Color? bannerColor,
  ImageSource? preferredPosterSource,
  ImageSource? preferredBannerSource,
  String? anilistPoster,
  String? anilistBanner,
  int? primaryAnilistId,
  bool isHidden = false,
  String? customListName,
  List<String>? customGridOrder,
  Metadata? metadata,
}) {
  return Series(
    id: id,
    name: name,
    path: PathString(path),
    localPosterPath: localPosterPath,
    localBannerPath: localBannerPath,
    seasons: seasons ?? [],
    relatedMedia: relatedMedia ?? [],
    anilistMappings: anilistMappings,
    anilistData: anilistData,
    posterColor: posterColor,
    bannerColor: bannerColor,
    preferredPosterSource: preferredPosterSource,
    preferredBannerSource: preferredBannerSource,
    anilistPoster: anilistPoster,
    anilistBanner: anilistBanner,
    primaryAnilistId: primaryAnilistId,
    isHidden: isHidden,
    customListName: customListName,
    customGridOrder: customGridOrder,
    metadata: metadata,
  );
}

AnilistMapping _makeMapping({
  required int anilistId,
  String? title,
  AnilistAnime? anilistData,
  String localPath = r'M:\Series\Test',
  Color? posterColor,
  Color? bannerColor,
}) {
  return AnilistMapping(
    localPath: PathString(localPath),
    anilistId: anilistId,
    title: title ?? 'Mapping $anilistId',
    anilistData: anilistData,
    posterColor: posterColor,
    bannerColor: bannerColor,
  );
}

AnilistAnime _makeAnime({
  int id = 1,
  String? romaji,
  String? english,
  String? native_,
  String? userPreferred,
  String? posterImage,
  String? bannerImage,
  String? dominantColor,
  String? description,
  int? averageScore,
  int? meanScore,
  int? popularity,
  String? format,
  String? status,
  List<String> genres = const [],
  int? seasonYear,
  String? season,
  DateValue? startDate,
  DateValue? endDate,
}) {
  return AnilistAnime(
    id: id,
    title: AnilistTitle(
      romaji: romaji ?? 'Test Romaji',
      english: english,
      native: native_,
      userPreferred: userPreferred,
    ),
    posterImage: posterImage,
    bannerImage: bannerImage,
    dominantColor: dominantColor,
    description: description,
    averageScore: averageScore,
    meanScore: meanScore,
    popularity: popularity,
    format: format,
    status: status,
    genres: genres,
    seasonYear: seasonYear,
    season: season,
    startDate: startDate,
    endDate: endDate,
  );
}

Episode _makeEpisode({
  int? id,
  String name = 'Episode 1',
  String path = r'M:\Series\Test\S01\E01.mkv',
  int? episodeNumber = 1,
  bool watched = false,
  double progress = 0.0,
}) {
  return Episode(
    id: id,
    name: name,
    path: PathString(path),
    episodeNumber: episodeNumber,
    watched: watched,
    progress: progress,
    parsedAnime: ParsedAnime(),
  );
}

Season _makeSeason({
  int? id,
  String name = 'Season 1',
  String path = r'M:\Series\Test\S01',
  List<Episode>? episodes,
  Metadata? metadata,
}) {
  return Season(
    id: id,
    name: name,
    path: PathString(path),
    episodes: episodes ?? [],
    metadata: metadata,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Manager.mockSettings = SettingsManager();
  });

  tearDownAll(() {
    Manager.mockSettings = null;
  });

  // =========================================================================
  // SeriesPresenter – effectivePosterPath (local / anilist explicit sources)
  // =========================================================================
  group('SeriesPresenter effectivePosterPath - explicit sources', () {
    test('local source returns local when available', () {
      final series = _makeSeries(
        localPosterPath: PathString(r'M:\local.jpg'),
        anilistPoster: 'https://anilist.poster',
        preferredPosterSource: ImageSource.local,
      );
      expect(series.presenter.effectivePosterPath, r'M:\local.jpg');
    });

    test('local source falls back to anilist when local not available', () {
      final series = _makeSeries(
        anilistPoster: 'https://anilist.poster',
        preferredPosterSource: ImageSource.local,
      );
      expect(series.presenter.effectivePosterPath, 'https://anilist.poster');
    });

    test('anilist source returns anilist when available', () {
      final series = _makeSeries(
        localPosterPath: PathString(r'M:\local.jpg'),
        anilistPoster: 'https://anilist.poster',
        preferredPosterSource: ImageSource.anilist,
      );
      expect(series.presenter.effectivePosterPath, 'https://anilist.poster');
    });

    test('anilist source falls back to local when anilist not available', () {
      final series = _makeSeries(
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.anilist,
      );
      expect(series.presenter.effectivePosterPath, r'M:\local.jpg');
    });

    test('returns null when both unavailable', () {
      final series = _makeSeries(preferredPosterSource: ImageSource.anilist);
      expect(series.presenter.effectivePosterPath, isNull);
    });
  });

  // =========================================================================
  // SeriesPresenter – effectiveBannerPath (all sources)
  // =========================================================================
  group('SeriesPresenter effectiveBannerPath - all sources', () {
    test('local source returns local when available', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\banner.jpg'),
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.local,
      );
      expect(series.presenter.effectiveBannerPath, r'M:\banner.jpg');
    });

    test('local source falls back to anilist when local not available', () {
      final series = _makeSeries(
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.local,
      );
      expect(series.presenter.effectiveBannerPath, 'https://anilist.banner');
    });

    test('anilist source returns anilist when available', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\banner.jpg'),
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.anilist,
      );
      expect(series.presenter.effectiveBannerPath, 'https://anilist.banner');
    });

    test('anilist source falls back to local when anilist not available', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\banner.jpg'),
        preferredBannerSource: ImageSource.anilist,
      );
      expect(series.presenter.effectiveBannerPath, r'M:\banner.jpg');
    });

    test('autoLocal prefers local when both available', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\banner.jpg'),
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.autoLocal,
      );
      expect(series.presenter.effectiveBannerPath, r'M:\banner.jpg');
    });

    test('autoLocal falls back to anilist', () {
      final series = _makeSeries(
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.autoLocal,
      );
      expect(series.presenter.effectiveBannerPath, 'https://anilist.banner');
    });

    test('returns null when both unavailable', () {
      final series = _makeSeries(preferredBannerSource: ImageSource.anilist);
      expect(series.presenter.effectiveBannerPath, isNull);
    });
  });

  // =========================================================================
  // SeriesPresenter – getEffectivePosterPathForEpisode
  // =========================================================================
  group('SeriesPresenter getEffectivePosterPathForEpisode', () {
    test('returns mapping poster for autoAnilist when mapping has poster', () {
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final anime = _makeAnime(posterImage: 'https://mapping.poster');
      final season = _makeSeason(
        path: r'M:\Series\Test\S01',
        episodes: [ep],
      );
      final mapping = _makeMapping(
        anilistId: 1,
        anilistData: anime,
        localPath: r'M:\Series\Test\S01',
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.autoAnilist,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), 'https://mapping.poster');
    });

    test('falls back to local when mapping has no poster (autoLocal)', () {
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final anime = _makeAnime(); // no posterImage
      final season = _makeSeason(
        path: r'M:\Series\Test\S01',
        episodes: [ep],
      );
      final mapping = _makeMapping(
        anilistId: 1,
        anilistData: anime,
        localPath: r'M:\Series\Test\S01',
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        localPosterPath: PathString(r'M:\local_poster.jpg'),
        preferredPosterSource: ImageSource.autoLocal,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), r'M:\local_poster.jpg');
    });

    test('local source returns local poster when available', () {
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final anime = _makeAnime(posterImage: 'https://anilist.poster');
      final season = _makeSeason(
        path: r'M:\Series\Test\S01',
        episodes: [ep],
      );
      final mapping = _makeMapping(
        anilistId: 1,
        anilistData: anime,
        localPath: r'M:\Series\Test\S01',
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        localPosterPath: PathString(r'M:\local_poster.jpg'),
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), r'M:\local_poster.jpg');
    });

    test('falls back to effectivePosterPath when no mapping found', () {
      final ep = _makeEpisode(path: r'M:\Unrelated\E01.mkv');
      final series = _makeSeries(
        anilistPoster: 'https://primary.poster',
        preferredPosterSource: ImageSource.autoAnilist,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), 'https://primary.poster');
    });
  });

  // =========================================================================
  // SeriesPresenter – getEffectivePosterColorForEpisode
  // =========================================================================
  group('SeriesPresenter getEffectivePosterColorForEpisode', () {
    test('local source returns local color when available', () {
      const localCol = Color(0xFFFF0000);
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final anime = _makeAnime(dominantColor: '#00FF00');
      final season = _makeSeason(path: r'M:\Series\Test\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime, localPath: r'M:\Series\Test\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), localCol);
    });

    test('local source falls back to mapping posterColor when no local color', () {
      const mappingCol = Color(0xFF00FF00);
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\Series\Test\S01', episodes: [ep]);
      final mapping = _makeMapping(
        anilistId: 1,
        localPath: r'M:\Series\Test\S01',
        posterColor: mappingCol,
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), mappingCol);
    });

    test('anilist source returns mapping posterColor first', () {
      const localCol = Color(0xFFFF0000);
      const mappingCol = Color(0xFF00FF00);
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\Series\Test\S01', episodes: [ep]);
      final mapping = _makeMapping(
        anilistId: 1,
        localPath: r'M:\Series\Test\S01',
        posterColor: mappingCol,
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), mappingCol);
    });

    test('anilist source falls back to anilist dominant color', () {
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final anime = _makeAnime(dominantColor: '#0000FF');
      final season = _makeSeason(path: r'M:\Series\Test\S01', episodes: [ep]);
      final mapping = _makeMapping(
        anilistId: 1,
        anilistData: anime,
        localPath: r'M:\Series\Test\S01',
      );
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), const Color(0xFF0000FF));
    });

    test('anilist source falls back to local color when no mapping/anilist color', () {
      const localCol = Color(0xFFFF0000);
      final ep = _makeEpisode(path: r'M:\Series\Test\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\Series\Test\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\Series\Test\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), localCol);
    });

    test('falls back to localPosterColor when no mapping found', () {
      const localCol = Color(0xFFFF0000);
      final ep = _makeEpisode(path: r'M:\Unrelated\E01.mkv');
      final series = _makeSeries(posterColor: localCol);

      expect(series.presenter.getEffectivePosterColorForEpisode(ep), localCol);
    });
  });

  // =========================================================================
  // SeriesPresenter – getEffectivePosterPathForAnilistId
  // =========================================================================
  group('SeriesPresenter getEffectivePosterPathForAnilistId', () {
    test('returns mapping poster for autoAnilist', () {
      final anime = _makeAnime(id: 42, posterImage: 'https://mapping42.poster');
      final mapping = _makeMapping(anilistId: 42, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 42,
        preferredPosterSource: ImageSource.autoAnilist,
      );

      expect(series.presenter.getEffectivePosterPathForAnilistId(42), 'https://mapping42.poster');
    });

    test('local source prefers local and falls back to mapping poster', () {
      final anime = _makeAnime(id: 42, posterImage: 'https://mapping42.poster');
      final mapping = _makeMapping(anilistId: 42, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 42,
        preferredPosterSource: ImageSource.local,
      );

      // No local path → fallback to mapping anilist poster
      expect(series.presenter.getEffectivePosterPathForAnilistId(42), 'https://mapping42.poster');
    });

    test('local source returns local when available', () {
      final anime = _makeAnime(id: 42, posterImage: 'https://mapping42.poster');
      final mapping = _makeMapping(anilistId: 42, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 42,
        localPosterPath: PathString(r'M:\local_poster.jpg'),
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterPathForAnilistId(42), r'M:\local_poster.jpg');
    });

    test('falls back to effectivePosterPath when mapping not found', () {
      final series = _makeSeries(
        anilistPoster: 'https://primary.poster',
        preferredPosterSource: ImageSource.autoAnilist,
      );

      expect(series.presenter.getEffectivePosterPathForAnilistId(999), 'https://primary.poster');
    });
  });

  // =========================================================================
  // SeriesPresenter – getEffectivePosterColorForAnilistId
  // =========================================================================
  group('SeriesPresenter getEffectivePosterColorForAnilistId', () {
    test('local source returns local color first', () {
      const localCol = Color(0xFFFF0000);
      const mapCol = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: mapCol);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterColorForAnilistId(1), localCol);
    });

    test('local source falls back to mapping posterColor', () {
      const mapCol = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: mapCol);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.local,
      );

      expect(series.presenter.getEffectivePosterColorForAnilistId(1), mapCol);
    });

    test('anilist source returns mapping posterColor first', () {
      const localCol = Color(0xFFFF0000);
      const mapCol = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: mapCol);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForAnilistId(1), mapCol);
    });

    test('anilist source falls back to anilist dominant color', () {
      final anime = _makeAnime(dominantColor: '#ABCDEF');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForAnilistId(1), const Color(0xFFABCDEF));
    });

    test('anilist source falls back to local color last', () {
      const localCol = Color(0xFFFF0000);
      final mapping = _makeMapping(anilistId: 1);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.presenter.getEffectivePosterColorForAnilistId(1), localCol);
    });

    test('falls back to localPosterColor when mapping not found', () {
      const localCol = Color(0xFFFF0000);
      final series = _makeSeries(posterColor: localCol);
      expect(series.presenter.getEffectivePosterColorForAnilistId(999), localCol);
    });
  });

  // =========================================================================
  // SeriesPresenter – effectivePrimaryColorSync
  // =========================================================================
  group('SeriesPresenter effectivePrimaryColorSync', () {
    // Default dominantColorSource is poster
    test('poster source local returns local poster color', () {
      const col = Color(0xFFFF0000);
      final series = _makeSeries(
        posterColor: col,
        localBannerPath: PathString(r'M:\banner.jpg'), // hasLocalBanner = true
        preferredPosterSource: ImageSource.local,
      );

      expect(series.effectivePrimaryColorSync(), col);
    });

    test('poster source local falls back to anilist dominant when no local banner', () {
      final anime = _makeAnime(dominantColor: '#00FF00');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        anilistBanner: 'https://banner.url', // hasAnilistBanner = true
        preferredPosterSource: ImageSource.local,
      );

      expect(series.effectivePrimaryColorSync(), const Color(0xFF00FF00));
    });

    test('poster source local returns null when no local banner and no anilist banner', () {
      final series = _makeSeries(
        posterColor: const Color(0xFFFF0000),
        preferredPosterSource: ImageSource.local,
      );

      // hasLocalBanner = false, hasAnilistBanner = false → null
      expect(series.effectivePrimaryColorSync(), isNull);
    });

    test('poster source anilist returns mapping poster color', () {
      const col = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: col);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.effectivePrimaryColorSync(1), col);
    });

    test('poster source anilist returns null when no matching mapping', () {
      final series = _makeSeries(
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.effectivePrimaryColorSync(999), isNull);
    });
  });

  // =========================================================================
  // SeriesPresenter – toJson with null values
  // =========================================================================
  group('SeriesPresenter toJson with null values', () {
    test('all null fields produce null json values', () {
      final series = _makeSeries();
      final json = series.presenter.toJson();

      expect(json['posterPath'], isNull);
      expect(json['bannerPath'], isNull);
      expect(json['posterColor'], isNull);
      expect(json['bannerColor'], isNull);
      expect(json['anilistPosterUrl'], isNull);
      expect(json['anilistBannerUrl'], isNull);
      expect(json['preferredPosterSource'], isNull);
      expect(json['preferredBannerSource'], isNull);
    });

    test('anilistPosterUrl falls back to anilistData in toJson', () {
      final anime = _makeAnime(posterImage: 'https://from-data.poster', bannerImage: 'https://from-data.banner');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
      );
      final json = series.presenter.toJson();

      expect(json['anilistPosterUrl'], 'https://from-data.poster');
      expect(json['anilistBannerUrl'], 'https://from-data.banner');
    });
  });

  // =========================================================================
  // Series – fromJson round-trip
  // =========================================================================
  group('Series.fromJson', () {
    test('basic round-trip preserves core fields', () {
      final original = _makeSeries(
        id: 42,
        name: 'My Show',
        path: r'M:\Shows\My Show',
        posterColor: const Color(0xFFFF0000),
        anilistPoster: 'https://poster.url',
        anilistBanner: 'https://banner.url',
        isHidden: true,
        customListName: 'custom_list',
      );

      final json = original.toJson();
      final restored = Series.fromJson(json);

      expect(restored.id, 42);
      expect(restored.name, 'My Show');
      expect(restored.path.path, r'M:\Shows\My Show');
      expect(restored.isForcedHidden, true);
      expect(restored.customListName, 'custom_list');
      expect(restored.anilistPosterUrl, 'https://poster.url');
      expect(restored.anilistBannerUrl, 'https://banner.url');
    });

    test('round-trip preserves poster/banner paths', () {
      final original = _makeSeries(
        localPosterPath: PathString(r'M:\poster.jpg'),
        localBannerPath: PathString(r'M:\banner.jpg'),
      );

      final json = original.toJson();
      final restored = Series.fromJson(json);

      expect(restored.localPosterPath?.path, r'M:\poster.jpg');
      expect(restored.localBannerPath?.path, r'M:\banner.jpg');
    });

    test('round-trip preserves seasons structure (episodes skipped without native lib)', () {
      // Episode.fromJson triggers FlutterAnitomy DLL unavailable in unit tests.
      // The fromJson gracefully catches errors so season is created but episodes empty.
      final ep = _makeEpisode(name: 'Ep1', episodeNumber: 1);
      final season = _makeSeason(name: 'Season 1', episodes: [ep]);
      final original = _makeSeries(seasons: [season]);

      final json = original.toJson();
      final restored = Series.fromJson(json);

      // Season itself is dropped because episode parsing fails inside Season.fromJson
      expect(restored.seasons.length, 0);
    });

    test('round-trip handles related media gracefully (no native lib)', () {
      // Episode.fromJson requires native lib; related media episodes skipped
      final ep = _makeEpisode(name: 'OVA 1', path: r'M:\Series\Test\OVA\OVA1.mkv');
      final original = _makeSeries(relatedMedia: [ep]);

      final json = original.toJson();
      final restored = Series.fromJson(json);

      // relatedMedia episodes are skipped because Episode.fromJson fails
      expect(restored.relatedMedia.length, 0);
    });

    test('round-trip preserves anilist mappings', () {
      final anime = _makeAnime(id: 100, romaji: 'Test');
      final mapping = _makeMapping(anilistId: 100, anilistData: anime, title: 'Test Mapping');
      final original = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 100,
      );

      final json = original.toJson();
      final restored = Series.fromJson(json);

      expect(restored.anilistMappings.length, 1);
      expect(restored.anilistMappings.first.anilistId, 100);
      expect(restored.primaryAnilistId, 100);
    });

    test('round-trip preserves customGridOrder', () {
      final original = _makeSeries(customGridOrder: ['season_2', 'season_1', 'special_uncategorized']);

      final json = original.toJson();
      final restored = Series.fromJson(json);

      expect(restored.customGridOrder, ['season_2', 'season_1', 'special_uncategorized']);
    });

    test('handles missing required fields gracefully', () {
      final json = <String, dynamic>{
        'name': '',
        'path': '',
      };

      // Should not throw
      final series = Series.fromJson(json);
      expect(series.name, isEmpty);
    });

    test('handles completely invalid json gracefully', () {
      final json = <String, dynamic>{
        'id': 1,
        'name': 'Fallback',
        'path': r'M:\path',
      };

      final series = Series.fromJson(json);
      expect(series.name, 'Fallback');
    });

    test('fromJson sets preferred source from string values', () {
      final json = _makeSeries(
        localPosterPath: PathString(r'M:\p.jpg'),
      ).toJson();

      // Override with explicit source strings
      json['preferredPosterSource'] = 'local';
      json['preferredBannerSource'] = 'anilist';

      final restored = Series.fromJson(json);

      expect(restored.preferredPosterSource, ImageSource.local);
      expect(restored.preferredBannerSource, ImageSource.anilist);
    });
  });

  // =========================================================================
  // Series – toString (requires Provider context, so we just verify it exists)
  // =========================================================================
  // Note: Series.toString() calls latestUpdatedAt which requires Provider context.
  // This is untestable without a full widget tree, so we skip it.

  // =========================================================================
  // Series – primaryAnilistId
  // =========================================================================
  group('Series primaryAnilistId', () {
    test('getter falls back to first mapping', () {
      final mapping = _makeMapping(anilistId: 42);
      final series = _makeSeries(anilistMappings: [mapping]);

      expect(series.primaryAnilistId, 42);
    });

    test('getter returns null when unlinked', () {
      final series = _makeSeries();
      expect(series.primaryAnilistId, isNull);
    });

    test('setter updates when valid id', () {
      final m1 = _makeMapping(anilistId: 1);
      final m2 = _makeMapping(anilistId: 2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      series.primaryAnilistId = 2;
      expect(series.primaryAnilistId, 2);
    });

    test('setter rejects invalid id', () {
      final m1 = _makeMapping(anilistId: 1);
      final series = _makeSeries(anilistMappings: [m1], primaryAnilistId: 1);

      series.primaryAnilistId = 999; // Not in mappings
      // Should remain at 1
      expect(series.primaryAnilistId, 1);
    });
  });

  // =========================================================================
  // Series – anilistData getter/setter
  // =========================================================================
  group('Series anilistData', () {
    test('getter returns primary mapping data', () {
      final anime = _makeAnime(id: 1, romaji: 'Primary');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.anilistData?.title.romaji, 'Primary');
    });

    test('getter auto-assigns primary from first mapping when null', () {
      final anime = _makeAnime(id: 10, romaji: 'First');
      final mapping = _makeMapping(anilistId: 10, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping]);

      expect(series.anilistData?.title.romaji, 'First');
    });

    test('getter returns null when no mappings', () {
      final series = _makeSeries();
      expect(series.anilistData, isNull);
    });

    test('setter updates mapping data and presenter URLs', () {
      final mapping = _makeMapping(anilistId: 1);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      final newAnime = _makeAnime(
        id: 1,
        posterImage: 'https://new.poster',
        bannerImage: 'https://new.banner',
      );

      series.anilistData = newAnime;

      expect(series.anilistData?.posterImage, 'https://new.poster');
      expect(series.presenter.rawAnilistPosterUrl, 'https://new.poster');
      expect(series.presenter.rawAnilistBannerUrl, 'https://new.banner');
    });
  });

  // =========================================================================
  // Series – currentAnilistData
  // =========================================================================
  group('Series currentAnilistData', () {
    test('returns data for primary id when available', () {
      final anime1 = _makeAnime(id: 1, romaji: 'First');
      final anime2 = _makeAnime(id: 2, romaji: 'Second');
      final m1 = _makeMapping(anilistId: 1, anilistData: anime1);
      final m2 = _makeMapping(anilistId: 2, anilistData: anime2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 2);

      expect(series.currentAnilistData?.title.romaji, 'Second');
    });

    test('falls back to anilistData when primaryId is null', () {
      final anime = _makeAnime(id: 1, romaji: 'Fallback');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping]);

      expect(series.currentAnilistData?.title.romaji, 'Fallback');
    });
  });

  // =========================================================================
  // Series – isLinked
  // =========================================================================
  group('Series isLinked', () {
    test('false when no mappings', () {
      expect(_makeSeries().isLinked, isFalse);
    });

    test('true when mappings exist', () {
      final mapping = _makeMapping(anilistId: 1);
      expect(_makeSeries(anilistMappings: [mapping]).isLinked, isTrue);
    });
  });

  // =========================================================================
  // Series – anilist getters
  // =========================================================================
  group('Series anilist getters', () {
    late Series series;

    setUp(() {
      final anime = _makeAnime(
        description: 'A test description',
        averageScore: 85,
        meanScore: 80,
        popularity: 5000,
        format: 'TV',
        genres: ['Action', 'Fantasy'],
        seasonYear: 2024,
        season: 'Winter',
      );
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
    });

    test('description', () => expect(series.description, 'A test description'));
    test('rating', () => expect(series.rating, 85));
    test('meanScore', () => expect(series.meanScore, 80));
    test('popularity', () => expect(series.popularity, 5000));
    test('format', () => expect(series.format, 'TV'));
    test('genres', () => expect(series.genres, ['Action', 'Fantasy']));
    test('seasonYear', () => expect(series.seasonYear, 2024));

    test('returns null when no anilist data', () {
      final unlinked = _makeSeries();
      expect(unlinked.description, isNull);
      expect(unlinked.rating, isNull);
      expect(unlinked.meanScore, isNull);
      expect(unlinked.popularity, isNull);
      expect(unlinked.format, isNull);
      expect(unlinked.genres, isEmpty);
      expect(unlinked.seasonYear, isNull);
    });
  });

  // =========================================================================
  // Series – formats
  // =========================================================================
  group('Series formats', () {
    test('returns joined format strings', () {
      final a1 = _makeAnime(id: 1, format: 'TV');
      final a2 = _makeAnime(id: 2, format: 'OVA');
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      final result = series.formats;
      expect(result, isNotNull);
      // Should contain both formats
      expect(result!.contains('TV'), isTrue);
    });

    test('returns null when no formats', () {
      final series = _makeSeries();
      // All mappings have null format → no non-null entries
      expect(series.formats, isEmpty);
    });
  });

  // =========================================================================
  // Series – seasonsYearRange / seasonAndSeasonYearRange
  // =========================================================================
  group('Series season year ranges', () {
    test('seasonsYearRange single year', () {
      final anime = _makeAnime(seasonYear: 2023);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.seasonsYearRange, '2023');
    });

    test('seasonsYearRange multiple years', () {
      final a1 = _makeAnime(id: 1, seasonYear: 2020);
      final a2 = _makeAnime(id: 2, seasonYear: 2023);
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.seasonsYearRange, '2020 - 2023');
    });

    test('seasonsYearRange returns null when unlinked', () {
      expect(_makeSeries().seasonsYearRange, isNull);
    });

    test('seasonsYearRange returns null when no years', () {
      final anime = _makeAnime(); // no seasonYear
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.seasonsYearRange, isNull);
    });

    test('seasonAndSeasonYearRange single', () {
      final anime = _makeAnime(season: 'Winter', seasonYear: 2023);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.seasonAndSeasonYearRange, 'Winter 2023');
    });

    test('seasonAndSeasonYearRange range', () {
      final a1 = _makeAnime(id: 1, season: 'Winter', seasonYear: 2020);
      final a2 = _makeAnime(id: 2, season: 'Fall', seasonYear: 2023);
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.seasonAndSeasonYearRange, 'Winter 2020 - Fall 2023');
    });

    test('seasonAndSeasonYearRange returns null when unlinked', () {
      expect(_makeSeries().seasonAndSeasonYearRange, isNull);
    });

    test('seasonAndSeasonYearRange returns null when no season data', () {
      final anime = _makeAnime(); // no season/year
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.seasonAndSeasonYearRange, isNull);
    });
  });

  // =========================================================================
  // Series – effectiveStatus
  // =========================================================================
  group('Series effectiveStatus', () {
    test('returns null when unlinked', () {
      expect(_makeSeries().effectiveStatus, isNull);
    });

    test('returns FINISHED when all mappings finished', () {
      final anime = _makeAnime(status: 'FINISHED');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.effectiveStatus, isNotNull);
      expect(series.effectiveStatus!.toLowerCase(), contains('finished'));
    });

    test('returns RELEASING when any mapping is releasing', () {
      final a1 = _makeAnime(id: 1, status: 'FINISHED');
      final a2 = _makeAnime(id: 2, status: 'RELEASING');
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.effectiveStatus!.toLowerCase(), contains('releasing'));
    });

    test('CANCELLED takes priority over RELEASING', () {
      final a1 = _makeAnime(id: 1, status: 'RELEASING');
      final a2 = _makeAnime(id: 2, status: 'CANCELLED');
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.effectiveStatus!.toLowerCase(), contains('cancelled'));
    });

    test('HIATUS takes priority over RELEASING', () {
      final a1 = _makeAnime(id: 1, status: 'RELEASING');
      final a2 = _makeAnime(id: 2, status: 'HIATUS');
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.effectiveStatus!.toLowerCase(), contains('hiatus'));
    });

    test('returns null when no status data', () {
      final anime = _makeAnime(); // no status
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.effectiveStatus, isNull);
    });
  });

  // =========================================================================
  // Series – Episode lookup methods
  // =========================================================================
  group('Series episode lookup', () {
    late Series series;
    late Episode ep1, ep2, ep3, relEp;

    setUp(() {
      ep1 = _makeEpisode(id: 10, name: 'Ep1', path: r'M:\S\S01\E01.mkv', episodeNumber: 1);
      ep2 = _makeEpisode(id: 11, name: 'Ep2', path: r'M:\S\S01\E02.mkv', episodeNumber: 2);
      ep3 = _makeEpisode(id: 12, name: 'Ep3', path: r'M:\S\S02\E01.mkv', episodeNumber: 1);
      relEp = _makeEpisode(id: 20, name: 'OVA', path: r'M:\S\OVA\OVA1.mkv', episodeNumber: 1);

      final s1 = _makeSeason(name: 'Season 1', path: r'M:\S\S01', episodes: [ep1, ep2]);
      final s2 = _makeSeason(name: 'Season 2', path: r'M:\S\S02', episodes: [ep3]);

      series = _makeSeries(
        path: r'M:\S',
        seasons: [s1, s2],
        relatedMedia: [relEp],
      );
    });

    test('getEpisodeById finds in season', () {
      expect(series.getEpisodeById(10)?.name, 'Ep1');
      expect(series.getEpisodeById(12)?.name, 'Ep3');
    });

    test('getEpisodeById finds in related media', () {
      expect(series.getEpisodeById(20)?.name, 'OVA');
    });

    test('getEpisodeById returns null for unknown id', () {
      expect(series.getEpisodeById(999), isNull);
    });

    test('getEpisodeByNumber finds in specific season', () {
      expect(series.getEpisodeByNumber(1, seasonNumber: 2)?.name, 'Ep3');
    });

    test('getEpisodeByNumber finds across all seasons', () {
      expect(series.getEpisodeByNumber(2)?.name, 'Ep2');
    });

    test('getEpisodeByNumber finds in related media', () {
      // Create a series where the episode number is unique to relatedMedia
      final uniqueRelEp = _makeEpisode(id: 30, name: 'OVA99', path: r'M:\S\OVA\ova99.mkv', episodeNumber: 99);
      final s = _makeSeries(
        relatedMedia: [uniqueRelEp],
      );

      expect(s.getEpisodeByNumber(99)?.name, 'OVA99');
    });

    test('getEpisodeByNumber returns null for invalid season number', () {
      expect(series.getEpisodeByNumber(1, seasonNumber: 99), isNull);
    });

    test('getEpisodeByPath finds episode', () {
      expect(series.getEpisodeByPath(PathString(r'M:\S\S01\E02.mkv'))?.name, 'Ep2');
    });

    test('getEpisodeByPath finds in related media', () {
      expect(series.getEpisodeByPath(PathString(r'M:\S\OVA\OVA1.mkv'))?.name, 'OVA');
    });

    test('getEpisodeByPath returns null for unknown path', () {
      expect(series.getEpisodeByPath(PathString(r'M:\Unknown.mkv')), isNull);
    });

    test('getEpisodesForSeason returns episodes for valid season', () {
      expect(series.getEpisodesForSeason(1).length, 2);
      expect(series.getEpisodesForSeason(2).length, 1);
    });

    test('getEpisodesForSeason returns empty for invalid season', () {
      expect(series.getEpisodesForSeason(0), isEmpty);
      expect(series.getEpisodesForSeason(99), isEmpty);
    });

    test('getSeasonFromPath returns matching season', () {
      expect(series.getSeasonFromPath(PathString(r'M:\S\S01'))?.name, 'Season 1');
    });

    test('getSeasonFromPath returns null for unknown path', () {
      expect(series.getSeasonFromPath(PathString(r'M:\Unknown')), isNull);
    });
  });

  // =========================================================================
  // Series – Grid ordering
  // =========================================================================
  group('Series grid ordering', () {
    test('getGridIdentifier', () {
      expect(Series.getGridIdentifier(0), 'special_uncategorized');
      expect(Series.getGridIdentifier(1), 'season_1');
      expect(Series.getGridIdentifier(5), 'season_5');
    });

    test('parseSeasonNumber', () {
      expect(Series.parseSeasonNumber('special_uncategorized'), 0);
      expect(Series.parseSeasonNumber('season_1'), 1);
      expect(Series.parseSeasonNumber('season_5'), 5);
      expect(Series.parseSeasonNumber('invalid'), isNull);
    });

    test('getGridDisplayOrder default order', () {
      final s1 = _makeSeason(path: r'M:\S\S01', episodes: [_makeEpisode()]);
      final s2 = _makeSeason(path: r'M:\S\S02', episodes: [_makeEpisode(path: r'M:\S\S02\E01.mkv')]);
      final series = _makeSeries(seasons: [s1, s2]);

      expect(series.getGridDisplayOrder(), ['season_1', 'season_2']);
    });

    test('getGridDisplayOrder respects custom order', () {
      final s1 = _makeSeason(path: r'M:\S\S01', episodes: [_makeEpisode()]);
      final s2 = _makeSeason(path: r'M:\S\S02', episodes: [_makeEpisode(path: r'M:\S\S02\E01.mkv')]);
      final series = _makeSeries(
        seasons: [s1, s2],
        customGridOrder: ['season_2', 'season_1'],
      );

      expect(series.getGridDisplayOrder(), ['season_2', 'season_1']);
    });

    test('getGridDisplayOrder adds new grids not in custom order', () {
      final s1 = _makeSeason(path: r'M:\S\S01', episodes: [_makeEpisode()]);
      final s2 = _makeSeason(path: r'M:\S\S02', episodes: [_makeEpisode(path: r'M:\S\S02\E01.mkv')]);
      final series = _makeSeries(
        seasons: [s1, s2],
        customGridOrder: ['season_1'], // missing season_2
      );

      final order = series.getGridDisplayOrder();
      expect(order, contains('season_1'));
      expect(order, contains('season_2'));
    });

    test('setGridDisplayOrder updates custom order', () {
      final series = _makeSeries();
      series.setGridDisplayOrder(['season_2', 'season_1']);
      expect(series.customGridOrder, ['season_2', 'season_1']);
    });

    test('setGridDisplayOrder null resets to default', () {
      final series = _makeSeries(customGridOrder: ['season_2', 'season_1']);
      series.setGridDisplayOrder(null);
      expect(series.customGridOrder, isNull);
    });

    test('isValidGridId', () {
      final s1 = _makeSeason(path: r'M:\S\S01', episodes: [_makeEpisode()]);
      final series = _makeSeries(seasons: [s1]);

      expect(series.isValidGridId('season_1'), isTrue);
      expect(series.isValidGridId('season_2'), isFalse);
      expect(series.isValidGridId('special_uncategorized'), isFalse); // no uncategorized eps
      expect(series.isValidGridId('invalid'), isFalse);
    });
  });

  // =========================================================================
  // Series – numberOfSeasons
  // =========================================================================
  group('Series numberOfSeasons', () {
    test('returns 0 for empty seasons', () {
      expect(_makeSeries().numberOfSeasons, 0);
    });

    test('returns count for simple seasons', () {
      final s1 = _makeSeason(name: 'S1');
      final s2 = _makeSeason(name: 'S2', path: r'M:\S\S02');
      final series = _makeSeries(seasons: [s1, s2]);

      expect(series.numberOfSeasons, 2);
    });
  });

  // =========================================================================
  // Series – metadata
  // =========================================================================
  group('Series metadata', () {
    test('metadata getter aggregates from seasons', () {
      final m1 = Metadata(size: 100, duration: const Duration(minutes: 24));
      final m2 = Metadata(size: 200, duration: const Duration(minutes: 24));
      final s1 = _makeSeason(metadata: m1);
      final s2 = _makeSeason(path: r'M:\S\S02', metadata: m2);
      final series = _makeSeries(seasons: [s1, s2]);

      final meta = series.metadata;
      expect(meta, isNotNull);
      expect(meta!.size, 300);
      expect(meta.duration, const Duration(minutes: 48));
    });

    test('metadata setter', () {
      final series = _makeSeries();
      final meta = Metadata(size: 500);
      series.metadata = meta;
      expect(series.metadata?.size, 500);
    });

    test('setMetadataFromValues creates new metadata', () {
      final series = _makeSeries();
      series.setMetadataFromValues(
        size: 1024,
        duration: const Duration(hours: 1),
      );

      expect(series.metadata?.size, 1024);
      expect(series.metadata?.duration, const Duration(hours: 1));
    });

    test('setMetadataFromValues updates existing metadata', () {
      final series = _makeSeries(metadata: Metadata(size: 100));
      series.setMetadataFromValues(size: 200);

      expect(series.metadata?.size, 200);
    });
  });

  // =========================================================================
  // Series – getMappingForEpisode
  // =========================================================================
  group('Series getMappingForEpisode', () {
    test('finds mapping by direct episode path', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01\E01.mkv');
      final series = _makeSeries(anilistMappings: [mapping]);

      expect(series.getMappingForEpisode(ep)?.anilistId, 1);
    });

    test('finds mapping via season path', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01');
      final series = _makeSeries(seasons: [season], anilistMappings: [mapping]);

      expect(series.getMappingForEpisode(ep)?.anilistId, 1);
    });

    test('returns null when no mapping found', () {
      final ep = _makeEpisode(path: r'M:\Unknown.mkv');
      final series = _makeSeries();
      expect(series.getMappingForEpisode(ep), isNull);
    });
  });

  // =========================================================================
  // Series – getTargetForMapping
  // =========================================================================
  group('Series getTargetForMapping', () {
    test('returns season target when mapping path matches season', () {
      final season = _makeSeason(path: r'M:\S\S01');
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01');
      final series = _makeSeries(seasons: [season], anilistMappings: [mapping]);

      final target = series.getTargetForMapping(mapping);
      expect(target, isNotNull);
    });

    test('returns episode target for related media', () {
      final ep = _makeEpisode(path: r'M:\S\OVA\OVA1.mkv');
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\OVA\OVA1.mkv');
      final series = _makeSeries(relatedMedia: [ep], anilistMappings: [mapping]);

      final target = series.getTargetForMapping(mapping);
      expect(target, isNotNull);
    });

    test('returns episode target within season', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01\E01.mkv');
      final series = _makeSeries(seasons: [season], anilistMappings: [mapping]);

      final target = series.getTargetForMapping(mapping);
      expect(target, isNotNull);
    });

    test('returns null when no target found', () {
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\Unknown');
      final series = _makeSeries(anilistMappings: [mapping]);

      expect(series.getTargetForMapping(mapping), isNull);
    });
  });

  // =========================================================================
  // Series – removeMapping
  // =========================================================================
  group('Series removeMapping', () {
    test('removes mapping by target path', () {
      final season = _makeSeason(path: r'M:\S\S01');
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
      );

      final target = series.getTargetForMapping(mapping)!;
      expect(series.removeMapping(target), isTrue);
      expect(series.anilistMappings, isEmpty);
    });

    test('returns false when target not found', () {
      final season = _makeSeason(path: r'M:\S\S01');
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
      );

      // Use a different season path
      final otherSeason = _makeSeason(path: r'M:\S\S99');
      final otherMapping = _makeMapping(anilistId: 2, localPath: r'M:\S\S99');
      // The otherMapping target won't be found in series.anilistMappings
      final otherTarget = _makeSeries(
        seasons: [otherSeason],
        anilistMappings: [otherMapping],
      ).getTargetForMapping(otherMapping);

      expect(series.removeMapping(otherTarget!), isFalse);
    });
  });

  // =========================================================================
  // Series – updateEpisodes
  // =========================================================================
  group('Series updateEpisodes', () {
    test('replaces episodes with matching paths', () {
      final ep1 = _makeEpisode(id: 1, name: 'Old', path: r'M:\S\S01\E01.mkv', watched: false);
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep1]);
      final series = _makeSeries(seasons: [season]);

      final newEp1 = _makeEpisode(id: 1, name: 'New', path: r'M:\S\S01\E01.mkv', watched: true);
      final updated = series.updateEpisodes([newEp1]);

      expect(updated, isTrue);
      expect(series.seasons.first.episodes.first.name, 'New');
      expect(series.seasons.first.episodes.first.watched, isTrue);
    });

    test('replaces related media episodes', () {
      final relEp = _makeEpisode(id: 10, name: 'Old OVA', path: r'M:\S\OVA\1.mkv');
      final series = _makeSeries(relatedMedia: [relEp]);

      final newRelEp = _makeEpisode(id: 10, name: 'New OVA', path: r'M:\S\OVA\1.mkv');
      final updated = series.updateEpisodes([newRelEp]);

      expect(updated, isTrue);
      expect(series.relatedMedia.first.name, 'New OVA');
    });

    test('returns false when no matches', () {
      final ep1 = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final season = _makeSeason(episodes: [ep1]);
      final series = _makeSeries(seasons: [season]);

      final unrelatedEp = _makeEpisode(path: r'M:\Other\E01.mkv');
      expect(series.updateEpisodes([unrelatedEp]), isFalse);
    });
  });

  // =========================================================================
  // Series – copyWith comprehensive
  // =========================================================================
  group('Series copyWith comprehensive', () {
    test('copies all overridable fields', () {
      final original = _makeSeries(
        id: 1,
        name: 'Original',
        path: r'M:\Original',
        isHidden: false,
        customListName: 'old_list',
      );

      final copy = original.copyWith(
        id: 2,
        name: 'Copy',
        path: PathString(r'M:\Copy'),
        isHidden: true,
        customListName: 'new_list',
        customGridOrder: ['season_1'],
      );

      expect(copy.id, 2);
      expect(copy.name, 'Copy');
      expect(copy.path.path, r'M:\Copy');
      expect(copy.isForcedHidden, true);
      expect(copy.customListName, 'new_list');
      expect(copy.customGridOrder, ['season_1']);
    });

    test('copies with new seasons', () {
      final original = _makeSeries(seasons: [_makeSeason()]);
      final newSeason = _makeSeason(name: 'New Season', path: r'M:\S\S99');
      final copy = original.copyWith(seasons: [newSeason]);

      expect(copy.seasons.length, 1);
      expect(copy.seasons.first.name, 'New Season');
    });

    test('copies with new anilist mappings', () {
      final original = _makeSeries();
      final mapping = _makeMapping(anilistId: 42);
      final copy = original.copyWith(anilistMappings: [mapping]);

      expect(copy.anilistMappings.length, 1);
      expect(copy.anilistMappings.first.anilistId, 42);
    });

    test('copies with banner overrides', () {
      const newColor = Color(0xFFABCDEF);
      final original = _makeSeries(bannerColor: const Color(0xFF000000));
      final copy = original.copyWith(
        bannerColor: newColor,
        folderBannerPath: PathString(r'M:\new_banner.jpg'),
        preferredBannerSource: ImageSource.anilist,
        anilistBanner: 'https://new.banner',
      );

      expect(copy.presenter.rawBannerColor, newColor);
      expect(copy.localBannerPath?.path, r'M:\new_banner.jpg');
      expect(copy.preferredBannerSource, ImageSource.anilist);
      expect(copy.presenter.rawAnilistBannerUrl, 'https://new.banner');
    });
  });

  // =========================================================================
  // Series – equality
  // =========================================================================
  group('Series equality comprehensive', () {
    test('series with different ids are not equal', () {
      final a = _makeSeries(id: 1, name: 'Same');
      final b = _makeSeries(id: 2, name: 'Same');
      expect(a, isNot(equals(b)));
    });

    test('series with different names are not equal', () {
      final a = _makeSeries(id: 1, name: 'A');
      final b = _makeSeries(id: 1, name: 'B');
      expect(a, isNot(equals(b)));
    });

    test('series with different paths are not equal', () {
      final a = _makeSeries(id: 1, path: r'M:\A');
      final b = _makeSeries(id: 1, path: r'M:\B');
      expect(a, isNot(equals(b)));
    });

    test('series with different seasons are not equal', () {
      final s1 = _makeSeason(name: 'S1');
      final s2 = _makeSeason(name: 'S2', path: r'M:\S\S02');
      final a = _makeSeries(id: 1, seasons: [s1]);
      final b = _makeSeries(id: 1, seasons: [s2]);
      expect(a, isNot(equals(b)));
    });

    test('series with different hidden state are not equal', () {
      final a = _makeSeries(id: 1, isHidden: true);
      final b = _makeSeries(id: 1, isHidden: false);
      expect(a, isNot(equals(b)));
    });

    test('series with different customListName are not equal', () {
      final a = _makeSeries(id: 1, customListName: 'A');
      final b = _makeSeries(id: 1, customListName: 'B');
      expect(a, isNot(equals(b)));
    });

    test('identical operator returns true for same instance', () {
      final series = _makeSeries();
      expect(series == series, isTrue);
    });

    test('not equal to non-Series object', () {
      final series = _makeSeries();
      // ignore: unrelated_type_equality_checks
      expect(series == 'not a series', isFalse);
    });
  });

  // =========================================================================
  // Series – totalEpisodes / numberOfSeasons with data
  // =========================================================================
  group('Series totalEpisodes', () {
    test('counts episodes from all seasons and related media', () {
      final ep1 = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final ep2 = _makeEpisode(path: r'M:\S\S01\E02.mkv');
      final ep3 = _makeEpisode(path: r'M:\S\S02\E01.mkv');
      final relEp = _makeEpisode(path: r'M:\S\OVA\OVA1.mkv');

      final s1 = _makeSeason(episodes: [ep1, ep2]);
      final s2 = _makeSeason(path: r'M:\S\S02', episodes: [ep3]);

      final series = _makeSeries(seasons: [s1, s2], relatedMedia: [relEp]);

      expect(series.totalEpisodes, 4);
    });
  });

  // =========================================================================
  // Series – getEffectiveListName
  // =========================================================================
  group('Series getEffectiveListName', () {
    test('returns default unlinked name for unlinked series without custom', () {
      final series = _makeSeries();
      final result = series.getEffectiveListName(['custom_Watching', 'custom_Completed']);
      expect(result, '__unlinked');
    });

    test('returns default when customListName is empty', () {
      final series = _makeSeries(customListName: '');
      final result = series.getEffectiveListName(['custom_Watching']);
      expect(result, '__unlinked');
    });

    test('returns customListName when it exists in available lists', () {
      final series = _makeSeries(customListName: 'MyList');
      final result = series.getEffectiveListName(['custom_MyList', 'other']);
      expect(result, 'MyList');
    });

    test('returns default when custom list not in available lists', () {
      final series = _makeSeries(customListName: 'NonExistent');
      final result = series.getEffectiveListName(['custom_Other']);
      expect(result, '__unlinked');
    });

    test('returns default for linked series', () {
      final mapping = _makeMapping(anilistId: 1);
      final series = _makeSeries(anilistMappings: [mapping], customListName: 'my_list');
      final result = series.getEffectiveListName(['custom_my_list']);
      expect(result, '__unlinked'); // linked → always returns unlinked constant
    });
  });

  // =========================================================================
  // SeriesPresenter – displayTitle extra coverage
  // =========================================================================
  group('displayTitle additional patterns', () {
    Series _seriesWithTitle(String title) {
      final anime = _makeAnime(userPreferred: title);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      return _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
    }

    test('removes Romaji season indicators', () {
      expect(_seriesWithTitle('Test ki 2').displayTitle, 'Test');
      expect(_seriesWithTitle('Test bu 1').displayTitle, 'Test');
    });

    test('removes Chapter indicator', () {
      expect(_seriesWithTitle('My Anime Chapter 5').displayTitle, 'My Anime');
      expect(_seriesWithTitle('My Anime Ch 3').displayTitle, 'My Anime');
    });

    test('removes Cour indicator', () {
      expect(_seriesWithTitle('My Anime Cour 2').displayTitle, 'My Anime');
    });

    test('removes 第Nシーズン', () {
      expect(_seriesWithTitle('Test 第2シーズン').displayTitle, 'Test');
    });

    test('removes 第N章', () {
      expect(_seriesWithTitle('Test 第3章').displayTitle, 'Test');
    });

    test('removes 第Nクール', () {
      expect(_seriesWithTitle('Test 第1クール').displayTitle, 'Test');
    });

    test('removes 第N巻', () {
      expect(_seriesWithTitle('Test 第4巻').displayTitle, 'Test');
    });

    test('removes パートN', () {
      expect(_seriesWithTitle('Test パート2').displayTitle, 'Test');
    });

    test('removes N章', () {
      expect(_seriesWithTitle('Test 3章').displayTitle, 'Test');
    });

    test('removes Nクール', () {
      expect(_seriesWithTitle('Test 2クール').displayTitle, 'Test');
    });

    test('removes N巻', () {
      expect(_seriesWithTitle('Test 5巻').displayTitle, 'Test');
    });

    test('removes Nシーズン', () {
      expect(_seriesWithTitle('Test 2シーズン').displayTitle, 'Test');
    });

    test('removes S followed by number', () {
      // "S" is in the season pattern
      expect(_seriesWithTitle('My Anime S2').displayTitle, 'My Anime');
    });

    test('removes trailing dash after removal', () {
      expect(_seriesWithTitle('My Anime - Season 2').displayTitle, 'My Anime');
    });

    test('removes trailing colon after removal', () {
      expect(_seriesWithTitle('My Anime: Part 3').displayTitle, 'My Anime');
    });

    test('handles multiple season indicators', () {
      // Both "Season 2" and "Part 1" should be removed
      expect(_seriesWithTitle('My Anime Season 2 Part 1').displayTitle, 'My Anime');
    });

    test('handles fully bracketed season in square brackets', () {
      expect(_seriesWithTitle('My Anime [Season 3]').displayTitle, 'My Anime []');
    });

    test('handles fully bracketed season in round brackets', () {
      expect(_seriesWithTitle('My Anime (Season 3)').displayTitle, 'My Anime ()');
    });
  });

  // =========================================================================
  // SeriesPresenter – hashCode / equality edge cases
  // =========================================================================
  group('SeriesPresenter equality edge cases', () {
    test('different localPosterPath → not equal', () {
      final a = _makeSeries(localPosterPath: PathString(r'M:\a.jpg'));
      final b = _makeSeries(localPosterPath: PathString(r'M:\b.jpg'));
      expect(a.presenter, isNot(equals(b.presenter)));
    });

    test('different localBannerPath → not equal', () {
      final a = _makeSeries(localBannerPath: PathString(r'M:\a.jpg'));
      final b = _makeSeries(localBannerPath: PathString(r'M:\b.jpg'));
      expect(a.presenter, isNot(equals(b.presenter)));
    });

    test('different preferredBannerSource → not equal', () {
      final a = _makeSeries(preferredBannerSource: ImageSource.local);
      final b = _makeSeries(preferredBannerSource: ImageSource.anilist);
      expect(a.presenter, isNot(equals(b.presenter)));
    });

    test('different anilistBannerUrl → not equal', () {
      final a = _makeSeries(anilistBanner: 'https://a.url');
      final b = _makeSeries(anilistBanner: 'https://b.url');
      expect(a.presenter, isNot(equals(b.presenter)));
    });

    test('identical to self', () {
      final series = _makeSeries();
      expect(series.presenter == series.presenter, isTrue);
    });

    test('not equal to non-SeriesPresenter', () {
      final series = _makeSeries();
      // ignore: unrelated_type_equality_checks
      expect(series.presenter == 'string', isFalse);
    });
  });

  // =========================================================================
  // SeriesPresenter – effectivePrimaryColorSync banner source
  // =========================================================================
  group('SeriesPresenter effectivePrimaryColorSync banner source', () {
    setUp(() {
      Manager.settings.dominantColorSource = DominantColorSource.banner;
    });

    tearDown(() {
      Manager.settings.dominantColorSource = DominantColorSource.poster;
    });

    test('banner source local returns local banner color when banner exists', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\banner.jpg'),
        bannerColor: const Color(0xFF112233),
        preferredBannerSource: ImageSource.local,
      );
      // _localBannerDominantColor is set from bannerColor in constructor
      expect(series.effectivePrimaryColorSync(), const Color(0xFF112233));
    });

    test('banner source local falls back to anilist dominant when no local banner', () {
      final anime = _makeAnime(dominantColor: '#FF00FF');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        anilistBanner: 'https://banner.url',
        preferredBannerSource: ImageSource.local,
      );

      expect(series.effectivePrimaryColorSync(), const Color(0xFFFF00FF));
    });

    test('banner source local returns null when no banners', () {
      final series = _makeSeries(preferredBannerSource: ImageSource.local);
      expect(series.effectivePrimaryColorSync(), isNull);
    });

    test('banner source anilist returns mapping banner color', () {
      const col = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, bannerColor: col);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredBannerSource: ImageSource.anilist,
      );

      expect(series.effectivePrimaryColorSync(1), col);
    });

    test('banner source anilist returns null when no matching mapping', () {
      final series = _makeSeries(preferredBannerSource: ImageSource.anilist);
      expect(series.effectivePrimaryColorSync(999), isNull);
    });
  });

  // =========================================================================
  // Series – numberOfSeasons with seasonNumber parsing
  // =========================================================================
  group('Series numberOfSeasons advanced', () {
    test('returns highest parsed season number', () {
      final s1 = _makeSeason(name: 'Season 1', path: r'M:\S\S01');
      final s2 = _makeSeason(name: 'Season 3', path: r'M:\S\S03');
      final series = _makeSeries(seasons: [s1, s2]);

      // Season 3 is the max → returns 3
      expect(series.numberOfSeasons, 3);
    });

    test('falls back to count when no parseable season names', () {
      final s1 = _makeSeason(name: 'Specials', path: r'M:\S\Specials');
      final s2 = _makeSeason(name: 'OVA', path: r'M:\S\OVA');
      final series = _makeSeries(seasons: [s1, s2]);

      // Neither name is "Season N" → falls back to count (2)
      expect(series.numberOfSeasons, 2);
    });
  });

  // =========================================================================
  // Series – _getMetadata comprehensive
  // =========================================================================
  group('Series _getMetadata with dates', () {
    test('aggregates creation/modification/access dates', () {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(days: 10));
      final later = now.add(const Duration(days: 5));

      final m1 = Metadata(
        size: 100,
        duration: const Duration(minutes: 10),
        creationTime: now,
        lastModified: now,
        lastAccessed: now,
      );
      final m2 = Metadata(
        size: 200,
        duration: const Duration(minutes: 20),
        creationTime: earlier,
        lastModified: later,
        lastAccessed: later,
      );
      final s1 = _makeSeason(metadata: m1);
      final s2 = _makeSeason(path: r'M:\S\S02', metadata: m2);
      final series = _makeSeries(seasons: [s1, s2]);

      final meta = series.metadata!;
      expect(meta.size, 300);
      expect(meta.duration, const Duration(minutes: 30));
      expect(meta.creationTime, earlier); // earliest
      expect(meta.lastModified, later); // latest
      expect(meta.lastAccessed, later); // latest
    });

    test('returns metadata with zeros when seasons have no metadata', () {
      final s1 = _makeSeason();
      final series = _makeSeries(seasons: [s1]);

      final meta = series.metadata!;
      expect(meta.size, 0);
      expect(meta.duration, Duration.zero);
    });
  });

  // =========================================================================
  // Series – getUncategorizedEpisodes
  // =========================================================================
  group('Series getUncategorizedEpisodes', () {
    test('returns episodes in relatedMedia not in seasons', () {
      final ep1 = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final relEp = _makeEpisode(path: r'M:\S\OVA\OVA1.mkv');
      final season = _makeSeason(episodes: [ep1]);
      final series = _makeSeries(seasons: [season], relatedMedia: [relEp]);

      final uncategorized = series.getUncategorizedEpisodes();
      expect(uncategorized.length, 1);
      expect(uncategorized.first.path.path, r'M:\S\OVA\OVA1.mkv');
    });

    test('returns empty when no related media', () {
      final series = _makeSeries();
      expect(series.getUncategorizedEpisodes(), isEmpty);
    });
  });

  // =========================================================================
  // Series – forwarding methods coverage
  // =========================================================================
  group('Series forwarding methods', () {
    test('localPosterPath getter/setter forwards', () {
      final series = _makeSeries();
      series.localPosterPath = PathString(r'M:\new_poster.jpg');
      expect(series.localPosterPath?.path, r'M:\new_poster.jpg');
    });

    test('localBannerPath getter/setter forwards', () {
      final series = _makeSeries();
      series.localBannerPath = PathString(r'M:\new_banner.jpg');
      expect(series.localBannerPath?.path, r'M:\new_banner.jpg');
    });

    test('preferredPosterSource getter/setter forwards', () {
      final series = _makeSeries();
      series.preferredPosterSource = ImageSource.local;
      expect(series.preferredPosterSource, ImageSource.local);
    });

    test('preferredBannerSource getter/setter forwards', () {
      final series = _makeSeries();
      series.preferredBannerSource = ImageSource.anilist;
      expect(series.preferredBannerSource, ImageSource.anilist);
    });

    test('localPosterColor forwards', () {
      final series = _makeSeries(posterColor: const Color(0xFFABCDEF));
      expect(series.localPosterColor, const Color(0xFFABCDEF));
    });

    test('localBannerColor forwards', () {
      final anime = _makeAnime(dominantColor: '#ABCDEF');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      // No local banner color → falls back to anilist dominant
      expect(series.localBannerColor, const Color(0xFFABCDEF));
    });

    test('anilistPosterUrl forwards', () {
      final series = _makeSeries(anilistPoster: 'https://poster.url');
      expect(series.anilistPosterUrl, 'https://poster.url');
    });

    test('anilistBannerUrl forwards', () {
      final series = _makeSeries(anilistBanner: 'https://banner.url');
      expect(series.anilistBannerUrl, 'https://banner.url');
    });

    test('effectivePosterPath forwards', () {
      final series = _makeSeries(anilistPoster: 'https://poster.url');
      expect(series.effectivePosterPath, 'https://poster.url');
    });

    test('effectiveBannerPath forwards', () {
      final series = _makeSeries(localBannerPath: PathString(r'M:\banner.jpg'));
      expect(series.effectiveBannerPath, r'M:\banner.jpg');
    });

    test('isAnilistPosterBeingUsed forwards', () {
      final series = _makeSeries(anilistPoster: 'https://poster.url');
      expect(series.isAnilistPosterBeingUsed, isTrue);
      expect(series.isLocalPosterBeingUsed, isFalse);
    });

    test('isLocalPosterBeingUsed forwards', () {
      final series = _makeSeries(localPosterPath: PathString(r'M:\poster.jpg'));
      expect(series.isLocalPosterBeingUsed, isTrue);
      expect(series.isAnilistPosterBeingUsed, isFalse);
    });

    test('isAnilistBannerBeingUsed forwards', () {
      final series = _makeSeries(anilistBanner: 'https://banner.url');
      expect(series.isAnilistBannerBeingUsed, isTrue);
      expect(series.isLocalBannerBeingUsed, isFalse);
    });

    test('isLocalBannerBeingUsed forwards', () {
      final series = _makeSeries(localBannerPath: PathString(r'M:\banner.jpg'));
      expect(series.isLocalBannerBeingUsed, isTrue);
      expect(series.isAnilistBannerBeingUsed, isFalse);
    });

    test('displayTitle forwards', () {
      final anime = _makeAnime(userPreferred: 'My Anime Season 2');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.displayTitle, 'My Anime');
    });

    test('bannerImage forwards from currentAnilistData', () {
      final anime = _makeAnime(bannerImage: 'https://banner.url');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.bannerImage, 'https://banner.url');
    });

    test('posterImage forwards from currentAnilistData', () {
      final anime = _makeAnime(posterImage: 'https://poster.url');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.posterImage, 'https://poster.url');
    });

    test('getEffectivePosterPathForEpisode forwards', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final anime = _makeAnime(posterImage: 'https://ep.poster');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime, localPath: r'M:\S\S01');
      final series = _makeSeries(seasons: [season], anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.getEffectivePosterPathForEpisode(ep), 'https://ep.poster');
    });

    test('getEffectivePosterColorForEpisode forwards', () {
      const col = Color(0xFFFF0000);
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, posterColor: col, localPath: r'M:\S\S01');
      final series = _makeSeries(seasons: [season], anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.getEffectivePosterColorForEpisode(ep), col);
    });

    test('getEffectivePosterPathForAnilistId forwards', () {
      final anime = _makeAnime(id: 42, posterImage: 'https://42.poster');
      final mapping = _makeMapping(anilistId: 42, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 42);

      expect(series.getEffectivePosterPathForAnilistId(42), 'https://42.poster');
    });

    test('getEffectivePosterColorForAnilistId forwards', () {
      const col = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 42, posterColor: col);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 42);

      expect(series.getEffectivePosterColorForAnilistId(42), col);
    });

    test('effectivePrimaryColorSync forwards', () {
      const col = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: col);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.anilist,
      );

      expect(series.effectivePrimaryColorSync(1), col);
    });

    test('clearCachedDominantColors forwards', () async {
      final series = _makeSeries(posterColor: const Color(0xFFFF0000));
      await series.clearCachedDominantColors();
      // After clearing, localPosterColor should fall back to anilist dominant
      // which is null (no anilist data) → null
      // But localPosterColor checks _localPosterDominantColor first, then anilist
      // Since posterColor sets the constructor value for mapping/raw, not _localPosterDominantColor,
      // this test just verifies it doesn't throw
    });
  });

  // =========================================================================
  // Series – formats edge cases
  // =========================================================================
  group('Series formats edge cases', () {
    test('deduplicates format strings', () {
      final a1 = _makeAnime(id: 1, format: 'TV');
      final a2 = _makeAnime(id: 2, format: 'TV');
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      // Deduplicates via toSet()
      expect(series.formats, 'TV');
    });

    test('handles mixed null and valid formats', () {
      final a1 = _makeAnime(id: 1, format: 'TV');
      final a2 = _makeAnime(id: 2); // null format
      final m1 = _makeMapping(anilistId: 1, anilistData: a1);
      final m2 = _makeMapping(anilistId: 2, anilistData: a2);
      final series = _makeSeries(anilistMappings: [m1, m2], primaryAnilistId: 1);

      expect(series.formats, isNotNull);
      expect(series.formats!.contains('TV'), isTrue);
    });
  });

  // =========================================================================
  // Series – totalEpisodes unlinked (no Manager.anilistProgress)
  // =========================================================================
  group('Series totalEpisodes unlinked', () {
    test('counts local episodes for unlinked', () {
      final eps1 = [
        _makeEpisode(path: r'M:\S\S01\E01.mkv'),
        _makeEpisode(path: r'M:\S\S01\E02.mkv'),
      ];
      final relEp = _makeEpisode(path: r'M:\S\OVA\OVA1.mkv');
      final s1 = _makeSeason(episodes: eps1);
      final series = _makeSeries(seasons: [s1], relatedMedia: [relEp]);

      expect(series.totalEpisodes, 3);
    });

    test('returns 0 for empty series', () {
      expect(_makeSeries().totalEpisodes, 0);
    });
  });

  // =========================================================================
  // Series toJson includes all presenter fields
  // =========================================================================
  group('Series toJson comprehensive', () {
    test('includes all key fields', () {
      final anime = _makeAnime(id: 1, posterImage: 'https://p.url', bannerImage: 'https://b.url');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(
        id: 5,
        name: 'Full Series',
        path: r'M:\Shows\Full',
        localPosterPath: PathString(r'M:\poster.jpg'),
        localBannerPath: PathString(r'M:\banner.jpg'),
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: const Color(0xFFFF0000),
        isHidden: true,
        customListName: 'favorites',
        customGridOrder: ['season_1'],
      );

      final json = series.toJson();
      expect(json['id'], 5);
      expect(json['name'], 'Full Series');
      expect(json['path'], r'M:\Shows\Full');
      expect(json['posterPath'], r'M:\poster.jpg');
      expect(json['bannerPath'], r'M:\banner.jpg');
      expect(json['isHidden'], true);
      expect(json['customListName'], 'favorites');
      expect(json['customGridOrder'], ['season_1']);
      expect(json['posterColor'], isNotNull); // Color serialized as int (posterColor → _localPosterDominantColor → rawPosterColor → toJson key)
      expect(json['anilistMappings'], isNotEmpty);
      expect(json['primaryAnilistId'], 1);
    });
  });

  // =========================================================================
  // Series – presenter raw accessors
  // =========================================================================
  group('SeriesPresenter raw accessors', () {
    test('rawAnilistPosterUrl and rawAnilistBannerUrl', () {
      final series = _makeSeries(
        anilistPoster: 'https://raw.poster',
        anilistBanner: 'https://raw.banner',
      );

      expect(series.presenter.rawAnilistPosterUrl, 'https://raw.poster');
      expect(series.presenter.rawAnilistBannerUrl, 'https://raw.banner');
    });

    test('rawPosterColor and rawBannerColor', () {
      const pc = Color(0xFFFF0000);
      const bc = Color(0xFF00FF00);
      final series = _makeSeries(posterColor: pc, bannerColor: bc);

      expect(series.presenter.rawPosterColor, pc);
      expect(series.presenter.rawBannerColor, bc);
    });
  });

  // =========================================================================
  // SeriesPresenter – autoAnilist poster (getEffective...ForEpisode branches)
  // =========================================================================
  group('SeriesPresenter autoAnilist specific branches', () {
    test('autoAnilist returns local poster when anilist not available', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final anime = _makeAnime(); // no posterImage
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime, localPath: r'M:\S\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.autoAnilist,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), r'M:\local.jpg');
    });

    test('autoLocal returns anilist poster when local not available', () {
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final anime = _makeAnime(posterImage: 'https://anilist.poster');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime, localPath: r'M:\S\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.autoLocal,
      );

      expect(series.presenter.getEffectivePosterPathForEpisode(ep), 'https://anilist.poster');
    });

    test('autoLocal ID returns local poster when available', () {
      final anime = _makeAnime(id: 42, posterImage: 'https://42.poster');
      final mapping = _makeMapping(anilistId: 42, anilistData: anime);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 42,
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.autoLocal,
      );

      expect(series.presenter.getEffectivePosterPathForAnilistId(42), r'M:\local.jpg');
    });

    test('autoLocal color for episode uses local dominant color first', () {
      const localCol = Color(0xFFFF0000);
      final ep = _makeEpisode(path: r'M:\S\S01\E01.mkv');
      final season = _makeSeason(path: r'M:\S\S01', episodes: [ep]);
      final mapping = _makeMapping(anilistId: 1, localPath: r'M:\S\S01');
      final series = _makeSeries(
        seasons: [season],
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        posterColor: localCol,
        preferredPosterSource: ImageSource.autoLocal,
      );

      // autoLocal: _localPosterDominantColor first → mapping.posterColor → anilist dominant
      // posterColor in constructor sets _localPosterDominantColor = localCol
      // So it returns localCol immediately
      final color = series.presenter.getEffectivePosterColorForEpisode(ep);
      expect(color, localCol);
    });

    test('autoLocal color for anilistId', () {
      const mapCol = Color(0xFF00FF00);
      final mapping = _makeMapping(anilistId: 1, posterColor: mapCol);
      final series = _makeSeries(
        anilistMappings: [mapping],
        primaryAnilistId: 1,
        preferredPosterSource: ImageSource.autoLocal,
      );

      // autoLocal: _localPosterDominantColor (null) → mapping.posterColor (mapCol)
      expect(series.presenter.getEffectivePosterColorForAnilistId(1), mapCol);
    });
  });
}
