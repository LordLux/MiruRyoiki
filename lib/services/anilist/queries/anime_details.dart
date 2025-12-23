part of 'anilist_service.dart';

extension AnilistServiceAnimeDetails on AnilistService {
  /// Get simple anime information by ID
  Future<AnilistAnime?> getAnimeDetails(int id) async {
    final map = await getMultipleAnimesDetails([id]);
    return map[id];
  }

  /// Get extremely detailed anime information by ID
  Future<AnimeOverview?> getDetailedAnimeDetails(int id) async {
    if (_client == null) return null;

    logTrace('Fetching Anilist details for ID: $id');

    final result = await executeQuery<Query$GetAnimeOverview>(
      options: QueryOptions(
        document: documentNodeQueryGetAnimeOverview,
        variables: Variables$Query$GetAnimeOverview(id: id).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetAnimeOverview',
      parser: (data) => Query$GetAnimeOverview.fromJson(data),
    );

    if (result == null || result.Media == null) return null;

    return AnimeOverview.fromQuery(result.Media!);
  }

  /// Get multiple anime details
  Future<Map<int, AnilistAnime>> getMultipleAnimesDetails(List<int> ids) async {
    if (_client == null || ids.isEmpty) return {};

    logTrace('Fetching Anilist details for ID${ids.length > 1 ? 's' : ''}: ${ids.join(', ')}');

    final result = await executeQuery<Query$GetMultipleAnimeDetails>(
      options: QueryOptions(
        document: documentNodeQueryGetMultipleAnimeDetails,
        variables: Variables$Query$GetMultipleAnimeDetails(ids: ids).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetMultipleAnimeDetails',
      parser: (data) => Query$GetMultipleAnimeDetails.fromJson(data),
    );

    if (result == null || result.Page == null || result.Page!.media == null) return {};

    final Map<int, AnilistAnime> animeMap = {};

    for (final media in result.Page!.media!) {
      if (media == null) continue;
      
      final anime = AnilistAnime(
          id: media.id,
          title: AnilistTitle(
            romaji: media.title?.romaji,
            english: media.title?.english,
            native: media.title?.native,
            userPreferred: media.title?.userPreferred,
          ),
          posterImage: media.coverImage?.extraLarge ?? media.coverImage?.large,
          dominantColor: media.coverImage?.color,
          bannerImage: media.bannerImage,
          description: media.description,
          status: media.status?.toJson(),
          format: media.format?.toJson(),
          episodes: media.episodes,
          seasonYear: media.seasonYear,
          season: media.season?.toJson(),
          genres: media.genres?.whereType<String>().toList() ?? [],
          averageScore: media.averageScore,
          meanScore: media.meanScore,
          popularity: media.popularity,
          isFavourite: media.isFavourite,
          startDate: media.startDate != null ? DateValue(year: media.startDate!.year, month: media.startDate!.month, day: media.startDate!.day) : null,
          endDate: media.endDate != null ? DateValue(year: media.endDate!.year, month: media.endDate!.month, day: media.endDate!.day) : null,
          updatedAt: media.updatedAt,
          nextAiringEpisode: media.nextAiringEpisode != null ? AiringEpisode(airingAt: media.nextAiringEpisode!.airingAt, episode: media.nextAiringEpisode!.episode, timeUntilAiring: media.nextAiringEpisode!.timeUntilAiring) : null,
          siteUrl: media.siteUrl,
          rankings: media.rankings?.isNotEmpty == true ? media.rankings!.first?.rank : null,
          trending: media.trending,
      );
      
      animeMap[media.id] = anime;
    }

    return animeMap;
  }

  AnilistAnime convertFragmentToAnilistAnime(AnimeOverview fragment) {
    return AnilistAnime(
      id: fragment.id,
      title: fragment.title,
      posterImage: fragment.coverImage,
      dominantColor: fragment.dominantColor,
      bannerImage: fragment.bannerImage,
      description: fragment.description,
      status: fragment.status,
      format: fragment.format,
      episodes: fragment.episodes,
      seasonYear: fragment.seasonYear,
      season: fragment.season,
      genres: fragment.genres,
      averageScore: fragment.averageScore,
      meanScore: fragment.meanScore,
      popularity: fragment.popularity,
      isFavourite: fragment.isFavourite,
      startDate: fragment.startDate,
      endDate: fragment.endDate,
      updatedAt: fragment.updatedAt,
      nextAiringEpisode: fragment.nextAiringEpisode,
      siteUrl: fragment.siteUrl,
      rankings: fragment.rankings.isNotEmpty ? fragment.rankings.first.rank : null,
    );
  }

  /// Get user anime lists
  Future<Map<String, AnilistUserList>> getUserAnimeLists({String? userName, int? userId}) async {
    if (_client == null) return <String, AnilistUserList>{};

    if (userName == null && userId == null) {
      logWarn('No user identifier provided for fetching anime lists');
      return <String, AnilistUserList>{};
    }

    logTrace('Fetching anime lists from Anilist for user ${userName ?? userId}...');

    final result = await executeQuery<Query$GetUserAnimeLists>(
      options: QueryOptions(
        document: documentNodeQueryGetUserAnimeLists,
        variables: Variables$Query$GetUserAnimeLists(userName: userName, userId: userId).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetUserAnimeLists',
      parser: (data) => Query$GetUserAnimeLists.fromJson(data),
    );

    if (result == null || result.MediaListCollection == null) return <String, AnilistUserList>{};

    final Map<String, AnilistUserList> lists = <String, AnilistUserList>{};
    final collection = result.MediaListCollection!;
    final customListNames = collection.user?.mediaListOptions?.animeList?.customLists?.whereType<String>().toList();
    final standardLists = collection.lists ?? [];

    // Standard lists
    for (final list in standardLists) {
      if (list == null || list.status == null) continue;
      
      lists[list.status!.name] = AnilistUserList.fromJson(
        {'lists': [list.toJson()]},
        StatusStatistic.statusNameToPretty(list.status!.name),
        isCustomList: false,
      );
    }

    // Custom lists
    if (customListNames != null) {
      for (final customListName in customListNames) {
        final entriesForCustomList = [];
        for (final list in standardLists) {
          if (list == null || list.entries == null) continue;
          
          for (final entry in list.entries!) {
            if (entry == null) continue;
            
            final customListsData = entry.customLists;
            Map<String, dynamic>? entryCustomLists;

            if (customListsData != null) {
              try {
                entryCustomLists = jsonDecode(customListsData) as Map<String, dynamic>?;
              } catch (e) {
                // Ignore
              }
            }

            if (entryCustomLists != null && 
                entryCustomLists.containsKey(customListName) && 
                entryCustomLists[customListName] == true) {
              entriesForCustomList.add(entry.toJson());
            }
          }
        }

        if (entriesForCustomList.isNotEmpty) {
          lists['custom_$customListName'] = AnilistUserList.fromJson(
            {
              'lists': [
                {'entries': entriesForCustomList}
              ]
            },
            customListName,
            isCustomList: true,
          );
        }
      }
    }

    return lists;
  }

  /// Get upcoming episodes for a list of anime IDs
  Future<Map<int, AiringEpisode?>> getUpcomingEpisodes(List<int> animeIds) async {
    if (_client == null || animeIds.isEmpty) return <int, AiringEpisode?>{};

    final Map<int, AiringEpisode?> allResults = {};

    // Process in chunks of maxChunkSize to respect API limits
    const int maxChunkSize = 50;

    for (int i = 0; i < animeIds.length; i += maxChunkSize) {
      final chunkEnd = (i + maxChunkSize < animeIds.length) ? i + maxChunkSize : animeIds.length;
      final chunk = animeIds.sublist(i, chunkEnd);

      final result = await executeQuery<Query$GetUpcomingEpisodes>(
        options: QueryOptions(
          document: documentNodeQueryGetUpcomingEpisodes,
          variables: Variables$Query$GetUpcomingEpisodes(ids: chunk).toJson(),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'GetUpcomingEpisodes',
        parser: (data) => Query$GetUpcomingEpisodes.fromJson(data),
      );

      if (result != null && result.Page != null && result.Page!.media != null) {
        for (final media in result.Page!.media!) {
          if (media != null) {
            if (media.nextAiringEpisode != null) {
              allResults[media.id] = AiringEpisode(
                airingAt: media.nextAiringEpisode!.airingAt,
                episode: media.nextAiringEpisode!.episode,
                timeUntilAiring: media.nextAiringEpisode!.timeUntilAiring,
              );
            } else {
              allResults[media.id] = null;
            }
          }
        }
      }
    }
    return allResults;
  }

  /// Get episode titles for a specific anime
  Future<Map<int, String>> getEpisodeTitles(int animeId) async {
    final result = await getMultipleEpisodeTitles([animeId]);
    return result[animeId] ?? {};
  }

  /// Get episode titles for multiple anime IDs in batches
  Future<Map<int, Map<int, String>>> getMultipleEpisodeTitles(List<int> animeIds, {int perPage = 50}) async {
    if (_client == null || animeIds.isEmpty) return <int, Map<int, String>>{};

    final Map<int, Map<int, String>> allResults = {};

    // Process in chunks of maxChunkSize to respect API limits
    const int maxChunkSize = 50;

    for (int i = 0; i < animeIds.length; i += maxChunkSize) {
      final chunkEnd = (i + maxChunkSize < animeIds.length) ? i + maxChunkSize : animeIds.length;
      final chunk = animeIds.sublist(i, chunkEnd);

      final result = await executeQuery<Query$GetEpisodeTitles>(
        options: QueryOptions(
          document: documentNodeQueryGetEpisodeTitles,
          variables: Variables$Query$GetEpisodeTitles(ids: chunk).toJson(),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        operationName: 'GetEpisodeTitles',
        parser: (data) => Query$GetEpisodeTitles.fromJson(data),
      );

      if (result != null && result.Page != null && result.Page!.media != null) {
        for (final media in result.Page!.media!) {
          if (media != null && media.streamingEpisodes != null) {
            final Map<int, String> episodeTitles = {};
            for (final episode in media.streamingEpisodes!) {
              if (episode != null && episode.title != null) {
                final title = episode.title!;
                final match = RegExp(r'^Episode\s+(\d+)').firstMatch(title);
                if (match != null) {
                  final episodeNumber = int.tryParse(match.group(1)!);
                  if (episodeNumber != null) {
                    episodeTitles[episodeNumber] = title;
                  }
                }
              }
            }
            if (episodeTitles.isNotEmpty) {
              allResults[media.id] = episodeTitles;
            }
          }
        }
      }
    }
    return allResults;
  }
}
