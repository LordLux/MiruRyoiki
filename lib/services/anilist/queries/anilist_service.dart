import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../../../models/anilist/anime.dart';
import '../../../../models/anilist/anime_overview.dart';
import '../../../../models/anilist/user_list.dart';
import '../../../../models/anilist/page_info.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/anilist/anime_card.dart';
import '../../../models/anilist/user_data.dart';
import '../../../models/notification.dart';
import '../../../database/database.dart';
import '../../../database/daos/notifications_dao.dart';
import '../../../utils/logging.dart';
import '../../../utils/time.dart';
import '../../connectivity/connectivity_service.dart';
import '../../library/library_provider.dart';
import '../anilist_availability.dart';
import '../auth.dart';
import '../provider/anilist_provider.dart';
import 'anilist_query_executor.dart';

import 'graphql/anime/details.graphql.dart';
import 'graphql/anime/discover.graphql.dart';
import 'graphql/common/fragments.graphql.dart';
import 'graphql/user/mutations.graphql.dart';
import 'graphql/user/user.graphql.dart';
import 'graphql/user/notifications.graphql.dart';
import 'graphql/schema.graphql.dart';

part 'initialization.dart';
part 'auth.dart';
part 'search.dart';
part 'user.dart';
part 'anime_details.dart';
part 'anime_tabs.dart';
part 'genres.dart';
part 'mutations.dart';
part 'browse.dart';
part '../notifications_service.dart';

class AnilistService with AnilistQueryExecutor {
  // Singleton
  static final AnilistService _instance = AnilistService._internal();
  factory AnilistService() => _instance;
  AnilistService._internal() : _authService = AnilistAuthService();

  AnilistAuthService _authService;
  
  @visibleForTesting
  set authService(AnilistAuthService service) => _authService = service;

  GraphQLClient? _client;

  @override
  GraphQLClient? get client => _client;

  /// Set the GraphQL client for testing purposes
  set client(GraphQLClient? client) => _client = client;

  // Throttling + cache for notifications
  DateTime? _lastNotificationsFetchAt;
  List<AnilistNotification>? _lastNotificationsCache;
  int? _lastNotificationsPage;
  int? _lastNotificationsPerPage;
  List<NotificationType>? _lastNotificationsTypes;
  DateTime? _lastNotificationsSyncAt; // whole-sync throttle timestamp
  Completer<List<AnilistNotification>>? _notificationsSyncCompleter; // dedupe concurrent syncs

  @visibleForTesting
  void resetCache() {
    _lastNotificationsFetchAt = null;
    _lastNotificationsCache = null;
    _lastNotificationsPage = null;
    _lastNotificationsPerPage = null;
    _lastNotificationsTypes = null;
    _lastNotificationsSyncAt = null;
    _notificationsSyncCompleter = null;
  }

  /// Whether the user is logged in.
  bool get isLoggedIn => _authService.isAuthenticated;

  /// API status names for user-defined lists.
  /// 
  /// [`CURRENT`, `PLANNING`, `COMPLETED`, `DROPPED`, `PAUSED`, `REPEATING`]
  static final List<String> statusListNamesApi = [
    AnilistListApiStatus.CURRENT.name_,
    AnilistListApiStatus.PLANNING.name_,
    AnilistListApiStatus.COMPLETED.name_,
    AnilistListApiStatus.DROPPED.name_,
    AnilistListApiStatus.PAUSED.name_,
    AnilistListApiStatus.REPEATING.name_,
  ];

  /// Special status name for unlinked series.
  /// 
  /// `__unlinked`
  static const String statusListNameUnlinked = '__unlinked';

  /// Custom status prefix for user-defined lists.
  ///
  /// `custom_`
  static const String statusListPrefixCustom = 'custom_';

  /// Pretty status names for display purposes.
  /// 
  /// [`Watching`, `Plan to Watch`, `Completed`, `Dropped`, `On Hold`, `Rewatching`]
  static const List<String> statusListNamesPretty = [
    "Watching",
    "Plan to Watch",
    "Completed",
    "Dropped",
    "On Hold",
    "Rewatching",
  ];

  /// Maps pretty status names to API status names.
  /// ```dart
  /// {
  ///   "Watching": CURRENT, 
  ///   "Plan to Watch": PLANNING, 
  ///   "Completed": COMPLETED, 
  ///   "Dropped": DROPPED, 
  ///   "On Hold": PAUSED, 
  ///   "Rewatching": REPEATING
  /// }
  /// ```
  static Map<String, String> get statusListNamesPrettyToApiMap => Map.fromIterables(statusListNamesPretty, statusListNamesApi);

  static String printAllStatuses() => statusListNamesApi.map((status) => StatusStatistic.statusNameToPretty(status)).join(', ');
}
