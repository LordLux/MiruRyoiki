import '../common/fragments.graphql.dart';
import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Variables$Query$SearchAnime {
  factory Variables$Query$SearchAnime({
    int? page,
    int? perPage,
    String? search,
    List<String?>? genres,
    List<String?>? excludedGenres,
    List<String?>? tags,
    List<String?>? excludedTags,
    List<Enum$MediaFormat?>? format,
    Enum$MediaStatus? status,
    Enum$MediaSeason? season,
    String? year,
    dynamic? yearLesser,
    dynamic? yearGreater,
    int? episodeLesser,
    int? episodeGreater,
    int? durationLesser,
    int? durationGreater,
    bool? onList,
    bool? isLicensed,
    List<int?>? licensedBy,
    int? minimumTagRank,
    String? countryOfOrigin,
    Enum$MediaSource? source,
    List<Enum$MediaSort?>? sort,
    bool? isAdult,
  }) =>
      Variables$Query$SearchAnime._({
        if (page != null) r'page': page,
        if (perPage != null) r'perPage': perPage,
        if (search != null) r'search': search,
        if (genres != null) r'genres': genres,
        if (excludedGenres != null) r'excludedGenres': excludedGenres,
        if (tags != null) r'tags': tags,
        if (excludedTags != null) r'excludedTags': excludedTags,
        if (format != null) r'format': format,
        if (status != null) r'status': status,
        if (season != null) r'season': season,
        if (year != null) r'year': year,
        if (yearLesser != null) r'yearLesser': yearLesser,
        if (yearGreater != null) r'yearGreater': yearGreater,
        if (episodeLesser != null) r'episodeLesser': episodeLesser,
        if (episodeGreater != null) r'episodeGreater': episodeGreater,
        if (durationLesser != null) r'durationLesser': durationLesser,
        if (durationGreater != null) r'durationGreater': durationGreater,
        if (onList != null) r'onList': onList,
        if (isLicensed != null) r'isLicensed': isLicensed,
        if (licensedBy != null) r'licensedBy': licensedBy,
        if (minimumTagRank != null) r'minimumTagRank': minimumTagRank,
        if (countryOfOrigin != null) r'countryOfOrigin': countryOfOrigin,
        if (source != null) r'source': source,
        if (sort != null) r'sort': sort,
        if (isAdult != null) r'isAdult': isAdult,
      });

  Variables$Query$SearchAnime._(this._$data);

  factory Variables$Query$SearchAnime.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    if (data.containsKey('perPage')) {
      final l$perPage = data['perPage'];
      result$data['perPage'] = (l$perPage as int?);
    }
    if (data.containsKey('search')) {
      final l$search = data['search'];
      result$data['search'] = (l$search as String?);
    }
    if (data.containsKey('genres')) {
      final l$genres = data['genres'];
      result$data['genres'] =
          (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList();
    }
    if (data.containsKey('excludedGenres')) {
      final l$excludedGenres = data['excludedGenres'];
      result$data['excludedGenres'] = (l$excludedGenres as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList();
    }
    if (data.containsKey('tags')) {
      final l$tags = data['tags'];
      result$data['tags'] =
          (l$tags as List<dynamic>?)?.map((e) => (e as String?)).toList();
    }
    if (data.containsKey('excludedTags')) {
      final l$excludedTags = data['excludedTags'];
      result$data['excludedTags'] = (l$excludedTags as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList();
    }
    if (data.containsKey('format')) {
      final l$format = data['format'];
      result$data['format'] = (l$format as List<dynamic>?)
          ?.map((e) =>
              e == null ? null : fromJson$Enum$MediaFormat((e as String)))
          .toList();
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : fromJson$Enum$MediaStatus((l$status as String));
    }
    if (data.containsKey('season')) {
      final l$season = data['season'];
      result$data['season'] = l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String));
    }
    if (data.containsKey('year')) {
      final l$year = data['year'];
      result$data['year'] = (l$year as String?);
    }
    if (data.containsKey('yearLesser')) {
      final l$yearLesser = data['yearLesser'];
      result$data['yearLesser'] = (l$yearLesser as dynamic?);
    }
    if (data.containsKey('yearGreater')) {
      final l$yearGreater = data['yearGreater'];
      result$data['yearGreater'] = (l$yearGreater as dynamic?);
    }
    if (data.containsKey('episodeLesser')) {
      final l$episodeLesser = data['episodeLesser'];
      result$data['episodeLesser'] = (l$episodeLesser as int?);
    }
    if (data.containsKey('episodeGreater')) {
      final l$episodeGreater = data['episodeGreater'];
      result$data['episodeGreater'] = (l$episodeGreater as int?);
    }
    if (data.containsKey('durationLesser')) {
      final l$durationLesser = data['durationLesser'];
      result$data['durationLesser'] = (l$durationLesser as int?);
    }
    if (data.containsKey('durationGreater')) {
      final l$durationGreater = data['durationGreater'];
      result$data['durationGreater'] = (l$durationGreater as int?);
    }
    if (data.containsKey('onList')) {
      final l$onList = data['onList'];
      result$data['onList'] = (l$onList as bool?);
    }
    if (data.containsKey('isLicensed')) {
      final l$isLicensed = data['isLicensed'];
      result$data['isLicensed'] = (l$isLicensed as bool?);
    }
    if (data.containsKey('licensedBy')) {
      final l$licensedBy = data['licensedBy'];
      result$data['licensedBy'] =
          (l$licensedBy as List<dynamic>?)?.map((e) => (e as int?)).toList();
    }
    if (data.containsKey('minimumTagRank')) {
      final l$minimumTagRank = data['minimumTagRank'];
      result$data['minimumTagRank'] = (l$minimumTagRank as int?);
    }
    if (data.containsKey('countryOfOrigin')) {
      final l$countryOfOrigin = data['countryOfOrigin'];
      result$data['countryOfOrigin'] = (l$countryOfOrigin as String?);
    }
    if (data.containsKey('source')) {
      final l$source = data['source'];
      result$data['source'] = l$source == null
          ? null
          : fromJson$Enum$MediaSource((l$source as String));
    }
    if (data.containsKey('sort')) {
      final l$sort = data['sort'];
      result$data['sort'] = (l$sort as List<dynamic>?)
          ?.map(
              (e) => e == null ? null : fromJson$Enum$MediaSort((e as String)))
          .toList();
    }
    if (data.containsKey('isAdult')) {
      final l$isAdult = data['isAdult'];
      result$data['isAdult'] = (l$isAdult as bool?);
    }
    return Variables$Query$SearchAnime._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get page => (_$data['page'] as int?);

  int? get perPage => (_$data['perPage'] as int?);

  String? get search => (_$data['search'] as String?);

  List<String?>? get genres => (_$data['genres'] as List<String?>?);

  List<String?>? get excludedGenres =>
      (_$data['excludedGenres'] as List<String?>?);

  List<String?>? get tags => (_$data['tags'] as List<String?>?);

  List<String?>? get excludedTags => (_$data['excludedTags'] as List<String?>?);

  List<Enum$MediaFormat?>? get format =>
      (_$data['format'] as List<Enum$MediaFormat?>?);

  Enum$MediaStatus? get status => (_$data['status'] as Enum$MediaStatus?);

  Enum$MediaSeason? get season => (_$data['season'] as Enum$MediaSeason?);

  String? get year => (_$data['year'] as String?);

  dynamic? get yearLesser => (_$data['yearLesser'] as dynamic?);

  dynamic? get yearGreater => (_$data['yearGreater'] as dynamic?);

  int? get episodeLesser => (_$data['episodeLesser'] as int?);

  int? get episodeGreater => (_$data['episodeGreater'] as int?);

  int? get durationLesser => (_$data['durationLesser'] as int?);

  int? get durationGreater => (_$data['durationGreater'] as int?);

  bool? get onList => (_$data['onList'] as bool?);

  bool? get isLicensed => (_$data['isLicensed'] as bool?);

  List<int?>? get licensedBy => (_$data['licensedBy'] as List<int?>?);

  int? get minimumTagRank => (_$data['minimumTagRank'] as int?);

  String? get countryOfOrigin => (_$data['countryOfOrigin'] as String?);

  Enum$MediaSource? get source => (_$data['source'] as Enum$MediaSource?);

  List<Enum$MediaSort?>? get sort => (_$data['sort'] as List<Enum$MediaSort?>?);

  bool? get isAdult => (_$data['isAdult'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    if (_$data.containsKey('perPage')) {
      final l$perPage = perPage;
      result$data['perPage'] = l$perPage;
    }
    if (_$data.containsKey('search')) {
      final l$search = search;
      result$data['search'] = l$search;
    }
    if (_$data.containsKey('genres')) {
      final l$genres = genres;
      result$data['genres'] = l$genres?.map((e) => e).toList();
    }
    if (_$data.containsKey('excludedGenres')) {
      final l$excludedGenres = excludedGenres;
      result$data['excludedGenres'] = l$excludedGenres?.map((e) => e).toList();
    }
    if (_$data.containsKey('tags')) {
      final l$tags = tags;
      result$data['tags'] = l$tags?.map((e) => e).toList();
    }
    if (_$data.containsKey('excludedTags')) {
      final l$excludedTags = excludedTags;
      result$data['excludedTags'] = l$excludedTags?.map((e) => e).toList();
    }
    if (_$data.containsKey('format')) {
      final l$format = format;
      result$data['format'] = l$format
          ?.map((e) => e == null ? null : toJson$Enum$MediaFormat(e))
          .toList();
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] =
          l$status == null ? null : toJson$Enum$MediaStatus(l$status);
    }
    if (_$data.containsKey('season')) {
      final l$season = season;
      result$data['season'] =
          l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    }
    if (_$data.containsKey('year')) {
      final l$year = year;
      result$data['year'] = l$year;
    }
    if (_$data.containsKey('yearLesser')) {
      final l$yearLesser = yearLesser;
      result$data['yearLesser'] = l$yearLesser;
    }
    if (_$data.containsKey('yearGreater')) {
      final l$yearGreater = yearGreater;
      result$data['yearGreater'] = l$yearGreater;
    }
    if (_$data.containsKey('episodeLesser')) {
      final l$episodeLesser = episodeLesser;
      result$data['episodeLesser'] = l$episodeLesser;
    }
    if (_$data.containsKey('episodeGreater')) {
      final l$episodeGreater = episodeGreater;
      result$data['episodeGreater'] = l$episodeGreater;
    }
    if (_$data.containsKey('durationLesser')) {
      final l$durationLesser = durationLesser;
      result$data['durationLesser'] = l$durationLesser;
    }
    if (_$data.containsKey('durationGreater')) {
      final l$durationGreater = durationGreater;
      result$data['durationGreater'] = l$durationGreater;
    }
    if (_$data.containsKey('onList')) {
      final l$onList = onList;
      result$data['onList'] = l$onList;
    }
    if (_$data.containsKey('isLicensed')) {
      final l$isLicensed = isLicensed;
      result$data['isLicensed'] = l$isLicensed;
    }
    if (_$data.containsKey('licensedBy')) {
      final l$licensedBy = licensedBy;
      result$data['licensedBy'] = l$licensedBy?.map((e) => e).toList();
    }
    if (_$data.containsKey('minimumTagRank')) {
      final l$minimumTagRank = minimumTagRank;
      result$data['minimumTagRank'] = l$minimumTagRank;
    }
    if (_$data.containsKey('countryOfOrigin')) {
      final l$countryOfOrigin = countryOfOrigin;
      result$data['countryOfOrigin'] = l$countryOfOrigin;
    }
    if (_$data.containsKey('source')) {
      final l$source = source;
      result$data['source'] =
          l$source == null ? null : toJson$Enum$MediaSource(l$source);
    }
    if (_$data.containsKey('sort')) {
      final l$sort = sort;
      result$data['sort'] = l$sort
          ?.map((e) => e == null ? null : toJson$Enum$MediaSort(e))
          .toList();
    }
    if (_$data.containsKey('isAdult')) {
      final l$isAdult = isAdult;
      result$data['isAdult'] = l$isAdult;
    }
    return result$data;
  }

  CopyWith$Variables$Query$SearchAnime<Variables$Query$SearchAnime>
      get copyWith => CopyWith$Variables$Query$SearchAnime(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SearchAnime ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$page = page;
    final lOther$page = other.page;
    if (_$data.containsKey('page') != other._$data.containsKey('page')) {
      return false;
    }
    if (l$page != lOther$page) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (_$data.containsKey('perPage') != other._$data.containsKey('perPage')) {
      return false;
    }
    if (l$perPage != lOther$perPage) {
      return false;
    }
    final l$search = search;
    final lOther$search = other.search;
    if (_$data.containsKey('search') != other._$data.containsKey('search')) {
      return false;
    }
    if (l$search != lOther$search) {
      return false;
    }
    final l$genres = genres;
    final lOther$genres = other.genres;
    if (_$data.containsKey('genres') != other._$data.containsKey('genres')) {
      return false;
    }
    if (l$genres != null && lOther$genres != null) {
      if (l$genres.length != lOther$genres.length) {
        return false;
      }
      for (int i = 0; i < l$genres.length; i++) {
        final l$genres$entry = l$genres[i];
        final lOther$genres$entry = lOther$genres[i];
        if (l$genres$entry != lOther$genres$entry) {
          return false;
        }
      }
    } else if (l$genres != lOther$genres) {
      return false;
    }
    final l$excludedGenres = excludedGenres;
    final lOther$excludedGenres = other.excludedGenres;
    if (_$data.containsKey('excludedGenres') !=
        other._$data.containsKey('excludedGenres')) {
      return false;
    }
    if (l$excludedGenres != null && lOther$excludedGenres != null) {
      if (l$excludedGenres.length != lOther$excludedGenres.length) {
        return false;
      }
      for (int i = 0; i < l$excludedGenres.length; i++) {
        final l$excludedGenres$entry = l$excludedGenres[i];
        final lOther$excludedGenres$entry = lOther$excludedGenres[i];
        if (l$excludedGenres$entry != lOther$excludedGenres$entry) {
          return false;
        }
      }
    } else if (l$excludedGenres != lOther$excludedGenres) {
      return false;
    }
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (_$data.containsKey('tags') != other._$data.containsKey('tags')) {
      return false;
    }
    if (l$tags != null && lOther$tags != null) {
      if (l$tags.length != lOther$tags.length) {
        return false;
      }
      for (int i = 0; i < l$tags.length; i++) {
        final l$tags$entry = l$tags[i];
        final lOther$tags$entry = lOther$tags[i];
        if (l$tags$entry != lOther$tags$entry) {
          return false;
        }
      }
    } else if (l$tags != lOther$tags) {
      return false;
    }
    final l$excludedTags = excludedTags;
    final lOther$excludedTags = other.excludedTags;
    if (_$data.containsKey('excludedTags') !=
        other._$data.containsKey('excludedTags')) {
      return false;
    }
    if (l$excludedTags != null && lOther$excludedTags != null) {
      if (l$excludedTags.length != lOther$excludedTags.length) {
        return false;
      }
      for (int i = 0; i < l$excludedTags.length; i++) {
        final l$excludedTags$entry = l$excludedTags[i];
        final lOther$excludedTags$entry = lOther$excludedTags[i];
        if (l$excludedTags$entry != lOther$excludedTags$entry) {
          return false;
        }
      }
    } else if (l$excludedTags != lOther$excludedTags) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (_$data.containsKey('format') != other._$data.containsKey('format')) {
      return false;
    }
    if (l$format != null && lOther$format != null) {
      if (l$format.length != lOther$format.length) {
        return false;
      }
      for (int i = 0; i < l$format.length; i++) {
        final l$format$entry = l$format[i];
        final lOther$format$entry = lOther$format[i];
        if (l$format$entry != lOther$format$entry) {
          return false;
        }
      }
    } else if (l$format != lOther$format) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (_$data.containsKey('season') != other._$data.containsKey('season')) {
      return false;
    }
    if (l$season != lOther$season) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (_$data.containsKey('year') != other._$data.containsKey('year')) {
      return false;
    }
    if (l$year != lOther$year) {
      return false;
    }
    final l$yearLesser = yearLesser;
    final lOther$yearLesser = other.yearLesser;
    if (_$data.containsKey('yearLesser') !=
        other._$data.containsKey('yearLesser')) {
      return false;
    }
    if (l$yearLesser != lOther$yearLesser) {
      return false;
    }
    final l$yearGreater = yearGreater;
    final lOther$yearGreater = other.yearGreater;
    if (_$data.containsKey('yearGreater') !=
        other._$data.containsKey('yearGreater')) {
      return false;
    }
    if (l$yearGreater != lOther$yearGreater) {
      return false;
    }
    final l$episodeLesser = episodeLesser;
    final lOther$episodeLesser = other.episodeLesser;
    if (_$data.containsKey('episodeLesser') !=
        other._$data.containsKey('episodeLesser')) {
      return false;
    }
    if (l$episodeLesser != lOther$episodeLesser) {
      return false;
    }
    final l$episodeGreater = episodeGreater;
    final lOther$episodeGreater = other.episodeGreater;
    if (_$data.containsKey('episodeGreater') !=
        other._$data.containsKey('episodeGreater')) {
      return false;
    }
    if (l$episodeGreater != lOther$episodeGreater) {
      return false;
    }
    final l$durationLesser = durationLesser;
    final lOther$durationLesser = other.durationLesser;
    if (_$data.containsKey('durationLesser') !=
        other._$data.containsKey('durationLesser')) {
      return false;
    }
    if (l$durationLesser != lOther$durationLesser) {
      return false;
    }
    final l$durationGreater = durationGreater;
    final lOther$durationGreater = other.durationGreater;
    if (_$data.containsKey('durationGreater') !=
        other._$data.containsKey('durationGreater')) {
      return false;
    }
    if (l$durationGreater != lOther$durationGreater) {
      return false;
    }
    final l$onList = onList;
    final lOther$onList = other.onList;
    if (_$data.containsKey('onList') != other._$data.containsKey('onList')) {
      return false;
    }
    if (l$onList != lOther$onList) {
      return false;
    }
    final l$isLicensed = isLicensed;
    final lOther$isLicensed = other.isLicensed;
    if (_$data.containsKey('isLicensed') !=
        other._$data.containsKey('isLicensed')) {
      return false;
    }
    if (l$isLicensed != lOther$isLicensed) {
      return false;
    }
    final l$licensedBy = licensedBy;
    final lOther$licensedBy = other.licensedBy;
    if (_$data.containsKey('licensedBy') !=
        other._$data.containsKey('licensedBy')) {
      return false;
    }
    if (l$licensedBy != null && lOther$licensedBy != null) {
      if (l$licensedBy.length != lOther$licensedBy.length) {
        return false;
      }
      for (int i = 0; i < l$licensedBy.length; i++) {
        final l$licensedBy$entry = l$licensedBy[i];
        final lOther$licensedBy$entry = lOther$licensedBy[i];
        if (l$licensedBy$entry != lOther$licensedBy$entry) {
          return false;
        }
      }
    } else if (l$licensedBy != lOther$licensedBy) {
      return false;
    }
    final l$minimumTagRank = minimumTagRank;
    final lOther$minimumTagRank = other.minimumTagRank;
    if (_$data.containsKey('minimumTagRank') !=
        other._$data.containsKey('minimumTagRank')) {
      return false;
    }
    if (l$minimumTagRank != lOther$minimumTagRank) {
      return false;
    }
    final l$countryOfOrigin = countryOfOrigin;
    final lOther$countryOfOrigin = other.countryOfOrigin;
    if (_$data.containsKey('countryOfOrigin') !=
        other._$data.containsKey('countryOfOrigin')) {
      return false;
    }
    if (l$countryOfOrigin != lOther$countryOfOrigin) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (_$data.containsKey('source') != other._$data.containsKey('source')) {
      return false;
    }
    if (l$source != lOther$source) {
      return false;
    }
    final l$sort = sort;
    final lOther$sort = other.sort;
    if (_$data.containsKey('sort') != other._$data.containsKey('sort')) {
      return false;
    }
    if (l$sort != null && lOther$sort != null) {
      if (l$sort.length != lOther$sort.length) {
        return false;
      }
      for (int i = 0; i < l$sort.length; i++) {
        final l$sort$entry = l$sort[i];
        final lOther$sort$entry = lOther$sort[i];
        if (l$sort$entry != lOther$sort$entry) {
          return false;
        }
      }
    } else if (l$sort != lOther$sort) {
      return false;
    }
    final l$isAdult = isAdult;
    final lOther$isAdult = other.isAdult;
    if (_$data.containsKey('isAdult') != other._$data.containsKey('isAdult')) {
      return false;
    }
    if (l$isAdult != lOther$isAdult) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$page = page;
    final l$perPage = perPage;
    final l$search = search;
    final l$genres = genres;
    final l$excludedGenres = excludedGenres;
    final l$tags = tags;
    final l$excludedTags = excludedTags;
    final l$format = format;
    final l$status = status;
    final l$season = season;
    final l$year = year;
    final l$yearLesser = yearLesser;
    final l$yearGreater = yearGreater;
    final l$episodeLesser = episodeLesser;
    final l$episodeGreater = episodeGreater;
    final l$durationLesser = durationLesser;
    final l$durationGreater = durationGreater;
    final l$onList = onList;
    final l$isLicensed = isLicensed;
    final l$licensedBy = licensedBy;
    final l$minimumTagRank = minimumTagRank;
    final l$countryOfOrigin = countryOfOrigin;
    final l$source = source;
    final l$sort = sort;
    final l$isAdult = isAdult;
    return Object.hashAll([
      _$data.containsKey('page') ? l$page : const {},
      _$data.containsKey('perPage') ? l$perPage : const {},
      _$data.containsKey('search') ? l$search : const {},
      _$data.containsKey('genres')
          ? l$genres == null
              ? null
              : Object.hashAll(l$genres.map((v) => v))
          : const {},
      _$data.containsKey('excludedGenres')
          ? l$excludedGenres == null
              ? null
              : Object.hashAll(l$excludedGenres.map((v) => v))
          : const {},
      _$data.containsKey('tags')
          ? l$tags == null
              ? null
              : Object.hashAll(l$tags.map((v) => v))
          : const {},
      _$data.containsKey('excludedTags')
          ? l$excludedTags == null
              ? null
              : Object.hashAll(l$excludedTags.map((v) => v))
          : const {},
      _$data.containsKey('format')
          ? l$format == null
              ? null
              : Object.hashAll(l$format.map((v) => v))
          : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('season') ? l$season : const {},
      _$data.containsKey('year') ? l$year : const {},
      _$data.containsKey('yearLesser') ? l$yearLesser : const {},
      _$data.containsKey('yearGreater') ? l$yearGreater : const {},
      _$data.containsKey('episodeLesser') ? l$episodeLesser : const {},
      _$data.containsKey('episodeGreater') ? l$episodeGreater : const {},
      _$data.containsKey('durationLesser') ? l$durationLesser : const {},
      _$data.containsKey('durationGreater') ? l$durationGreater : const {},
      _$data.containsKey('onList') ? l$onList : const {},
      _$data.containsKey('isLicensed') ? l$isLicensed : const {},
      _$data.containsKey('licensedBy')
          ? l$licensedBy == null
              ? null
              : Object.hashAll(l$licensedBy.map((v) => v))
          : const {},
      _$data.containsKey('minimumTagRank') ? l$minimumTagRank : const {},
      _$data.containsKey('countryOfOrigin') ? l$countryOfOrigin : const {},
      _$data.containsKey('source') ? l$source : const {},
      _$data.containsKey('sort')
          ? l$sort == null
              ? null
              : Object.hashAll(l$sort.map((v) => v))
          : const {},
      _$data.containsKey('isAdult') ? l$isAdult : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$SearchAnime<TRes> {
  factory CopyWith$Variables$Query$SearchAnime(
    Variables$Query$SearchAnime instance,
    TRes Function(Variables$Query$SearchAnime) then,
  ) = _CopyWithImpl$Variables$Query$SearchAnime;

  factory CopyWith$Variables$Query$SearchAnime.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SearchAnime;

  TRes call({
    int? page,
    int? perPage,
    String? search,
    List<String?>? genres,
    List<String?>? excludedGenres,
    List<String?>? tags,
    List<String?>? excludedTags,
    List<Enum$MediaFormat?>? format,
    Enum$MediaStatus? status,
    Enum$MediaSeason? season,
    String? year,
    dynamic? yearLesser,
    dynamic? yearGreater,
    int? episodeLesser,
    int? episodeGreater,
    int? durationLesser,
    int? durationGreater,
    bool? onList,
    bool? isLicensed,
    List<int?>? licensedBy,
    int? minimumTagRank,
    String? countryOfOrigin,
    Enum$MediaSource? source,
    List<Enum$MediaSort?>? sort,
    bool? isAdult,
  });
}

class _CopyWithImpl$Variables$Query$SearchAnime<TRes>
    implements CopyWith$Variables$Query$SearchAnime<TRes> {
  _CopyWithImpl$Variables$Query$SearchAnime(
    this._instance,
    this._then,
  );

  final Variables$Query$SearchAnime _instance;

  final TRes Function(Variables$Query$SearchAnime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? page = _undefined,
    Object? perPage = _undefined,
    Object? search = _undefined,
    Object? genres = _undefined,
    Object? excludedGenres = _undefined,
    Object? tags = _undefined,
    Object? excludedTags = _undefined,
    Object? format = _undefined,
    Object? status = _undefined,
    Object? season = _undefined,
    Object? year = _undefined,
    Object? yearLesser = _undefined,
    Object? yearGreater = _undefined,
    Object? episodeLesser = _undefined,
    Object? episodeGreater = _undefined,
    Object? durationLesser = _undefined,
    Object? durationGreater = _undefined,
    Object? onList = _undefined,
    Object? isLicensed = _undefined,
    Object? licensedBy = _undefined,
    Object? minimumTagRank = _undefined,
    Object? countryOfOrigin = _undefined,
    Object? source = _undefined,
    Object? sort = _undefined,
    Object? isAdult = _undefined,
  }) =>
      _then(Variables$Query$SearchAnime._({
        ..._instance._$data,
        if (page != _undefined) 'page': (page as int?),
        if (perPage != _undefined) 'perPage': (perPage as int?),
        if (search != _undefined) 'search': (search as String?),
        if (genres != _undefined) 'genres': (genres as List<String?>?),
        if (excludedGenres != _undefined)
          'excludedGenres': (excludedGenres as List<String?>?),
        if (tags != _undefined) 'tags': (tags as List<String?>?),
        if (excludedTags != _undefined)
          'excludedTags': (excludedTags as List<String?>?),
        if (format != _undefined)
          'format': (format as List<Enum$MediaFormat?>?),
        if (status != _undefined) 'status': (status as Enum$MediaStatus?),
        if (season != _undefined) 'season': (season as Enum$MediaSeason?),
        if (year != _undefined) 'year': (year as String?),
        if (yearLesser != _undefined) 'yearLesser': (yearLesser as dynamic?),
        if (yearGreater != _undefined) 'yearGreater': (yearGreater as dynamic?),
        if (episodeLesser != _undefined)
          'episodeLesser': (episodeLesser as int?),
        if (episodeGreater != _undefined)
          'episodeGreater': (episodeGreater as int?),
        if (durationLesser != _undefined)
          'durationLesser': (durationLesser as int?),
        if (durationGreater != _undefined)
          'durationGreater': (durationGreater as int?),
        if (onList != _undefined) 'onList': (onList as bool?),
        if (isLicensed != _undefined) 'isLicensed': (isLicensed as bool?),
        if (licensedBy != _undefined) 'licensedBy': (licensedBy as List<int?>?),
        if (minimumTagRank != _undefined)
          'minimumTagRank': (minimumTagRank as int?),
        if (countryOfOrigin != _undefined)
          'countryOfOrigin': (countryOfOrigin as String?),
        if (source != _undefined) 'source': (source as Enum$MediaSource?),
        if (sort != _undefined) 'sort': (sort as List<Enum$MediaSort?>?),
        if (isAdult != _undefined) 'isAdult': (isAdult as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Query$SearchAnime<TRes>
    implements CopyWith$Variables$Query$SearchAnime<TRes> {
  _CopyWithStubImpl$Variables$Query$SearchAnime(this._res);

  TRes _res;

  call({
    int? page,
    int? perPage,
    String? search,
    List<String?>? genres,
    List<String?>? excludedGenres,
    List<String?>? tags,
    List<String?>? excludedTags,
    List<Enum$MediaFormat?>? format,
    Enum$MediaStatus? status,
    Enum$MediaSeason? season,
    String? year,
    dynamic? yearLesser,
    dynamic? yearGreater,
    int? episodeLesser,
    int? episodeGreater,
    int? durationLesser,
    int? durationGreater,
    bool? onList,
    bool? isLicensed,
    List<int?>? licensedBy,
    int? minimumTagRank,
    String? countryOfOrigin,
    Enum$MediaSource? source,
    List<Enum$MediaSort?>? sort,
    bool? isAdult,
  }) =>
      _res;
}

class Query$SearchAnime {
  Query$SearchAnime({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$SearchAnime.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime(
      Page: l$Page == null
          ? null
          : Query$SearchAnime$Page.fromJson((l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SearchAnime$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Page = Page;
    final lOther$Page = other.Page;
    if (l$Page != lOther$Page) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime on Query$SearchAnime {
  CopyWith$Query$SearchAnime<Query$SearchAnime> get copyWith =>
      CopyWith$Query$SearchAnime(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SearchAnime<TRes> {
  factory CopyWith$Query$SearchAnime(
    Query$SearchAnime instance,
    TRes Function(Query$SearchAnime) then,
  ) = _CopyWithImpl$Query$SearchAnime;

  factory CopyWith$Query$SearchAnime.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime;

  TRes call({
    Query$SearchAnime$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$SearchAnime$Page<TRes> get Page;
}

class _CopyWithImpl$Query$SearchAnime<TRes>
    implements CopyWith$Query$SearchAnime<TRes> {
  _CopyWithImpl$Query$SearchAnime(
    this._instance,
    this._then,
  );

  final Query$SearchAnime _instance;

  final TRes Function(Query$SearchAnime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$SearchAnime$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$SearchAnime$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$SearchAnime$Page.stub(_then(_instance))
        : CopyWith$Query$SearchAnime$Page(local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$SearchAnime<TRes>
    implements CopyWith$Query$SearchAnime<TRes> {
  _CopyWithStubImpl$Query$SearchAnime(this._res);

  TRes _res;

  call({
    Query$SearchAnime$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$SearchAnime$Page<TRes> get Page =>
      CopyWith$Query$SearchAnime$Page.stub(_res);
}

const documentNodeQuerySearchAnime = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'SearchAnime'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'perPage')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'search')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'genres')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'excludedGenres')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'tags')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'excludedTags')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'format')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'MediaFormat'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'status')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaStatus'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'season')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaSeason'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'year')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'yearLesser')),
        type: NamedTypeNode(
          name: NameNode(value: 'FuzzyDateInt'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'yearGreater')),
        type: NamedTypeNode(
          name: NameNode(value: 'FuzzyDateInt'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'episodeLesser')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'episodeGreater')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'durationLesser')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'durationGreater')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'onList')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'isLicensed')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'licensedBy')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'Int'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'minimumTagRank')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'countryOfOrigin')),
        type: NamedTypeNode(
          name: NameNode(value: 'CountryCode'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'source')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaSource'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'sort')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'MediaSort'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'isAdult')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'page'),
            value: VariableNode(name: NameNode(value: 'page')),
          ),
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: VariableNode(name: NameNode(value: 'perPage')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'pageInfo'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'total'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'perPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'currentPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'lastPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'hasNextPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'type'),
                value: EnumValueNode(name: NameNode(value: 'ANIME')),
              ),
              ArgumentNode(
                name: NameNode(value: 'search'),
                value: VariableNode(name: NameNode(value: 'search')),
              ),
              ArgumentNode(
                name: NameNode(value: 'genre_in'),
                value: VariableNode(name: NameNode(value: 'genres')),
              ),
              ArgumentNode(
                name: NameNode(value: 'genre_not_in'),
                value: VariableNode(name: NameNode(value: 'excludedGenres')),
              ),
              ArgumentNode(
                name: NameNode(value: 'tag_in'),
                value: VariableNode(name: NameNode(value: 'tags')),
              ),
              ArgumentNode(
                name: NameNode(value: 'tag_not_in'),
                value: VariableNode(name: NameNode(value: 'excludedTags')),
              ),
              ArgumentNode(
                name: NameNode(value: 'format_in'),
                value: VariableNode(name: NameNode(value: 'format')),
              ),
              ArgumentNode(
                name: NameNode(value: 'status'),
                value: VariableNode(name: NameNode(value: 'status')),
              ),
              ArgumentNode(
                name: NameNode(value: 'season'),
                value: VariableNode(name: NameNode(value: 'season')),
              ),
              ArgumentNode(
                name: NameNode(value: 'startDate_like'),
                value: VariableNode(name: NameNode(value: 'year')),
              ),
              ArgumentNode(
                name: NameNode(value: 'startDate_lesser'),
                value: VariableNode(name: NameNode(value: 'yearLesser')),
              ),
              ArgumentNode(
                name: NameNode(value: 'startDate_greater'),
                value: VariableNode(name: NameNode(value: 'yearGreater')),
              ),
              ArgumentNode(
                name: NameNode(value: 'episodes_lesser'),
                value: VariableNode(name: NameNode(value: 'episodeLesser')),
              ),
              ArgumentNode(
                name: NameNode(value: 'episodes_greater'),
                value: VariableNode(name: NameNode(value: 'episodeGreater')),
              ),
              ArgumentNode(
                name: NameNode(value: 'duration_lesser'),
                value: VariableNode(name: NameNode(value: 'durationLesser')),
              ),
              ArgumentNode(
                name: NameNode(value: 'duration_greater'),
                value: VariableNode(name: NameNode(value: 'durationGreater')),
              ),
              ArgumentNode(
                name: NameNode(value: 'onList'),
                value: VariableNode(name: NameNode(value: 'onList')),
              ),
              ArgumentNode(
                name: NameNode(value: 'isLicensed'),
                value: VariableNode(name: NameNode(value: 'isLicensed')),
              ),
              ArgumentNode(
                name: NameNode(value: 'licensedById_in'),
                value: VariableNode(name: NameNode(value: 'licensedBy')),
              ),
              ArgumentNode(
                name: NameNode(value: 'minimumTagRank'),
                value: VariableNode(name: NameNode(value: 'minimumTagRank')),
              ),
              ArgumentNode(
                name: NameNode(value: 'countryOfOrigin'),
                value: VariableNode(name: NameNode(value: 'countryOfOrigin')),
              ),
              ArgumentNode(
                name: NameNode(value: 'source'),
                value: VariableNode(name: NameNode(value: 'source')),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: VariableNode(name: NameNode(value: 'sort')),
              ),
              ArgumentNode(
                name: NameNode(value: 'isAdult'),
                value: VariableNode(name: NameNode(value: 'isAdult')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'AnimeCard'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: 'bannerImage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'description'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'endDate'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'year'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'month'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'day'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: 'updatedAt'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'siteUrl'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionAnimeCard,
]);
Query$SearchAnime _parserFn$Query$SearchAnime(Map<String, dynamic> data) =>
    Query$SearchAnime.fromJson(data);
typedef OnQueryComplete$Query$SearchAnime = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$SearchAnime?,
);

class Options$Query$SearchAnime
    extends graphql.QueryOptions<Query$SearchAnime> {
  Options$Query$SearchAnime({
    String? operationName,
    Variables$Query$SearchAnime? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SearchAnime? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SearchAnime? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$SearchAnime(data),
                  ),
          onError: onError,
          document: documentNodeQuerySearchAnime,
          parserFn: _parserFn$Query$SearchAnime,
        );

  final OnQueryComplete$Query$SearchAnime? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$SearchAnime
    extends graphql.WatchQueryOptions<Query$SearchAnime> {
  WatchOptions$Query$SearchAnime({
    String? operationName,
    Variables$Query$SearchAnime? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SearchAnime? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQuerySearchAnime,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$SearchAnime,
        );
}

class FetchMoreOptions$Query$SearchAnime extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SearchAnime({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$SearchAnime? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQuerySearchAnime,
        );
}

extension ClientExtension$Query$SearchAnime on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SearchAnime>> query$SearchAnime(
          [Options$Query$SearchAnime? options]) async =>
      await this.query(options ?? Options$Query$SearchAnime());
  graphql.ObservableQuery<Query$SearchAnime> watchQuery$SearchAnime(
          [WatchOptions$Query$SearchAnime? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$SearchAnime());
  void writeQuery$SearchAnime({
    required Query$SearchAnime data,
    Variables$Query$SearchAnime? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(document: documentNodeQuerySearchAnime),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$SearchAnime? readQuery$SearchAnime({
    Variables$Query$SearchAnime? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQuerySearchAnime),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SearchAnime.fromJson(result);
  }
}

class Query$SearchAnime$Page {
  Query$SearchAnime$Page({
    this.pageInfo,
    this.media,
    this.$__typename = 'Page',
  });

  factory Query$SearchAnime$Page.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page(
      pageInfo: l$pageInfo == null
          ? null
          : Query$SearchAnime$Page$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      media: (l$media as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$SearchAnime$Page$media.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SearchAnime$Page$pageInfo? pageInfo;

  final List<Query$SearchAnime$Page$media?>? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$media = media;
    _resultData['media'] = l$media?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$media == null ? null : Object.hashAll(l$media.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page || runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != null && lOther$media != null) {
      if (l$media.length != lOther$media.length) {
        return false;
      }
      for (int i = 0; i < l$media.length; i++) {
        final l$media$entry = l$media[i];
        final lOther$media$entry = lOther$media[i];
        if (l$media$entry != lOther$media$entry) {
          return false;
        }
      }
    } else if (l$media != lOther$media) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page on Query$SearchAnime$Page {
  CopyWith$Query$SearchAnime$Page<Query$SearchAnime$Page> get copyWith =>
      CopyWith$Query$SearchAnime$Page(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SearchAnime$Page<TRes> {
  factory CopyWith$Query$SearchAnime$Page(
    Query$SearchAnime$Page instance,
    TRes Function(Query$SearchAnime$Page) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page;

  factory CopyWith$Query$SearchAnime$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page;

  TRes call({
    Query$SearchAnime$Page$pageInfo? pageInfo,
    List<Query$SearchAnime$Page$media?>? media,
    String? $__typename,
  });
  CopyWith$Query$SearchAnime$Page$pageInfo<TRes> get pageInfo;
  TRes media(
      Iterable<Query$SearchAnime$Page$media?>? Function(
              Iterable<
                  CopyWith$Query$SearchAnime$Page$media<
                      Query$SearchAnime$Page$media>?>?)
          _fn);
}

class _CopyWithImpl$Query$SearchAnime$Page<TRes>
    implements CopyWith$Query$SearchAnime$Page<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page _instance;

  final TRes Function(Query$SearchAnime$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$SearchAnime$Page$pageInfo?),
        media: media == _undefined
            ? _instance.media
            : (media as List<Query$SearchAnime$Page$media?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$SearchAnime$Page$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$SearchAnime$Page$pageInfo.stub(_then(_instance))
        : CopyWith$Query$SearchAnime$Page$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes media(
          Iterable<Query$SearchAnime$Page$media?>? Function(
                  Iterable<
                      CopyWith$Query$SearchAnime$Page$media<
                          Query$SearchAnime$Page$media>?>?)
              _fn) =>
      call(
          media: _fn(_instance.media?.map((e) => e == null
              ? null
              : CopyWith$Query$SearchAnime$Page$media(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$SearchAnime$Page<TRes>
    implements CopyWith$Query$SearchAnime$Page<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page(this._res);

  TRes _res;

  call({
    Query$SearchAnime$Page$pageInfo? pageInfo,
    List<Query$SearchAnime$Page$media?>? media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$SearchAnime$Page$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$SearchAnime$Page$pageInfo.stub(_res);

  media(_fn) => _res;
}

class Query$SearchAnime$Page$pageInfo {
  Query$SearchAnime$Page$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$SearchAnime$Page$pageInfo.fromJson(Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
      return false;
    }
    final l$currentPage = currentPage;
    final lOther$currentPage = other.currentPage;
    if (l$currentPage != lOther$currentPage) {
      return false;
    }
    final l$lastPage = lastPage;
    final lOther$lastPage = other.lastPage;
    if (l$lastPage != lOther$lastPage) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$pageInfo
    on Query$SearchAnime$Page$pageInfo {
  CopyWith$Query$SearchAnime$Page$pageInfo<Query$SearchAnime$Page$pageInfo>
      get copyWith => CopyWith$Query$SearchAnime$Page$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$pageInfo<TRes> {
  factory CopyWith$Query$SearchAnime$Page$pageInfo(
    Query$SearchAnime$Page$pageInfo instance,
    TRes Function(Query$SearchAnime$Page$pageInfo) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$pageInfo;

  factory CopyWith$Query$SearchAnime$Page$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$pageInfo<TRes>
    implements CopyWith$Query$SearchAnime$Page$pageInfo<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$pageInfo(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$pageInfo _instance;

  final TRes Function(Query$SearchAnime$Page$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$pageInfo<TRes>
    implements CopyWith$Query$SearchAnime$Page$pageInfo<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$SearchAnime$Page$media implements Fragment$AnimeCard {
  Query$SearchAnime$Page$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.status,
    this.episodes,
    this.seasonYear,
    this.season,
    this.averageScore,
    this.meanScore,
    this.popularity,
    this.isAdult,
    required this.isFavourite,
    this.nextAiringEpisode,
    this.startDate,
    this.genres,
    this.$__typename = 'Media',
    this.bannerImage,
    this.description,
    this.endDate,
    this.updatedAt,
    this.siteUrl,
  });

  factory Query$SearchAnime$Page$media.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$status = json['status'];
    final l$episodes = json['episodes'];
    final l$seasonYear = json['seasonYear'];
    final l$season = json['season'];
    final l$averageScore = json['averageScore'];
    final l$meanScore = json['meanScore'];
    final l$popularity = json['popularity'];
    final l$isAdult = json['isAdult'];
    final l$isFavourite = json['isFavourite'];
    final l$nextAiringEpisode = json['nextAiringEpisode'];
    final l$startDate = json['startDate'];
    final l$genres = json['genres'];
    final l$$__typename = json['__typename'];
    final l$bannerImage = json['bannerImage'];
    final l$description = json['description'];
    final l$endDate = json['endDate'];
    final l$updatedAt = json['updatedAt'];
    final l$siteUrl = json['siteUrl'];
    return Query$SearchAnime$Page$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$SearchAnime$Page$media$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$SearchAnime$Page$media$coverImage.fromJson(
              (l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaStatus((l$status as String)),
      episodes: (l$episodes as int?),
      seasonYear: (l$seasonYear as int?),
      season: l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String)),
      averageScore: (l$averageScore as int?),
      meanScore: (l$meanScore as int?),
      popularity: (l$popularity as int?),
      isAdult: (l$isAdult as bool?),
      isFavourite: (l$isFavourite as bool),
      nextAiringEpisode: l$nextAiringEpisode == null
          ? null
          : Query$SearchAnime$Page$media$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Query$SearchAnime$Page$media$startDate.fromJson(
              (l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      bannerImage: (l$bannerImage as String?),
      description: (l$description as String?),
      endDate: l$endDate == null
          ? null
          : Query$SearchAnime$Page$media$endDate.fromJson(
              (l$endDate as Map<String, dynamic>)),
      updatedAt: (l$updatedAt as int?),
      siteUrl: (l$siteUrl as String?),
    );
  }

  final int id;

  final Query$SearchAnime$Page$media$title? title;

  final Query$SearchAnime$Page$media$coverImage? coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final Enum$MediaStatus? status;

  final int? episodes;

  final int? seasonYear;

  final Enum$MediaSeason? season;

  final int? averageScore;

  final int? meanScore;

  final int? popularity;

  final bool? isAdult;

  final bool isFavourite;

  final Query$SearchAnime$Page$media$nextAiringEpisode? nextAiringEpisode;

  final Query$SearchAnime$Page$media$startDate? startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? bannerImage;

  final String? description;

  final Query$SearchAnime$Page$media$endDate? endDate;

  final int? updatedAt;

  final String? siteUrl;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title?.toJson();
    final l$coverImage = coverImage;
    _resultData['coverImage'] = l$coverImage?.toJson();
    final l$type = type;
    _resultData['type'] = l$type == null ? null : toJson$Enum$MediaType(l$type);
    final l$format = format;
    _resultData['format'] =
        l$format == null ? null : toJson$Enum$MediaFormat(l$format);
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaStatus(l$status);
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$seasonYear = seasonYear;
    _resultData['seasonYear'] = l$seasonYear;
    final l$season = season;
    _resultData['season'] =
        l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    final l$averageScore = averageScore;
    _resultData['averageScore'] = l$averageScore;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$popularity = popularity;
    _resultData['popularity'] = l$popularity;
    final l$isAdult = isAdult;
    _resultData['isAdult'] = l$isAdult;
    final l$isFavourite = isFavourite;
    _resultData['isFavourite'] = l$isFavourite;
    final l$nextAiringEpisode = nextAiringEpisode;
    _resultData['nextAiringEpisode'] = l$nextAiringEpisode?.toJson();
    final l$startDate = startDate;
    _resultData['startDate'] = l$startDate?.toJson();
    final l$genres = genres;
    _resultData['genres'] = l$genres?.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$bannerImage = bannerImage;
    _resultData['bannerImage'] = l$bannerImage;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$endDate = endDate;
    _resultData['endDate'] = l$endDate?.toJson();
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$status = status;
    final l$episodes = episodes;
    final l$seasonYear = seasonYear;
    final l$season = season;
    final l$averageScore = averageScore;
    final l$meanScore = meanScore;
    final l$popularity = popularity;
    final l$isAdult = isAdult;
    final l$isFavourite = isFavourite;
    final l$nextAiringEpisode = nextAiringEpisode;
    final l$startDate = startDate;
    final l$genres = genres;
    final l$$__typename = $__typename;
    final l$bannerImage = bannerImage;
    final l$description = description;
    final l$endDate = endDate;
    final l$updatedAt = updatedAt;
    final l$siteUrl = siteUrl;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$status,
      l$episodes,
      l$seasonYear,
      l$season,
      l$averageScore,
      l$meanScore,
      l$popularity,
      l$isAdult,
      l$isFavourite,
      l$nextAiringEpisode,
      l$startDate,
      l$genres == null ? null : Object.hashAll(l$genres.map((v) => v)),
      l$$__typename,
      l$bannerImage,
      l$description,
      l$endDate,
      l$updatedAt,
      l$siteUrl,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$coverImage = coverImage;
    final lOther$coverImage = other.coverImage;
    if (l$coverImage != lOther$coverImage) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (l$format != lOther$format) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
      return false;
    }
    final l$seasonYear = seasonYear;
    final lOther$seasonYear = other.seasonYear;
    if (l$seasonYear != lOther$seasonYear) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (l$season != lOther$season) {
      return false;
    }
    final l$averageScore = averageScore;
    final lOther$averageScore = other.averageScore;
    if (l$averageScore != lOther$averageScore) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$popularity = popularity;
    final lOther$popularity = other.popularity;
    if (l$popularity != lOther$popularity) {
      return false;
    }
    final l$isAdult = isAdult;
    final lOther$isAdult = other.isAdult;
    if (l$isAdult != lOther$isAdult) {
      return false;
    }
    final l$isFavourite = isFavourite;
    final lOther$isFavourite = other.isFavourite;
    if (l$isFavourite != lOther$isFavourite) {
      return false;
    }
    final l$nextAiringEpisode = nextAiringEpisode;
    final lOther$nextAiringEpisode = other.nextAiringEpisode;
    if (l$nextAiringEpisode != lOther$nextAiringEpisode) {
      return false;
    }
    final l$startDate = startDate;
    final lOther$startDate = other.startDate;
    if (l$startDate != lOther$startDate) {
      return false;
    }
    final l$genres = genres;
    final lOther$genres = other.genres;
    if (l$genres != null && lOther$genres != null) {
      if (l$genres.length != lOther$genres.length) {
        return false;
      }
      for (int i = 0; i < l$genres.length; i++) {
        final l$genres$entry = l$genres[i];
        final lOther$genres$entry = lOther$genres[i];
        if (l$genres$entry != lOther$genres$entry) {
          return false;
        }
      }
    } else if (l$genres != lOther$genres) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$bannerImage = bannerImage;
    final lOther$bannerImage = other.bannerImage;
    if (l$bannerImage != lOther$bannerImage) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$endDate = endDate;
    final lOther$endDate = other.endDate;
    if (l$endDate != lOther$endDate) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media
    on Query$SearchAnime$Page$media {
  CopyWith$Query$SearchAnime$Page$media<Query$SearchAnime$Page$media>
      get copyWith => CopyWith$Query$SearchAnime$Page$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media(
    Query$SearchAnime$Page$media instance,
    TRes Function(Query$SearchAnime$Page$media) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media;

  factory CopyWith$Query$SearchAnime$Page$media.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media;

  TRes call({
    int? id,
    Query$SearchAnime$Page$media$title? title,
    Query$SearchAnime$Page$media$coverImage? coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    Enum$MediaStatus? status,
    int? episodes,
    int? seasonYear,
    Enum$MediaSeason? season,
    int? averageScore,
    int? meanScore,
    int? popularity,
    bool? isAdult,
    bool? isFavourite,
    Query$SearchAnime$Page$media$nextAiringEpisode? nextAiringEpisode,
    Query$SearchAnime$Page$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$SearchAnime$Page$media$endDate? endDate,
    int? updatedAt,
    String? siteUrl,
  });
  CopyWith$Query$SearchAnime$Page$media$title<TRes> get title;
  CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> get coverImage;
  CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode;
  CopyWith$Query$SearchAnime$Page$media$startDate<TRes> get startDate;
  CopyWith$Query$SearchAnime$Page$media$endDate<TRes> get endDate;
}

class _CopyWithImpl$Query$SearchAnime$Page$media<TRes>
    implements CopyWith$Query$SearchAnime$Page$media<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media _instance;

  final TRes Function(Query$SearchAnime$Page$media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? status = _undefined,
    Object? episodes = _undefined,
    Object? seasonYear = _undefined,
    Object? season = _undefined,
    Object? averageScore = _undefined,
    Object? meanScore = _undefined,
    Object? popularity = _undefined,
    Object? isAdult = _undefined,
    Object? isFavourite = _undefined,
    Object? nextAiringEpisode = _undefined,
    Object? startDate = _undefined,
    Object? genres = _undefined,
    Object? $__typename = _undefined,
    Object? bannerImage = _undefined,
    Object? description = _undefined,
    Object? endDate = _undefined,
    Object? updatedAt = _undefined,
    Object? siteUrl = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title as Query$SearchAnime$Page$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage as Query$SearchAnime$Page$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaStatus?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        seasonYear: seasonYear == _undefined
            ? _instance.seasonYear
            : (seasonYear as int?),
        season: season == _undefined
            ? _instance.season
            : (season as Enum$MediaSeason?),
        averageScore: averageScore == _undefined
            ? _instance.averageScore
            : (averageScore as int?),
        meanScore:
            meanScore == _undefined ? _instance.meanScore : (meanScore as int?),
        popularity: popularity == _undefined
            ? _instance.popularity
            : (popularity as int?),
        isAdult: isAdult == _undefined ? _instance.isAdult : (isAdult as bool?),
        isFavourite: isFavourite == _undefined || isFavourite == null
            ? _instance.isFavourite
            : (isFavourite as bool),
        nextAiringEpisode: nextAiringEpisode == _undefined
            ? _instance.nextAiringEpisode
            : (nextAiringEpisode
                as Query$SearchAnime$Page$media$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate as Query$SearchAnime$Page$media$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        bannerImage: bannerImage == _undefined
            ? _instance.bannerImage
            : (bannerImage as String?),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        endDate: endDate == _undefined
            ? _instance.endDate
            : (endDate as Query$SearchAnime$Page$media$endDate?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
      ));

  CopyWith$Query$SearchAnime$Page$media$title<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$SearchAnime$Page$media$title.stub(_then(_instance))
        : CopyWith$Query$SearchAnime$Page$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$SearchAnime$Page$media$coverImage.stub(
            _then(_instance))
        : CopyWith$Query$SearchAnime$Page$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode.stub(
            _then(_instance))
        : CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Query$SearchAnime$Page$media$startDate<TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Query$SearchAnime$Page$media$startDate.stub(_then(_instance))
        : CopyWith$Query$SearchAnime$Page$media$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Query$SearchAnime$Page$media$endDate<TRes> get endDate {
    final local$endDate = _instance.endDate;
    return local$endDate == null
        ? CopyWith$Query$SearchAnime$Page$media$endDate.stub(_then(_instance))
        : CopyWith$Query$SearchAnime$Page$media$endDate(
            local$endDate, (e) => call(endDate: e));
  }
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media<TRes>
    implements CopyWith$Query$SearchAnime$Page$media<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media(this._res);

  TRes _res;

  call({
    int? id,
    Query$SearchAnime$Page$media$title? title,
    Query$SearchAnime$Page$media$coverImage? coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    Enum$MediaStatus? status,
    int? episodes,
    int? seasonYear,
    Enum$MediaSeason? season,
    int? averageScore,
    int? meanScore,
    int? popularity,
    bool? isAdult,
    bool? isFavourite,
    Query$SearchAnime$Page$media$nextAiringEpisode? nextAiringEpisode,
    Query$SearchAnime$Page$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$SearchAnime$Page$media$endDate? endDate,
    int? updatedAt,
    String? siteUrl,
  }) =>
      _res;

  CopyWith$Query$SearchAnime$Page$media$title<TRes> get title =>
      CopyWith$Query$SearchAnime$Page$media$title.stub(_res);

  CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> get coverImage =>
      CopyWith$Query$SearchAnime$Page$media$coverImage.stub(_res);

  CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode =>
          CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode.stub(_res);

  CopyWith$Query$SearchAnime$Page$media$startDate<TRes> get startDate =>
      CopyWith$Query$SearchAnime$Page$media$startDate.stub(_res);

  CopyWith$Query$SearchAnime$Page$media$endDate<TRes> get endDate =>
      CopyWith$Query$SearchAnime$Page$media$endDate.stub(_res);
}

class Query$SearchAnime$Page$media$title implements Fragment$AnimeCard$title {
  Query$SearchAnime$Page$media$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$SearchAnime$Page$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$media$title(
      userPreferred: (l$userPreferred as String?),
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? userPreferred;

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$userPreferred = userPreferred;
    _resultData['userPreferred'] = l$userPreferred;
    final l$romaji = romaji;
    _resultData['romaji'] = l$romaji;
    final l$english = english;
    _resultData['english'] = l$english;
    final l$native = native;
    _resultData['native'] = l$native;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$userPreferred = userPreferred;
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$userPreferred,
      l$romaji,
      l$english,
      l$native,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media$title ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$userPreferred = userPreferred;
    final lOther$userPreferred = other.userPreferred;
    if (l$userPreferred != lOther$userPreferred) {
      return false;
    }
    final l$romaji = romaji;
    final lOther$romaji = other.romaji;
    if (l$romaji != lOther$romaji) {
      return false;
    }
    final l$english = english;
    final lOther$english = other.english;
    if (l$english != lOther$english) {
      return false;
    }
    final l$native = native;
    final lOther$native = other.native;
    if (l$native != lOther$native) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media$title
    on Query$SearchAnime$Page$media$title {
  CopyWith$Query$SearchAnime$Page$media$title<
          Query$SearchAnime$Page$media$title>
      get copyWith => CopyWith$Query$SearchAnime$Page$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media$title<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media$title(
    Query$SearchAnime$Page$media$title instance,
    TRes Function(Query$SearchAnime$Page$media$title) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media$title;

  factory CopyWith$Query$SearchAnime$Page$media$title.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$media$title<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$title<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media$title(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media$title _instance;

  final TRes Function(Query$SearchAnime$Page$media$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media$title(
        userPreferred: userPreferred == _undefined
            ? _instance.userPreferred
            : (userPreferred as String?),
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media$title<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$title<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media$title(this._res);

  TRes _res;

  call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$SearchAnime$Page$media$coverImage
    implements Fragment$AnimeCard$coverImage {
  Query$SearchAnime$Page$media$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$SearchAnime$Page$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$media$coverImage(
      extraLarge: (l$extraLarge as String?),
      large: (l$large as String?),
      color: (l$color as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? extraLarge;

  final String? large;

  final String? color;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$extraLarge = extraLarge;
    _resultData['extraLarge'] = l$extraLarge;
    final l$large = large;
    _resultData['large'] = l$large;
    final l$color = color;
    _resultData['color'] = l$color;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$extraLarge = extraLarge;
    final l$large = large;
    final l$color = color;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$extraLarge,
      l$large,
      l$color,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$extraLarge = extraLarge;
    final lOther$extraLarge = other.extraLarge;
    if (l$extraLarge != lOther$extraLarge) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$color = color;
    final lOther$color = other.color;
    if (l$color != lOther$color) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media$coverImage
    on Query$SearchAnime$Page$media$coverImage {
  CopyWith$Query$SearchAnime$Page$media$coverImage<
          Query$SearchAnime$Page$media$coverImage>
      get copyWith => CopyWith$Query$SearchAnime$Page$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media$coverImage(
    Query$SearchAnime$Page$media$coverImage instance,
    TRes Function(Query$SearchAnime$Page$media$coverImage) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media$coverImage;

  factory CopyWith$Query$SearchAnime$Page$media$coverImage.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$media$coverImage<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media$coverImage _instance;

  final TRes Function(Query$SearchAnime$Page$media$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media$coverImage(
        extraLarge: extraLarge == _undefined
            ? _instance.extraLarge
            : (extraLarge as String?),
        large: large == _undefined ? _instance.large : (large as String?),
        color: color == _undefined ? _instance.color : (color as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media$coverImage<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$coverImage<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media$coverImage(this._res);

  TRes _res;

  call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  }) =>
      _res;
}

class Query$SearchAnime$Page$media$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Query$SearchAnime$Page$media$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$SearchAnime$Page$media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$media$nextAiringEpisode(
      airingAt: (l$airingAt as int),
      timeUntilAiring: (l$timeUntilAiring as int),
      episode: (l$episode as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int airingAt;

  final int timeUntilAiring;

  final int episode;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$airingAt = airingAt;
    _resultData['airingAt'] = l$airingAt;
    final l$timeUntilAiring = timeUntilAiring;
    _resultData['timeUntilAiring'] = l$timeUntilAiring;
    final l$episode = episode;
    _resultData['episode'] = l$episode;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$airingAt = airingAt;
    final l$timeUntilAiring = timeUntilAiring;
    final l$episode = episode;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$airingAt,
      l$timeUntilAiring,
      l$episode,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media$nextAiringEpisode ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$airingAt = airingAt;
    final lOther$airingAt = other.airingAt;
    if (l$airingAt != lOther$airingAt) {
      return false;
    }
    final l$timeUntilAiring = timeUntilAiring;
    final lOther$timeUntilAiring = other.timeUntilAiring;
    if (l$timeUntilAiring != lOther$timeUntilAiring) {
      return false;
    }
    final l$episode = episode;
    final lOther$episode = other.episode;
    if (l$episode != lOther$episode) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media$nextAiringEpisode
    on Query$SearchAnime$Page$media$nextAiringEpisode {
  CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<
          Query$SearchAnime$Page$media$nextAiringEpisode>
      get copyWith => CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode(
    Query$SearchAnime$Page$media$nextAiringEpisode instance,
    TRes Function(Query$SearchAnime$Page$media$nextAiringEpisode) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media$nextAiringEpisode;

  factory CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$media$nextAiringEpisode<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media$nextAiringEpisode _instance;

  final TRes Function(Query$SearchAnime$Page$media$nextAiringEpisode) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media$nextAiringEpisode(
        airingAt: airingAt == _undefined || airingAt == null
            ? _instance.airingAt
            : (airingAt as int),
        timeUntilAiring:
            timeUntilAiring == _undefined || timeUntilAiring == null
                ? _instance.timeUntilAiring
                : (timeUntilAiring as int),
        episode: episode == _undefined || episode == null
            ? _instance.episode
            : (episode as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media$nextAiringEpisode<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$nextAiringEpisode<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media$nextAiringEpisode(this._res);

  TRes _res;

  call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  }) =>
      _res;
}

class Query$SearchAnime$Page$media$startDate
    implements Fragment$AnimeCard$startDate {
  Query$SearchAnime$Page$media$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$SearchAnime$Page$media$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$media$startDate(
      year: (l$year as int?),
      month: (l$month as int?),
      day: (l$day as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? year;

  final int? month;

  final int? day;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$year = year;
    _resultData['year'] = l$year;
    final l$month = month;
    _resultData['month'] = l$month;
    final l$day = day;
    _resultData['day'] = l$day;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$year = year;
    final l$month = month;
    final l$day = day;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$year,
      l$month,
      l$day,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media$startDate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$month = month;
    final lOther$month = other.month;
    if (l$month != lOther$month) {
      return false;
    }
    final l$day = day;
    final lOther$day = other.day;
    if (l$day != lOther$day) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media$startDate
    on Query$SearchAnime$Page$media$startDate {
  CopyWith$Query$SearchAnime$Page$media$startDate<
          Query$SearchAnime$Page$media$startDate>
      get copyWith => CopyWith$Query$SearchAnime$Page$media$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media$startDate<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media$startDate(
    Query$SearchAnime$Page$media$startDate instance,
    TRes Function(Query$SearchAnime$Page$media$startDate) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media$startDate;

  factory CopyWith$Query$SearchAnime$Page$media$startDate.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$media$startDate<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$startDate<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media$startDate(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media$startDate _instance;

  final TRes Function(Query$SearchAnime$Page$media$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media$startDate<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$startDate<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media$startDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Query$SearchAnime$Page$media$endDate {
  Query$SearchAnime$Page$media$endDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$SearchAnime$Page$media$endDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$SearchAnime$Page$media$endDate(
      year: (l$year as int?),
      month: (l$month as int?),
      day: (l$day as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? year;

  final int? month;

  final int? day;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$year = year;
    _resultData['year'] = l$year;
    final l$month = month;
    _resultData['month'] = l$month;
    final l$day = day;
    _resultData['day'] = l$day;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$year = year;
    final l$month = month;
    final l$day = day;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$year,
      l$month,
      l$day,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SearchAnime$Page$media$endDate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$month = month;
    final lOther$month = other.month;
    if (l$month != lOther$month) {
      return false;
    }
    final l$day = day;
    final lOther$day = other.day;
    if (l$day != lOther$day) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SearchAnime$Page$media$endDate
    on Query$SearchAnime$Page$media$endDate {
  CopyWith$Query$SearchAnime$Page$media$endDate<
          Query$SearchAnime$Page$media$endDate>
      get copyWith => CopyWith$Query$SearchAnime$Page$media$endDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SearchAnime$Page$media$endDate<TRes> {
  factory CopyWith$Query$SearchAnime$Page$media$endDate(
    Query$SearchAnime$Page$media$endDate instance,
    TRes Function(Query$SearchAnime$Page$media$endDate) then,
  ) = _CopyWithImpl$Query$SearchAnime$Page$media$endDate;

  factory CopyWith$Query$SearchAnime$Page$media$endDate.stub(TRes res) =
      _CopyWithStubImpl$Query$SearchAnime$Page$media$endDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SearchAnime$Page$media$endDate<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$endDate<TRes> {
  _CopyWithImpl$Query$SearchAnime$Page$media$endDate(
    this._instance,
    this._then,
  );

  final Query$SearchAnime$Page$media$endDate _instance;

  final TRes Function(Query$SearchAnime$Page$media$endDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SearchAnime$Page$media$endDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$SearchAnime$Page$media$endDate<TRes>
    implements CopyWith$Query$SearchAnime$Page$media$endDate<TRes> {
  _CopyWithStubImpl$Query$SearchAnime$Page$media$endDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$GetHomeSection {
  factory Variables$Query$GetHomeSection({
    int? page,
    int? perPage,
    Enum$MediaSeason? season,
    int? seasonYear,
    List<Enum$MediaSort?>? sort,
    Enum$MediaStatus? status,
  }) =>
      Variables$Query$GetHomeSection._({
        if (page != null) r'page': page,
        if (perPage != null) r'perPage': perPage,
        if (season != null) r'season': season,
        if (seasonYear != null) r'seasonYear': seasonYear,
        if (sort != null) r'sort': sort,
        if (status != null) r'status': status,
      });

  Variables$Query$GetHomeSection._(this._$data);

  factory Variables$Query$GetHomeSection.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    if (data.containsKey('perPage')) {
      final l$perPage = data['perPage'];
      result$data['perPage'] = (l$perPage as int?);
    }
    if (data.containsKey('season')) {
      final l$season = data['season'];
      result$data['season'] = l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String));
    }
    if (data.containsKey('seasonYear')) {
      final l$seasonYear = data['seasonYear'];
      result$data['seasonYear'] = (l$seasonYear as int?);
    }
    if (data.containsKey('sort')) {
      final l$sort = data['sort'];
      result$data['sort'] = (l$sort as List<dynamic>?)
          ?.map(
              (e) => e == null ? null : fromJson$Enum$MediaSort((e as String)))
          .toList();
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : fromJson$Enum$MediaStatus((l$status as String));
    }
    return Variables$Query$GetHomeSection._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get page => (_$data['page'] as int?);

  int? get perPage => (_$data['perPage'] as int?);

  Enum$MediaSeason? get season => (_$data['season'] as Enum$MediaSeason?);

  int? get seasonYear => (_$data['seasonYear'] as int?);

  List<Enum$MediaSort?>? get sort => (_$data['sort'] as List<Enum$MediaSort?>?);

  Enum$MediaStatus? get status => (_$data['status'] as Enum$MediaStatus?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    if (_$data.containsKey('perPage')) {
      final l$perPage = perPage;
      result$data['perPage'] = l$perPage;
    }
    if (_$data.containsKey('season')) {
      final l$season = season;
      result$data['season'] =
          l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    }
    if (_$data.containsKey('seasonYear')) {
      final l$seasonYear = seasonYear;
      result$data['seasonYear'] = l$seasonYear;
    }
    if (_$data.containsKey('sort')) {
      final l$sort = sort;
      result$data['sort'] = l$sort
          ?.map((e) => e == null ? null : toJson$Enum$MediaSort(e))
          .toList();
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] =
          l$status == null ? null : toJson$Enum$MediaStatus(l$status);
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetHomeSection<Variables$Query$GetHomeSection>
      get copyWith => CopyWith$Variables$Query$GetHomeSection(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetHomeSection ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$page = page;
    final lOther$page = other.page;
    if (_$data.containsKey('page') != other._$data.containsKey('page')) {
      return false;
    }
    if (l$page != lOther$page) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (_$data.containsKey('perPage') != other._$data.containsKey('perPage')) {
      return false;
    }
    if (l$perPage != lOther$perPage) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (_$data.containsKey('season') != other._$data.containsKey('season')) {
      return false;
    }
    if (l$season != lOther$season) {
      return false;
    }
    final l$seasonYear = seasonYear;
    final lOther$seasonYear = other.seasonYear;
    if (_$data.containsKey('seasonYear') !=
        other._$data.containsKey('seasonYear')) {
      return false;
    }
    if (l$seasonYear != lOther$seasonYear) {
      return false;
    }
    final l$sort = sort;
    final lOther$sort = other.sort;
    if (_$data.containsKey('sort') != other._$data.containsKey('sort')) {
      return false;
    }
    if (l$sort != null && lOther$sort != null) {
      if (l$sort.length != lOther$sort.length) {
        return false;
      }
      for (int i = 0; i < l$sort.length; i++) {
        final l$sort$entry = l$sort[i];
        final lOther$sort$entry = lOther$sort[i];
        if (l$sort$entry != lOther$sort$entry) {
          return false;
        }
      }
    } else if (l$sort != lOther$sort) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$page = page;
    final l$perPage = perPage;
    final l$season = season;
    final l$seasonYear = seasonYear;
    final l$sort = sort;
    final l$status = status;
    return Object.hashAll([
      _$data.containsKey('page') ? l$page : const {},
      _$data.containsKey('perPage') ? l$perPage : const {},
      _$data.containsKey('season') ? l$season : const {},
      _$data.containsKey('seasonYear') ? l$seasonYear : const {},
      _$data.containsKey('sort')
          ? l$sort == null
              ? null
              : Object.hashAll(l$sort.map((v) => v))
          : const {},
      _$data.containsKey('status') ? l$status : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetHomeSection<TRes> {
  factory CopyWith$Variables$Query$GetHomeSection(
    Variables$Query$GetHomeSection instance,
    TRes Function(Variables$Query$GetHomeSection) then,
  ) = _CopyWithImpl$Variables$Query$GetHomeSection;

  factory CopyWith$Variables$Query$GetHomeSection.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetHomeSection;

  TRes call({
    int? page,
    int? perPage,
    Enum$MediaSeason? season,
    int? seasonYear,
    List<Enum$MediaSort?>? sort,
    Enum$MediaStatus? status,
  });
}

class _CopyWithImpl$Variables$Query$GetHomeSection<TRes>
    implements CopyWith$Variables$Query$GetHomeSection<TRes> {
  _CopyWithImpl$Variables$Query$GetHomeSection(
    this._instance,
    this._then,
  );

  final Variables$Query$GetHomeSection _instance;

  final TRes Function(Variables$Query$GetHomeSection) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? page = _undefined,
    Object? perPage = _undefined,
    Object? season = _undefined,
    Object? seasonYear = _undefined,
    Object? sort = _undefined,
    Object? status = _undefined,
  }) =>
      _then(Variables$Query$GetHomeSection._({
        ..._instance._$data,
        if (page != _undefined) 'page': (page as int?),
        if (perPage != _undefined) 'perPage': (perPage as int?),
        if (season != _undefined) 'season': (season as Enum$MediaSeason?),
        if (seasonYear != _undefined) 'seasonYear': (seasonYear as int?),
        if (sort != _undefined) 'sort': (sort as List<Enum$MediaSort?>?),
        if (status != _undefined) 'status': (status as Enum$MediaStatus?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetHomeSection<TRes>
    implements CopyWith$Variables$Query$GetHomeSection<TRes> {
  _CopyWithStubImpl$Variables$Query$GetHomeSection(this._res);

  TRes _res;

  call({
    int? page,
    int? perPage,
    Enum$MediaSeason? season,
    int? seasonYear,
    List<Enum$MediaSort?>? sort,
    Enum$MediaStatus? status,
  }) =>
      _res;
}

class Query$GetHomeSection {
  Query$GetHomeSection({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetHomeSection.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetHomeSection(
      Page: l$Page == null
          ? null
          : Query$GetHomeSection$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetHomeSection$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetHomeSection || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Page = Page;
    final lOther$Page = other.Page;
    if (l$Page != lOther$Page) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetHomeSection on Query$GetHomeSection {
  CopyWith$Query$GetHomeSection<Query$GetHomeSection> get copyWith =>
      CopyWith$Query$GetHomeSection(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetHomeSection<TRes> {
  factory CopyWith$Query$GetHomeSection(
    Query$GetHomeSection instance,
    TRes Function(Query$GetHomeSection) then,
  ) = _CopyWithImpl$Query$GetHomeSection;

  factory CopyWith$Query$GetHomeSection.stub(TRes res) =
      _CopyWithStubImpl$Query$GetHomeSection;

  TRes call({
    Query$GetHomeSection$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetHomeSection$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetHomeSection<TRes>
    implements CopyWith$Query$GetHomeSection<TRes> {
  _CopyWithImpl$Query$GetHomeSection(
    this._instance,
    this._then,
  );

  final Query$GetHomeSection _instance;

  final TRes Function(Query$GetHomeSection) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetHomeSection(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetHomeSection$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetHomeSection$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetHomeSection$Page.stub(_then(_instance))
        : CopyWith$Query$GetHomeSection$Page(local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetHomeSection<TRes>
    implements CopyWith$Query$GetHomeSection<TRes> {
  _CopyWithStubImpl$Query$GetHomeSection(this._res);

  TRes _res;

  call({
    Query$GetHomeSection$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetHomeSection$Page<TRes> get Page =>
      CopyWith$Query$GetHomeSection$Page.stub(_res);
}

const documentNodeQueryGetHomeSection = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetHomeSection'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'perPage')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'season')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaSeason'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'seasonYear')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'sort')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'MediaSort'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'status')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaStatus'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'page'),
            value: VariableNode(name: NameNode(value: 'page')),
          ),
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: VariableNode(name: NameNode(value: 'perPage')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'pageInfo'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'total'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'perPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'currentPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'lastPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'hasNextPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'type'),
                value: EnumValueNode(name: NameNode(value: 'ANIME')),
              ),
              ArgumentNode(
                name: NameNode(value: 'season'),
                value: VariableNode(name: NameNode(value: 'season')),
              ),
              ArgumentNode(
                name: NameNode(value: 'seasonYear'),
                value: VariableNode(name: NameNode(value: 'seasonYear')),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: VariableNode(name: NameNode(value: 'sort')),
              ),
              ArgumentNode(
                name: NameNode(value: 'status'),
                value: VariableNode(name: NameNode(value: 'status')),
              ),
              ArgumentNode(
                name: NameNode(value: 'isAdult'),
                value: BooleanValueNode(value: false),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'AnimeCard'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionAnimeCard,
]);
Query$GetHomeSection _parserFn$Query$GetHomeSection(
        Map<String, dynamic> data) =>
    Query$GetHomeSection.fromJson(data);
typedef OnQueryComplete$Query$GetHomeSection = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetHomeSection?,
);

class Options$Query$GetHomeSection
    extends graphql.QueryOptions<Query$GetHomeSection> {
  Options$Query$GetHomeSection({
    String? operationName,
    Variables$Query$GetHomeSection? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetHomeSection? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetHomeSection? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$GetHomeSection(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetHomeSection,
          parserFn: _parserFn$Query$GetHomeSection,
        );

  final OnQueryComplete$Query$GetHomeSection? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetHomeSection
    extends graphql.WatchQueryOptions<Query$GetHomeSection> {
  WatchOptions$Query$GetHomeSection({
    String? operationName,
    Variables$Query$GetHomeSection? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetHomeSection? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetHomeSection,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetHomeSection,
        );
}

class FetchMoreOptions$Query$GetHomeSection extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetHomeSection({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetHomeSection? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetHomeSection,
        );
}

extension ClientExtension$Query$GetHomeSection on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetHomeSection>> query$GetHomeSection(
          [Options$Query$GetHomeSection? options]) async =>
      await this.query(options ?? Options$Query$GetHomeSection());
  graphql.ObservableQuery<Query$GetHomeSection> watchQuery$GetHomeSection(
          [WatchOptions$Query$GetHomeSection? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetHomeSection());
  void writeQuery$GetHomeSection({
    required Query$GetHomeSection data,
    Variables$Query$GetHomeSection? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetHomeSection),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetHomeSection? readQuery$GetHomeSection({
    Variables$Query$GetHomeSection? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetHomeSection),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetHomeSection.fromJson(result);
  }
}

class Query$GetHomeSection$Page {
  Query$GetHomeSection$Page({
    this.pageInfo,
    this.media,
    this.$__typename = 'Page',
  });

  factory Query$GetHomeSection$Page.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetHomeSection$Page(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetHomeSection$Page$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      media: (l$media as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Fragment$AnimeCard.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetHomeSection$Page$pageInfo? pageInfo;

  final List<Fragment$AnimeCard?>? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$media = media;
    _resultData['media'] = l$media?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$media == null ? null : Object.hashAll(l$media.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetHomeSection$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != null && lOther$media != null) {
      if (l$media.length != lOther$media.length) {
        return false;
      }
      for (int i = 0; i < l$media.length; i++) {
        final l$media$entry = l$media[i];
        final lOther$media$entry = lOther$media[i];
        if (l$media$entry != lOther$media$entry) {
          return false;
        }
      }
    } else if (l$media != lOther$media) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetHomeSection$Page
    on Query$GetHomeSection$Page {
  CopyWith$Query$GetHomeSection$Page<Query$GetHomeSection$Page> get copyWith =>
      CopyWith$Query$GetHomeSection$Page(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetHomeSection$Page<TRes> {
  factory CopyWith$Query$GetHomeSection$Page(
    Query$GetHomeSection$Page instance,
    TRes Function(Query$GetHomeSection$Page) then,
  ) = _CopyWithImpl$Query$GetHomeSection$Page;

  factory CopyWith$Query$GetHomeSection$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetHomeSection$Page;

  TRes call({
    Query$GetHomeSection$Page$pageInfo? pageInfo,
    List<Fragment$AnimeCard?>? media,
    String? $__typename,
  });
  CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> get pageInfo;
  TRes media(
      Iterable<Fragment$AnimeCard?>? Function(
              Iterable<CopyWith$Fragment$AnimeCard<Fragment$AnimeCard>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetHomeSection$Page<TRes>
    implements CopyWith$Query$GetHomeSection$Page<TRes> {
  _CopyWithImpl$Query$GetHomeSection$Page(
    this._instance,
    this._then,
  );

  final Query$GetHomeSection$Page _instance;

  final TRes Function(Query$GetHomeSection$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetHomeSection$Page(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetHomeSection$Page$pageInfo?),
        media: media == _undefined
            ? _instance.media
            : (media as List<Fragment$AnimeCard?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetHomeSection$Page$pageInfo.stub(_then(_instance))
        : CopyWith$Query$GetHomeSection$Page$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes media(
          Iterable<Fragment$AnimeCard?>? Function(
                  Iterable<CopyWith$Fragment$AnimeCard<Fragment$AnimeCard>?>?)
              _fn) =>
      call(
          media: _fn(_instance.media?.map((e) => e == null
              ? null
              : CopyWith$Fragment$AnimeCard(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetHomeSection$Page<TRes>
    implements CopyWith$Query$GetHomeSection$Page<TRes> {
  _CopyWithStubImpl$Query$GetHomeSection$Page(this._res);

  TRes _res;

  call({
    Query$GetHomeSection$Page$pageInfo? pageInfo,
    List<Fragment$AnimeCard?>? media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$GetHomeSection$Page$pageInfo.stub(_res);

  media(_fn) => _res;
}

class Query$GetHomeSection$Page$pageInfo {
  Query$GetHomeSection$Page$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetHomeSection$Page$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$GetHomeSection$Page$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetHomeSection$Page$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
      return false;
    }
    final l$currentPage = currentPage;
    final lOther$currentPage = other.currentPage;
    if (l$currentPage != lOther$currentPage) {
      return false;
    }
    final l$lastPage = lastPage;
    final lOther$lastPage = other.lastPage;
    if (l$lastPage != lOther$lastPage) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetHomeSection$Page$pageInfo
    on Query$GetHomeSection$Page$pageInfo {
  CopyWith$Query$GetHomeSection$Page$pageInfo<
          Query$GetHomeSection$Page$pageInfo>
      get copyWith => CopyWith$Query$GetHomeSection$Page$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> {
  factory CopyWith$Query$GetHomeSection$Page$pageInfo(
    Query$GetHomeSection$Page$pageInfo instance,
    TRes Function(Query$GetHomeSection$Page$pageInfo) then,
  ) = _CopyWithImpl$Query$GetHomeSection$Page$pageInfo;

  factory CopyWith$Query$GetHomeSection$Page$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$GetHomeSection$Page$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetHomeSection$Page$pageInfo<TRes>
    implements CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> {
  _CopyWithImpl$Query$GetHomeSection$Page$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetHomeSection$Page$pageInfo _instance;

  final TRes Function(Query$GetHomeSection$Page$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetHomeSection$Page$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetHomeSection$Page$pageInfo<TRes>
    implements CopyWith$Query$GetHomeSection$Page$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetHomeSection$Page$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetGenreCollection {
  Query$GetGenreCollection({
    this.GenreCollection,
    this.$__typename = 'Query',
  });

  factory Query$GetGenreCollection.fromJson(Map<String, dynamic> json) {
    final l$GenreCollection = json['GenreCollection'];
    final l$$__typename = json['__typename'];
    return Query$GetGenreCollection(
      GenreCollection: (l$GenreCollection as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String?>? GenreCollection;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$GenreCollection = GenreCollection;
    _resultData['GenreCollection'] = l$GenreCollection?.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$GenreCollection = GenreCollection;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$GenreCollection == null
          ? null
          : Object.hashAll(l$GenreCollection.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetGenreCollection ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$GenreCollection = GenreCollection;
    final lOther$GenreCollection = other.GenreCollection;
    if (l$GenreCollection != null && lOther$GenreCollection != null) {
      if (l$GenreCollection.length != lOther$GenreCollection.length) {
        return false;
      }
      for (int i = 0; i < l$GenreCollection.length; i++) {
        final l$GenreCollection$entry = l$GenreCollection[i];
        final lOther$GenreCollection$entry = lOther$GenreCollection[i];
        if (l$GenreCollection$entry != lOther$GenreCollection$entry) {
          return false;
        }
      }
    } else if (l$GenreCollection != lOther$GenreCollection) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetGenreCollection
    on Query$GetGenreCollection {
  CopyWith$Query$GetGenreCollection<Query$GetGenreCollection> get copyWith =>
      CopyWith$Query$GetGenreCollection(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetGenreCollection<TRes> {
  factory CopyWith$Query$GetGenreCollection(
    Query$GetGenreCollection instance,
    TRes Function(Query$GetGenreCollection) then,
  ) = _CopyWithImpl$Query$GetGenreCollection;

  factory CopyWith$Query$GetGenreCollection.stub(TRes res) =
      _CopyWithStubImpl$Query$GetGenreCollection;

  TRes call({
    List<String?>? GenreCollection,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetGenreCollection<TRes>
    implements CopyWith$Query$GetGenreCollection<TRes> {
  _CopyWithImpl$Query$GetGenreCollection(
    this._instance,
    this._then,
  );

  final Query$GetGenreCollection _instance;

  final TRes Function(Query$GetGenreCollection) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? GenreCollection = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetGenreCollection(
        GenreCollection: GenreCollection == _undefined
            ? _instance.GenreCollection
            : (GenreCollection as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetGenreCollection<TRes>
    implements CopyWith$Query$GetGenreCollection<TRes> {
  _CopyWithStubImpl$Query$GetGenreCollection(this._res);

  TRes _res;

  call({
    List<String?>? GenreCollection,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeQueryGetGenreCollection = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetGenreCollection'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'GenreCollection'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Query$GetGenreCollection _parserFn$Query$GetGenreCollection(
        Map<String, dynamic> data) =>
    Query$GetGenreCollection.fromJson(data);
typedef OnQueryComplete$Query$GetGenreCollection = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetGenreCollection?,
);

class Options$Query$GetGenreCollection
    extends graphql.QueryOptions<Query$GetGenreCollection> {
  Options$Query$GetGenreCollection({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetGenreCollection? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetGenreCollection? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$GetGenreCollection(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetGenreCollection,
          parserFn: _parserFn$Query$GetGenreCollection,
        );

  final OnQueryComplete$Query$GetGenreCollection? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetGenreCollection
    extends graphql.WatchQueryOptions<Query$GetGenreCollection> {
  WatchOptions$Query$GetGenreCollection({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetGenreCollection? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetGenreCollection,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetGenreCollection,
        );
}

class FetchMoreOptions$Query$GetGenreCollection
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetGenreCollection(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetGenreCollection,
        );
}

extension ClientExtension$Query$GetGenreCollection on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetGenreCollection>>
      query$GetGenreCollection(
              [Options$Query$GetGenreCollection? options]) async =>
          await this.query(options ?? Options$Query$GetGenreCollection());
  graphql.ObservableQuery<Query$GetGenreCollection>
      watchQuery$GetGenreCollection(
              [WatchOptions$Query$GetGenreCollection? options]) =>
          this.watchQuery(options ?? WatchOptions$Query$GetGenreCollection());
  void writeQuery$GetGenreCollection({
    required Query$GetGenreCollection data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(
                document: documentNodeQueryGetGenreCollection)),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetGenreCollection? readQuery$GetGenreCollection(
      {bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetGenreCollection)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetGenreCollection.fromJson(result);
  }
}

class Variables$Query$GetUpcomingEpisodes {
  factory Variables$Query$GetUpcomingEpisodes({List<int?>? ids}) =>
      Variables$Query$GetUpcomingEpisodes._({
        if (ids != null) r'ids': ids,
      });

  Variables$Query$GetUpcomingEpisodes._(this._$data);

  factory Variables$Query$GetUpcomingEpisodes.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('ids')) {
      final l$ids = data['ids'];
      result$data['ids'] =
          (l$ids as List<dynamic>?)?.map((e) => (e as int?)).toList();
    }
    return Variables$Query$GetUpcomingEpisodes._(result$data);
  }

  Map<String, dynamic> _$data;

  List<int?>? get ids => (_$data['ids'] as List<int?>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('ids')) {
      final l$ids = ids;
      result$data['ids'] = l$ids?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetUpcomingEpisodes<
          Variables$Query$GetUpcomingEpisodes>
      get copyWith => CopyWith$Variables$Query$GetUpcomingEpisodes(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetUpcomingEpisodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (_$data.containsKey('ids') != other._$data.containsKey('ids')) {
      return false;
    }
    if (l$ids != null && lOther$ids != null) {
      if (l$ids.length != lOther$ids.length) {
        return false;
      }
      for (int i = 0; i < l$ids.length; i++) {
        final l$ids$entry = l$ids[i];
        final lOther$ids$entry = lOther$ids[i];
        if (l$ids$entry != lOther$ids$entry) {
          return false;
        }
      }
    } else if (l$ids != lOther$ids) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('ids')
          ? l$ids == null
              ? null
              : Object.hashAll(l$ids.map((v) => v))
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetUpcomingEpisodes<TRes> {
  factory CopyWith$Variables$Query$GetUpcomingEpisodes(
    Variables$Query$GetUpcomingEpisodes instance,
    TRes Function(Variables$Query$GetUpcomingEpisodes) then,
  ) = _CopyWithImpl$Variables$Query$GetUpcomingEpisodes;

  factory CopyWith$Variables$Query$GetUpcomingEpisodes.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetUpcomingEpisodes;

  TRes call({List<int?>? ids});
}

class _CopyWithImpl$Variables$Query$GetUpcomingEpisodes<TRes>
    implements CopyWith$Variables$Query$GetUpcomingEpisodes<TRes> {
  _CopyWithImpl$Variables$Query$GetUpcomingEpisodes(
    this._instance,
    this._then,
  );

  final Variables$Query$GetUpcomingEpisodes _instance;

  final TRes Function(Variables$Query$GetUpcomingEpisodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? ids = _undefined}) =>
      _then(Variables$Query$GetUpcomingEpisodes._({
        ..._instance._$data,
        if (ids != _undefined) 'ids': (ids as List<int?>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetUpcomingEpisodes<TRes>
    implements CopyWith$Variables$Query$GetUpcomingEpisodes<TRes> {
  _CopyWithStubImpl$Variables$Query$GetUpcomingEpisodes(this._res);

  TRes _res;

  call({List<int?>? ids}) => _res;
}

class Query$GetUpcomingEpisodes {
  Query$GetUpcomingEpisodes({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetUpcomingEpisodes.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetUpcomingEpisodes(
      Page: l$Page == null
          ? null
          : Query$GetUpcomingEpisodes$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetUpcomingEpisodes$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUpcomingEpisodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$Page = Page;
    final lOther$Page = other.Page;
    if (l$Page != lOther$Page) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetUpcomingEpisodes
    on Query$GetUpcomingEpisodes {
  CopyWith$Query$GetUpcomingEpisodes<Query$GetUpcomingEpisodes> get copyWith =>
      CopyWith$Query$GetUpcomingEpisodes(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetUpcomingEpisodes<TRes> {
  factory CopyWith$Query$GetUpcomingEpisodes(
    Query$GetUpcomingEpisodes instance,
    TRes Function(Query$GetUpcomingEpisodes) then,
  ) = _CopyWithImpl$Query$GetUpcomingEpisodes;

  factory CopyWith$Query$GetUpcomingEpisodes.stub(TRes res) =
      _CopyWithStubImpl$Query$GetUpcomingEpisodes;

  TRes call({
    Query$GetUpcomingEpisodes$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetUpcomingEpisodes$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetUpcomingEpisodes<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes<TRes> {
  _CopyWithImpl$Query$GetUpcomingEpisodes(
    this._instance,
    this._then,
  );

  final Query$GetUpcomingEpisodes _instance;

  final TRes Function(Query$GetUpcomingEpisodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUpcomingEpisodes(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetUpcomingEpisodes$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUpcomingEpisodes$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetUpcomingEpisodes$Page.stub(_then(_instance))
        : CopyWith$Query$GetUpcomingEpisodes$Page(
            local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetUpcomingEpisodes<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes<TRes> {
  _CopyWithStubImpl$Query$GetUpcomingEpisodes(this._res);

  TRes _res;

  call({
    Query$GetUpcomingEpisodes$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUpcomingEpisodes$Page<TRes> get Page =>
      CopyWith$Query$GetUpcomingEpisodes$Page.stub(_res);
}

const documentNodeQueryGetUpcomingEpisodes = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetUpcomingEpisodes'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'ids')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'Int'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: IntValueNode(value: '50'),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id_in'),
                value: VariableNode(name: NameNode(value: 'ids')),
              ),
              ArgumentNode(
                name: NameNode(value: 'type'),
                value: EnumValueNode(name: NameNode(value: 'ANIME')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'id'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'status'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'format'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'episodes'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'nextAiringEpisode'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'airingAt'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'episode'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'timeUntilAiring'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Query$GetUpcomingEpisodes _parserFn$Query$GetUpcomingEpisodes(
        Map<String, dynamic> data) =>
    Query$GetUpcomingEpisodes.fromJson(data);
typedef OnQueryComplete$Query$GetUpcomingEpisodes = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetUpcomingEpisodes?,
);

class Options$Query$GetUpcomingEpisodes
    extends graphql.QueryOptions<Query$GetUpcomingEpisodes> {
  Options$Query$GetUpcomingEpisodes({
    String? operationName,
    Variables$Query$GetUpcomingEpisodes? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetUpcomingEpisodes? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetUpcomingEpisodes? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$GetUpcomingEpisodes(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetUpcomingEpisodes,
          parserFn: _parserFn$Query$GetUpcomingEpisodes,
        );

  final OnQueryComplete$Query$GetUpcomingEpisodes? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetUpcomingEpisodes
    extends graphql.WatchQueryOptions<Query$GetUpcomingEpisodes> {
  WatchOptions$Query$GetUpcomingEpisodes({
    String? operationName,
    Variables$Query$GetUpcomingEpisodes? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetUpcomingEpisodes? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetUpcomingEpisodes,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetUpcomingEpisodes,
        );
}

class FetchMoreOptions$Query$GetUpcomingEpisodes
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetUpcomingEpisodes({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetUpcomingEpisodes? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetUpcomingEpisodes,
        );
}

extension ClientExtension$Query$GetUpcomingEpisodes on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetUpcomingEpisodes>>
      query$GetUpcomingEpisodes(
              [Options$Query$GetUpcomingEpisodes? options]) async =>
          await this.query(options ?? Options$Query$GetUpcomingEpisodes());
  graphql.ObservableQuery<Query$GetUpcomingEpisodes>
      watchQuery$GetUpcomingEpisodes(
              [WatchOptions$Query$GetUpcomingEpisodes? options]) =>
          this.watchQuery(options ?? WatchOptions$Query$GetUpcomingEpisodes());
  void writeQuery$GetUpcomingEpisodes({
    required Query$GetUpcomingEpisodes data,
    Variables$Query$GetUpcomingEpisodes? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetUpcomingEpisodes),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetUpcomingEpisodes? readQuery$GetUpcomingEpisodes({
    Variables$Query$GetUpcomingEpisodes? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetUpcomingEpisodes),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetUpcomingEpisodes.fromJson(result);
  }
}

class Query$GetUpcomingEpisodes$Page {
  Query$GetUpcomingEpisodes$Page({
    this.media,
    this.$__typename = 'Page',
  });

  factory Query$GetUpcomingEpisodes$Page.fromJson(Map<String, dynamic> json) {
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetUpcomingEpisodes$Page(
      media: (l$media as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetUpcomingEpisodes$Page$media.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetUpcomingEpisodes$Page$media?>? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$media = media;
    _resultData['media'] = l$media?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$media == null ? null : Object.hashAll(l$media.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUpcomingEpisodes$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != null && lOther$media != null) {
      if (l$media.length != lOther$media.length) {
        return false;
      }
      for (int i = 0; i < l$media.length; i++) {
        final l$media$entry = l$media[i];
        final lOther$media$entry = lOther$media[i];
        if (l$media$entry != lOther$media$entry) {
          return false;
        }
      }
    } else if (l$media != lOther$media) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetUpcomingEpisodes$Page
    on Query$GetUpcomingEpisodes$Page {
  CopyWith$Query$GetUpcomingEpisodes$Page<Query$GetUpcomingEpisodes$Page>
      get copyWith => CopyWith$Query$GetUpcomingEpisodes$Page(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUpcomingEpisodes$Page<TRes> {
  factory CopyWith$Query$GetUpcomingEpisodes$Page(
    Query$GetUpcomingEpisodes$Page instance,
    TRes Function(Query$GetUpcomingEpisodes$Page) then,
  ) = _CopyWithImpl$Query$GetUpcomingEpisodes$Page;

  factory CopyWith$Query$GetUpcomingEpisodes$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page;

  TRes call({
    List<Query$GetUpcomingEpisodes$Page$media?>? media,
    String? $__typename,
  });
  TRes media(
      Iterable<Query$GetUpcomingEpisodes$Page$media?>? Function(
              Iterable<
                  CopyWith$Query$GetUpcomingEpisodes$Page$media<
                      Query$GetUpcomingEpisodes$Page$media>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetUpcomingEpisodes$Page<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes$Page<TRes> {
  _CopyWithImpl$Query$GetUpcomingEpisodes$Page(
    this._instance,
    this._then,
  );

  final Query$GetUpcomingEpisodes$Page _instance;

  final TRes Function(Query$GetUpcomingEpisodes$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUpcomingEpisodes$Page(
        media: media == _undefined
            ? _instance.media
            : (media as List<Query$GetUpcomingEpisodes$Page$media?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes media(
          Iterable<Query$GetUpcomingEpisodes$Page$media?>? Function(
                  Iterable<
                      CopyWith$Query$GetUpcomingEpisodes$Page$media<
                          Query$GetUpcomingEpisodes$Page$media>?>?)
              _fn) =>
      call(
          media: _fn(_instance.media?.map((e) => e == null
              ? null
              : CopyWith$Query$GetUpcomingEpisodes$Page$media(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes$Page<TRes> {
  _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page(this._res);

  TRes _res;

  call({
    List<Query$GetUpcomingEpisodes$Page$media?>? media,
    String? $__typename,
  }) =>
      _res;

  media(_fn) => _res;
}

class Query$GetUpcomingEpisodes$Page$media {
  Query$GetUpcomingEpisodes$Page$media({
    required this.id,
    this.status,
    this.format,
    this.episodes,
    this.nextAiringEpisode,
    this.$__typename = 'Media',
  });

  factory Query$GetUpcomingEpisodes$Page$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$status = json['status'];
    final l$format = json['format'];
    final l$episodes = json['episodes'];
    final l$nextAiringEpisode = json['nextAiringEpisode'];
    final l$$__typename = json['__typename'];
    return Query$GetUpcomingEpisodes$Page$media(
      id: (l$id as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaStatus((l$status as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      episodes: (l$episodes as int?),
      nextAiringEpisode: l$nextAiringEpisode == null
          ? null
          : Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$MediaStatus? status;

  final Enum$MediaFormat? format;

  final int? episodes;

  final Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode?
      nextAiringEpisode;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaStatus(l$status);
    final l$format = format;
    _resultData['format'] =
        l$format == null ? null : toJson$Enum$MediaFormat(l$format);
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$nextAiringEpisode = nextAiringEpisode;
    _resultData['nextAiringEpisode'] = l$nextAiringEpisode?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$status = status;
    final l$format = format;
    final l$episodes = episodes;
    final l$nextAiringEpisode = nextAiringEpisode;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$status,
      l$format,
      l$episodes,
      l$nextAiringEpisode,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUpcomingEpisodes$Page$media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (l$format != lOther$format) {
      return false;
    }
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
      return false;
    }
    final l$nextAiringEpisode = nextAiringEpisode;
    final lOther$nextAiringEpisode = other.nextAiringEpisode;
    if (l$nextAiringEpisode != lOther$nextAiringEpisode) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetUpcomingEpisodes$Page$media
    on Query$GetUpcomingEpisodes$Page$media {
  CopyWith$Query$GetUpcomingEpisodes$Page$media<
          Query$GetUpcomingEpisodes$Page$media>
      get copyWith => CopyWith$Query$GetUpcomingEpisodes$Page$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUpcomingEpisodes$Page$media<TRes> {
  factory CopyWith$Query$GetUpcomingEpisodes$Page$media(
    Query$GetUpcomingEpisodes$Page$media instance,
    TRes Function(Query$GetUpcomingEpisodes$Page$media) then,
  ) = _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media;

  factory CopyWith$Query$GetUpcomingEpisodes$Page$media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media;

  TRes call({
    int? id,
    Enum$MediaStatus? status,
    Enum$MediaFormat? format,
    int? episodes,
    Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode? nextAiringEpisode,
    String? $__typename,
  });
  CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode;
}

class _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes$Page$media<TRes> {
  _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media(
    this._instance,
    this._then,
  );

  final Query$GetUpcomingEpisodes$Page$media _instance;

  final TRes Function(Query$GetUpcomingEpisodes$Page$media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? status = _undefined,
    Object? format = _undefined,
    Object? episodes = _undefined,
    Object? nextAiringEpisode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUpcomingEpisodes$Page$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaStatus?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        nextAiringEpisode: nextAiringEpisode == _undefined
            ? _instance.nextAiringEpisode
            : (nextAiringEpisode
                as Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode.stub(
            _then(_instance))
        : CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }
}

class _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media<TRes>
    implements CopyWith$Query$GetUpcomingEpisodes$Page$media<TRes> {
  _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaStatus? status,
    Enum$MediaFormat? format,
    int? episodes,
    Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode? nextAiringEpisode,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode =>
          CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode.stub(
              _res);
}

class Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode {
  Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode({
    required this.airingAt,
    required this.episode,
    required this.timeUntilAiring,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$episode = json['episode'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$$__typename = json['__typename'];
    return Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
      airingAt: (l$airingAt as int),
      episode: (l$episode as int),
      timeUntilAiring: (l$timeUntilAiring as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int airingAt;

  final int episode;

  final int timeUntilAiring;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$airingAt = airingAt;
    _resultData['airingAt'] = l$airingAt;
    final l$episode = episode;
    _resultData['episode'] = l$episode;
    final l$timeUntilAiring = timeUntilAiring;
    _resultData['timeUntilAiring'] = l$timeUntilAiring;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$airingAt = airingAt;
    final l$episode = episode;
    final l$timeUntilAiring = timeUntilAiring;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$airingAt,
      l$episode,
      l$timeUntilAiring,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$airingAt = airingAt;
    final lOther$airingAt = other.airingAt;
    if (l$airingAt != lOther$airingAt) {
      return false;
    }
    final l$episode = episode;
    final lOther$episode = other.episode;
    if (l$episode != lOther$episode) {
      return false;
    }
    final l$timeUntilAiring = timeUntilAiring;
    final lOther$timeUntilAiring = other.timeUntilAiring;
    if (l$timeUntilAiring != lOther$timeUntilAiring) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode
    on Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode {
  CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<
          Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode>
      get copyWith =>
          CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<
    TRes> {
  factory CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
    Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode instance,
    TRes Function(Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode) then,
  ) = _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode;

  factory CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? episode,
    int? timeUntilAiring,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes>
    implements
        CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes> {
  _CopyWithImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode _instance;

  final TRes Function(Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? episode = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
        airingAt: airingAt == _undefined || airingAt == null
            ? _instance.airingAt
            : (airingAt as int),
        episode: episode == _undefined || episode == null
            ? _instance.episode
            : (episode as int),
        timeUntilAiring:
            timeUntilAiring == _undefined || timeUntilAiring == null
                ? _instance.timeUntilAiring
                : (timeUntilAiring as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode<TRes> {
  _CopyWithStubImpl$Query$GetUpcomingEpisodes$Page$media$nextAiringEpisode(
      this._res);

  TRes _res;

  call({
    int? airingAt,
    int? episode,
    int? timeUntilAiring,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$GetEpisodeTitles {
  factory Variables$Query$GetEpisodeTitles({List<int?>? ids}) =>
      Variables$Query$GetEpisodeTitles._({
        if (ids != null) r'ids': ids,
      });

  Variables$Query$GetEpisodeTitles._(this._$data);

  factory Variables$Query$GetEpisodeTitles.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('ids')) {
      final l$ids = data['ids'];
      result$data['ids'] =
          (l$ids as List<dynamic>?)?.map((e) => (e as int?)).toList();
    }
    return Variables$Query$GetEpisodeTitles._(result$data);
  }

  Map<String, dynamic> _$data;

  List<int?>? get ids => (_$data['ids'] as List<int?>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('ids')) {
      final l$ids = ids;
      result$data['ids'] = l$ids?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetEpisodeTitles<Variables$Query$GetEpisodeTitles>
      get copyWith => CopyWith$Variables$Query$GetEpisodeTitles(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetEpisodeTitles ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (_$data.containsKey('ids') != other._$data.containsKey('ids')) {
      return false;
    }
    if (l$ids != null && lOther$ids != null) {
      if (l$ids.length != lOther$ids.length) {
        return false;
      }
      for (int i = 0; i < l$ids.length; i++) {
        final l$ids$entry = l$ids[i];
        final lOther$ids$entry = lOther$ids[i];
        if (l$ids$entry != lOther$ids$entry) {
          return false;
        }
      }
    } else if (l$ids != lOther$ids) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('ids')
          ? l$ids == null
              ? null
              : Object.hashAll(l$ids.map((v) => v))
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetEpisodeTitles<TRes> {
  factory CopyWith$Variables$Query$GetEpisodeTitles(
    Variables$Query$GetEpisodeTitles instance,
    TRes Function(Variables$Query$GetEpisodeTitles) then,
  ) = _CopyWithImpl$Variables$Query$GetEpisodeTitles;

  factory CopyWith$Variables$Query$GetEpisodeTitles.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetEpisodeTitles;

  TRes call({List<int?>? ids});
}

class _CopyWithImpl$Variables$Query$GetEpisodeTitles<TRes>
    implements CopyWith$Variables$Query$GetEpisodeTitles<TRes> {
  _CopyWithImpl$Variables$Query$GetEpisodeTitles(
    this._instance,
    this._then,
  );

  final Variables$Query$GetEpisodeTitles _instance;

  final TRes Function(Variables$Query$GetEpisodeTitles) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? ids = _undefined}) =>
      _then(Variables$Query$GetEpisodeTitles._({
        ..._instance._$data,
        if (ids != _undefined) 'ids': (ids as List<int?>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetEpisodeTitles<TRes>
    implements CopyWith$Variables$Query$GetEpisodeTitles<TRes> {
  _CopyWithStubImpl$Variables$Query$GetEpisodeTitles(this._res);

  TRes _res;

  call({List<int?>? ids}) => _res;
}

class Query$GetEpisodeTitles {
  Query$GetEpisodeTitles({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetEpisodeTitles.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetEpisodeTitles(
      Page: l$Page == null
          ? null
          : Query$GetEpisodeTitles$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetEpisodeTitles$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetEpisodeTitles || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Page = Page;
    final lOther$Page = other.Page;
    if (l$Page != lOther$Page) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetEpisodeTitles on Query$GetEpisodeTitles {
  CopyWith$Query$GetEpisodeTitles<Query$GetEpisodeTitles> get copyWith =>
      CopyWith$Query$GetEpisodeTitles(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetEpisodeTitles<TRes> {
  factory CopyWith$Query$GetEpisodeTitles(
    Query$GetEpisodeTitles instance,
    TRes Function(Query$GetEpisodeTitles) then,
  ) = _CopyWithImpl$Query$GetEpisodeTitles;

  factory CopyWith$Query$GetEpisodeTitles.stub(TRes res) =
      _CopyWithStubImpl$Query$GetEpisodeTitles;

  TRes call({
    Query$GetEpisodeTitles$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetEpisodeTitles$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetEpisodeTitles<TRes>
    implements CopyWith$Query$GetEpisodeTitles<TRes> {
  _CopyWithImpl$Query$GetEpisodeTitles(
    this._instance,
    this._then,
  );

  final Query$GetEpisodeTitles _instance;

  final TRes Function(Query$GetEpisodeTitles) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetEpisodeTitles(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetEpisodeTitles$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetEpisodeTitles$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetEpisodeTitles$Page.stub(_then(_instance))
        : CopyWith$Query$GetEpisodeTitles$Page(
            local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetEpisodeTitles<TRes>
    implements CopyWith$Query$GetEpisodeTitles<TRes> {
  _CopyWithStubImpl$Query$GetEpisodeTitles(this._res);

  TRes _res;

  call({
    Query$GetEpisodeTitles$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetEpisodeTitles$Page<TRes> get Page =>
      CopyWith$Query$GetEpisodeTitles$Page.stub(_res);
}

const documentNodeQueryGetEpisodeTitles = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetEpisodeTitles'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'ids')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'Int'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: IntValueNode(value: '50'),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id_in'),
                value: VariableNode(name: NameNode(value: 'ids')),
              ),
              ArgumentNode(
                name: NameNode(value: 'type'),
                value: EnumValueNode(name: NameNode(value: 'ANIME')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'id'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'streamingEpisodes'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'title'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Query$GetEpisodeTitles _parserFn$Query$GetEpisodeTitles(
        Map<String, dynamic> data) =>
    Query$GetEpisodeTitles.fromJson(data);
typedef OnQueryComplete$Query$GetEpisodeTitles = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetEpisodeTitles?,
);

class Options$Query$GetEpisodeTitles
    extends graphql.QueryOptions<Query$GetEpisodeTitles> {
  Options$Query$GetEpisodeTitles({
    String? operationName,
    Variables$Query$GetEpisodeTitles? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetEpisodeTitles? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetEpisodeTitles? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$GetEpisodeTitles(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetEpisodeTitles,
          parserFn: _parserFn$Query$GetEpisodeTitles,
        );

  final OnQueryComplete$Query$GetEpisodeTitles? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetEpisodeTitles
    extends graphql.WatchQueryOptions<Query$GetEpisodeTitles> {
  WatchOptions$Query$GetEpisodeTitles({
    String? operationName,
    Variables$Query$GetEpisodeTitles? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetEpisodeTitles? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetEpisodeTitles,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetEpisodeTitles,
        );
}

class FetchMoreOptions$Query$GetEpisodeTitles extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetEpisodeTitles({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetEpisodeTitles? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetEpisodeTitles,
        );
}

extension ClientExtension$Query$GetEpisodeTitles on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetEpisodeTitles>> query$GetEpisodeTitles(
          [Options$Query$GetEpisodeTitles? options]) async =>
      await this.query(options ?? Options$Query$GetEpisodeTitles());
  graphql.ObservableQuery<Query$GetEpisodeTitles> watchQuery$GetEpisodeTitles(
          [WatchOptions$Query$GetEpisodeTitles? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetEpisodeTitles());
  void writeQuery$GetEpisodeTitles({
    required Query$GetEpisodeTitles data,
    Variables$Query$GetEpisodeTitles? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetEpisodeTitles),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetEpisodeTitles? readQuery$GetEpisodeTitles({
    Variables$Query$GetEpisodeTitles? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetEpisodeTitles),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetEpisodeTitles.fromJson(result);
  }
}

class Query$GetEpisodeTitles$Page {
  Query$GetEpisodeTitles$Page({
    this.media,
    this.$__typename = 'Page',
  });

  factory Query$GetEpisodeTitles$Page.fromJson(Map<String, dynamic> json) {
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetEpisodeTitles$Page(
      media: (l$media as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetEpisodeTitles$Page$media.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetEpisodeTitles$Page$media?>? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$media = media;
    _resultData['media'] = l$media?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$media == null ? null : Object.hashAll(l$media.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetEpisodeTitles$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != null && lOther$media != null) {
      if (l$media.length != lOther$media.length) {
        return false;
      }
      for (int i = 0; i < l$media.length; i++) {
        final l$media$entry = l$media[i];
        final lOther$media$entry = lOther$media[i];
        if (l$media$entry != lOther$media$entry) {
          return false;
        }
      }
    } else if (l$media != lOther$media) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetEpisodeTitles$Page
    on Query$GetEpisodeTitles$Page {
  CopyWith$Query$GetEpisodeTitles$Page<Query$GetEpisodeTitles$Page>
      get copyWith => CopyWith$Query$GetEpisodeTitles$Page(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetEpisodeTitles$Page<TRes> {
  factory CopyWith$Query$GetEpisodeTitles$Page(
    Query$GetEpisodeTitles$Page instance,
    TRes Function(Query$GetEpisodeTitles$Page) then,
  ) = _CopyWithImpl$Query$GetEpisodeTitles$Page;

  factory CopyWith$Query$GetEpisodeTitles$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetEpisodeTitles$Page;

  TRes call({
    List<Query$GetEpisodeTitles$Page$media?>? media,
    String? $__typename,
  });
  TRes media(
      Iterable<Query$GetEpisodeTitles$Page$media?>? Function(
              Iterable<
                  CopyWith$Query$GetEpisodeTitles$Page$media<
                      Query$GetEpisodeTitles$Page$media>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetEpisodeTitles$Page<TRes>
    implements CopyWith$Query$GetEpisodeTitles$Page<TRes> {
  _CopyWithImpl$Query$GetEpisodeTitles$Page(
    this._instance,
    this._then,
  );

  final Query$GetEpisodeTitles$Page _instance;

  final TRes Function(Query$GetEpisodeTitles$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetEpisodeTitles$Page(
        media: media == _undefined
            ? _instance.media
            : (media as List<Query$GetEpisodeTitles$Page$media?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes media(
          Iterable<Query$GetEpisodeTitles$Page$media?>? Function(
                  Iterable<
                      CopyWith$Query$GetEpisodeTitles$Page$media<
                          Query$GetEpisodeTitles$Page$media>?>?)
              _fn) =>
      call(
          media: _fn(_instance.media?.map((e) => e == null
              ? null
              : CopyWith$Query$GetEpisodeTitles$Page$media(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetEpisodeTitles$Page<TRes>
    implements CopyWith$Query$GetEpisodeTitles$Page<TRes> {
  _CopyWithStubImpl$Query$GetEpisodeTitles$Page(this._res);

  TRes _res;

  call({
    List<Query$GetEpisodeTitles$Page$media?>? media,
    String? $__typename,
  }) =>
      _res;

  media(_fn) => _res;
}

class Query$GetEpisodeTitles$Page$media {
  Query$GetEpisodeTitles$Page$media({
    required this.id,
    this.streamingEpisodes,
    this.$__typename = 'Media',
  });

  factory Query$GetEpisodeTitles$Page$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$streamingEpisodes = json['streamingEpisodes'];
    final l$$__typename = json['__typename'];
    return Query$GetEpisodeTitles$Page$media(
      id: (l$id as int),
      streamingEpisodes: (l$streamingEpisodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetEpisodeTitles$Page$media$streamingEpisodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final List<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>?
      streamingEpisodes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$streamingEpisodes = streamingEpisodes;
    _resultData['streamingEpisodes'] =
        l$streamingEpisodes?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$streamingEpisodes = streamingEpisodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$streamingEpisodes == null
          ? null
          : Object.hashAll(l$streamingEpisodes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetEpisodeTitles$Page$media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$streamingEpisodes = streamingEpisodes;
    final lOther$streamingEpisodes = other.streamingEpisodes;
    if (l$streamingEpisodes != null && lOther$streamingEpisodes != null) {
      if (l$streamingEpisodes.length != lOther$streamingEpisodes.length) {
        return false;
      }
      for (int i = 0; i < l$streamingEpisodes.length; i++) {
        final l$streamingEpisodes$entry = l$streamingEpisodes[i];
        final lOther$streamingEpisodes$entry = lOther$streamingEpisodes[i];
        if (l$streamingEpisodes$entry != lOther$streamingEpisodes$entry) {
          return false;
        }
      }
    } else if (l$streamingEpisodes != lOther$streamingEpisodes) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetEpisodeTitles$Page$media
    on Query$GetEpisodeTitles$Page$media {
  CopyWith$Query$GetEpisodeTitles$Page$media<Query$GetEpisodeTitles$Page$media>
      get copyWith => CopyWith$Query$GetEpisodeTitles$Page$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetEpisodeTitles$Page$media<TRes> {
  factory CopyWith$Query$GetEpisodeTitles$Page$media(
    Query$GetEpisodeTitles$Page$media instance,
    TRes Function(Query$GetEpisodeTitles$Page$media) then,
  ) = _CopyWithImpl$Query$GetEpisodeTitles$Page$media;

  factory CopyWith$Query$GetEpisodeTitles$Page$media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media;

  TRes call({
    int? id,
    List<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>?
        streamingEpisodes,
    String? $__typename,
  });
  TRes streamingEpisodes(
      Iterable<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>? Function(
              Iterable<
                  CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<
                      Query$GetEpisodeTitles$Page$media$streamingEpisodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetEpisodeTitles$Page$media<TRes>
    implements CopyWith$Query$GetEpisodeTitles$Page$media<TRes> {
  _CopyWithImpl$Query$GetEpisodeTitles$Page$media(
    this._instance,
    this._then,
  );

  final Query$GetEpisodeTitles$Page$media _instance;

  final TRes Function(Query$GetEpisodeTitles$Page$media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? streamingEpisodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetEpisodeTitles$Page$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        streamingEpisodes: streamingEpisodes == _undefined
            ? _instance.streamingEpisodes
            : (streamingEpisodes
                as List<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes streamingEpisodes(
          Iterable<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<
                          Query$GetEpisodeTitles$Page$media$streamingEpisodes>?>?)
              _fn) =>
      call(
          streamingEpisodes: _fn(_instance.streamingEpisodes?.map((e) => e ==
                  null
              ? null
              : CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media<TRes>
    implements CopyWith$Query$GetEpisodeTitles$Page$media<TRes> {
  _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media(this._res);

  TRes _res;

  call({
    int? id,
    List<Query$GetEpisodeTitles$Page$media$streamingEpisodes?>?
        streamingEpisodes,
    String? $__typename,
  }) =>
      _res;

  streamingEpisodes(_fn) => _res;
}

class Query$GetEpisodeTitles$Page$media$streamingEpisodes {
  Query$GetEpisodeTitles$Page$media$streamingEpisodes({
    this.title,
    this.$__typename = 'MediaStreamingEpisode',
  });

  factory Query$GetEpisodeTitles$Page$media$streamingEpisodes.fromJson(
      Map<String, dynamic> json) {
    final l$title = json['title'];
    final l$$__typename = json['__typename'];
    return Query$GetEpisodeTitles$Page$media$streamingEpisodes(
      title: (l$title as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? title;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$title = title;
    _resultData['title'] = l$title;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$title = title;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$title,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetEpisodeTitles$Page$media$streamingEpisodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetEpisodeTitles$Page$media$streamingEpisodes
    on Query$GetEpisodeTitles$Page$media$streamingEpisodes {
  CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<
          Query$GetEpisodeTitles$Page$media$streamingEpisodes>
      get copyWith =>
          CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<
    TRes> {
  factory CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes(
    Query$GetEpisodeTitles$Page$media$streamingEpisodes instance,
    TRes Function(Query$GetEpisodeTitles$Page$media$streamingEpisodes) then,
  ) = _CopyWithImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes;

  factory CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes;

  TRes call({
    String? title,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes<TRes>
    implements
        CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<TRes> {
  _CopyWithImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes(
    this._instance,
    this._then,
  );

  final Query$GetEpisodeTitles$Page$media$streamingEpisodes _instance;

  final TRes Function(Query$GetEpisodeTitles$Page$media$streamingEpisodes)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? title = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetEpisodeTitles$Page$media$streamingEpisodes(
        title: title == _undefined ? _instance.title : (title as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes<
        TRes>
    implements
        CopyWith$Query$GetEpisodeTitles$Page$media$streamingEpisodes<TRes> {
  _CopyWithStubImpl$Query$GetEpisodeTitles$Page$media$streamingEpisodes(
      this._res);

  TRes _res;

  call({
    String? title,
    String? $__typename,
  }) =>
      _res;
}
