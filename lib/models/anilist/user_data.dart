import 'package:miruryoiki/enums.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import '../../manager.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/anilist/queries/anilist_service.dart';
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
  final AnilistStats? stats;

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
    this.stats,
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
      stats: json['stats'] != null ? AnilistStats.fromJson(json['stats']) : null,
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
      'stats': stats?.toJson(),
    };
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    return Object.hash(
      options?.uiChangeHashCode,
      mediaStatistics?.uiChangeHashCode,
      favourites?.uiChangeHashCode,
      statistics?.uiChangeHashCode,
      donatorTier.hashCode,
      donatorBadge.hashCode,
      stats?.uiChangeHashCode,
    );
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

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    return Object.hash(
      titleLanguage,
      profileColor,
      staffNameLanguage,
    );
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

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode => hashCode; // All properties affect UI
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

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode => anime?.uiChangeHashCode ?? 0;
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

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    return Object.hash(
      anime?.uiChangeHashCode,
      characters?.uiChangeHashCode,
      staff?.uiChangeHashCode,
      studios?.uiChangeHashCode,
    );
  }
}

abstract class FavouriteCollection<T> {
  final List<T>? nodes;

  FavouriteCollection({this.nodes});

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes?.map((x) => (x as dynamic).toJson()).toList(),
    };
  }
}

class FavouriteAnime extends FavouriteCollection<AnilistAnime> {
  FavouriteAnime({super.nodes});

  factory FavouriteAnime.fromJson(Map<String, dynamic> json) {
    return FavouriteAnime(
      nodes: json['nodes'] != null ? List<AnilistAnime>.from(json['nodes'].map((x) => AnilistAnime.fromJson(x))) : null,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    if (nodes == null) return 0;
    int hash = 0;
    for (final anime in nodes!) {
      hash = Object.hash(hash, anime.uiChangeHashCode);
    }
    return hash;
  }
}

class FavouriteCharacters extends FavouriteCollection<Character> {
  FavouriteCharacters({super.nodes});

  factory FavouriteCharacters.fromJson(Map<String, dynamic> json) {
    return FavouriteCharacters(
      nodes: json['nodes'] != null ? List<Character>.from(json['nodes'].map((x) => Character.fromJson(x))) : null,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    if (nodes == null) return 0;
    int hash = 0;
    for (final character in nodes!) {
      hash = Object.hash(hash, character.id);
    }
    return hash;
  }
}

class Character {
  final int? id;
  final CharacterName? name;
  final CharacterImage? image;
  final String? siteUrl;

