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
  });

  factory AnilistAnime.fromJson(Map<String, dynamic> json) {
    return AnilistAnime(
      id: json['id'] as int,
      bannerImage: json['bannerImage'] as String?,
      posterImage: json['coverImage'] != null ? json['coverImage']['extraLarge'] as String? : null,
      dominantColor: json['coverImage'] != null ? json['coverImage']['color'] as String? : null,
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
    );
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
}
