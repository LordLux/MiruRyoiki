import 'dart:async';
import 'dart:convert';
import 'package:graphql/client.dart';
import '../../../../models/anilist/anime.dart';
import '../../../../models/anilist/user_list.dart';
import '../../../main.dart';
import '../../../manager.dart';
import '../../../models/anilist/user_data.dart';
import '../../../models/notification.dart';
import '../../../database/database.dart';
import '../../../database/daos/notifications_dao.dart';
import '../../../utils/logging.dart';
import '../../../utils/retry_utils.dart';
import '../../../utils/time_utils.dart';
import '../auth.dart';

part 'initialization.dart';
part 'auth.dart';
part 'search.dart';
part 'user.dart';
part 'anime_details.dart';
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

  bool get isLoggedIn => _authService.isAuthenticated;

  static final List<String> statusListNamesApi = [
    AnilistListApiStatus.CURRENT.name_,
    AnilistListApiStatus.PLANNING.name_,
    AnilistListApiStatus.COMPLETED.name_,
    AnilistListApiStatus.DROPPED.name_,
    AnilistListApiStatus.PAUSED.name_,
    AnilistListApiStatus.REPEATING.name_,
  ];

  static const List<String> statusListNamesPretty = [
    "Watching",
    "Plan to Watch",
    "Completed",
    "Dropped",
    "On Hold",
    "Rewatching",
  ];

  static String printAllStatuses() => statusListNamesApi.map((status) => StatusStatistic.statusNameToPretty(status)).join(', ');
}
