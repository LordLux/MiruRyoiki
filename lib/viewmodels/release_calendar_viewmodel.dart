import 'package:fluent_ui/fluent_ui.dart';

import '../models/anilist/anime.dart';
import '../models/calendar_entry.dart';
import '../models/notification.dart';
import '../models/series.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/show_info.dart';
import '../utils/logging.dart';
import '../utils/time.dart';
import 'disposable_view_model.dart';

/// ViewModel for the Release Calendar screen.
///
/// Owns all calendar *state* and all *data access*.
///
/// Registered app-wide via `ChangeNotifierProxyProvider2<Library, AnilistProvider, ReleaseCalendarViewModel>` in `main.dart`, so dialogs can share the same instance.
class ReleaseCalendarViewModel extends DisposableViewModel {
  ReleaseCalendarViewModel({AnilistService? anilistService}) : _anilistServiceOverride = anilistService;

  final AnilistService? _anilistServiceOverride;

  /// Resolved lazily: constructing [AnilistService] initializes the auth service (which reads .env),
  /// so pure-logic unit tests that never load data must not trigger it.
  AnilistService get _anilistService => _anilistServiceOverride ?? AnilistService();

  late Library _library;
  late AnilistProvider _anilist;

  /// Called by the ChangeNotifierProxyProvider2 whenever [Library] or [AnilistProvider] notify.
  ///
  /// Only swaps references.
  void update(Library library, AnilistProvider anilist) {
    _library = library;
    _anilist = anilist;
  }

  // State

  DateTime _selectedDate = now;
  DateTime _focusedMonth = now;
  Map<DateTime, List<CalendarEntry>> _calendarCache = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _showOnlyTodayEpisodes = false;
  bool _filterSelectedDate = false;
  bool _showOlderNotifications = false;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  Map<DateTime, List<CalendarEntry>> get calendarCache => _calendarCache;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showOnlyTodayEpisodes => _showOnlyTodayEpisodes;
  bool get filterSelectedDate => _filterSelectedDate;
  bool get showOlderNotifications => _showOlderNotifications;

  /// Test-only: seed the calendar cache directly, bypassing data loading.
  @visibleForTesting
  void debugSetCalendarCache(Map<DateTime, List<CalendarEntry>> cache) {
    _calendarCache = cache;
    notifySafe();
  }

  // Screen State

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool get isSelectedToday => _isSameDay(_selectedDate, now);
  bool get isSelectedFuture => _selectedDate.isAfter(_dayKey(now));

  List<CalendarEntry> get selectedDayEntries => _calendarCache[_dayKey(_selectedDate)] ?? const [];

  bool get hasAnyEntries => _calendarCache.values.any((e) => e.isNotEmpty);

  /// Count unread notifications currently present in the calendar cache
  int get unreadCount {
    var count = 0;
    for (final entries in _calendarCache.values) {
      for (final e in entries) {
        if (e is NotificationCalendarEntry && !e.notification.isRead) count++;
      }
    }
    return count;
  }

  /// Whether the "Show older notifications" button should be offered.
  bool get shouldShowOlderButton {
    final isOnSelectedDateWithNoEntries = _filterSelectedDate && selectedDayEntries.isEmpty;
    return (isSelectedToday && !_showOnlyTodayEpisodes && !_showOlderNotifications) || //
        (isOnSelectedDateWithNoEntries && !_showOlderNotifications);
  }

  /// The entries the list should currently display, grouped by day and sorted within each day.
  /// Single source of truth for the screen's list AND the auto-scroll calculation.
  ///
  /// Modes, in priority order:
  /// 1 today-only filter → just today's entries;
  /// 2 a selected date with entries → just that date;
  /// 3 a selected date without entries → empty until "show older" is toggled;
  /// 4 default (on today) → everything, hiding days before today unless "show older" is toggled.
  Map<DateTime, List<CalendarEntry>> get visibleEntriesByDate {
    final todayKey = _dayKey(now);

    if (_showOnlyTodayEpisodes) {
      final todaysEntries = _calendarCache[todayKey] ?? const [];
      if (todaysEntries.isEmpty) return const {};
      return {todayKey: List.of(todaysEntries)..sort((a, b) => a.date.compareTo(b.date))};
    }

    final selectedKey = _dayKey(_selectedDate);
    final selected = selectedDayEntries;

    if (_filterSelectedDate && selected.isNotEmpty) //
      return {selectedKey: List.of(selected)..sort((a, b) => a.date.compareTo(b.date))};

    if (_filterSelectedDate && selected.isEmpty && !_showOlderNotifications) //
      return const {};

    // Default: all entries grouped by day; when on today (and not revealing
    // older ones) hide days strictly before today.
    final shouldFilterOlder = !_showOlderNotifications && !_filterSelectedDate && isSelectedToday;

    final allEntries = _calendarCache.values.expand((e) => e).toList()..sort((a, b) => a.date.compareTo(b.date));
    final map = <DateTime, List<CalendarEntry>>{};
    for (final entry in allEntries) {
      final k = _dayKey(entry.date);
      if (shouldFilterOlder && k.isBefore(todayKey)) continue;
      map.putIfAbsent(k, () => []).add(entry);
    }
    return map;
  }

