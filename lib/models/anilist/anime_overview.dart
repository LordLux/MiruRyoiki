import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/models/anilist/anime_card.dart';
import 'package:miruryoiki/services/anilist/queries/graphql/anime/details.graphql.dart';
import 'package:miruryoiki/services/anilist/queries/graphql/common/fragments.graphql.dart';

class AnimeOverview extends AnimeCard {
  final String? bannerImage;
  final String? description;
  final DateValue? endDate;
  final int? trending;
  final int? favourites;
  final int? updatedAt;
  final String? siteUrl;
  final int? duration;
  final List<String> synonyms;
  final String? source;
  final String? hashtag;
  final bool isLocked;
  final bool isFavouriteBlocked;
  final String? countryOfOrigin;
  final bool isLicensed;
  final bool isRecommendationBlocked;
  final bool isReviewBlocked;
  final List<StreamingEpisode> streamingEpisodes;
  final Trailer? trailer;
  final List<AnimeTag> tags;
  final MediaListEntry? mediaListEntry;
  final List<StudioEdge> studios;
  // final List<ReviewNode> reviewPreview;
  final List<RelationEdge> relations;
  final List<AnimeRanking> rankings;
  final AnimeStats? stats;
  final List<CharacterEdge> characters;
  final List<StaffEdge> staff;
  final List<RecommendationNode> recommendations;
  final List<ExternalLink> externalLinks;
  final List<MediaListFollowing> following;

  const AnimeOverview({
    required super.id,
    required super.title,
    super.coverImage,
    super.dominantColor,
    super.genres,
    super.status,
    super.format,
    super.episodes,
    super.seasonYear,
    super.season,
    super.averageScore,
    super.meanScore,
    super.popularity,
    super.isAdult,
    super.isFavourite,
    super.nextAiringEpisode,
    super.startDate,
    this.bannerImage,
    this.description,
    this.endDate,
    this.trending,
    this.favourites,
    this.updatedAt,
    this.siteUrl,
    this.duration,
    this.synonyms = const [],
    this.source,
    this.hashtag,
    this.isLocked = false,
    this.isFavouriteBlocked = false,
    this.countryOfOrigin,
    this.isLicensed = false,
    this.isRecommendationBlocked = false,
    this.isReviewBlocked = false,
    this.streamingEpisodes = const [],
    this.trailer,
    this.tags = const [],
    this.mediaListEntry,
    this.studios = const [],
    // this.reviewPreview = const [],
    this.relations = const [],
    this.rankings = const [],
    this.stats,
    this.characters = const [],
    this.staff = const [],
    this.recommendations = const [],
    this.externalLinks = const [],
    this.following = const [],
  });

