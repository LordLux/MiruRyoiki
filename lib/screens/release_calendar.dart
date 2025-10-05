import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../models/notification.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../utils/color.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../widgets/notifications/notif.dart';
import '../widgets/notifications/scheduled.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
import '../manager.dart';
import '../widgets/tooltip_wrapper.dart';
import '../enums.dart';
import '../settings.dart';

class ReleaseCalendarScreen extends StatefulWidget {
  final Function(PathString) onSeriesSelected;
  final ScrollController scrollController;

  const ReleaseCalendarScreen({
    super.key,
    required this.onSeriesSelected,
    required this.scrollController,
  });

  @override
  State<ReleaseCalendarScreen> createState() => ReleaseCalendarScreenState();
}

class ReleaseCalendarScreenState extends State<ReleaseCalendarScreen> {
  DateTime _selectedDate = now;
  DateTime _focusedMonth = now;

  // Cache for release data to avoid repeated calculations
  Map<DateTime, List<CalendarEntry>> _calendarCache = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _showOnlyTodayEpisodes = false; // Track if we're filtering to today only
  Timer? _minuteRefreshTimer; // periodic UI refresh for relative labels & countdowns
  bool _filterSelectedDate = false; // controls whether selected date filter is active
  bool _showOlderNotifications = false; // Track if we're showing older notifications when on today
  bool _isDisposed = false;
  bool _isTempHidingResults = false;

  @override
  void initState() {
    super.initState();
    // Initial load
    nextFrame(() => loadReleaseData());

    // Periodic refresh for relative times
    _minuteRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _minuteRefreshTimer?.cancel();
    super.dispose();
  }

  void focusToday() {
    if (mounted && !_isDisposed) {
      setState(() {
        _focusedMonth = DateTime(now.year, now.month, 1);
        _selectedDate = now; // Reset selection to today
        _filterSelectedDate = false; // Disable filter to show all episodes
        _showOlderNotifications = false; // Reset older notifications flag
      });
      // nextFrame(() => scrollToToday(animated: false)); // Scroll immediately without animation
    }
  }

  void toggleFilter([bool? value]) {
    if (mounted && !_isDisposed) {
      setState(() {
        _showOnlyTodayEpisodes = value ?? !_showOnlyTodayEpisodes;
      });
    }
  }

  void toggleOlderNotifications([bool? value]) {
    if (mounted && !_isDisposed) {
      final newValue = value ?? !_showOlderNotifications;

      setState(() {
        _showOlderNotifications = newValue;
      });

      // Auto-scroll when toggled to true
      if (newValue && widget.scrollController.hasClients) {
        // Wait for the list to rebuild before calculating scroll position
        nextFrame(() => _autoScrollToScheduledEpisodes());
      }
    }
  }

