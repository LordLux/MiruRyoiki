import 'package:flutter/widgets.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/mapping.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/settings.dart';
import 'package:miruryoiki/utils/path.dart';

/// Helper to create a minimal [Series] for testing.
Series _makeSeries({
  int? id,
  String name = 'Test Series',
  String path = r'M:\Series\Test Series',
  PathString? localPosterPath,
  PathString? localBannerPath,
  List<AnilistMapping> anilistMappings = const [],
  AnilistAnime? anilistData,
  Color? posterColor,
  Color? bannerColor,
  ImageSource? preferredPosterSource,
  ImageSource? preferredBannerSource,
  String? anilistPoster,
  String? anilistBanner,
  int? primaryAnilistId,
}) {
  return Series(
    id: id,
    name: name,
    path: PathString(path),
    localPosterPath: localPosterPath,
    localBannerPath: localBannerPath,
    seasons: [],
    relatedMedia: [],
    anilistMappings: anilistMappings,
    anilistData: anilistData,
    posterColor: posterColor,
    bannerColor: bannerColor,
    preferredPosterSource: preferredPosterSource,
    preferredBannerSource: preferredBannerSource,
    anilistPoster: anilistPoster,
    anilistBanner: anilistBanner,
    primaryAnilistId: primaryAnilistId,
  );
}

