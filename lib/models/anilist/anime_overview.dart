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
  final List<AnimeRanking> rankings;
  final AnimeStats? stats;
  final List<CharacterEdge> characters;
  final List<StaffEdge> staff;
  final List<RecommendationNode> recommendations;
  final List<ExternalLink> externalLinks;

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
    this.rankings = const [],
    this.stats,
    this.characters = const [],
    this.staff = const [],
    this.recommendations = const [],
    this.externalLinks = const [],
  });

  factory AnimeOverview.fromQuery(Query$GetAnimeOverview$Media data) {
    return AnimeOverview(
      // AnimeCard fields
      id: data.id,
      title: AnilistTitle(
        romaji: data.title?.romaji,
        english: data.title?.english,
        native: data.title?.native,
        userPreferred: data.title?.userPreferred,
      ),
      coverImage: data.coverImage?.extraLarge ?? data.coverImage?.large,
      dominantColor: data.coverImage?.color,
      status: data.status?.name,
      format: data.format?.name,
      episodes: data.episodes,
      seasonYear: data.seasonYear,
      season: data.season?.name,
      averageScore: data.averageScore,
      meanScore: data.meanScore,
      popularity: data.popularity,
      isAdult: data.isAdult ?? false,
      isFavourite: data.isFavourite,
      nextAiringEpisode: data.nextAiringEpisode != null
          ? AiringEpisode(
              airingAt: data.nextAiringEpisode!.airingAt,
              episode: data.nextAiringEpisode!.episode,
              timeUntilAiring: data.nextAiringEpisode!.timeUntilAiring,
            )
          : null,
      startDate: data.startDate != null
          ? DateValue(
              year: data.startDate!.year,
              month: data.startDate!.month,
              day: data.startDate!.day,
            )
          : null,

      // AnimeOverview fields
      bannerImage: data.bannerImage,
      description: data.description,
      endDate: data.endDate != null
          ? DateValue(
              year: data.endDate!.year,
              month: data.endDate!.month,
              day: data.endDate!.day,
            )
          : null,
      genres: data.genres?.whereType<String>().toList() ?? [],
      trending: data.trending,
      favourites: data.favourites,
      updatedAt: data.updatedAt,
      siteUrl: data.siteUrl,
      rankings: data.rankings //
              ?.whereType<Query$GetAnimeOverview$Media$rankings>()
              .map((e) => AnimeRanking.fromFragment(e))
              .toList() ??
          [],
      stats: data.stats != null ? AnimeStats.fromFragment(data.stats!) : null,
      characters: data.characterPreview?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$characterPreview$edges>()
              .map((e) => CharacterEdge.fromFragment(e))
              .toList() ??
          [],
      staff: data.staffPreview?.edges //
              ?.whereType<Query$GetAnimeOverview$Media$staffPreview$edges>()
              .map((e) => StaffEdge.fromFragment(e))
              .toList() ??
          [],
      recommendations: data.recommendations?.nodes //
              ?.whereType<Query$GetAnimeOverview$Media$recommendations$nodes>()
              .map((e) => RecommendationNode.fromFragment(e))
              .toList() ??
          [],
      externalLinks: data.externalLinks //
              ?.whereType<Query$GetAnimeOverview$Media$externalLinks>()
              .map((e) => ExternalLink.fromFragment(e))
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
      rankings count: ${rankings.length},
      stats: $stats,
      characters count: ${characters.length},
      staff count: ${staff.length},
      recommendations count: ${recommendations.length},
      externalLinks count: ${externalLinks.length},
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
