part of 'queries/anilist_service.dart';

extension AnilistServiceNotifications on AnilistService {
  // GraphQL query for fetching notifications
  static const String _notificationsQuery = '''
    query GetNotifications(\$page: Int = 1, \$perPage: Int = 25, \$type_in: [NotificationType]) {
      Page(page: \$page, perPage: \$perPage) {
        pageInfo {
          total
          currentPage
          lastPage
          hasNextPage
          perPage
        }
        notifications(type_in: \$type_in) {
          ... on AiringNotification {
            id
            type
            animeId
            episode
            contexts
            createdAt
            media {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              type
              format
              episodes
            }
          }
          ... on RelatedMediaAdditionNotification {
            id
            type
            mediaId
            context
            createdAt
            media {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              type
              format
              episodes
            }
          }
          ... on MediaDataChangeNotification {
            id
            type
            mediaId
            context
            reason
            createdAt
            media {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              type
              format
              episodes
            }
          }
          ... on MediaMergeNotification {
            id
            type
            mediaId
            deletedMediaTitles
            context
            reason
            createdAt
            media {
              id
              title {
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              type
              format
              episodes
            }
          }
          ... on MediaDeletionNotification {
            id
            type
            deletedMediaTitle
            context
            reason
            createdAt
          }
        }
      }
    }
  ''';