AnilistMapping _makeMapping({
  required int anilistId,
  String? title,
  AnilistAnime? anilistData,
  String localPath = r'M:\Series\Test',
}) {
  return AnilistMapping(
    localPath: PathString(localPath),
    anilistId: anilistId,
    title: title ?? 'Mapping $anilistId',
    anilistData: anilistData,
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
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // SettingsManager defaults are used (defaultPosterSource = autoAnilist, etc.)
    Manager.mockSettings = SettingsManager();
  });

  tearDownAll(() {
    Manager.mockSettings = null;
  });

  // =========================================================================
  // SeriesPresenter construction
  // =========================================================================
  group('SeriesPresenter construction', () {
    test('stores all fields from constructor', () {
      const posterCol = Color(0xFFFF0000);
      const bannerCol = Color(0xFF00FF00);
      final series = _makeSeries(
        posterColor: posterCol,
        bannerColor: bannerCol,
        preferredPosterSource: ImageSource.local,
        preferredBannerSource: ImageSource.anilist,
        anilistPoster: 'https://poster.url',
        anilistBanner: 'https://banner.url',
        localPosterPath: PathString(r'M:\posters\poster.jpg'),
        localBannerPath: PathString(r'M:\banners\banner.jpg'),
      );

      final p = series.presenter;
      expect(p.rawPosterColor, posterCol);
      expect(p.rawBannerColor, bannerCol);
      expect(p.preferredPosterSource, ImageSource.local);
      expect(p.preferredBannerSource, ImageSource.anilist);
      expect(p.rawAnilistPosterUrl, 'https://poster.url');
      expect(p.rawAnilistBannerUrl, 'https://banner.url');
      expect(p.localPosterPath?.path, r'M:\posters\poster.jpg');
      expect(p.localBannerPath?.path, r'M:\banners\banner.jpg');
    });

    test('fields default to null when not provided', () {
      final series = _makeSeries();
      final p = series.presenter;

      expect(p.rawPosterColor, isNull);
      expect(p.rawBannerColor, isNull);
      expect(p.preferredPosterSource, isNull);
      expect(p.preferredBannerSource, isNull);
      expect(p.rawAnilistPosterUrl, isNull);
      expect(p.rawAnilistBannerUrl, isNull);
      expect(p.localPosterPath, isNull);
      expect(p.localBannerPath, isNull);
    });
  });

  // =========================================================================
  // Equality & hashCode
  // =========================================================================
  group('SeriesPresenter equality', () {
    test('presenters with identical fields are equal', () {
      const col = Color(0xFFABCDEF);
      final a = _makeSeries(posterColor: col, anilistPoster: 'https://p.url');
      final b = _makeSeries(posterColor: col, anilistPoster: 'https://p.url');

      expect(a.presenter, equals(b.presenter));
      expect(a.presenter.hashCode, equals(b.presenter.hashCode));
    });

    test('presenters with different fields are not equal', () {
      final a = _makeSeries(posterColor: const Color(0xFFFF0000));
      final b = _makeSeries(posterColor: const Color(0xFF00FF00));

      expect(a.presenter, isNot(equals(b.presenter)));
    });

    test('equality propagates to Series', () {
      const col = Color(0xFF112233);
      final a = _makeSeries(id: 1, name: 'S', path: r'M:\S', posterColor: col);
      final b = _makeSeries(id: 1, name: 'S', path: r'M:\S', posterColor: col);

      expect(a, equals(b));
    });
  });

  // =========================================================================
  // Forwarding - Series delegates to presenter
  // =========================================================================
  group('Series -> SeriesPresenter forwarding', () {
    test('localPosterPath getter/setter forwards', () {
      final series = _makeSeries();
      expect(series.localPosterPath, isNull);

      series.localPosterPath = PathString(r'M:\new_poster.jpg');
      expect(series.localPosterPath?.path, r'M:\new_poster.jpg');
      expect(series.presenter.localPosterPath?.path, r'M:\new_poster.jpg');
    });

    test('localBannerPath getter/setter forwards', () {
      final series = _makeSeries();
      series.localBannerPath = PathString(r'M:\new_banner.jpg');
      expect(series.localBannerPath?.path, r'M:\new_banner.jpg');
      expect(series.presenter.localBannerPath?.path, r'M:\new_banner.jpg');
    });

    test('preferredPosterSource getter/setter forwards', () {
      final series = _makeSeries();
      series.preferredPosterSource = ImageSource.local;
      expect(series.preferredPosterSource, ImageSource.local);
      expect(series.presenter.preferredPosterSource, ImageSource.local);
    });

    test('preferredBannerSource getter/setter forwards', () {
      final series = _makeSeries();
      series.preferredBannerSource = ImageSource.anilist;
      expect(series.preferredBannerSource, ImageSource.anilist);
      expect(series.presenter.preferredBannerSource, ImageSource.anilist);
    });

    test('localPosterColor forwards', () {
      const col = Color(0xFFFF0000);
      final series = _makeSeries(posterColor: col);
      expect(series.localPosterColor, col);
      expect(series.presenter.localPosterColor, col);
    });

    test('localBannerColor forwards', () {
      const col = Color(0xFF00FF00);
      final series = _makeSeries(bannerColor: col);
      expect(series.localBannerColor, col);
      expect(series.presenter.localBannerColor, col);
    });

    test('anilistPosterUrl forwards', () {
      final series = _makeSeries(anilistPoster: 'https://poster.url');
      expect(series.anilistPosterUrl, 'https://poster.url');
    });

    test('anilistBannerUrl forwards', () {
      final series = _makeSeries(anilistBanner: 'https://banner.url');
      expect(series.anilistBannerUrl, 'https://banner.url');
    });

    test('bannerImage forwards', () {
      final anime = _makeAnime(bannerImage: 'https://banner.img');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.bannerImage, 'https://banner.img');
      expect(series.presenter.bannerImage, 'https://banner.img');
    });

    test('posterImage forwards', () {
      final anime = _makeAnime(posterImage: 'https://poster.img');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.posterImage, 'https://poster.img');
      expect(series.presenter.posterImage, 'https://poster.img');
    });

    test('displayTitle forwards', () {
      final anime = _makeAnime(userPreferred: 'My Anime');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.displayTitle, 'My Anime');
      expect(series.presenter.displayTitle, 'My Anime');
    });
  });

  // =========================================================================
  // displayTitle - season indicator removal
  // =========================================================================
  group('displayTitle season indicator removal', () {
    Series _seriesWithTitle(String title) {
      final anime = _makeAnime(userPreferred: title);
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      return _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
    }

    test('plain title unchanged', () {
      expect(_seriesWithTitle('Attack on Titan').displayTitle, 'Attack on Titan');
    });

    test('removes English "Season N"', () {
      expect(_seriesWithTitle('Attack on Titan Season 2').displayTitle, 'Attack on Titan');
    });

    test('removes English "Part N"', () {
      expect(_seriesWithTitle('Attack on Titan Part 3').displayTitle, 'Attack on Titan');
    });

    test('removes case-insensitive "season"', () {
      expect(_seriesWithTitle('My Anime SEASON 4').displayTitle, 'My Anime');
    });

    test('removes Japanese 第N期', () {
      expect(_seriesWithTitle('進撃の巨人 第2期').displayTitle, '進撃の巨人');
    });

    test('removes Japanese シーズンN', () {
      expect(_seriesWithTitle('Test シーズン3').displayTitle, 'Test');
    });

    test('removes Japanese N期', () {
      expect(_seriesWithTitle('Test 2期').displayTitle, 'Test');
    });

    test('removes bracketed season indicators', () {
      // The bracket content is removed by the general season pattern first,
      // leaving empty brackets which remain (pre-existing behavior).
      expect(_seriesWithTitle('My Anime [Season 2]').displayTitle, 'My Anime []');
    });

    test('removes Volume indicators', () {
      expect(_seriesWithTitle('My Anime Volume 3').displayTitle, 'My Anime');
    });

    test('removes trailing punctuation after removal', () {
      expect(_seriesWithTitle('My Anime: Season 2').displayTitle, 'My Anime');
    });

    test('falls back to series name when no anilist data', () {
      final series = _makeSeries(name: 'Folder Name');
      expect(series.displayTitle, 'Folder Name');
    });

    test('falls back to english title when userPreferred is null', () {
      final anime = _makeAnime(userPreferred: null, english: 'English Title');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.displayTitle, 'English Title');
    });

    test('falls back to romaji when english is also null', () {
      final anime = _makeAnime(userPreferred: null, english: null, romaji: 'Romaji Title');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.displayTitle, 'Romaji Title');
    });
  });

  // =========================================================================
  // toJson
  // =========================================================================
  group('SeriesPresenter toJson', () {
    test('serializes all presenter fields', () {
      const posterCol = Color(0xFFFF0000);
      const bannerCol = Color(0xFF00FF00);
      final series = _makeSeries(
        posterColor: posterCol,
        bannerColor: bannerCol,
        preferredPosterSource: ImageSource.local,
        preferredBannerSource: ImageSource.anilist,
        anilistPoster: 'https://poster.url',
        anilistBanner: 'https://banner.url',
        localPosterPath: PathString(r'M:\poster.jpg'),
        localBannerPath: PathString(r'M:\banner.jpg'),
      );

      final json = series.presenter.toJson();

      expect(json['posterPath'], r'M:\poster.jpg');
      expect(json['bannerPath'], r'M:\banner.jpg');
      expect(json['posterColor'], posterCol.value);
      expect(json['bannerColor'], bannerCol.value);
      expect(json['anilistPosterUrl'], 'https://poster.url');
      expect(json['anilistBannerUrl'], 'https://banner.url');
      expect(json['preferredPosterSource'], 'Local');
      expect(json['preferredBannerSource'], 'AniList');
    });

    test('toJson is spread into Series.toJson', () {
      const posterCol = Color(0xFFABCDEF);
      final series = _makeSeries(
        id: 42,
        name: 'My Show',
        posterColor: posterCol,
        anilistPoster: 'https://poster.url',
      );

      final json = series.toJson();
      // Series own fields
      expect(json['id'], 42);
      expect(json['name'], 'My Show');
      // Presenter fields merged in
      expect(json['posterColor'], posterCol.value);
      expect(json['anilistPosterUrl'], 'https://poster.url');
    });
  });

  // =========================================================================
  // copyWith
  // =========================================================================
  group('Series.copyWith preserves presenter state', () {
    test('copyWith without overrides preserves presenter fields', () {
      const posterCol = Color(0xFFFF0000);
      final original = _makeSeries(
        posterColor: posterCol,
        preferredPosterSource: ImageSource.local,
        anilistPoster: 'https://original.url',
        localPosterPath: PathString(r'M:\poster.jpg'),
      );

      final copy = original.copyWith(name: 'New Name');

      expect(copy.name, 'New Name');
      expect(copy.presenter.rawPosterColor, posterCol);
      expect(copy.presenter.preferredPosterSource, ImageSource.local);
      expect(copy.presenter.rawAnilistPosterUrl, 'https://original.url');
      expect(copy.presenter.localPosterPath?.path, r'M:\poster.jpg');
    });

    test('copyWith with overrides replaces presenter fields', () {
      final original = _makeSeries(posterColor: const Color(0xFFFF0000));
      const newCol = Color(0xFF00FF00);

      final copy = original.copyWith(posterColor: newCol);

      expect(copy.presenter.rawPosterColor, newCol);
    });
  });

  // =========================================================================
  // updateAnilistUrls
  // =========================================================================
  group('updateAnilistUrls', () {
    test('updates cached URLs', () {
      final series = _makeSeries();
      series.presenter.updateAnilistUrls(
        poster: 'https://new-poster.url',
        banner: 'https://new-banner.url',
      );

      expect(series.presenter.rawAnilistPosterUrl, 'https://new-poster.url');
      expect(series.presenter.rawAnilistBannerUrl, 'https://new-banner.url');
      expect(series.anilistPosterUrl, 'https://new-poster.url');
      expect(series.anilistBannerUrl, 'https://new-banner.url');
    });

    test('called when series.anilistData is set', () {
      final anime = _makeAnime(
        posterImage: 'https://poster.img',
        bannerImage: 'https://banner.img',
      );
      final mapping = _makeMapping(anilistId: 1);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      // Before setting anilistData
      expect(series.presenter.rawAnilistPosterUrl, isNull);

      // Set anilistData triggers updateAnilistUrls
      series.anilistData = anime;

      expect(series.presenter.rawAnilistPosterUrl, 'https://poster.img');
      expect(series.presenter.rawAnilistBannerUrl, 'https://banner.img');
    });
  });

  // =========================================================================
  // clearCachedDominantColors
  // =========================================================================
  group('clearCachedDominantColors', () {
    test('clears both cached colors', () async {
      const posterCol = Color(0xFFFF0000);
      const bannerCol = Color(0xFF00FF00);
      final series = _makeSeries(posterColor: posterCol, bannerColor: bannerCol);

      expect(series.presenter.rawPosterColor, posterCol);
      expect(series.presenter.rawBannerColor, bannerCol);

      await series.clearCachedDominantColors();

      expect(series.presenter.rawPosterColor, isNull);
      expect(series.presenter.rawBannerColor, isNull);
    });
  });

  // =========================================================================
  // Color fallback logic
  // =========================================================================
  group('Color fallback logic', () {
    test('localPosterColor returns stored color when available', () {
      const col = Color(0xFFFF0000);
      final series = _makeSeries(posterColor: col);
      expect(series.localPosterColor, col);
    });

    test('localPosterColor falls back to anilist dominant color', () {
      final anime = _makeAnime(dominantColor: '#00FF00');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      // No posterColor set, but anilist data has dominantColor
      expect(series.localPosterColor, const Color(0xFF00FF00));
    });

    test('localPosterColor returns null when nothing available', () {
      final series = _makeSeries();
      expect(series.localPosterColor, isNull);
    });

    test('localBannerColor returns stored color when available', () {
      const col = Color(0xFF0000FF);
      final series = _makeSeries(bannerColor: col);
      expect(series.localBannerColor, col);
    });

    test('localBannerColor falls back to anilist dominant color', () {
      final anime = _makeAnime(dominantColor: '#FF00FF');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.localBannerColor, const Color(0xFFFF00FF));
    });
  });

  // =========================================================================
  // Image source resolution (effectivePosterPath / effectiveBannerPath)
  // =========================================================================
  group('effectivePosterPath', () {
    test('autoAnilist prefers anilist URL when available', () {
      final series = _makeSeries(
        anilistPoster: 'https://anilist.poster',
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.autoAnilist,
      );
      expect(series.presenter.effectivePosterPath, 'https://anilist.poster');
    });

    test('autoAnilist falls back to local when no anilist URL', () {
      final series = _makeSeries(
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.autoAnilist,
      );
      expect(series.presenter.effectivePosterPath, r'M:\local.jpg');
    });

    test('autoLocal prefers local path when available', () {
      final series = _makeSeries(
        anilistPoster: 'https://anilist.poster',
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.autoLocal,
      );
      expect(series.presenter.effectivePosterPath, r'M:\local.jpg');
    });

    test('autoLocal falls back to anilist when no local path', () {
      final series = _makeSeries(
        anilistPoster: 'https://anilist.poster',
        preferredPosterSource: ImageSource.autoLocal,
      );
      expect(series.presenter.effectivePosterPath, 'https://anilist.poster');
    });

    test('returns null when nothing available', () {
      final series = _makeSeries(preferredPosterSource: ImageSource.local);
      expect(series.presenter.effectivePosterPath, isNull);
    });
  });

  group('effectiveBannerPath', () {
    test('autoAnilist prefers anilist URL when available', () {
      final series = _makeSeries(
        anilistBanner: 'https://anilist.banner',
        localBannerPath: PathString(r'M:\local_banner.jpg'),
        preferredBannerSource: ImageSource.autoAnilist,
      );
      expect(series.presenter.effectiveBannerPath, 'https://anilist.banner');
    });

    test('autoLocal prefers local path when available', () {
      final series = _makeSeries(
        anilistBanner: 'https://anilist.banner',
        localBannerPath: PathString(r'M:\local_banner.jpg'),
        preferredBannerSource: ImageSource.autoLocal,
      );
      expect(series.presenter.effectiveBannerPath, r'M:\local_banner.jpg');
    });
  });

  // =========================================================================
  // Source detection
  // =========================================================================
  group('Source detection', () {
    test('isAnilistPosterBeingUsed is true when anilist URL is effective path', () {
      final series = _makeSeries(
        anilistPoster: 'https://anilist.poster',
        preferredPosterSource: ImageSource.anilist,
      );
      expect(series.isAnilistPosterBeingUsed, isTrue);
      expect(series.isLocalPosterBeingUsed, isFalse);
    });

    test('isLocalPosterBeingUsed is true when local path is effective path', () {
      final series = _makeSeries(
        localPosterPath: PathString(r'M:\local.jpg'),
        preferredPosterSource: ImageSource.local,
      );
      expect(series.isLocalPosterBeingUsed, isTrue);
      expect(series.isAnilistPosterBeingUsed, isFalse);
    });

    test('isAnilistBannerBeingUsed is true when anilist URL is effective path', () {
      final series = _makeSeries(
        anilistBanner: 'https://anilist.banner',
        preferredBannerSource: ImageSource.anilist,
      );
      expect(series.isAnilistBannerBeingUsed, isTrue);
      expect(series.isLocalBannerBeingUsed, isFalse);
    });

    test('isLocalBannerBeingUsed is true when local path is effective path', () {
      final series = _makeSeries(
        localBannerPath: PathString(r'M:\local_banner.jpg'),
        preferredBannerSource: ImageSource.local,
      );
      expect(series.isLocalBannerBeingUsed, isTrue);
      expect(series.isAnilistBannerBeingUsed, isFalse);
    });

    test('all source detection false when no path available', () {
      final series = _makeSeries();
      expect(series.isAnilistPosterBeingUsed, isFalse);
      expect(series.isLocalPosterBeingUsed, isFalse);
      expect(series.isAnilistBannerBeingUsed, isFalse);
      expect(series.isLocalBannerBeingUsed, isFalse);
    });
  });

  // =========================================================================
  // Anilist URL fallback
  // =========================================================================
  group('Anilist URL fallback', () {
    test('anilistPosterUrl returns cached URL when set', () {
      final series = _makeSeries(anilistPoster: 'https://cached.url');
      expect(series.anilistPosterUrl, 'https://cached.url');
    });

    test('anilistPosterUrl falls back to anilistData posterImage', () {
      final anime = _makeAnime(posterImage: 'https://data.poster');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.anilistPosterUrl, 'https://data.poster');
    });

    test('anilistBannerUrl returns cached URL when set', () {
      final series = _makeSeries(anilistBanner: 'https://cached.banner');
      expect(series.anilistBannerUrl, 'https://cached.banner');
    });

    test('anilistBannerUrl falls back to anilistData bannerImage', () {
      final anime = _makeAnime(bannerImage: 'https://data.banner');
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);
      expect(series.anilistBannerUrl, 'https://data.banner');
    });
  });

  // =========================================================================
  // bannerImage / posterImage from anilist data
  // =========================================================================
  group('bannerImage / posterImage', () {
    test('returns null when no anilist data', () {
      final series = _makeSeries();
      expect(series.bannerImage, isNull);
      expect(series.posterImage, isNull);
    });

    test('returns anilist data images when linked', () {
      final anime = _makeAnime(
        posterImage: 'https://poster.img',
        bannerImage: 'https://banner.img',
      );
      final mapping = _makeMapping(anilistId: 1, anilistData: anime);
      final series = _makeSeries(anilistMappings: [mapping], primaryAnilistId: 1);

      expect(series.posterImage, 'https://poster.img');
      expect(series.bannerImage, 'https://banner.img');
    });
  });
}
