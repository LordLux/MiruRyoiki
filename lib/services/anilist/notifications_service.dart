part of 'queries/anilist_service.dart';

extension AnilistServiceNotifications on AnilistService {
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

    // If offline, return empty list as sync will load from database instead
    if (ConnectivityService().isOffline) {
      logTrace('Offline: skipping notification fetch (will use database cache)');
      return [];
    }

    final typeIn = types?.map((t) {
      switch (t) {
        case NotificationType.AIRING:
          return Enum$NotificationType.AIRING;
        case NotificationType.RELATED_MEDIA_ADDITION:
          return Enum$NotificationType.RELATED_MEDIA_ADDITION;
        case NotificationType.MEDIA_DATA_CHANGE:
          return Enum$NotificationType.MEDIA_DATA_CHANGE;
        case NotificationType.MEDIA_MERGE:
          return Enum$NotificationType.MEDIA_MERGE;
        case NotificationType.MEDIA_DELETION:
          return Enum$NotificationType.MEDIA_DELETION;
      }
    }).toList();

    final result = await executeQuery<Query$GetNotifications>(
      options: QueryOptions(
        document: documentNodeQueryGetNotifications,
        variables: Variables$Query$GetNotifications(
          page: page,
          perPage: perPage,
          type_in: typeIn,
        ).toJson(),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      operationName: 'GetNotifications',
      parser: (data) => Query$GetNotifications.fromJson(data),
    );

    if (result != null && result.Page?.notifications != null) {
      final notifications = <AnilistNotification>[];
      for (final notificationData in result.Page!.notifications!) {
        if (notificationData == null) continue;
        final notification = _convertNotification(notificationData);
        if (notification != null) {
          notifications.add(notification);
        }
      }

      // Save cache & metadata
      _lastNotificationsFetchAt = now;
      _lastNotificationsCache = notifications;
      _lastNotificationsPage = page;
      _lastNotificationsPerPage = perPage;
      _lastNotificationsTypes = types == null ? null : List.of(types);
      return notifications;
    }

    return [];
  }

  /// Convert GraphQL notification data to AnilistNotification model
  /// 
  /// Filters by ANIME type notifications
  /// 
  /// Returns null if the notification type is unsupported or invalid
  AnilistNotification? _convertNotification(Query$GetNotifications$Page$notifications data) {
    if (data is Query$GetNotifications$Page$notifications$$AiringNotification) {
      if (data.media?.type != Enum$MediaType.ANIME) return null;
      return AiringNotification(
        id: data.id,
        type: NotificationType.AIRING,
        createdAt: data.createdAt ?? 0,
        animeId: data.animeId,
        episode: data.episode,
        contexts: data.contexts?.whereType<String>().toList() ?? [],
        media: _convertMediaInfo(data.media),
        format: data.media?.format?.name,
      );
    } else if (data is Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification) {
      if (data.media?.type != Enum$MediaType.ANIME) return null;
      return RelatedMediaAdditionNotification(
        id: data.id,
        type: NotificationType.RELATED_MEDIA_ADDITION,
        createdAt: data.createdAt ?? 0,
        mediaId: data.mediaId,
        context: data.context,
        media: _convertMediaInfo(data.media),
      );
    } else if (data is Query$GetNotifications$Page$notifications$$MediaDataChangeNotification) {
      if (data.media?.type != Enum$MediaType.ANIME) return null;
      return MediaDataChangeNotification(
        id: data.id,
        type: NotificationType.MEDIA_DATA_CHANGE,
        createdAt: data.createdAt ?? 0,
        mediaId: data.mediaId,
        context: data.context,
        reason: data.reason,
        media: _convertMediaInfo(data.media),
      );
    } else if (data is Query$GetNotifications$Page$notifications$$MediaMergeNotification) {
      if (data.media?.type != Enum$MediaType.ANIME) return null;
      return MediaMergeNotification(
        id: data.id,
        type: NotificationType.MEDIA_MERGE,
        createdAt: data.createdAt ?? 0,
        mediaId: data.mediaId,
        deletedMediaTitles: data.deletedMediaTitles?.whereType<String>().toList() ?? [],
        context: data.context,
        reason: data.reason,
        media: _convertMediaInfo(data.media),
      );
    }
    //  else if (data is Query$GetNotifications$Page$notifications$$MediaDeletionNotification) {
    //   // MediaDeletionNotification doesn't have media object so we can't filter by type
    //   return MediaDeletionNotification(
    //     id: data.id,
    //     type: NotificationType.MEDIA_DELETION,
    //     createdAt: data.createdAt ?? 0,
    //     deletedMediaTitle: data.deletedMediaTitle,
    //     context: data.context,
    //     reason: data.reason,
    //   );
    // }
    return null;
  }

  MediaInfo? _convertMediaInfo(dynamic media) {
    if (media == null) return null;
    // All media objects in the query have the same structure
    return MediaInfo(
      id: media.id,
      title: media.title?.english ?? media.title?.romaji ?? media.title?.native,
      coverImage: media.coverImage?.large ?? media.coverImage?.medium,
      type: media.type?.toJson(),
      format: media.format?.toJson(),
      episodes: media.episodes,
    );
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
        _notificationsSyncCompleter = null;
        rethrow;
      }
    }

    // If last completed within 5s, just return cached (if any)
    if (_lastNotificationsSyncAt != null && now.difference(_lastNotificationsSyncAt!).inSeconds < 5) {
      if (_lastNotificationsCache != null) return _lastNotificationsCache!;
    }

    _notificationsSyncCompleter = Completer<List<AnilistNotification>>();

    try {
      // If offline, load from database immediately
      if (ConnectivityService().isOffline) {
        logTrace('Offline: loading notifications from database cache');
        final cachedNotifications = await getCachedNotifications(
          database: database,
          limit: 256,
        );
        _lastNotificationsCache = cachedNotifications;
        _lastNotificationsSyncAt = now;
        _notificationsSyncCompleter!.complete(cachedNotifications);
        _notificationsSyncCompleter = null;
        return cachedNotifications;
      }

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
        
        // If we failed on the first page, try to load from database
        if (page == 1) {
          logWarn('Failed to fetch notifications from API, loading from database cache');
          final cachedNotifications = await getCachedNotifications(
            database: database,
            limit: 256,
          );
          _lastNotificationsCache = cachedNotifications;
          _lastNotificationsSyncAt = now;
          _notificationsSyncCompleter!.complete(cachedNotifications);
          _notificationsSyncCompleter = null;
          return cachedNotifications;
        }
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

      _lastNotificationsSyncAt = now;
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