  void scrollTo(double offset) {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 2900),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _autoScrollToScheduledEpisodes() async {
    if (!widget.scrollController.hasClients) return;

    try {
      // Calculate the number of scheduled episodes and date headers that should be skipped
      int scheduledEpisodeCount = 0;
      int dateHeaderCount = 0;

      // Get current entries
      final Map<DateTime, List<CalendarEntry>> entriesByDate = _getCurrentEntriesByDate();
      final sortedDates = entriesByDate.keys.toList()..sort();

      // Count items that appear in future dates (scheduled episodes and their headers)
      final todayStart = DateTime(now.year, now.month, now.day);

      for (final date in sortedDates) {
        final entries = entriesByDate[date]!;

        // If this date is in the future, count its items
        if (date.isAfter(todayStart)) {
          // Count the date header
          dateHeaderCount++;

          // Count all episodes for future dates (they are all scheduled)
          scheduledEpisodeCount += entries.length;
        }
      }

      // Calculate scroll position
      // Date headers: 54px height * font size multiplier
      // Episode entries: 83px height * font size multiplier
      final headerHeight = 54 * Manager.fontSizeMultiplier;
      final episodeHeight = 83 * Manager.fontSizeMultiplier;
      final availableSpace = (ScreenUtils.height - (ScreenUtils.kMinHeaderHeight + ScreenUtils.kTitleBarHeight - 36));

      final targetOffset = (dateHeaderCount * headerHeight) + (scheduledEpisodeCount * episodeHeight);
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      final clampedPosition = (maxScrollExtent - targetOffset + availableSpace).clamp(0.0, maxScrollExtent);

      if (targetOffset <= availableSpace || scheduledEpisodeCount == 0) {
        widget.scrollController.jumpTo(maxScrollExtent);
        return; // if the target offset fits in available space, no need to scroll up, as the content will be in the lower part of the screen
      }
      widget.scrollController.jumpTo(clampedPosition - 65); // space occupied by the 'show older notifications' button
      logTrace('Auto-scrolling to position: $targetOffset <= available space: $availableSpace');
      setState(() => _isTempHidingResults = true);
      await Future.delayed(const Duration(milliseconds: 5));

      nextFrame(delay: 5, () {
        setState(() => _isTempHidingResults = false);
        widget.scrollController.animateTo(
          clampedPosition - 250,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
        );
      });
    } catch (e) {
      // If calculation fails, just scroll to bottom
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Map<DateTime, List<CalendarEntry>> _getCurrentEntriesByDate() {
    // This helper method returns the current entries by date
    // We need to replicate the filtering logic from the build method
    final Map<DateTime, List<CalendarEntry>> entriesByDate = {};

    for (final entry in _calendarCache.entries) {
      final date = entry.key;
      final entries = entry.value;

      if (entries.isEmpty) continue;

      // Apply the same filtering logic as in build method
      final isOnToday = date.year == now.year && date.month == now.month && date.day == now.day;
      final shouldFilterOlder = isOnToday && !_showOnlyTodayEpisodes && !_showOlderNotifications;

      List<CalendarEntry> filteredEntries = entries;
      if (shouldFilterOlder) {
        // Filter out older notifications (keep only future episodes)
        filteredEntries = entries.where((entry) {
          if (entry is EpisodeCalendarEntry && entry.isFutureEntry) return true; // Keep scheduled episodes
          if (entry is NotificationCalendarEntry) {
            final notificationTime = DateTime.fromMillisecondsSinceEpoch(entry.notification.createdAt * 1000);
            return notificationTime.isAfter(now.subtract(const Duration(hours: 6)));
          }
          return true;
        }).toList();
      }

      if (filteredEntries.isNotEmpty) {
        entriesByDate[date] = filteredEntries;
      }
    }

    return entriesByDate;
  }

  Future<void> loadReleaseData() async {
    if (_isLoading || _isDisposed) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      final library = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      // Check if user is logged in before making requests
      if (!anilistProvider.isLoggedIn || anilistProvider.isOffline) {
        if (mounted && !_isDisposed) setState(() => _isLoading = false);
        return;
      }

      // Check cancellation before proceeding
      if (_isDisposed) return;

      // Sync notifications to get the latest data before loading
      try {
        final anilistService = AnilistService();
        await anilistService.syncNotifications(
          database: library.database,
          types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
          maxPages: 2,
        );

        // Check cancellation after async operation
        if (_isDisposed) return;
      } catch (e) {
        // Log but don't fail - we can still show cached notifications
        logErr('Failed to sync notifications for release calendar', e);
        if (_isDisposed) return;
      }

      // Get date range (±2 weeks from today for wider view)
      // final startDate = now.subtract(const Duration(days: 14));
      // final endDate = now.add(const Duration(days: 14));

      final Map<DateTime, List<CalendarEntry>> calendarMap = {};

      // Load episodes (future releases)
      await _loadEpisodeData(library, anilistProvider, calendarMap, now, null); // we want all schedules

      if (_isDisposed) return;

      // Load notifications (past events)
      await _loadNotificationData(library, calendarMap, null, now);

      if (_isDisposed) return;

      // temporarily multiplicate all scheduled episodes items (only dates after today) for testing by random number
      // calendarMap.forEach((date, entries) {
      //   if (date.isAfter(DateTime(now.year, now.month, now.day))) {
      //     final episodesToDuplicate = entries.whereType<EpisodeCalendarEntry>().toList();
      //     final randomCount = 1 + (DateTime.now().millisecondsSinceEpoch % 12); // Random number between 7-12
      //     final duplicatedEpisodes = <EpisodeCalendarEntry>[];
      //     for (int i = 0; i < randomCount; i++) {
      //       duplicatedEpisodes.addAll(episodesToDuplicate);
      //     }
      //     calendarMap[date] = [...entries, ...duplicatedEpisodes];
      //   }
      // });

      // Sort entries by date within each day
      for (final dayEntries in calendarMap.values) {
        dayEntries.sort((a, b) => a.date.compareTo(b.date));
      }

      logTrace('  Found ${calendarMap.length} days with entries, total entries: ${calendarMap.values.expand((x) => x).length}');

      if (mounted && !_isDisposed) {
        setState(() {
          _calendarCache = calendarMap;
          _errorMessage = calendarMap.isEmpty ? 'No episodes or notifications found within the selected date range.' : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading data: ${e.toString()}';
        });
      }
      logErr('Error loading calendar data', e);
    }
  }

  Future<void> _loadEpisodeData(Library library, AnilistProvider anilistProvider, Map<DateTime, List<CalendarEntry>> calendarMap, DateTime? startDate, DateTime? endDate) async {
    if (_isDisposed) return;

    // Get unique anime IDs to avoid duplicate requests
    final Set<int> animeIds = {};
    for (final series in library.series) {
      if (series.anilistMappings.isNotEmpty) {
        for (final mapping in series.anilistMappings) {
          if (mapping.anilistData?.status == 'RELEASING') animeIds.add(mapping.anilistId); // only consider RELEASING series
        }
      }
    }

    if (animeIds.isEmpty || _isDisposed) return;

    // Use the same approach as homepage - get cached data first, refresh in background
    final cachedUpcomingEpisodes = anilistProvider.getCachedUpcomingEpisodes(animeIds.toList(), refreshInBackground: true);

    logTrace('  Using cached upcoming episodes for ${cachedUpcomingEpisodes.length} anime');

    // Process the cached results first
    if (cachedUpcomingEpisodes.isNotEmpty) {
      for (final series in library.series) {
        if (_isDisposed) return;

        if (series.anilistMappings.isNotEmpty) {
          for (final mapping in series.anilistMappings) {
            final airingInfo = cachedUpcomingEpisodes[mapping.anilistId]; // Get airing info for this anime ID
            if (airingInfo?.airingAt != null) {
              final airingDate = DateTime.fromMillisecondsSinceEpoch(airingInfo!.airingAt! * 1000);
              final dateKey = DateTime(airingDate.year, airingDate.month, airingDate.day);

              if ((startDate == null || airingDate.isAfter(startDate)) && (endDate == null || airingDate.isBefore(endDate))) {
                final episodeInfo = ReleaseEpisodeInfo(
                  series: series,
                  animeData: null, // We don't need full anime data for this
                  airingEpisode: airingInfo,
                  airingDate: airingDate,
                  isWatched: false,
                  isAvailable: false, // TODO Implement availability check
                );

                final calendarEntry = EpisodeCalendarEntry(episodeInfo: episodeInfo);
                calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
              }
            }
          }
        }
      }
    }

    // If no cached data available, try fetching fresh data as fallback
    if (calendarMap.isEmpty && !_isDisposed) {
      try {
        final upcomingEpisodes = await anilistProvider.getUpcomingEpisodes(animeIds.toList());

        if (_isDisposed) return;

        // Process the fresh results
        for (final series in library.series) {
          if (_isDisposed) return;

          if (series.anilistMappings.isNotEmpty) {
            for (final mapping in series.anilistMappings) {
              final airingInfo = upcomingEpisodes[mapping.anilistId];
              if (airingInfo?.airingAt != null) {
                final airingDate = DateTime.fromMillisecondsSinceEpoch(airingInfo!.airingAt! * 1000);
                final dateKey = DateTime(airingDate.year, airingDate.month, airingDate.day);

                if ((startDate == null || airingDate.isAfter(startDate)) && (endDate == null || airingDate.isBefore(endDate))) {
                  final episodeInfo = ReleaseEpisodeInfo(
                    series: series,
                    animeData: null, // We don't need full anime data for this
                    airingEpisode: airingInfo,
                    airingDate: airingDate,
                    isWatched: false,
                    isAvailable: false, //TODO: Implement availability check
                  );

                  final calendarEntry = EpisodeCalendarEntry(episodeInfo: episodeInfo);
                  calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
                }
              }
            }
          }
        }
      } catch (e, st) {
        // If API call fails, log but don't fail completely since we might have notifications
        logErr('Episode API call failed', e, st);
      }
    }
  }

  Future<void> _loadNotificationData(Library library, Map<DateTime, List<CalendarEntry>> calendarMap, DateTime? startDate, DateTime endDate) async {
    if (_isDisposed) return;

    try {
      final anilistService = AnilistService();

      // Get notifications from the database
      final notifications = await anilistService.getCachedNotifications(
        database: library.database,
        limit: 100, // Get more notifications for broader date range
      );

      if (_isDisposed) return;

      logTrace('  Loaded ${notifications.length} cached notifications');

      // Filter notifications for our date range and add them to calendar
      for (final notification in notifications) {
        if (_isDisposed) return;

        final notificationDate = DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000);

        if ((((startDate != null && notificationDate.isAfter(startDate)) || startDate == null) && notificationDate.isBefore(endDate))) {
          final dateKey = DateTime(notificationDate.year, notificationDate.month, notificationDate.day);
          Series? associatedSeries;
          int? anilistIdToCheck;

          // Extract the AniList ID based on notification type
          anilistIdToCheck = switch (notification) {
            AiringNotification n => n.animeId,
            RelatedMediaAdditionNotification n => n.mediaId,
            MediaDataChangeNotification n => n.mediaId,
            _ => null,
          };

          // Look for a series with matching anilist ID
          if (anilistIdToCheck != null) {
            for (final series in library.series) {
              if (series.anilistMappings.any((mapping) => mapping.anilistId == anilistIdToCheck)) {
                associatedSeries = series;
                break;
              }
            }
          }

          // Check if this notification should be filtered based on hidden series
          if (anilistIdToCheck != null && library.hiddenSeriesService.shouldFilterAnilistId(anilistIdToCheck)) //
            continue;

          final calendarEntry = NotificationCalendarEntry(
            notification: notification,
            series: associatedSeries,
          );

          calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
        }
      }
    } catch (e, st) {
      // Log error but don't fail completely since we might have episodes
      logErr('Error loading notifications', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruRyoikiTemplatePage(
      headerWidget: HeaderWidget(
        title: (_, __) => const PageHeader(title: Text('Release Calendar')),
        titleLeftAligned: true,
        fixed: 100,
        children: [
          VDiv(0),
        ],
      ),
      headerMaxHeight: 100,
      headerMinHeight: 100,
      content: _buildContent(),
      scrollableContent: false,
      hideInfoBar: true,
      noHeaderBanner: true,
    );
  }

  Widget _buildContent() {
    return SizedBox(
      height: ScreenUtils.height,
      child: Row(
        children: [
          // Left side - Calendar
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 24.0),
              child: _buildCalendar(),
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            color: Colors.white.withOpacity(0.15),
          ),

          // Right side - Episode list
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 0.0),
              child: _buildEpisodeList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    const double maxCalendarHeight = 466.0;
    const double minCalendarWidth = 380.0;

    // Calculate calendar height based on ScreenUtils.height
    // - If screen height > 720 use the maximum calendar height
    // - If screen height <= 600 use the minimum calendar height
    // - Between 600 and 720 interpolate linearly from min to max
    final double screenH = ScreenUtils.height;
    double calendarWidth;
    if (screenH > 720.0)
      calendarWidth = maxCalendarHeight;
    else if (screenH <= 600.0)
      calendarWidth = minCalendarWidth;
    else {
      final double t = (screenH - 620.0) / (720.0 - 600.0); // 0..1
      calendarWidth = minCalendarWidth + t * (maxCalendarHeight - minCalendarWidth);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Calendar header with navigation
        _buildCalendarHeader(calendarWidth),
        VDiv(16),

        // Calendar grid
        _buildCalendarGrid(calendarWidth),
      ],
    );
  }

  Widget _buildCalendarHeader(double calendarWidth) {
    return SizedBox(
      width: calendarWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Button(
              style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.all(8))),
              onPressed: () {
                if (mounted && !_isDisposed) {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                }
              },
              child: const Icon(FluentIcons.chevron_left),
            ),
          ),
          MouseButtonWrapper(
            tooltip: 'Click to go to current date',
            child: (_) => GestureDetector(
              onTap: () => focusToday(),
              child: Text(
                DateFormat.yMMMM().format(_focusedMonth),
                style: FluentTheme.of(context).typography.subtitle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Button(
              style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.all(8))),
              onPressed: () {
                if (mounted && !_isDisposed) {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                }
              },
              child: const Icon(FluentIcons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(double calendarWidth) {
    final settings = SettingsManager();
    final firstDayOfWeekSetting = settings.firstDayOfWeek;

    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);

    // Calculate start day based on configurable first day of week
    final firstDayWeekdayValue = firstDayOfWeekSetting.toWeekdayValue;
    int startDay = (firstDayOfMonth.weekday - firstDayWeekdayValue) % 7;
    if (startDay < 0) startDay += 7;

    // Generate day headers based on first day of week setting
    final dayHeaders = <String>[];
    final allDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final startIndex = (firstDayWeekdayValue == 7) ? 0 : firstDayWeekdayValue; // Sunday = 0, Monday = 1, etc.
    for (int i = 0; i < 7; i++) {
      dayHeaders.add(allDays[(startIndex + i) % 7]);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day headers
          SizedBox(
            width: calendarWidth,
            child: Row(
              children: dayHeaders
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: FluentTheme.of(context).typography.caption,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          VDiv(8),

          // Calendar days - Use a container with fixed height instead of Expanded
          Flexible(
            child: SizedBox(
              width: calendarWidth, // Adjust width based on height
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 42, // 6 weeks
                itemBuilder: (context, index) {
                  final dayOffset = index - startDay + 1;

                  if (dayOffset < 1 || dayOffset > daysInMonth) return Container(); // Empty cell

                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset);
                  final dateKey = DateTime(date.year, date.month, date.day);
                  final entriesForDay = _calendarCache[dateKey] ?? [];
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, now);

                  return _buildCalendarDay(date, entriesForDay, isSelected, isToday);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, List<CalendarEntry> entries, bool isSelected, bool isToday) {
    final entryCount = entries.length;

    return Container(
      margin: const EdgeInsets.all(2),
      child: MouseButtonWrapper(
        tooltip: entryCount > 0 //
            ? '${DateFormat.yMMMd().format(date)}\n$entryCount notification${entryCount > 1 ? 's' : ''}'
            : '${DateFormat.yMMMd().format(date)}\nNo notifications',
        child: (isHovering) => Button(
          onPressed: () {
            if (mounted && !_isDisposed) {
              setState(() {
                // Toggle filter off/on when clicking the same selected date
                if (isSelected) {
                  // DISABLE FILTER - show all episodes when clicking the already selected date
                  _filterSelectedDate = false;
                } else {
                  // ENABLE FILTER - show only this date's episodes when clicking a different date
                  _selectedDate = date;
                  _filterSelectedDate = true;
                }
                // Turning off today-only if user manually toggles date
                if (_showOnlyTodayEpisodes && !_filterSelectedDate) {
                  _showOnlyTodayEpisodes = false;
                }
                // Reset older notifications flag when navigating to any different date
                _showOlderNotifications = false;
                if (_selectedDate.month == now.month && _selectedDate.year == now.year && _selectedDate.day == now.day) {
                  _filterSelectedDate = false;
                }
              });
            }
          },
          style: ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.all(0)),
            backgroundColor: ButtonState.resolveWith((states) {
              if (isSelected && !isHovering) return Manager.accentColor.light.withOpacity(0.7);
              if (isSelected && isHovering) return Manager.accentColor.light.withOpacity(0.9);
              if (isToday && !isHovering) return Manager.accentColor.light.withOpacity(0.3);
              if (isToday && isHovering) return Manager.accentColor.light.withOpacity(0.5);
              if (isHovering) return Manager.accentColor.light.withOpacity(0.2);
              return Colors.transparent;
            }),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              // Entry dots
              if (entryCount > 0) ...[
                VDiv(4),
                _buildEpisodeDots(entryCount, isSelected),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeDots(int count, bool isSelected) {
    if (count == 0) return const SizedBox();

    if (count <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity((index + 1) / 3) : Manager.accentColor.swatch.values.toList()[index + 3],
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      // Show 3+ indicator
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            3,
            (index) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Manager.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Text(
            '+',
            style: TextStyle(
              fontSize: 8,
              color: Manager.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildEpisodeList() {
    if (_isLoading) return Center(child: ProgressRing());

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.error, size: 48, color: Colors.red.light),
          VDiv(16),
          Text(_errorMessage!, style: FluentTheme.of(context).typography.subtitle),
          VDiv(16),
          Button(
            onPressed: loadReleaseData,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    // Entries for selected date
    final selectedDateKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final selectedDayEntries = _calendarCache[selectedDateKey] ?? [];

    // All entries (within cached window)
    final allEntries = _calendarCache.entries.expand((entry) => entry.value).toList();

    if (allEntries.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.calendar_day, size: 48, color: FluentTheme.of(context).inactiveColor),
          VDiv(16),
          Text('No episodes scheduled', style: FluentTheme.of(context).typography.subtitle),
        ],
      );
    }

    // Decide mode: today-only, selected-date, or all grouped
    late Map<DateTime, List<CalendarEntry>> entriesByDate;

    if (_showOnlyTodayEpisodes) {
      final today = now;
      final todayKey = DateTime(today.year, today.month, today.day);
      final todaysEntries = _calendarCache[todayKey] ?? [];
      if (todaysEntries.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.calendar_day, size: 48, color: FluentTheme.of(context).inactiveColor),
            VDiv(16),
            Text('No entries today', style: FluentTheme.of(context).typography.subtitle),
          ],
        );
      }
      entriesByDate = {todayKey: List.of(todaysEntries)..sort((a, b) => a.date.compareTo(b.date))};
    } else if (_filterSelectedDate && selectedDayEntries.isNotEmpty) {
      // Show ONLY selected date
      entriesByDate = {selectedDateKey: List.of(selectedDayEntries)..sort((a, b) => a.date.compareTo(b.date))};
    } else if (_filterSelectedDate && selectedDayEntries.isEmpty) {
      // Selected date has no entries - check if we should filter older notifications
      if (!_showOlderNotifications) {
        // Show empty for now, but we'll show the button to reveal older notifications
        entriesByDate = {};
      } else {
        // Show all entries when revealing older notifications
        allEntries.sort((a, b) => a.date.compareTo(b.date));
        final map = <DateTime, List<CalendarEntry>>{};
        for (final entry in allEntries) {
          final k = DateTime(entry.date.year, entry.date.month, entry.date.day);
          map.putIfAbsent(k, () => []).add(entry);
        }
        entriesByDate = map;
      }
    } else {
      // Group all entries (within cache window)
      allEntries.sort((a, b) => a.date.compareTo(b.date));
      final map = <DateTime, List<CalendarEntry>>{};

      // Check if we're on today and should filter older notifications
      final today = now;
      final todayKey = DateTime(today.year, today.month, today.day);
      final isOnToday = _selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day;
      final shouldFilterOlder = isOnToday && !_showOnlyTodayEpisodes && !_showOlderNotifications;

      for (final entry in allEntries) {
        final k = DateTime(entry.date.year, entry.date.month, entry.date.day);

        // If we should filter older notifications, skip past entries
        if (shouldFilterOlder && k.isBefore(todayKey)) {
          continue;
        }

        map.putIfAbsent(k, () => []).add(entry);
      }
      entriesByDate = map;
    }

    final sortedDates = entriesByDate.keys.toList()..sort();

    final List<Object> flattenedList = [];
    for (final date in sortedDates) {
      flattenedList.add(date); // Add the date as a header item
      flattenedList.addAll(entriesByDate[date]!); // Add all entries for that date
    }

    final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;

    // Check if we should show the "Show older notifications" button
    // Show the button when:
    // 1. We're on today and not in today-only mode and not showing older notifications
    // 2. We're on a selected date that has no entries (filtered) and not showing older notifications
    final isOnSelectedDateWithNoEntries = _filterSelectedDate && selectedDayEntries.isEmpty;
    final shouldShowOlderButton = (isToday && !_showOnlyTodayEpisodes && !_showOlderNotifications) || (isOnSelectedDateWithNoEntries && !_showOlderNotifications);

    // If we have no entries to show and should show the button, show a different empty state
    if (entriesByDate.isEmpty && shouldShowOlderButton) {
      return Column(
        children: [
          // Show older notifications button
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0, top: 8.0),
            child: Row(
              children: [
                Button(
                  style: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  ),
                  onPressed: () => toggleOlderNotifications(true),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.history, size: 14),
                      const SizedBox(width: 6),
                      Text(isToday ? 'Show older notifications' : 'Show all notifications'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Empty state message
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.calendar_day, size: 48, color: FluentTheme.of(context).inactiveColor),
                VDiv(16),
                Text(
                  isToday ? 'No episodes scheduled for today' : 'No episodes scheduled for this date',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedOpacity(
        duration: shortDuration,
        opacity: _isTempHidingResults ? 0.0 : 1.0,
        curve: Curves.decelerate,
        child: Column(
          children: [
            // Show older notifications button (when conditions are met)
            if (shouldShowOlderButton) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0, top: 8.0),
                child: Row(
                  children: [
                    Button(
                      style: ButtonStyle(
                        padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                      ),
                      onPressed: () => toggleOlderNotifications(true),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.history, size: 14),
                          const SizedBox(width: 6),
                          Text(isToday ? 'Show older notifications' : 'Show all notifications'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Episode list
            Expanded(
              child: DynMouseScroll(
                  controller: widget.scrollController,
                  stopScroll: KeyboardState.ctrlPressedNotifier,
                  scrollSpeed: 1.0,
                  enableSmoothScroll: Manager.animationsEnabled,
                  durationMS: 350,
                  animationCurve: Curves.easeOutQuint,
                  builder: (context, controller, physics) {
                    return ValueListenableBuilder(
                        valueListenable: KeyboardState.ctrlPressedNotifier,
                        builder: (context, isCtrlPressed, _) {
                          return ListView.builder(
                            physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                            controller: controller,
                            cacheExtent: 999999,
                            padding: const EdgeInsets.only(right: 8.0),
                            itemCount: flattenedList.length,
                            itemBuilder: (context, index) {
                              final item = flattenedList[index];

                              // Date header
                              if (item is DateTime) {
                                final date = item;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0, top: 16.0, left: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      TooltipWrapper(
                                        waitDuration: const Duration(milliseconds: 400),
                                        tooltip: '${DateFormat.EEEE().format(date)} ${DateFormat('d MMM${now.year == date.year ? '' : ' y'}').format(date)} (${entriesByDate[date]!.length} entries)',
                                        child: (_) => Text(
                                          _getRelativeDateLabel(date),
                                          style: Manager.bodyLargeStyle.copyWith(fontWeight: FontWeight.w600, color: lighten(Manager.accentColor.lightest)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Manager.accentColor.light.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Manager.accentColor.light.withOpacity(0.4), width: 1),
                                        ),
                                        child: Transform.translate(
                                          offset: const Offset(0, -0.66),
                                          child: Text(
                                            '${entriesByDate[date]!.length}',
                                            style: Manager.captionStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: lighten(Manager.accentColor.lightest),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (item is CalendarEntry) {
                                final entry = item;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: _buildCalendarEntryItem(entry),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          );
                        });
                  }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarEntryItem(CalendarEntry entry) {
    return switch (entry) {
      NotificationCalendarEntry notificationEntry => NotificationCalendarEntryWidget(
          notificationEntry.notification,
          notificationEntry.series,
          onSeriesSelected: widget.onSeriesSelected,
          onDownloadButton: (animeId, episodeId) {
            // TODO callback for when user wants to download this episode -> go to download page with preselected anime/episode
            print('Download button clicked for episode $episodeId of anime ID: $animeId');
            snackBar('Download feature not implemented yet', severity: InfoBarSeverity.warning);
          },
          onAddedToList: (animeId) {
            // TODO show anilist dialog with list preselected to Plan to Watch
            print('Add to list clicked for anime ID: $animeId');
            snackBar('Add to list feature not implemented yet', severity: InfoBarSeverity.warning);
          },
          onRelatedMediaAdditionNotificationTapped: (animeId) {
            final url = 'https://anilist.co/anime/$animeId';
            logTrace('Opening related media addition notification URL: $url');
            launchUrl(Uri.parse(url));
          },
          onNotificationRead: (notificationId) async {
            // check if the notification is already marked as read and if so, do nothing
            if (notificationEntry.notification.isRead) return;

            final library = Provider.of<Library>(context, listen: false);
            await AnilistService().markAsRead(library.database, notificationId);
            setState(() {
              final dateKey = DateTime(notificationEntry.date.year, notificationEntry.date.month, notificationEntry.date.day);
              final entriesForDate = _calendarCache[dateKey];
              if (entriesForDate != null) {
                _calendarCache[dateKey] = entriesForDate.map((e) {
                  if (e is NotificationCalendarEntry && e.notification.id == notificationId) {
                    final updatedNotification = e.notification.copyWith(isRead: true);
                    return NotificationCalendarEntry(notification: updatedNotification, series: e.series);
                  }
                  return e;
                }).toList();
              }
            });
          },
        ),
      EpisodeCalendarEntry episodeEntry => ScheduledEpisodeCalendarEntryWidget(
          episodeEntry: episodeEntry,
          onNotificationButtonToggled: (series) /* we have the DB id of the series, not anilist id */ {
            // TODO callback for when user wants to be notified about this episode(remember to account for when seriesId is -1)
            print('Notification button toggled for episode ${episodeEntry.episodeInfo.airingEpisode.episode} of series: ${series?.name}');
            snackBar('Notification feature not implemented yet', severity: InfoBarSeverity.warning);
          },
        ),
      _ => const SizedBox(), // fallback for abstract CalendarEntry
    };
  }

  String _getRelativeDateLabel(DateTime date) {
    final today = now;
    final todayDate = DateTime(today.year, today.month, today.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(todayDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class ReleaseEpisodeInfo {
  final Series series;
  final AnilistAnime? animeData; // Make nullable
  final AiringEpisode airingEpisode;
  final DateTime airingDate;
  final bool isWatched;
  final bool isAvailable;

  ReleaseEpisodeInfo({
    required this.series,
    required this.animeData,
    required this.airingEpisode,
    required this.airingDate,
    required this.isWatched,
    required this.isAvailable,
  });
}

// Unified data structure for calendar entries (episodes and notifications)
abstract class CalendarEntry {
  final DateTime date;
  final Series? series; // nullable because notifications might not have series

  CalendarEntry({
    required this.date,
    this.series,
  });

  bool get isPastEntry => date.isBefore(now);
  bool get isFutureEntry => date.isAfter(now);
}

class EpisodeCalendarEntry extends CalendarEntry {
  final ReleaseEpisodeInfo episodeInfo;

  EpisodeCalendarEntry({
    required this.episodeInfo,
  }) : super(
          date: episodeInfo.airingDate,
          series: episodeInfo.series,
        );
}

class NotificationCalendarEntry extends CalendarEntry {
  final AnilistNotification notification;

  NotificationCalendarEntry({
    required this.notification,
    super.series,
  }) : super(
          date: notification.createdAt != 0 ? DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000) : DateTime.now(),
        );
}