  Character({
    this.id,
    this.name,
    this.image,
    this.siteUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'] != null ? CharacterName.fromJson(json['name']) : null,
      image: json['image'] != null ? CharacterImage.fromJson(json['image']) : null,
      siteUrl: json['siteUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
      'image': image?.toJson(),
      'siteUrl': siteUrl,
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

class FavouriteStaff extends FavouriteCollection<Staff> {
  FavouriteStaff({super.nodes});

  factory FavouriteStaff.fromJson(Map<String, dynamic> json) {
    return FavouriteStaff(
      nodes: json['nodes'] != null ? List<Staff>.from(json['nodes'].map((x) => Staff.fromJson(x))) : null,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    if (nodes == null) return 0;
    int hash = 0;
    for (final staff in nodes!) {
      hash = Object.hash(hash, staff.id);
    }
    return hash;
  }
}

class Staff {
  final int? id;
  final CharacterName? name;
  final CharacterImage? image;
  final String? siteUrl;

  Staff({
    this.id,
    this.name,
    this.image,
    this.siteUrl,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'] != null ? CharacterName.fromJson(json['name']) : null,
      image: json['image'] != null ? CharacterImage.fromJson(json['image']) : null,
      siteUrl: json['siteUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name?.toJson(),
      'image': image?.toJson(),
      'siteUrl': siteUrl,
    };
  }
}

class FavouriteStudios extends FavouriteCollection<Studio> {
  FavouriteStudios({super.nodes});

  factory FavouriteStudios.fromJson(Map<String, dynamic> json) {
    return FavouriteStudios(
      nodes: json['nodes'] != null ? List<Studio>.from(json['nodes'].map((x) => Studio.fromJson(x))) : null,
    );
  }

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode {
    if (nodes == null) return 0;
    int hash = 0;
    for (final studio in nodes!) {
      hash = Object.hash(hash, studio.id);
    }
    return hash;
  }
}

class Studio {
  final int? id;
  final String? name;
  final String? siteUrl;

  Studio({
    this.id,
    this.name,
    this.siteUrl,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['id'],
      name: json['name'],
      siteUrl: json['siteUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'siteUrl': siteUrl,
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

  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode => anime?.uiChangeHashCode ?? 0;
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

  String? get formatPretty {
    if (format?.toLowerCase() == 'tv') return 'TV';
    if (format?.toLowerCase() == 'movie') return 'Movie';
    if (format?.toLowerCase() == 'ova') return 'OVA';
    if (format?.toLowerCase() == 'ona') return 'ONA';
    return format?.titleCase;
  }

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

  String? get statusPretty => statusNameToPretty(status ?? '');

  String? get statusApi => statusNameToApi(statusPretty ?? '');

  // Helper method to convert display names to API names
  static String statusNameToApi(String listName) {
    if (listName == AnilistService.statusListNamesPretty[0]) return AnilistService.statusListNamesApi[0]; // Watching -> CURRENT
    if (listName == AnilistService.statusListNamesPretty[1]) return AnilistService.statusListNamesApi[1]; // Completed -> COMPLETED
    if (listName == AnilistService.statusListNamesPretty[2]) return AnilistService.statusListNamesApi[2]; // Plan to Watch -> PLANNING
    if (listName == AnilistService.statusListNamesPretty[3]) return AnilistService.statusListNamesApi[3]; // Dropped -> DROPPED
    if (listName == AnilistService.statusListNamesPretty[4]) return AnilistService.statusListNamesApi[4]; // On Hold -> PAUSED
    if (listName == AnilistService.statusListNamesPretty[5]) return AnilistService.statusListNamesApi[5]; // Rewatching -> REPEATING
    if (listName == 'Unlinked') return AnilistService.statusListNameUnlinked;
    // If already has the custom_ prefix, return as-is (already API format)
    if (listName.startsWith(AnilistService.statusListPrefixCustom)) return listName;
    // Otherwise, assume it's a custom list display name and add the prefix
    return '${AnilistService.statusListPrefixCustom}$listName';
  }

  static String statusNameToPretty(String displayName) {
    if (displayName == AnilistService.statusListNamesApi[0]) return AnilistService.statusListNamesPretty[0]; // CURRENT -> Watching
    if (displayName == AnilistService.statusListNamesApi[1]) return AnilistService.statusListNamesPretty[1]; // COMPLETED -> Completed
    if (displayName == AnilistService.statusListNamesApi[2]) return AnilistService.statusListNamesPretty[2]; // PLANNING -> Plan to Watch
    if (displayName == AnilistService.statusListNamesApi[3]) return AnilistService.statusListNamesPretty[3]; // DROPPED -> Dropped
    if (displayName == AnilistService.statusListNamesApi[4]) return AnilistService.statusListNamesPretty[4]; // PAUSED -> On Hold
    if (displayName == AnilistService.statusListNamesApi[5]) return AnilistService.statusListNamesPretty[5]; // REPEATING -> Rewatching
    if (displayName == AnilistService.statusListNameUnlinked) return 'Unlinked';
    if (displayName.startsWith(AnilistService.statusListPrefixCustom)) return displayName.substring(7); // Remove 'custom_' prefix

    // Check if it might be a custom list
    final customLists = Provider.of<AnilistProvider>(Manager.context, listen: false).userLists.keys.where((k) => k.startsWith(AnilistService.statusListPrefixCustom));
    for (final customList in customLists) {
      if (statusNameToApi(customList) == displayName) return customList;
    }
    return displayName;
  }

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

class AnilistActivityHistory {
  final int date;
  final int amount;
  final int level;

  AnilistActivityHistory({
    required this.date,
    required this.amount,
    required this.level,
  });

  String get datePretty => DateTime.fromMillisecondsSinceEpoch(date * 1000).pretty();

  factory AnilistActivityHistory.fromJson(Map<String, dynamic> json) {
    return AnilistActivityHistory(
      date: json['date'] as int,
      amount: json['amount'] as int,
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'level': level,
    };
  }
}

class AnilistStats {
  final List<AnilistActivityHistory> activityHistory;

  AnilistStats({
    required this.activityHistory,
  });

  factory AnilistStats.fromJson(Map<String, dynamic> json) {
    final activityHistoryJson = json['activityHistory'] as List<dynamic>;
    return AnilistStats(
      activityHistory: activityHistoryJson.map((item) => AnilistActivityHistory.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityHistory': activityHistory.map((item) => item.toJson()).toList(),
    };
  }
  
  /// Hash code for UI-affecting properties only
  int get uiChangeHashCode => activityHistory.hashCode;
}
