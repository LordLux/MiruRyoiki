import 'anime.dart';

class AnilistUserData {
  final String? about;
  final String? siteUrl;
  final Options? options;
  final MediaStatistics? mediaStatistics;
  final Favourites? favourites;
  final Statistics? statistics;
  final int? donatorTier;
  final String? donatorBadge;
  final int? createdAt;
  final int? updatedAt;

  AnilistUserData({
    this.about,
    this.siteUrl,
    this.options,
    this.mediaStatistics,
    this.favourites,
    this.statistics,
    this.donatorTier,
    this.donatorBadge,
    this.createdAt,
    this.updatedAt,
  });

  factory AnilistUserData.fromJson(Map<String, dynamic> json) {
    return AnilistUserData(
      about: json['about'],
      siteUrl: json['siteUrl'],
      options: json['options'] != null ? Options.fromJson(json['options']) : null,
      mediaStatistics: json['mediaStatistics'] != null ? MediaStatistics.fromJson(json['mediaStatistics']) : null,
      favourites: json['favourites'] != null ? Favourites.fromJson(json['favourites']) : null,
      statistics: json['statistics'] != null ? Statistics.fromJson(json['statistics']) : null,
      donatorTier: json['donatorTier'],
      donatorBadge: json['donatorBadge'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'about': about,
      'siteUrl': siteUrl,
      'options': options?.toJson(),
      'mediaStatistics': mediaStatistics?.toJson(),
      'favourites': favourites?.toJson(),
      'statistics': statistics?.toJson(),
      'donatorTier': donatorTier,
      'donatorBadge': donatorBadge,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Options {
  final String? titleLanguage;
  final bool? displayAdultContent;
  final bool? airingNotifications;
  final String? profileColor;
  final String? timezone;
  final int? activityMergeTime;
  final bool? restrictMessagesToFollowing;
  final String? staffNameLanguage;

  Options({
    this.titleLanguage,
    this.displayAdultContent,
    this.airingNotifications,
    this.profileColor,
    this.timezone,
    this.activityMergeTime,
    this.restrictMessagesToFollowing,
    this.staffNameLanguage,
  });

  factory Options.fromJson(Map<String, dynamic> json) {
    return Options(
      titleLanguage: json['titleLanguage'],
      displayAdultContent: json['displayAdultContent'],
      airingNotifications: json['airingNotifications'],
      profileColor: json['profileColor'],
      timezone: json['timezone'],
      activityMergeTime: json['activityMergeTime'],
      restrictMessagesToFollowing: json['restrictMessagesToFollowing'],
      staffNameLanguage: json['staffNameLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleLanguage': titleLanguage,
      'displayAdultContent': displayAdultContent,
      'airingNotifications': airingNotifications,
      'profileColor': profileColor,
      'timezone': timezone,
      'activityMergeTime': activityMergeTime,
      'restrictMessagesToFollowing': restrictMessagesToFollowing,
      'staffNameLanguage': staffNameLanguage,
    };
  }
}

class AnimeStatistics {
  final int? count;
  final double? meanScore;
  final double? standardDeviation;
  final int? minutesWatched;
  final int? episodesWatched;
  final List<GenreStatistic>? genres;
  final List<TagStatistic>? tags;

  AnimeStatistics({
    this.count,
    this.meanScore,
    this.standardDeviation,
    this.minutesWatched,
    this.episodesWatched,
    this.genres,
    this.tags,
  });

  factory AnimeStatistics.fromJson(Map<String, dynamic> json) {
    return AnimeStatistics(
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      standardDeviation: json['standardDeviation']?.toDouble(),
      minutesWatched: json['minutesWatched'],
      episodesWatched: json['episodesWatched'],
      genres: json['genres'] != null ? List<GenreStatistic>.from(json['genres'].map((x) => GenreStatistic.fromJson(x))) : null,
      tags: json['tags'] != null ? List<TagStatistic>.from(json['tags'].map((x) => TagStatistic.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'meanScore': meanScore,
      'standardDeviation': standardDeviation,
      'minutesWatched': minutesWatched,
      'episodesWatched': episodesWatched,
      'genres': genres?.map((x) => x.toJson()).toList(),
      'tags': tags?.map((x) => x.toJson()).toList(),
    };
  }
}

class GenreStatistic {
  final String? genre;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  GenreStatistic({
    this.genre,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory GenreStatistic.fromJson(Map<String, dynamic> json) {
    return GenreStatistic(
      genre: json['genre'],
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genre': genre,
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class TagStatistic {
  final Tag? tag;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  TagStatistic({
    this.tag,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory TagStatistic.fromJson(Map<String, dynamic> json) {
    return TagStatistic(
      tag: json['tag'] != null ? Tag.fromJson(json['tag']) : null,
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag?.toJson(),
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class Tag {
  final int? id;
  final String? name;

  Tag({
    this.id,
    this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class MediaStatistics {
  final AnimeStatistics? anime;

  MediaStatistics({
    this.anime,
  });

  factory MediaStatistics.fromJson(Map<String, dynamic> json) {
    return MediaStatistics(
      anime: json['anime'] != null ? AnimeStatistics.fromJson(json['anime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anime': anime?.toJson(),
    };
  }
}

class Favourites {
  final FavouriteAnime? anime;
  final FavouriteCharacters? characters;
  final FavouriteStaff? staff;
  final FavouriteStudios? studios;

  Favourites({
    this.anime,
    this.characters,
    this.staff,
    this.studios,
  });

  factory Favourites.fromJson(Map<String, dynamic> json) {
    return Favourites(
      anime: json['anime'] != null ? FavouriteAnime.fromJson(json['anime']) : null,
      characters: json['characters'] != null ? FavouriteCharacters.fromJson(json['characters']) : null,
      staff: json['staff'] != null ? FavouriteStaff.fromJson(json['staff']) : null,
      studios: json['studios'] != null ? FavouriteStudios.fromJson(json['studios']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anime': anime?.toJson(),
      'characters': characters?.toJson(),
      'staff': staff?.toJson(),
      'studios': studios?.toJson(),
    };
  }
}

class FavouriteAnime {
  final List<AnilistAnime>? nodes;

  FavouriteAnime({
    this.nodes,
  });

  factory FavouriteAnime.fromJson(Map<String, dynamic> json) {
    return FavouriteAnime(
      nodes: json['nodes'] != null ? List<AnilistAnime>.from(json['nodes'].map((x) => AnilistAnime.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes?.map((x) => x.toJson()).toList(),
    };
  }
}

class FavouriteCharacters {
  final List<Character>? nodes;

  FavouriteCharacters({
    this.nodes,
  });

  factory FavouriteCharacters.fromJson(Map<String, dynamic> json) {
    return FavouriteCharacters(
      nodes: json['nodes'] != null ? List<Character>.from(json['nodes'].map((x) => Character.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes?.map((x) => x.toJson()).toList(),
    };
  }
}

class Character {
  final int? id;
  final CharacterName? name;
  final CharacterImage? image;

  Character({
    this.id,
    this.name,
    this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'] != null ? CharacterName.fromJson(json['name']) : null,
      image: json['image'] != null ? CharacterImage.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
      'image': image?.toJson(),
    };
  }
}

class CharacterName {
  final String? full;
  final String? native;

  CharacterName({
    this.full,
    this.native,
  });

  factory CharacterName.fromJson(Map<String, dynamic> json) {
    return CharacterName(
      full: json['full'],
      native: json['native'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full': full,
      'native': native,
    };
  }
}

class CharacterImage {
  final String? large;

  CharacterImage({
    this.large,
  });

  factory CharacterImage.fromJson(Map<String, dynamic> json) {
    return CharacterImage(
      large: json['large'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'large': large,
    };
  }
}

class FavouriteStaff {
  final List<Staff>? nodes;

  FavouriteStaff({
    this.nodes,
  });

  factory FavouriteStaff.fromJson(Map<String, dynamic> json) {
    return FavouriteStaff(
      nodes: json['nodes'] != null ? List<Staff>.from(json['nodes'].map((x) => Staff.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes?.map((x) => x.toJson()).toList(),
    };
  }
}

class Staff {
  final int? id;
  final CharacterName? name;
  final CharacterImage? image;

  Staff({
    this.id,
    this.name,
    this.image,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'] != null ? CharacterName.fromJson(json['name']) : null,
      image: json['image'] != null ? CharacterImage.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
      'image': image?.toJson(),
    };
  }
}

class FavouriteStudios {
  final List<Studio>? nodes;

  FavouriteStudios({
    this.nodes,
  });

  factory FavouriteStudios.fromJson(Map<String, dynamic> json) {
    return FavouriteStudios(
      nodes: json['nodes'] != null ? List<Studio>.from(json['nodes'].map((x) => Studio.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes?.map((x) => x.toJson()).toList(),
    };
  }
}

class Studio {
  final int? id;
  final String? name;

  Studio({
    this.id,
    this.name,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Statistics {
  final DetailedAnimeStatistics? anime;

  Statistics({
    this.anime,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      anime: json['anime'] != null ? DetailedAnimeStatistics.fromJson(json['anime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anime': anime?.toJson(),
    };
  }
}

class DetailedAnimeStatistics extends AnimeStatistics {
  final List<FormatStatistic>? formats;
  final List<StatusStatistic>? statuses;
  final List<YearStatistic>? releaseYears;
  final List<YearStatistic>? startYears;
  final List<CountryStatistic>? countries;
  final List<VoiceActorStatistic>? voiceActors;
  final List<StaffStatistic>? staff;
  final List<StudioStatistic>? studios;

  DetailedAnimeStatistics({
    super.count,
    super.meanScore,
    super.standardDeviation,
    super.minutesWatched,
    super.episodesWatched,
    super.genres,
    super.tags,
    this.formats,
    this.statuses,
    this.releaseYears,
    this.startYears,
    this.countries,
    this.voiceActors,
    this.staff,
    this.studios,
  });

  factory DetailedAnimeStatistics.fromJson(Map<String, dynamic> json) {
    return DetailedAnimeStatistics(
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      standardDeviation: json['standardDeviation']?.toDouble(),
      minutesWatched: json['minutesWatched'],
      episodesWatched: json['episodesWatched'],
      genres: json['genres'] != null ? List<GenreStatistic>.from(json['genres'].map((x) => GenreStatistic.fromJson(x))) : null,
      tags: json['tags'] != null ? List<TagStatistic>.from(json['tags'].map((x) => TagStatistic.fromJson(x))) : null,
      formats: json['formats'] != null ? List<FormatStatistic>.from(json['formats'].map((x) => FormatStatistic.fromJson(x))) : null,
      statuses: json['statuses'] != null ? List<StatusStatistic>.from(json['statuses'].map((x) => StatusStatistic.fromJson(x))) : null,
      releaseYears: json['releaseYears'] != null ? List<YearStatistic>.from(json['releaseYears'].map((x) => YearStatistic.fromJson(x, 'releaseYear'))) : null,
      startYears: json['startYears'] != null ? List<YearStatistic>.from(json['startYears'].map((x) => YearStatistic.fromJson(x, 'startYear'))) : null,
      countries: json['countries'] != null ? List<CountryStatistic>.from(json['countries'].map((x) => CountryStatistic.fromJson(x))) : null,
      voiceActors: json['voiceActors'] != null ? List<VoiceActorStatistic>.from(json['voiceActors'].map((x) => VoiceActorStatistic.fromJson(x))) : null,
      staff: json['staff'] != null ? List<StaffStatistic>.from(json['staff'].map((x) => StaffStatistic.fromJson(x))) : null,
      studios: json['studios'] != null ? List<StudioStatistic>.from(json['studios'].map((x) => StudioStatistic.fromJson(x))) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'formats': formats?.map((x) => x.toJson()).toList(),
      'statuses': statuses?.map((x) => x.toJson()).toList(),
      'releaseYears': releaseYears?.map((x) => x.toJson()).toList(),
      'startYears': startYears?.map((x) => x.toJson()).toList(),
      'countries': countries?.map((x) => x.toJson()).toList(),
      'voiceActors': voiceActors?.map((x) => x.toJson()).toList(),
      'staff': staff?.map((x) => x.toJson()).toList(),
      'studios': studios?.map((x) => x.toJson()).toList(),
    });
    return data;
  }
}

class FormatStatistic {
  final String? format;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  FormatStatistic({
    this.format,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory FormatStatistic.fromJson(Map<String, dynamic> json) {
    return FormatStatistic(
      format: json['format'],
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class StatusStatistic {
  final String? status;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  StatusStatistic({
    this.status,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory StatusStatistic.fromJson(Map<String, dynamic> json) {
    return StatusStatistic(
      status: json['status'],
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class YearStatistic {
  final int? year;
  final int? count;
  final double? meanScore;
  final int? timeWatched;
  final String yearField;

  YearStatistic({
    this.year,
    this.count,
    this.meanScore,
    this.timeWatched,
    required this.yearField,
  });

  factory YearStatistic.fromJson(Map<String, dynamic> json, String yearField) {
    return YearStatistic(
      year: json[yearField],
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
      yearField: yearField,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      yearField: year,
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class CountryStatistic {
  final String? country;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  CountryStatistic({
    this.country,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory CountryStatistic.fromJson(Map<String, dynamic> json) {
    return CountryStatistic(
      country: json['country'],
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class VoiceActorStatistic {
  final Staff? voiceActor;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  VoiceActorStatistic({
    this.voiceActor,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory VoiceActorStatistic.fromJson(Map<String, dynamic> json) {
    return VoiceActorStatistic(
      voiceActor: json['voiceActor'] != null ? Staff.fromJson(json['voiceActor']) : null,
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voiceActor': voiceActor?.toJson(),
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class StaffStatistic {
  final Staff? staff;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  StaffStatistic({
    this.staff,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory StaffStatistic.fromJson(Map<String, dynamic> json) {
    return StaffStatistic(
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff': staff?.toJson(),
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}

class StudioStatistic {
  final Studio? studio;
  final int? count;
  final double? meanScore;
  final int? timeWatched;

  StudioStatistic({
    this.studio,
    this.count,
    this.meanScore,
    this.timeWatched,
  });

  factory StudioStatistic.fromJson(Map<String, dynamic> json) {
    return StudioStatistic(
      studio: json['studio'] != null ? Studio.fromJson(json['studio']) : null,
      count: json['count'],
      meanScore: json['meanScore']?.toDouble(),
      timeWatched: json['timeWatched'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studio': studio?.toJson(),
      'count': count,
      'meanScore': meanScore,
      'timeWatched': timeWatched,
    };
  }
}