  // Fetch notifications from Anilist API
  Future<List<AnilistNotification>> fetchNotifications({
    int page = 1,
    int perPage = 25,
    List<NotificationType>? types,
    bool force = false, // bypass throttle when true (used by sync/pagination)
  }) async {
    if (!isLoggedIn) {
      throw Exception('User is not authenticated with Anilist');
    }

    // Throttle: if last fetch within 5s with same parameters, return cached
    final withinWindow = _lastNotificationsFetchAt != null && now.difference(_lastNotificationsFetchAt!).inSeconds < 5;
    final sameParams = _lastNotificationsPage == page && _lastNotificationsPerPage == perPage && _compareNotificationTypeLists(_lastNotificationsTypes, types);
    if (!force && withinWindow && sameParams && _lastNotificationsCache != null) {
      return _lastNotificationsCache!;
    }

    // Access the GraphQL client directly since we're an extension
    final client = _client;
    if (client == null) throw Exception('GraphQL client not initialized');

    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    // Add type filter if specified
    if (types != null && types.isNotEmpty) {
      variables['type_in'] = types.map((type) => type.name.toUpperCase()).toList();
    }

    try {
      final result = await RetryUtils.retry<QueryResult>(
        () async {
          return await client.query(
            QueryOptions(
              document: gql(_notificationsQuery),
              variables: variables,
              fetchPolicy: FetchPolicy.noCache,
            ),
          );
        },
        maxRetries: 3,
        retryIf: RetryUtils.shouldRetryAnilistError,
        operationName: 'getNotifications(page: $page, perPage: $perPage)',
      );

      if (result == null || result.hasException) throw Exception('Failed to fetch notifications: ${result?.exception}');

      final notificationsData = result.data?['Page']?['notifications'] as List<dynamic>? ?? [];
      final notifications = <AnilistNotification>[];

      for (final notificationJson in notificationsData) {
        final notification = _parseNotification(notificationJson as Map<String, dynamic>);
        if (notification != null) {
          notifications.add(notification);
        }
      }

      // Save cache & metadata
      _lastNotificationsFetchAt = DateTime.now();
      _lastNotificationsCache = notifications;
      _lastNotificationsPage = page;
      _lastNotificationsPerPage = perPage;
      _lastNotificationsTypes = types == null ? null : List.of(types);
      return notifications;
    } catch (e) {
      logErr('Error fetching notifications from Anilist', e);
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  bool _compareNotificationTypeLists(List<NotificationType>? a, List<NotificationType>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Parse notification JSON from Anilist API
  AnilistNotification? _parseNotification(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    if (typeStr == null) return null;

    final notificationType = _parseNotificationType(typeStr);
    if (notificationType == null) return null;

    final id = json['id'] as int?;
    final createdAt = json['createdAt'] as int?;

    if (id == null || createdAt == null) return null;

    // Parse media info if available
    MediaInfo? mediaInfo;
    final mediaJson = json['media'] as Map<String, dynamic>?;
    if (mediaJson != null) {
      mediaInfo = _parseMediaInfo(mediaJson);
    }

    switch (notificationType) {
      case NotificationType.AIRING:
        final animeId = json['animeId'] as int? ?? 0;
        final episode = json['episode'] as int? ?? 0;
        final contexts = (json['contexts'] as List<dynamic>?)?.cast<String>() ?? [];

        return AiringNotification(
          id: id,
          type: notificationType,
          createdAt: createdAt,
          animeId: animeId,
          episode: episode,
          contexts: contexts,
          media: mediaInfo,
        );
      case NotificationType.RELATED_MEDIA_ADDITION:
        final mediaId = json['mediaId'] as int? ?? 0;
        final context = json['context'] as String?;

        return RelatedMediaAdditionNotification(
          id: id,
          type: notificationType,
          createdAt: createdAt,
          mediaId: mediaId,
          context: context,
          media: mediaInfo,
        );

      case NotificationType.MEDIA_DATA_CHANGE:
        final mediaId = json['mediaId'] as int? ?? 0;
        final context = json['context'] as String?;
        final reason = json['reason'] as String?;

        return MediaDataChangeNotification(
          id: id,
          type: notificationType,
          createdAt: createdAt,
          mediaId: mediaId,
          context: context,
          reason: reason,
          media: mediaInfo,
        );

      case NotificationType.MEDIA_MERGE:
        final mediaId = json['mediaId'] as int? ?? 0;
        final deletedMediaTitles = (json['deletedMediaTitles'] as List<dynamic>?)?.cast<String>() ?? [];
        final context = json['context'] as String?;
        final reason = json['reason'] as String?;

        return MediaMergeNotification(
          id: id,
          type: notificationType,
          createdAt: createdAt,
          mediaId: mediaId,
          deletedMediaTitles: deletedMediaTitles,
          context: context,
          reason: reason,
          media: mediaInfo,
        );

      case NotificationType.MEDIA_DELETION:
        final deletedMediaTitle = json['deletedMediaTitle'] as String?;
        final context = json['context'] as String?;
        final reason = json['reason'] as String?;

        return MediaDeletionNotification(
          id: id,
          type: notificationType,
          createdAt: createdAt,
          deletedMediaTitle: deletedMediaTitle,
          context: context,
          reason: reason,
        );
    }
  }

  // Parse notification type from string
  NotificationType? _parseNotificationType(String typeStr) {
    switch (typeStr.toUpperCase()) {
      case 'AIRING':
        return NotificationType.AIRING;
      case 'RELATED_MEDIA_ADDITION':
        return NotificationType.RELATED_MEDIA_ADDITION;
      case 'MEDIA_DATA_CHANGE':
        return NotificationType.MEDIA_DATA_CHANGE;
      case 'MEDIA_MERGE':
        return NotificationType.MEDIA_MERGE;
      case 'MEDIA_DELETION':
        return NotificationType.MEDIA_DELETION;
      default:
        return null;
    }
  }

  // Parse media info from JSON
  MediaInfo _parseMediaInfo(Map<String, dynamic> json) {
    final id = json['id'] as int;

    // Extract title (prefer English, fallback to romaji, then native)
    final titleJson = json['title'] as Map<String, dynamic>?;
    String? title;
    if (titleJson != null) {
      title = titleJson['english'] as String? ?? titleJson['romaji'] as String? ?? titleJson['native'] as String?;
    }

    // Extract cover image
    final coverImageJson = json['coverImage'] as Map<String, dynamic>?;
    String? coverImage;
    if (coverImageJson != null) {
      coverImage = coverImageJson['large'] as String? ?? coverImageJson['medium'] as String?;
    }

    return MediaInfo(
      id: id,
      title: title,
      coverImage: coverImage,
      type: json['type'] as String?,
      format: json['format'] as String?,
      episodes: json['episodes'] as int?,
    );
  }

  // Sync notifications from Anilist and update local database
  Future<List<AnilistNotification>> syncNotifications({
    required AppDatabase database,
    List<NotificationType>? types,
    int maxPages = 3,
  }) async {
    // If a sync is in progress, return the same future with timeout
    if (_notificationsSyncCompleter != null) {
      try {
        return await _notificationsSyncCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Reset the completer on timeout and retry
            _notificationsSyncCompleter = null;
            return syncNotifications(
              database: database,
              types: types,
              maxPages: maxPages,
            );
          },
        );
      } catch (e) {
        // If timeout or other error, reset completer and continue
        _notificationsSyncCompleter = null;
        rethrow;
      }
    }

    // Throttle full syncs: if last completed within 5s, just return cached (if any)
    if (_lastNotificationsSyncAt != null && now.difference(_lastNotificationsSyncAt!).inSeconds < 5) {
      if (_lastNotificationsCache != null) return _lastNotificationsCache!;
    }

    _notificationsSyncCompleter = Completer<List<AnilistNotification>>();

    try {
      final allNotifications = <AnilistNotification>[];
      final notificationsDao = database.notificationsDao;

    // Fetch notifications from multiple pages
    for (int page = 1; page <= maxPages; page++) {
      try {
        final notifications = await fetchNotifications(
          page: page,
          perPage: 25,
          types: types,
          force: true, // ensure paging not blocked by throttle
        );

        if (notifications.isEmpty) break;
        allNotifications.addAll(notifications);

        // If we got less than the requested per page, we've reached the end
        if (notifications.length < 25) break;
      } catch (e) {
        // If we fail on a subsequent page, return what we have so far
        if (page > 1) break;
        rethrow;
      }
    }

    // Before writing, merge existing read state from DB so we don't regress isRead
    if (allNotifications.isNotEmpty) {
      final existing = await notificationsDao.getNotificationsByIds(allNotifications.map((n) => n.id).toList());
      final readIds = existing.where((e) => e.isRead).map((e) => e.id).toSet();
      for (int i = 0; i < allNotifications.length; i++) {
        final n = allNotifications[i];
        if (readIds.contains(n.id) && !n.isRead) {
          switch (n) {
            case AiringNotification airing:
              allNotifications[i] = airing.copyWith(isRead: true);
            case RelatedMediaAdditionNotification related:
              allNotifications[i] = related.copyWith(isRead: true);
            case MediaDataChangeNotification dataChange:
              allNotifications[i] = dataChange.copyWith(isRead: true);
            case MediaMergeNotification merge:
              allNotifications[i] = merge.copyWith(isRead: true);
            case MediaDeletionNotification deletion:
              allNotifications[i] = deletion.copyWith(isRead: true);
          }
        }
      }

      await notificationsDao.upsertNotifications(allNotifications);
      await notificationsDao.deleteOldNotifications(keepCount: 200); // cleanup
    }

      _lastNotificationsSyncAt = DateTime.now();
      _lastNotificationsCache = allNotifications; // cache entire result set for popup usage
      _notificationsSyncCompleter!.complete(allNotifications);
      _notificationsSyncCompleter = null;
      return allNotifications;
    } catch (e) {
      // Ensure completer is always cleaned up on error
      if (_notificationsSyncCompleter != null && !_notificationsSyncCompleter!.isCompleted) {
        _notificationsSyncCompleter!.completeError(e);
      }
      _notificationsSyncCompleter = null;
      rethrow;
    }
  }

  // Get cached notifications from local database
  Future<List<AnilistNotification>> getCachedNotifications({
    required AppDatabase database,
    int limit = 25,
  }) async {
    final notificationsDao = database.notificationsDao;
    final dataList = await notificationsDao.getRecentNotifications(limit: limit);

    final notifications = <AnilistNotification>[];
    for (final data in dataList) {
      final notification = NotificationsDao.dataToNotification(data);
      if (notification != null) {
        notifications.add(notification);
      }
    }

    // Also if there is in-memory cache from latest sync, overlay its isRead states (in case user read after cache write)
    if (_lastNotificationsCache != null && _lastNotificationsCache!.isNotEmpty) {
      final cacheMap = {for (final n in _lastNotificationsCache!) n.id: n.isRead};
      for (int i = 0; i < notifications.length; i++) {
        final current = notifications[i];
        final cachedRead = cacheMap[current.id];
        if (cachedRead == true && !current.isRead) {
          switch (current) {
            case AiringNotification airing:
              notifications[i] = airing.copyWith(isRead: true);
            case RelatedMediaAdditionNotification related:
              notifications[i] = related.copyWith(isRead: true);
            case MediaDataChangeNotification dataChange:
              notifications[i] = dataChange.copyWith(isRead: true);
            case MediaMergeNotification merge:
              notifications[i] = merge.copyWith(isRead: true);
            case MediaDeletionNotification deletion:
              notifications[i] = deletion.copyWith(isRead: true);
          }
        }
      }
    }

    return notifications;
  }

  // Get unread notifications count
  Future<int> getUnreadCount(AppDatabase database) {
    final notificationsDao = database.notificationsDao;
    return notificationsDao.getUnreadCount();
  }

  // Mark notification as read
  Future<void> markAsRead(AppDatabase database, int notificationId) {
    final notificationsDao = database.notificationsDao;
    // Update in-memory cache immediately
    if (_lastNotificationsCache != null) {
      for (int i = 0; i < _lastNotificationsCache!.length; i++) {
        if (_lastNotificationsCache![i].id == notificationId) {
          final n = _lastNotificationsCache![i];
          switch (n) {
            case AiringNotification airing:
              _lastNotificationsCache![i] = airing.copyWith(isRead: true);
            case MediaDataChangeNotification dataChange:
              _lastNotificationsCache![i] = dataChange.copyWith(isRead: true);
            case MediaMergeNotification merge:
              _lastNotificationsCache![i] = merge.copyWith(isRead: true);
            case MediaDeletionNotification deletion:
              _lastNotificationsCache![i] = deletion.copyWith(isRead: true);
          }
          break;
        }
      }
    }
    return notificationsDao.markAsRead(notificationId);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(AppDatabase database) {
    final notificationsDao = database.notificationsDao;
    if (_lastNotificationsCache != null) {
      for (int i = 0; i < _lastNotificationsCache!.length; i++) {
        final n = _lastNotificationsCache![i];
        switch (n) {
          case AiringNotification airing:
            _lastNotificationsCache![i] = airing.copyWith(isRead: true);
          case MediaDataChangeNotification dataChange:
            _lastNotificationsCache![i] = dataChange.copyWith(isRead: true);
          case MediaMergeNotification merge:
            _lastNotificationsCache![i] = merge.copyWith(isRead: true);
          case MediaDeletionNotification deletion:
            _lastNotificationsCache![i] = deletion.copyWith(isRead: true);
        }
      }
    }
    return notificationsDao.markAllAsRead();
  }
}