  // UI intents

  void focusToday() {
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
    _filterSelectedDate = false;
    _showOlderNotifications = false;
    notifySafe();
  }

  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifySafe();
  }

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifySafe();
  }

  void toggleTodayFilter([bool? value]) {
    _showOnlyTodayEpisodes = value ?? !_showOnlyTodayEpisodes;
    notifySafe();
  }

  /// Returns true when toggled on (the screen auto-scrolls in that case)
  bool toggleOlderNotifications([bool? value]) {
    final newValue = value ?? !_showOlderNotifications;
    _showOlderNotifications = newValue;
    notifySafe();
    return newValue;
  }

  /// Day-cell tap: clicking the already-selected date clears the filter, clicking another date selects and filters it.
  ///
  /// Selecting today never keeps the date filter (today is the default view).
  void selectDate(DateTime date) {
    if (_isSameDay(date, _selectedDate)) {
      _filterSelectedDate = false;
    } else {
      _selectedDate = date;
      _filterSelectedDate = true;
    }

    if (_showOnlyTodayEpisodes && !_filterSelectedDate) {
      _showOnlyTodayEpisodes = false;
    }

    _showOlderNotifications = false;

    if (isSelectedToday) {
      _filterSelectedDate = false;
    }

    notifySafe();
  }

  // Data loading

  Future<void> loadReleaseData() async {
    if (_isLoading || isDisposed) return;

    _isLoading = true;
    notifySafe();

    try {
      if (!_anilist.isLoggedIn) {
        _isLoading = false;
        notifySafe();
        return;
      }

      final Map<DateTime, List<CalendarEntry>> calendarMap = {};

      // Load cached data and display it immediately
      await _loadNotificationData(calendarMap, null, now);
      await _loadEpisodeData(calendarMap, now, null);
      if (isDisposed) return;

      if (calendarMap.isNotEmpty) {
        _calendarCache = calendarMap;
        _errorMessage = null;
        notifySafe();
      }

      if (!_anilist.isOffline) {
        // Online: sync notifications in background, then reload fresh
        try {
          await _anilistService.syncNotifications(
            database: _library.database,
            types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
            maxPages: 2,
          );
          if (isDisposed) return;

          final freshCalendarMap = <DateTime, List<CalendarEntry>>{};
          await _loadNotificationData(freshCalendarMap, null, now);
          await _loadEpisodeData(freshCalendarMap, now, null);
          if (isDisposed) return;

          for (final dayEntries in freshCalendarMap.values) //
            dayEntries.sort((a, b) => a.date.compareTo(b.date));

          logTrace('  Found ${freshCalendarMap.length} days with entries after sync, total entries: ${freshCalendarMap.values.expand((x) => x).length}');

          _calendarCache = freshCalendarMap;
          _errorMessage = freshCalendarMap.isEmpty ? 'No episodes or notifications found within the selected date range.' : null;
        } catch (e) {
          logErr('Failed to sync notifications for release calendar', e);
        }
      } else {
        // Offline: keep cached data
        for (final dayEntries in calendarMap.values) //
          dayEntries.sort((a, b) => a.date.compareTo(b.date));
        _errorMessage = calendarMap.isEmpty ? 'No episodes or notifications found within the selected date range.' : null;
      }
    } catch (e) {
      _errorMessage = 'Error loading data: ${e.toString()}';
      logErr('Error loading calendar data', e);
    } finally {
      _isLoading = false;
      notifySafe();
    }
  }

  Future<void> _loadEpisodeData(Map<DateTime, List<CalendarEntry>> calendarMap, DateTime? startDate, DateTime? endDate) async {
    if (isDisposed) return;

    // Unique RELEASING anime IDs across all mapped series
    final Set<int> animeIds = {};
    for (final series in _library.series) {
      for (final mapping in series.anilistMappings) {
        if (mapping.anilistData?.status?.toAnimeStatus() == AnilistAnimeStatus.RELEASING) animeIds.add(mapping.anilistId);
      }
    }
    if (animeIds.isEmpty || isDisposed) return;

    // Cached data first (kicks off a background refresh), same as homepage
    final cachedUpcomingEpisodes = _anilist.getCachedUpcomingEpisodes(animeIds.toList(), refreshInBackground: true);
    logTrace('  Using cached upcoming episodes for ${cachedUpcomingEpisodes.length} anime');

    if (cachedUpcomingEpisodes.isNotEmpty) {
      _addAiringEntries(calendarMap, cachedUpcomingEpisodes, startDate, endDate);
    }

    // If no cached data available, fetch fresh data as fallback
    if (calendarMap.isEmpty && !isDisposed) {
      try {
        final upcomingEpisodes = await _anilist.getUpcomingEpisodes(animeIds.toList());
        if (isDisposed) return;
        _addAiringEntries(calendarMap, upcomingEpisodes, startDate, endDate);
      } catch (e, st) {
        // Log but don't fail completely — we might still have notifications
        logErr('Episode API call failed', e, st);
      }
    }
  }

  void _addAiringEntries(
    Map<DateTime, List<CalendarEntry>> calendarMap,
    Map<int, AiringEpisode?> upcomingEpisodes,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    for (final series in _library.series) {
      if (isDisposed) return;

      for (final mapping in series.anilistMappings) {
        final airingInfo = upcomingEpisodes[mapping.anilistId];
        if (airingInfo?.airingAt == null) continue;

        final airingDate = DateTime.fromMillisecondsSinceEpoch(airingInfo!.airingAt! * 1000);
        if ((startDate != null && !airingDate.isAfter(startDate)) || (endDate != null && !airingDate.isBefore(endDate))) continue;

        final episodeInfo = ReleaseEpisodeInfo(
          series: series,
          animeData: null, // full anime data not needed here
          airingEpisode: airingInfo,
          airingDate: airingDate,
          isWatched: false,
          isAvailable: false, // TODO: implement availability check
        );
        calendarMap.putIfAbsent(_dayKey(airingDate), () => []).add(EpisodeCalendarEntry(episodeInfo: episodeInfo));
      }
    }
  }

  Future<void> _loadNotificationData(Map<DateTime, List<CalendarEntry>> calendarMap, DateTime? startDate, DateTime endDate) async {
    if (isDisposed) return;

    try {
      final notifications = await _anilistService.getCachedNotifications(
        database: _library.database,
        limit: 256,
      );
      if (isDisposed) return;

      logTrace('  Loaded ${notifications.length} cached notifications for calendar');

      for (final notification in notifications) {
        if (isDisposed) return;

        final notificationDate = DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000);
        final inRange = (startDate == null || notificationDate.isAfter(startDate)) && notificationDate.isBefore(endDate);
        if (!inRange) continue;

        final anilistIdToCheck = notification.anilistId;

        // Skip notifications for hidden series
        if (anilistIdToCheck != null && _library.hiddenSeriesService.shouldFilterAnilistId(anilistIdToCheck)) continue;

        // Associate a local series by AniList ID, if any
        Series? associatedSeries;
        if (anilistIdToCheck != null) {
          for (final series in _library.series) {
            if (series.anilistMappings.any((mapping) => mapping.anilistId == anilistIdToCheck)) {
              associatedSeries = series;
              break;
            }
          }
        }

        calendarMap.putIfAbsent(_dayKey(notificationDate), () => []).add(NotificationCalendarEntry(
              notification: notification,
              series: associatedSeries,
            ));
      }
    } catch (e, st) {
      // Log but don't fail completely — we might still have episodes
      logErr('Error loading notifications', e, st);
    }
  }

  // Notification read-status

  /// Mark one notification as read: persists via [AnilistService] and updates the local cache.
  /// 
  /// No-op if it is already read.
  Future<void> markNotificationRead(int notificationId) async {
    await _anilistService.markAsRead(_library.database, notificationId);
    applyNotificationRead(notificationId);
  }

  /// Mark all unread notifications as read (remote DB + local cache) + snackbar
  Future<void> markAllAsRead() async {
    try {
      await _anilistService.markAllAsRead(_library.database);
      applyAllNotificationsRead();
      snackBar('Marked all notifications as read', severity: InfoBarSeverity.success);
    } catch (e) {
      logErr('Failed to mark all notifications as read', e);
      snackBar('Failed to mark all notifications as read', severity: InfoBarSeverity.error);
    }
  }

  /// Cache-only: flip one notification to read.
  /// 
  /// Used after the DB write has already happened elsewhere.
  void applyNotificationRead(int notificationId) {
    _mapNotifications((n) => n.notification.id == notificationId && !n.notification.isRead ? NotificationCalendarEntry(notification: n.notification.copyWith(isRead: true), series: n.series) : n);
  }

  /// Cache-only: flip every notification to read.
  /// 
  /// Used after the DB write has already happened elsewhere.
  void applyAllNotificationsRead() {
    _mapNotifications((n) => !n.notification.isRead //
        ? NotificationCalendarEntry(notification: n.notification.copyWith(isRead: true), series: n.series)
        : n);
  }

  void _mapNotifications(NotificationCalendarEntry Function(NotificationCalendarEntry) transform) {
    for (final dateKey in _calendarCache.keys) {
      final entriesForDate = _calendarCache[dateKey];
      if (entriesForDate == null) continue;
      _calendarCache[dateKey] = [
        for (final e in entriesForDate) //
          e is NotificationCalendarEntry ? transform(e) : e,
      ];
    }
    notifySafe();
  }
}
