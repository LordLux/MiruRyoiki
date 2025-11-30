import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../../../models/anilist/anime.dart';
import '../../../../models/anilist/user_list.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/anilist/user_data.dart';
import '../../../models/notification.dart';
import '../../../database/database.dart';
import '../../../database/daos/notifications_dao.dart';
import '../../../utils/logging.dart';
import '../../../utils/retry.dart';
import '../../../utils/time.dart';
import '../../connectivity/connectivity_service.dart';
import '../../library/library_provider.dart';
import '../auth.dart';
import '../provider/anilist_provider.dart';

part 'initialization.dart';
part 'auth.dart';
part 'search.dart';
part 'user.dart';
part 'anime_details.dart';
part 'genres.dart';
part 'mutations.dart';
part '../notifications_service.dart';

class AnilistService {
  // Singleton
  static final AnilistService _instance = AnilistService._internal();
  factory AnilistService() => _instance;
  AnilistService._internal() : _authService = AnilistAuthService();

  final AnilistAuthService _authService;
  GraphQLClient? _client;

  // Throttling + cache for notifications
  DateTime? _lastNotificationsFetchAt;
  List<AnilistNotification>? _lastNotificationsCache;
  int? _lastNotificationsPage;
  int? _lastNotificationsPerPage;
  List<NotificationType>? _lastNotificationsTypes;
  DateTime? _lastNotificationsSyncAt; // whole-sync throttle timestamp
  Completer<List<AnilistNotification>>? _notificationsSyncCompleter; // dedupe concurrent syncs

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
