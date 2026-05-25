import 'package:graphql/client.dart';
import 'package:miruryoiki/models/anilist/user_list.dart';
import 'package:miruryoiki/services/anilist/queries/anilist_service.dart';

/// Helpers for resetting AniList account state to a known blank slate.
///
/// Each real-API test category uses only the helpers relevant to it
/// (e.g. mutation tests call [ensureEntryAbsent] / [ensureEntryWithStatus];
/// a full wipe is available via [wipeAccount] for an optional global setup).
///
/// All network calls go through [AnilistService] or the shared [GraphQLClient]
/// that already has [RateLimitLink] in its chain, so rate limiting is automatic.
class AccountReset {
  final AnilistService _service;
  final GraphQLClient _client;
  final int _userId;

  AccountReset({
    required AnilistService service,
    required GraphQLClient client,
    required int userId,
  })  : _service = service,
        _client = client,
        _userId = userId;

  // ── Scoped helpers ──────────────────────────────────────────────────────────

  /// Ensure no list entry exists for [mediaId].
  ///
  /// Fetches the current entry (if any) and deletes it.
  Future<void> ensureEntryAbsent(int mediaId) async {
    final json = await _service.getMediaListEntry(mediaId, _userId);
    if (json == null) return;
    final entryId = json['id'] as int?;
    if (entryId != null) await _service.deleteMediaListEntry(entryId);
  }

  /// Ensure an entry exists for [mediaId] with the given [status].
  ///
  /// Creates it if absent, updates the status if it differs.
  Future<void> ensureEntryWithStatus(int mediaId, AnilistListApiStatus status) async {
    final json = await _service.getMediaListEntry(mediaId, _userId);
    if (json == null) {
      await _service.saveMediaListEntry(mediaId: mediaId, status: status);
      return;
    }
    final currentStatus = (json['status'] as String?)?.toListStatus();
    if (currentStatus != status) {
      await _service.saveMediaListEntry(mediaId: mediaId, status: status);
    }
  }

  /// Reset all mutable fields of an entry to their defaults while preserving
  /// the list [status].
  ///
  /// Sends an explicit mutation with empty notes, zero score, and null dates
  /// to guarantee AniList stores blank values (not whatever was there before).
  Future<void> resetEntryFields(int mediaId, {AnilistListApiStatus status = AnilistListApiStatus.PLANNING}) async {
    await _service.saveMediaListEntry(
      mediaId: mediaId,
      status: status,
      scoreRaw: 0,
      progress: 0,
      repeat: 0,
      notes: '',
      private: false,
      hiddenFromStatusLists: false,
      customLists: [],
    );
    // AniList doesn't clear dates via the service wrapper (null DateValue is
    // omitted from the request).  Use a raw mutation to force null dates.
    await _rawMutate(
      r'''
      mutation($mediaId: Int, $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput) {
        SaveMediaListEntry(mediaId: $mediaId, startedAt: $startedAt, completedAt: $completedAt) { id }
      }
      ''',
      {
        'mediaId': mediaId,
        'startedAt': {'year': null, 'month': null, 'day': null},
        'completedAt': {'year': null, 'month': null, 'day': null},
      },
    );
  }

  /// Ensure [mediaId] is not in the user's favourites.
  Future<void> ensureNotFavourite(int mediaId) async {
    final anime = await _service.getAnimeDetails(mediaId);
    if (anime?.isFavourite == true) await _service.toggleFavourite(mediaId);
  }

  /// Ensure a custom list named [name] exists in the user's anime list options.
  Future<void> ensureCustomListExists(String name) async {
    final existing = await _fetchCustomListNames();
    if (existing.contains(name)) return;
    await _rawMutate(
      r'mutation($lists: [String]) { UpdateUser(animeListOptions: {customLists: $lists}) { id } }',
      {'lists': [...existing, name]},
    );
  }

  /// Delete a custom list by [name] (no-op if it doesn't exist).
  Future<void> deleteCustomList(String name) async {
    final existing = await _fetchCustomListNames();
    if (!existing.contains(name)) return;
    await _rawMutate(
      r'mutation($list: String, $type: MediaType) { DeleteCustomList(customList: $list, type: $type) { deleted } }',
      {'list': name, 'type': 'ANIME'},
    );
  }

  // ── Full wipe ───────────────────────────────────────────────────────────────

  /// Delete every list entry, custom list, and unfavourite all anime on the account.
  ///
  /// Only call this in a global setUpAll for a fully disposable debug account.
  Future<void> wipeAccount() async {
    await _deleteAllListEntries();
    await _deleteAllCustomLists();
    // Favourites are left intact — querying/toggling all favourites is expensive
    // and they don't affect list-entry tests.
  }

  Future<void> _deleteAllListEntries() async {
    final allLists = await _service.getUserAnimeLists(userId: _userId);
    for (final list in allLists.values) {
      if (list.isCustomList) continue; // entries already covered by status lists
      for (final entry in list.entries) {
        await _service.deleteMediaListEntry(entry.id);
      }
    }
  }

  Future<void> _deleteAllCustomLists() async {
    final names = await _fetchCustomListNames();
    for (final name in names) {
      await _rawMutate(
        r'mutation($list: String, $type: MediaType) { DeleteCustomList(customList: $list, type: $type) { deleted } }',
        {'list': name, 'type': 'ANIME'},
      );
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<List<String>> _fetchCustomListNames() async {
    final result = await _client.query(QueryOptions(
      document: gql(
        r'query { Viewer { mediaListOptions { animeList { customLists } } } }',
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    return (result.data?['Viewer']?['mediaListOptions']?['animeList']?['customLists'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
  }

  /// Execute a raw GraphQL mutation, retrying once on 429.
  Future<QueryResult<Object?>> _rawMutate(String mutation, Map<String, dynamic> variables) async {
    var result = await _client.mutate(MutationOptions(
      document: gql(mutation),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    if (result.hasException) {
      final headers = result.context.entry<HttpLinkResponseContext>()?.headers ?? {};
      final retryAfter = headers['retry-after'] ?? headers['Retry-After'];
      if (retryAfter != null) {
        final wait = int.tryParse(retryAfter) ?? 62;
        await Future.delayed(Duration(seconds: wait + 1));
        result = await _client.mutate(MutationOptions(
          document: gql(mutation),
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly,
        ));
      }
    }

    return result;
  }
}