  factory AnimeOverview.fromQuery(Query$GetAnimeOverview data) {
    final media = data.Media!;
    return AnimeOverview(
      // AnimeCard fields
      id: media.id,
      title: AnilistTitle(
        romaji: media.title?.romaji,
        english: media.title?.english,
        native: media.title?.native,
        userPreferred: media.title?.userPreferred,
      ),
      coverImage: media.coverImage?.extraLarge ?? media.coverImage?.large,
      dominantColor: media.coverImage?.color,
      status: media.status?.name,
      format: media.format?.name,
      duration: media.duration,
      episodes: media.episodes,
      seasonYear: media.seasonYear,
      season: media.season?.name,
      averageScore: media.averageScore,
      meanScore: media.meanScore,
      popularity: media.popularity,
      isAdult: media.isAdult ?? false,
      isFavourite: media.isFavourite,
      nextAiringEpisode: media.nextAiringEpisode != null
          ? AiringEpisode(
              airingAt: media.nextAiringEpisode!.airingAt,
              episode: media.nextAiringEpisode!.episode,
              timeUntilAiring: media.nextAiringEpisode!.timeUntilAiring,
            )
          : null,
      startDate: media.startDate != null
          ? DateValue(
              year: media.startDate!.year,
              month: media.startDate!.month,
              day: media.startDate!.day,
            )
          : null,

      // AnimeOverview fields
      bannerImage: media.bannerImage,
      description: media.description,
      endDate: media.endDate != null
          ? DateValue(
              year: media.endDate!.year,
              month: media.endDate!.month,
              day: media.endDate!.day,
            )
          : null,
      genres: media.genres?.whereType<String>().toList() ?? [],
      trending: media.trending,
      favourites: media.favourites,
      updatedAt: media.updatedAt,
      siteUrl: media.siteUrl,
      synonyms: media.synonyms?.whereType<String>().toList() ?? [],
      source: media.source?.name,
      hashtag: media.hashtag,
      isLocked: media.isLocked ?? false,
      isFavouriteBlocked: media.isFavouriteBlocked,
      countryOfOrigin: media.countryOfOrigin.toString(),
      isLicensed: media.isLicensed ?? false,
      isRecommendationBlocked: media.isRecommendationBlocked ?? false,
      isReviewBlocked: media.isReviewBlocked ?? false,
      streamingEpisodes: media.streamingEpisodes //
              ?.whereType<Query$GetAnimeOverview$Media$streamingEpisodes>()
              .map((e) => StreamingEpisode.fromFragment(e))
              .toList() ??
          [],
      trailer: media.trailer != null ? Trailer.fromFragment(media.trailer!) : null,
      tags: media.tags //
              ?.whereType<Query$GetAnimeOverview$Media$tags>()
              .map((e) => AnimeTag.fromFragment(e))
              .toList() ??
          [],
      mediaListEntry: media.mediaListEntry != null ? MediaListEntry.fromFragment(media.mediaListEntry!) : null,
      studios: media.studios?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$studios$edges>()
              .map((e) => StudioEdge.fromFragment(e))
              .toList() ??
          [],
      // reviewPreview: media.reviewPreview?.nodes //
      //         ?.whereType<Query$GetAnimeOverview$Media$reviewPreview$nodes>()
      //         .map((e) => ReviewNode.fromFragment(e))
      //         .toList() ??
      //     [],
      relations: media.relations?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$relations$edges>()
              .map((e) => RelationEdge.fromFragment(e))
              .toList() ??
          [],
      rankings: media.rankings //
              ?.whereType<Query$GetAnimeOverview$Media$rankings>()
              .map((e) => AnimeRanking.fromFragment(e))
              .toList() ??
          [],
      stats: media.stats != null ? AnimeStats.fromFragment(media.stats!) : null,
      characters: media.characterPreview?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$characterPreview$edges>()
              .map((e) => CharacterEdge.fromFragment(e))
              .toList() ??
          [],
      staff: media.staffPreview?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$staffPreview$edges>()
              .map((e) => StaffEdge.fromFragment(e))
              .toList() ??
          [],
      recommendations: media.recommendations?.nodes //
              ?.whereType<Query$GetAnimeOverview$Media$recommendations$nodes>()
              .map((e) => RecommendationNode.fromFragment(e))
              .toList() ??
          [],
      externalLinks: media.externalLinks //
              ?.whereType<Query$GetAnimeOverview$Media$externalLinks>()
              .map((e) => ExternalLink.fromFragment(e))
              .toList() ??
          [],
      following: data.Page?.mediaList //
              ?.whereType<Query$GetAnimeOverview$Page$mediaList>()
              .map((e) => MediaListFollowing.fromFragment(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() => '''
    AnimeOverview(
      id: $id,
      title: $title,
      bannerImage: $bannerImage,
      description: ${description != null ? '[${description!.length} chars]' : 'null'},
      status: $status,
      format: $format,
      episodes: $episodes,
      seasonYear: $seasonYear,
      season: $season,
      averageScore: $averageScore,
      meanScore: $meanScore,
      popularity: $popularity,
      isAdult: $isAdult,
      isFavourite: $isFavourite,
      nextAiringEpisode: $nextAiringEpisode,
      startDate: $startDate,
      endDate: $endDate,
      trending: $trending,
      favourites: $favourites,
      updatedAt: $updatedAt,
      siteUrl: $siteUrl,
      duration: $duration,
      synonyms: $synonyms,
      source: $source,
      hashtag: $hashtag,
      isLocked: $isLocked,
      isFavouriteBlocked: $isFavouriteBlocked,
      countryOfOrigin: $countryOfOrigin,
      isLicensed: $isLicensed,
      isRecommendationBlocked: $isRecommendationBlocked,
      isReviewBlocked: $isReviewBlocked,
      streamingEpisodes count: ${streamingEpisodes.length},
      trailer: $trailer,
      tags count: ${tags.length},
      mediaListEntry: $mediaListEntry,
      studios count: ${studios.length},
      relations count: ${relations.length},
      rankings count: ${rankings.length},
      stats: $stats,
      characters count: ${characters.length},
      staff count: ${staff.length},
      recommendations count: ${recommendations.length},
      externalLinks count: ${externalLinks.length},
      following count: ${following.length},
    )
    ''';
}

class AnimeRanking {
  final int id;
  final int rank;
  final String type;
  final String format;
  final int? year;
  final String? season;
  final bool allTime;
  final String context;

  const AnimeRanking({
    required this.id,
    required this.rank,
    required this.type,
    required this.format,
    this.year,
    this.season,
    required this.allTime,
    required this.context,
  });

  factory AnimeRanking.fromFragment(Query$GetAnimeOverview$Media$rankings fragment) {
    return AnimeRanking(
      id: fragment.id,
      rank: fragment.rank,
      type: fragment.type.name,
      format: fragment.format.name,
      year: fragment.year,
      season: fragment.season?.name,
      allTime: fragment.allTime ?? false,
      context: fragment.context,
    );
  }
}

class AnimeStats {
  final List<StatusDistribution> statusDistribution;
  final List<ScoreDistribution> scoreDistribution;

  const AnimeStats({
    required this.statusDistribution,
    required this.scoreDistribution,
  });

  factory AnimeStats.fromFragment(Query$GetAnimeOverview$Media$stats fragment) {
    return AnimeStats(
      statusDistribution: fragment.statusDistribution //
              ?.whereType<Query$GetAnimeOverview$Media$stats$statusDistribution>()
              .map((e) => StatusDistribution(
                    status: e.status?.name ?? 'Unknown',
                    amount: e.amount ?? 0,
                  ))
              .toList() ??
          [],
      scoreDistribution: fragment.scoreDistribution //
              ?.whereType<Query$GetAnimeOverview$Media$stats$scoreDistribution>()
              .map((e) => ScoreDistribution(
                    score: e.score ?? 0,
                    amount: e.amount ?? 0,
                  ))
              .toList() ??
          [],
    );
  }
}

class StatusDistribution {
  final String status;
  final int amount;

  const StatusDistribution({required this.status, required this.amount});
}

class ScoreDistribution {
  final int score;
  final int amount;

  const ScoreDistribution({required this.score, required this.amount});
}

class CharacterEdge {
  final int id;
  final String? role;
  final String? name; // Character name from edge? No, usually on node.
  final CharacterCard? node;
  final List<StaffCard> voiceActors;

  const CharacterEdge({
    required this.id,
    this.role,
    this.name,
    this.node,
    this.voiceActors = const [],
  });

  factory CharacterEdge.fromFragment(Query$GetAnimeOverview$Media$characterPreview$edges fragment) {
    return CharacterEdge(
      id: fragment.id ?? 0,
      role: fragment.role?.name,
      name: fragment.name,
      node: fragment.node != null ? CharacterCard.fromFragment(fragment.node!) : null,
      voiceActors: fragment.voiceActors //
              ?.whereType<Fragment$StaffCard>()
              .map((e) => StaffCard.fromFragment(e))
              .toList() ??
          [],
    );
  }

  factory CharacterEdge.fromFullQuery(Query$GetAnimeCharacters$Media$characters$edges fragment) {
    return CharacterEdge(
      id: fragment.id ?? 0,
      role: fragment.role?.name,
      name: fragment.name,
      node: fragment.node != null ? CharacterCard.fromFragment(fragment.node!) : null,
      voiceActors: fragment.voiceActors //
              ?.whereType<Fragment$StaffCard>()
              .map((e) => StaffCard.fromFragment(e))
              .toList() ??
          [],
    );
  }
}

class StaffEdge {
  final int id;
  final String? role;
  final StaffCard? node;

  const StaffEdge({
    required this.id,
    this.role,
    this.node,
  });

  factory StaffEdge.fromFragment(Query$GetAnimeOverview$Media$staffPreview$edges fragment) {
    return StaffEdge(
      id: fragment.id ?? 0,
      role: fragment.role,
      node: fragment.node != null ? StaffCard.fromFragment(fragment.node!) : null,
    );
  }

  factory StaffEdge.fromFullQuery(Query$GetAnimeStaff$Media$staff$edges fragment) {
    return StaffEdge(
      id: fragment.id ?? 0,
      role: fragment.role,
      node: fragment.node != null ? StaffCard.fromFragment(fragment.node!) : null,
    );
  }
}

class RecommendationNode {
  final int id;
  final int? rating;
  final int? userRating;
  final AnimeCard? mediaRecommendation;
  final UserAvatar? user;

  const RecommendationNode({
    required this.id,
    this.rating,
    this.userRating,
    this.mediaRecommendation,
    this.user,
  });

  factory RecommendationNode.fromFragment(Query$GetAnimeOverview$Media$recommendations$nodes fragment) {
    return RecommendationNode(
      id: fragment.id,
      rating: fragment.rating,
      userRating: fragment.userRating?.name == 'NO_RATING' ? 0 : (fragment.userRating?.name == 'UP_VOTE' ? 1 : -1), // Simplified
      mediaRecommendation: fragment.mediaRecommendation != null //
          ? AnimeCard.fromFragment(fragment.mediaRecommendation!)
          : null,
      user: fragment.user != null ? UserAvatar.fromFragment(fragment.user!) : null,
    );
  }
}

class ExternalLink {
  final int id;
  final String site;
  final String? url;
  final String? type;
  final String? language;
  final String? color;
  final String? icon;
  final String? notes;
  final bool isDisabled;

  const ExternalLink({
    required this.id,
    required this.site,
    this.url,
    this.type,
    this.language,
    this.color,
    this.icon,
    this.notes,
    this.isDisabled = false,
  });

  factory ExternalLink.fromFragment(Query$GetAnimeOverview$Media$externalLinks fragment) {
    return ExternalLink(
      id: fragment.id,
      site: fragment.site,
      url: fragment.url,
      type: fragment.type?.name,
      language: fragment.language,
      color: fragment.color,
      icon: fragment.icon,
      notes: fragment.notes,
      isDisabled: fragment.isDisabled ?? false,
    );
  }
}

class StreamingEpisode {
  final String site;
  final String title;
  final String? thumbnail;
  final String? url;

  const StreamingEpisode({
    required this.site,
    required this.title,
    this.thumbnail,
    this.url,
  });

  factory StreamingEpisode.fromFragment(Query$GetAnimeOverview$Media$streamingEpisodes fragment) {
    return StreamingEpisode(
      site: fragment.site ?? '',
      title: fragment.title ?? '',
      thumbnail: fragment.thumbnail,
      url: fragment.url,
    );
  }
}

class Trailer {
  final String? id;
  final String? site;

  const Trailer({this.id, this.site});

  factory Trailer.fromFragment(Query$GetAnimeOverview$Media$trailer fragment) {
    return Trailer(
      id: fragment.id,
      site: fragment.site,
    );
  }
}

class AnimeTag {
  final int id;
  final String name;
  final String? description;
  final int? rank;
  final bool isMediaSpoiler;
  final bool isGeneralSpoiler;
  final int? userId;

  const AnimeTag({
    required this.id,
    required this.name,
    this.description,
    this.rank,
    this.isMediaSpoiler = false,
    this.isGeneralSpoiler = false,
    this.userId,
  });

  factory AnimeTag.fromFragment(Query$GetAnimeOverview$Media$tags fragment) {
    return AnimeTag(
      id: fragment.id,
      name: fragment.name,
      description: fragment.description,
      rank: fragment.rank,
      isMediaSpoiler: fragment.isMediaSpoiler ?? false,
      isGeneralSpoiler: fragment.isGeneralSpoiler ?? false,
      userId: fragment.userId,
    );
  }
}

class MediaListEntry {
  final int id;
  final String? status;
  final double? score;

  const MediaListEntry({
    required this.id,
    this.status,
    this.score,
  });

  factory MediaListEntry.fromFragment(Query$GetAnimeOverview$Media$mediaListEntry fragment) {
    return MediaListEntry(
      id: fragment.id,
      status: fragment.status?.name,
      score: fragment.score,
    );
  }
}

class StudioEdge {
  final bool isMain;
  final int id;
  final String name;

  const StudioEdge({
    required this.isMain,
    required this.id,
    required this.name,
  });

  factory StudioEdge.fromFragment(Query$GetAnimeOverview$Media$studios$edges fragment) {
    return StudioEdge(
      isMain: fragment.isMain,
      id: fragment.node?.id ?? 0,
      name: fragment.node?.name ?? '',
    );
  }
}

// class ReviewNode {
//   final int id;
//   final String? summary;
//   final int? rating;
//   final int? ratingAmount;
//   final UserAvatar? user;

//   const ReviewNode({
//     required this.id,
//     this.summary,
//     this.rating,
//     this.ratingAmount,
//     this.user,
//   });

//   factory ReviewNode.fromFragment(Query$GetAnimeOverview$Media$reviewPreview$nodes fragment) {
//     return ReviewNode(
//       id: fragment.id,
//       summary: fragment.summary,
//       rating: fragment.rating,
//       ratingAmount: fragment.ratingAmount,
//       user: fragment.user != null ? UserAvatar.fromFragment(fragment.user!) : null,
//     );
//   }
// }

class CharacterCard {
  final int id;
  final String? name;
  final String? image;

  const CharacterCard({required this.id, this.name, this.image});

  factory CharacterCard.fromFragment(Fragment$CharacterCard fragment) {
    return CharacterCard(
      id: fragment.id,
      name: fragment.name?.userPreferred,
      image: fragment.image?.large,
    );
  }
}

class StaffCard {
  final int id;
  final String? name;
  final String? image;
  final String? language;

  const StaffCard({required this.id, this.name, this.image, this.language});

  factory StaffCard.fromFragment(Fragment$StaffCard fragment) {
    return StaffCard(
      id: fragment.id,
      name: fragment.name?.userPreferred,
      image: fragment.image?.large,
      language: fragment.language,
    );
  }
}

class UserAvatar {
  final int id;
  final String name;
  final String? avatar;
  final int? donatorTier;
  final String? donatorBadge;

  const UserAvatar({
    required this.id,
    required this.name,
    this.avatar,
    this.donatorTier,
    this.donatorBadge,
  });

  factory UserAvatar.fromFragment(Fragment$UserAvatar fragment) {
    return UserAvatar(
      id: fragment.id,
      name: fragment.name,
      avatar: fragment.avatar?.large,
      donatorTier: fragment.donatorTier,
      donatorBadge: fragment.donatorBadge,
    );
  }
}

class RelationEdge {
  final int id;
  final MediaRelationType relationType;
  final AnimeCard? node;

  const RelationEdge({
    required this.id,
    this.relationType = MediaRelationType.unknown,
    this.node,
  });

  factory RelationEdge.fromFragment(Query$GetAnimeOverview$Media$relations$edges fragment) {
    return RelationEdge(
      id: fragment.id ?? 0,
      relationType: MediaRelationTypeX.fromString(fragment.relationType?.name),
      node: fragment.node != null ? AnimeCard.fromFragment(fragment.node!) : null,
    );
  }
}

class MediaListFollowing {
  final int id;
  final String? status;
  final double? score;
  final int? progress;
  final UserAvatar? user;

  const MediaListFollowing({
    required this.id,
    this.status,
    this.score,
    this.progress,
    this.user,
  });

  factory MediaListFollowing.fromFragment(Query$GetAnimeOverview$Page$mediaList fragment) {
    return MediaListFollowing(
      id: fragment.id,
      status: fragment.status?.name,
      score: fragment.score,
      progress: fragment.progress,
      user: fragment.user != null
          ? UserAvatar(
              id: fragment.user!.id,
              name: fragment.user!.name,
              avatar: fragment.user!.avatar?.large,
            )
          : null,
    );
  }
}

/// Social tab entry, representing another user's activity related to this anime
class MediaListSocial {
  final int id;
  final String? status;
  final double? score;
  final int? updatedAt;
  final UserAvatar? user;

  const MediaListSocial({
    required this.id,
    this.status,
    this.score,
    this.updatedAt,
    this.user,
  });

  factory MediaListSocial.fromFragment(Query$GetAnimeSocial$Page$mediaList fragment) {
    return MediaListSocial(
      id: fragment.id,
      status: fragment.status?.name,
      score: fragment.score,
      updatedAt: fragment.updatedAt,
      user: fragment.user != null
          ? UserAvatar(
              id: fragment.user!.id,
              name: fragment.user!.name,
              avatar: fragment.user!.avatar?.large,
              donatorTier: fragment.user!.donatorTier,
              donatorBadge: fragment.user!.donatorBadge,
            )
          : null,
    );
  }
}

/// A single data point from the media trend timeline
class AnimeTrend {
  final int date;
  final int? episode;
  final int? averageScore;
  final int? inProgress;
  final int trending;
  final int? popularity;

  const AnimeTrend({
    required this.date,
    this.episode,
    this.averageScore,
    this.inProgress,
    required this.trending,
    this.popularity,
  });

  factory AnimeTrend.fromFragment(Query$GetAnimeStats$Media$trends$nodes fragment) {
    return AnimeTrend(
      date: fragment.date,
      episode: fragment.episode,
      averageScore: fragment.averageScore,
      inProgress: fragment.inProgress,
      trending: fragment.trending,
      popularity: fragment.popularity,
    );
  }
}

/// Full stats data including trends
class AnimeStatsFull extends AnimeStats {
  final List<AnimeTrend> trends;

  const AnimeStatsFull({
    required super.statusDistribution,
    required super.scoreDistribution,
    required this.trends,
  });

  factory AnimeStatsFull.fromQuery(Query$GetAnimeStats$Media media) {
    final stats = media.stats;
    return AnimeStatsFull(
      statusDistribution: stats?.statusDistribution //
              ?.whereType<Query$GetAnimeStats$Media$stats$statusDistribution>()
              .map((e) => StatusDistribution(
                    status: e.status?.name ?? 'Unknown',
                    amount: e.amount ?? 0,
                  ))
              .toList() ??
          [],
      scoreDistribution: stats?.scoreDistribution //
              ?.whereType<Query$GetAnimeStats$Media$stats$scoreDistribution>()
              .map((e) => ScoreDistribution(
                    score: e.score ?? 0,
                    amount: e.amount ?? 0,
                  ))
              .toList() ??
          [],
      trends: media.trends?.nodes //
              ?.whereType<Query$GetAnimeStats$Media$trends$nodes>()
              .map((e) => AnimeTrend.fromFragment(e))
              .toList() ??
          [],
    );
  }
}
