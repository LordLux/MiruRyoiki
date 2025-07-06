import 'package:miruryoiki/enums.dart';
import 'package:path/path.dart';

class AnilistAnime {
  final int id;
  final String? bannerImage;
  final String? posterImage;
  final String? dominantColor;
  final AnilistTitle title;
  final String? description;
  final int? meanScore;
  final int? popularity;
  final int? favourites;
  final String? status;
  final String? format;
  final int? episodes;
  final int? seasonYear;
  final String? season;
  final List<String> genres;
  final int? averageScore;
  final int? trending;
  final int? rankings;
  final DateValue? startDate;
  final DateValue? endDate;
  final int? updatedAt;
  final DateValue? startedAt;
  final DateValue? completedAt;
  final Map<String, int>? advancedScores;
  final AiringEpisode? nextAiringEpisode;
  final bool? isFavourite;
  final String? siteUrl;
  final bool? isHidden;

  AnilistAnime({
    required this.id,
    this.bannerImage,
    this.posterImage,
    this.dominantColor,
    required this.title,
    this.description,
    this.meanScore,
    this.popularity,
    this.favourites,
    this.status,
    this.format,
    this.episodes,
    this.seasonYear,
    this.season,
    this.genres = const [],
    this.averageScore,
    this.trending,
    this.rankings,
    this.startDate,
    this.endDate,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.advancedScores,
    this.nextAiringEpisode,
    this.isFavourite,
    this.siteUrl,
    this.isHidden,
  });
  factory AnilistAnime.fromJson(Map<String, dynamic> json) {
    return AnilistAnime(
      id: json['id'] as int,
      bannerImage: json['bannerImage'] as String?,
      posterImage: json['coverImage'] != null ? json['coverImage']['extraLarge'] as String? : null,
      dominantColor: json['coverImage'] != null ? json['coverImage']['color'] as String? : null, // from doc: coverImage{ extraLarge, color }
      title: AnilistTitle.fromJson(json['title']),
      description: json['description'] as String?,
      meanScore: json['meanScore'] as int?,
      popularity: json['popularity'] as int?,
      favourites: json['favourites'] as int?,
      status: json['status'] as String?,
      format: json['format'] as String?,
      episodes: json['episodes'] as int?,
      seasonYear: json['seasonYear'] as int?,
      season: json['season'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      averageScore: json['averageScore'] as int?,
      trending: json['trending'] as int?,
      rankings: json['rankings'] != null && (json['rankings'] as List).isNotEmpty ? (json['rankings'] as List).first['rank'] : null,
      startDate: json['startDate'] != null ? DateValue.fromJson(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateValue.fromJson(json['endDate']) : null,
      updatedAt: json['updatedAt'] as int?,
      startedAt: json['startedAt'] != null ? DateValue.fromJson(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateValue.fromJson(json['completedAt']) : null,
      advancedScores: json['advancedScores'] != null ? Map<String, int>.from(json['advancedScores']) : null,
      nextAiringEpisode: json['nextAiringEpisode'] != null ? AiringEpisode.fromJson(json['nextAiringEpisode']) : null,
      isFavourite: json['isFavourite'] as bool?,
      siteUrl: json['siteUrl'] as String?,
      isHidden: json['hidden'] as bool? ?? false,
    );
  }

  AnilistAnime copyWith({
    int? id,
    String? bannerImage,
    String? posterImage,
    String? dominantColor,
    AnilistTitle? title,
    String? description,
    int? meanScore,
    int? popularity,
    int? favourites,
    String? status,
    String? format,
    int? episodes,
    int? seasonYear,
    String? season,
    List<String>? genres,
    int? averageScore,
    int? trending,
    int? rankings,
    DateValue? startDate,
    DateValue? endDate,
    int? updatedAt,
    DateValue? startedAt,
    DateValue? completedAt,
    Map<String, int>? advancedScores,
    AiringEpisode? nextAiringEpisode,
    bool? isFavourite,
    String? siteUrl,
    bool? isHidden,
  }) {
    return AnilistAnime(
      id: id ?? this.id,
      bannerImage: bannerImage ?? this.bannerImage,
      posterImage: posterImage ?? this.posterImage,
      dominantColor: dominantColor ?? this.dominantColor,
      title: title ?? this.title,
      description: description ?? this.description,
      meanScore: meanScore ?? this.meanScore,
      popularity: popularity ?? this.popularity,
      favourites: favourites ?? this.favourites,
      status: status ?? this.status,
      format: format ?? this.format,
      episodes: episodes ?? this.episodes,
      seasonYear: seasonYear ?? this.seasonYear,
      season: season ?? this.season,
      genres: genres ?? this.genres,
      averageScore: averageScore ?? this.averageScore,
      trending: trending ?? this.trending,
      rankings: rankings ?? this.rankings,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      advancedScores: advancedScores ?? this.advancedScores,
      nextAiringEpisode: nextAiringEpisode ?? this.nextAiringEpisode,
      isFavourite: isFavourite ?? this.isFavourite,
      siteUrl: siteUrl ?? this.siteUrl,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bannerImage': bannerImage,
      'posterImage': posterImage,
      'dominantColor': dominantColor,
      'title': title.toJson(),
      'description': description,
      'meanScore': meanScore,
      'popularity': popularity,
      'favourites': favourites,
      'status': status,
      'format': format,
      'episodes': episodes,
      'seasonYear': seasonYear,
      'season': season,
      'genres': genres,
      'averageScore': averageScore,
      'trending': trending,
      'rankings': rankings,
      'startDate': startDate?.toJson(),
      'endDate': endDate?.toJson(),
      'updatedAt': updatedAt,
      'startedAt': startedAt?.toJson(),
      'completedAt': completedAt?.toJson(),
      'advancedScores': advancedScores,
      'nextAiringEpisode': nextAiringEpisode?.toJson(),
      'isFavourite': isFavourite,
      'siteUrl': siteUrl,
      'hidden': isHidden,
    };
  }

  @override
  String toString() {
    return 'AnilistAnime(id: $id, title: ${title.romaji}, status: $status, episodes: $episodes, bannerImage: ${basename(bannerImage ?? '')}, posterImage: ${basename(posterImage ?? '')})${isHidden == true ? ' [HIDDEN]' : ''}';
  }
}

class AnilistTitle {
  final String? romaji;
  final String? english;
  final String? native;
  final String? userPreferred;

  AnilistTitle({
    this.romaji,
    this.english,
    this.native,
    this.userPreferred,
  });

  factory AnilistTitle.fromJson(Map<String, dynamic> json) {
    return AnilistTitle(
      romaji: json['romaji'] as String?,
      english: json['english'] as String?,
      native: json['native'] as String?,
      userPreferred: json['userPreferred'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'romaji': romaji,
      'english': english,
      'native': native,
      'userPreferred': userPreferred,
    };
  }
}

// Helper class for date values
class DateValue {
  final int? year;
  final int? month;
  final int? day;

  DateValue({this.year, this.month, this.day});

  factory DateValue.fromJson(Map<String, dynamic> json) {
    return DateValue(
      year: json['year'] as int?,
      month: json['month'] as int?,
      day: json['day'] as int?,
    );
  }

  DateTime? toDateTime() {
    if (year != null && month != null && day != null) return DateTime(year!, month!, day!);

    return null;
  }

  @override
  String toString() => toDateTime().pretty();

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateValue && other.year == year && other.month == month && other.day == day;
  }

  operator >(DateValue other) {
    if (year != null && other.year != null) {
      if (year! > other.year!) return true;
      if (year! < other.year!) return false;
    }
    if (month != null && other.month != null) {
      if (month! > other.month!) return true;
      if (month! < other.month!) return false;
    }
    if (day != null && other.day != null) {
      if (day! > other.day!) return true;
      if (day! < other.day!) return false;
    }
    return false;
  }

  operator <(DateValue other) {
    if (year != null && other.year != null) {
      if (year! < other.year!) return true;
      if (year! > other.year!) return false;
    }
    if (month != null && other.month != null) {
      if (month! < other.month!) return true;
      if (month! > other.month!) return false;
    }
    if (day != null && other.day != null) {
      if (day! < other.day!) return true;
      if (day! > other.day!) return false;
    }
    return false;
  }

  operator >=(DateValue other) {
    if (year != null && other.year != null) {
      if (year! >= other.year!) return true;
      if (year! < other.year!) return false;
    }
    if (month != null && other.month != null) {
      if (month! >= other.month!) return true;
      if (month! < other.month!) return false;
    }
    if (day != null && other.day != null) {
      if (day! >= other.day!) return true;
      if (day! < other.day!) return false;
    }
    return false;
  }

  operator <=(DateValue other) {
    if (year != null && other.year != null) {
      if (year! <= other.year!) return true;
      if (year! > other.year!) return false;
    }
    if (month != null && other.month != null) {
      if (month! <= other.month!) return true;
      if (month! > other.month!) return false;
    }
    if (day != null && other.day != null) {
      if (day! <= other.day!) return true;
      if (day! > other.day!) return false;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }
}

// Helper class for airing episode information
class AiringEpisode {
  final int? airingAt;
  final int? episode;
  final int? timeUntilAiring;

  AiringEpisode({this.airingAt, this.episode, this.timeUntilAiring});

  factory AiringEpisode.fromJson(Map<String, dynamic> json) {
    return AiringEpisode(
      airingAt: json['airingAt'] as int?,
      episode: json['episode'] as int?,
      timeUntilAiring: json['timeUntilAiring'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airingAt': airingAt,
      'episode': episode,
      'timeUntilAiring': timeUntilAiring,
    };
  }
}
