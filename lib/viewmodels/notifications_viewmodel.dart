import 'package:fluent_ui/fluent_ui.dart';

import '../models/notification.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/show_info.dart';
import '../utils/logging.dart';
import '../utils/time.dart';

/// ViewModel for AniList notifications, shared by the notifications dialog and the title-bar unread badge.
///
/// Owns the recent-notifications list, the unread count, sync/read-status actions.
///
/// Registered app-wide via `ChangeNotifierProxyProvider<Library, NotificationsViewModel>` in `main.dart`.
class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({AnilistService? anilistService}) : _anilistServiceOverride = anilistService;

  final AnilistService? _anilistServiceOverride;

  AnilistService get _anilistService => _anilistServiceOverride ?? AnilistService();

  late Library _library;
  bool _disposed = false;

  /// Called by the ChangeNotifierProxyProvider whenever [Library] notifies
  void update(Library library) {
    _library = library;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // State

  static const int _recentLimit = 5;

  List<AnilistNotification> _recent = [];
  int _unreadCount = 0;
  bool _isRefreshing = false;
  DateTime? _lastSync;

  /// The most recent (up to 5) notifications, hidden-series filtered
  List<AnilistNotification> get recentNotifications => _recent;
  int get unreadCount => _unreadCount;
  bool get isRefreshing => _isRefreshing;
  DateTime? get lastSync => _lastSync;

  /// Notifications not related to hidden series (true = keep)
  List<AnilistNotification> _filterHidden(List<AnilistNotification> notifications) {
    return notifications.where((notification) {
      final anilistIdToCheck = notification.anilistId;
      if (anilistIdToCheck != null && _library.hiddenSeriesService.shouldFilterAnilistId(anilistIdToCheck)) return false;
      return true;
    }).toList();
  }

  // Data access

  /// Loads the cached notifications + unread count (no network)
  Future<void> loadCached() async {
    try {
      final notifications = await _anilistService.getCachedNotifications(
        database: _library.database,
        limit: 20,
      );
      final unreadCount = await _anilistService.getUnreadCount(_library.database);

      _recent = _filterHidden(notifications).take(_recentLimit).toList();
      _unreadCount = unreadCount;
      _notify();
    } catch (e) {
      // Silently handle cache loading errors
      logErr("Error loading cached notifications", e);
    }
  }

  /// Syncs notifications from AniList and refreshes the list + unread count.
  ///
  /// Shows a snackbar on real failures; stays quiet when offline.
  Future<void> sync() async {
    _isRefreshing = true;
    _notify();

    try {
      final notifications = await _anilistService.syncNotifications(
        database: _library.database,
        types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
        maxPages: 2,
      );
      final unreadCount = await _anilistService.getUnreadCount(_library.database);

      _recent = _filterHidden(notifications).take(_recentLimit).toList();
      _unreadCount = unreadCount;
      _lastSync = now;
    } catch (e) {
      if (e.toString().toLowerCase().contains('socket is not connected') || //
          e.toString().toLowerCase().contains('errno = 10057') ||
          e.toString().toLowerCase().contains('offline')) {
        logTrace('Failed to refresh notifications - offline');
      } else {
        snackBar("Failed to refresh notifications", exception: e, severity: InfoBarSeverity.error);
      }
    } finally {
      _isRefreshing = false;
      _notify();
    }
  }

  /// Badge refresh: best-effort sync, falling back to the cached unread count when offline
  Future<void> refreshUnreadCount() async {
    try {
      await _anilistService.syncNotifications(
        database: _library.database,
        types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
        maxPages: 2,
      );
      _unreadCount = await _anilistService.getUnreadCount(_library.database);
      _notify();
    } catch (_) {
      // Offline or API error: fall back to the cached count
      try {
        _unreadCount = await _anilistService.getUnreadCount(_library.database);
        _notify();
      } catch (_) {}
    }
  }

  // Read-status actions

  /// Marks one notification as read (DB + local list + unread count).
  ///
  /// Returns true on success so callers can sync other caches.
  Future<bool> markAsRead(int notificationId) async {
    try {
      await _anilistService.markAsRead(_library.database, notificationId);

      _recent = [
        for (final n in _recent) n.id == notificationId ? n.copyWith(isRead: true) : n,
      ];
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      _notify();
      return true;
    } catch (e) {
      logErr("Error marking notification $notificationId as read: $e");
      return false;
    }
  }

  /// Marks all notifications as read (DB + local list + unread count).
  ///
  /// Returns true on success so callers can sync other caches.
  Future<bool> markAllAsRead() async {
    try {
      await _anilistService.markAllAsRead(_library.database);

      _recent = [for (final n in _recent) n.copyWith(isRead: true)];
      _unreadCount = 0;
      _notify();
      return true;
    } catch (e) {
      // Handle error silently
      logErr("Error marking all notifications as read: $e");
      return false;
    }
  }
}
