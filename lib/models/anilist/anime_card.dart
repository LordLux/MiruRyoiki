import 'package:miruryoiki/models/anilist/anime.dart';
import 'package:miruryoiki/services/anilist/queries/graphql/common/fragments.graphql.dart';

class AnimeCard {
  final int id;
  final AnilistTitle title;
  final String? coverImage;
  final String? dominantColor;
  final List<String> genres;
  final String? status;
  final String? format;
  final int? episodes;
  final int? seasonYear;
  final String? season;
  final int? averageScore;
  final int? meanScore;
  final int? popularity;
  final bool isAdult;
  final bool isFavourite;
  final AiringEpisode? nextAiringEpisode;
  final DateValue? startDate;

  const AnimeCard({
    required this.id,
    required this.title,
    this.coverImage,
    this.dominantColor,
    this.genres = const [],
    this.status,
    this.format,
    this.episodes,
    this.seasonYear,
    this.season,
    this.averageScore,
    this.meanScore,
    this.popularity,
    this.isAdult = false,
    this.isFavourite = false,
    this.nextAiringEpisode,
    this.startDate,
  });

  factory AnimeCard.fromFragment(Fragment$AnimeCard fragment) {
    return AnimeCard(
      id: fragment.id,
      title: AnilistTitle(
        romaji: fragment.title?.romaji,
        english: fragment.title?.english,
        native: fragment.title?.native,
        userPreferred: fragment.title?.userPreferred,
      ),
      coverImage: fragment.coverImage?.extraLarge ?? fragment.coverImage?.large,
      dominantColor: fragment.coverImage?.color,
      genres: fragment.genres?.whereType<String>().toList() ?? [],
      status: fragment.status?.name,
      format: fragment.format?.name,
      episodes: fragment.episodes,
      seasonYear: fragment.seasonYear,
      season: fragment.season?.name,
      averageScore: fragment.averageScore,
      meanScore: fragment.meanScore,
      popularity: fragment.popularity,
      isAdult: fragment.isAdult ?? false,
      isFavourite: fragment.isFavourite,
      nextAiringEpisode: fragment.nextAiringEpisode != null
          ? AiringEpisode(
              airingAt: fragment.nextAiringEpisode!.airingAt,
              episode: fragment.nextAiringEpisode!.episode,
              timeUntilAiring: fragment.nextAiringEpisode!.timeUntilAiring,
            )
          : null,
      startDate: fragment.startDate != null
          ? DateValue(
              year: fragment.startDate!.year,
              month: fragment.startDate!.month,
              day: fragment.startDate!.day,
            )
          : null,
    );
  }
}
