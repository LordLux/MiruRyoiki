import 'dart:async';
import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../models/notification.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../utils/color_utils.dart';
import '../utils/logging.dart';
import '../utils/path_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page.dart';
import '../manager.dart';

class ReleaseCalendarScreen extends StatefulWidget {
  final Function(PathString) onSeriesSelected;
  final ScrollController scrollController;

  const ReleaseCalendarScreen({
    super.key,
    required this.onSeriesSelected,
    required this.scrollController,
  });

  @override
  State<ReleaseCalendarScreen> createState() => _ReleaseCalendarScreenState();
}

class _ReleaseCalendarScreenState extends State<ReleaseCalendarScreen> {
  DateTime _selectedDate = now;
  DateTime _focusedMonth = now;
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController _episodeListController = ItemScrollController();

  double _spacerHeight = 0.0;
  int _firstUpcomingItemIndex = -1;
  int _lastItemIndex = -1;

  // Cache for release data to avoid repeated calculations
  Map<DateTime, List<CalendarEntry>> _calendarCache = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _showOnlyTodayEpisodes = false; // Track if we're filtering to today only
  Timer? _minuteRefreshTimer; // periodic UI refresh for relative labels & countdowns
  bool _filterSelectedDate = true; // controls whether selected date filter is active

  @override
  void initState() {
    super.initState();
    // Initial load & scroll after first frame
    nextFrame(() {
      _loadReleaseData();
      _itemPositionsListener.itemPositions.addListener(_updateSpacerHeight);
      nextFrame(() => _scrollToToday());
    });
    // Periodic refresh for relative times
    _minuteRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteRefreshTimer?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_updateSpacerHeight);
    super.dispose();
  }

  void _updateSpacerHeight() {
    if (!mounted || _firstUpcomingItemIndex == -1) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the visible item positions for our start and end indices
    final firstItemPos = positions.where((p) => p.index == _firstUpcomingItemIndex).firstOrNull;
    final lastItemPos = positions.where((p) => p.index == _lastItemIndex).firstOrNull;

    // We can only calculate the height if BOTH the start and end items are visible.
    // This is a limitation, but for many UI cases it's sufficient.
    // If you need to calculate off-screen items, the logic becomes much more complex.
    if (firstItemPos != null && lastItemPos != null) {
      // The position values are fractions of the viewport height (0.0 to 1.0)
      // itemLeadingEdge is the top, itemTrailingEdge is the bottom.
      final contentHeightFraction = lastItemPos.itemTrailingEdge - firstItemPos.itemLeadingEdge;

      // Get the viewport height. We wrap the list in a LayoutBuilder for this.
      final viewportHeight = MediaQuery.of(context).size.height; // Or get from LayoutBuilder
      final contentPixelHeight = contentHeightFraction * viewportHeight;

      final availableHeight = ScreenUtils.height - ScreenUtils.kTitleBarHeight - 100 /*StuckHeader*/ - 16 /*bottom padding*/;
      final newSpacerHeight = math.max(0.0, availableHeight - contentPixelHeight);

      // Update state only if the value has changed to avoid unnecessary rebuilds
      if ((newSpacerHeight - _spacerHeight).abs() > 1.0) {
        setState(() {
          _spacerHeight = newSpacerHeight + 60;
        });
      }
    }
  }

  void _scrollToToday() {
    // Find today's position in the calendar entries and scroll to it
    if (!mounted || _calendarCache.isEmpty) return;

    // Scroll to position, but don't exceed the max scroll extent
    _episodeListController.scrollTo(
      index: _firstUpcomingItemIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadReleaseData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final library = Provider.of<Library>(context, listen: false);
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);

      // Check if user is logged in before making requests
      if (!anilistProvider.isLoggedIn || anilistProvider.isOffline) {
        setState(() => _isLoading = false);
        return;
      }

      // Get date range (±2 weeks from today for wider view)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 14));
      final endDate = now.add(const Duration(days: 14));

      final Map<DateTime, List<CalendarEntry>> calendarMap = {};

      // Load episodes (future releases)
      await _loadEpisodeData(library, anilistProvider, calendarMap, startDate, endDate);

      // Load notifications (past events)
      await _loadNotificationData(library, calendarMap, startDate, endDate);

      // Sort entries by date within each day
      for (final dayEntries in calendarMap.values) {
        dayEntries.sort((a, b) => a.date.compareTo(b.date));
      }

      logTrace('Found ${calendarMap.length} days with entries, total entries: ${calendarMap.values.expand((x) => x).length}');

      setState(() {
        _calendarCache = calendarMap;
        if (calendarMap.isEmpty) {
          _errorMessage = 'No episodes or notifications found within the selected date range.';
        } else {
          _errorMessage = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
      logErr('Error loading calendar data', e);
    }
  }

  Future<void> _loadEpisodeData(Library library, AnilistProvider anilistProvider, Map<DateTime, List<CalendarEntry>> calendarMap, DateTime startDate, DateTime endDate) async {
    // Get unique anime IDs to avoid duplicate requests
    final Set<int> animeIds = {};
    for (final series in library.series) {
      if (series.anilistMappings.isNotEmpty) {
        for (final mapping in series.anilistMappings) {
          animeIds.add(mapping.anilistId);
        }
      }
    }

    if (animeIds.isEmpty) return;

    // Use the same approach as homepage - get cached data first, refresh in background
    final cachedUpcomingEpisodes = anilistProvider.getCachedUpcomingEpisodes(animeIds.toList(), refreshInBackground: true);

    logTrace('Using cached upcoming episodes for ${cachedUpcomingEpisodes.length} anime');

    // Process the cached results first
    for (final series in library.series) {
      if (series.anilistMappings.isNotEmpty) {
        for (final mapping in series.anilistMappings) {
          final airingInfo = cachedUpcomingEpisodes[mapping.anilistId];
          if (airingInfo?.airingAt != null) {
            final airingDate = DateTime.fromMillisecondsSinceEpoch(airingInfo!.airingAt! * 1000);
            final dateKey = DateTime(airingDate.year, airingDate.month, airingDate.day);

            if (airingDate.isAfter(startDate) && airingDate.isBefore(endDate)) {
              final episodeInfo = ReleaseEpisodeInfo(
                series: series,
                animeData: null, // We don't need full anime data for this
                airingEpisode: airingInfo,
                airingDate: airingDate,
                isWatched: false,
                isAvailable: false,
              );

              final calendarEntry = EpisodeCalendarEntry(episodeInfo: episodeInfo);
              calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
            }
          }
        }
      }
    }

    // If no cached data available, try fetching fresh data as fallback
    if (calendarMap.isEmpty) {
      try {
        final upcomingEpisodes = await anilistProvider.getUpcomingEpisodes(animeIds.toList());

        logTrace('Fallback: Loaded upcoming episodes for ${upcomingEpisodes.length} anime');

        // Process the fresh results
        for (final series in library.series) {
          if (series.anilistMappings.isNotEmpty) {
            for (final mapping in series.anilistMappings) {
              final airingInfo = upcomingEpisodes[mapping.anilistId];
              if (airingInfo?.airingAt != null) {
                final airingDate = DateTime.fromMillisecondsSinceEpoch(airingInfo!.airingAt! * 1000);
                final dateKey = DateTime(airingDate.year, airingDate.month, airingDate.day);

                if (airingDate.isAfter(startDate) && airingDate.isBefore(endDate)) {
                  final episodeInfo = ReleaseEpisodeInfo(
                    series: series,
                    animeData: null, // We don't need full anime data for this
                    airingEpisode: airingInfo,
                    airingDate: airingDate,
                    isWatched: false,
                    isAvailable: false,
                  );

                  final calendarEntry = EpisodeCalendarEntry(episodeInfo: episodeInfo);
                  calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
                }
              }
            }
          }
        }
      } catch (e) {
        // If API call fails, log but don't fail completely since we might have notifications
        logErr('Episode API call failed', e);
      }
    }
  }

  Future<void> _loadNotificationData(Library library, Map<DateTime, List<CalendarEntry>> calendarMap, DateTime startDate, DateTime endDate) async {
    try {
      final anilistService = AnilistService();

      // Get notifications from the database
      final notifications = await anilistService.getCachedNotifications(
        database: library.database,
        limit: 100, // Get more notifications for broader date range
      );

      logTrace('Loaded ${notifications.length} cached notifications');

      // Filter notifications for our date range and add them to calendar
      for (final notification in notifications) {
        final notificationDate = DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000);

        if (notificationDate.isAfter(startDate) && notificationDate.isBefore(endDate)) {
          final dateKey = DateTime(notificationDate.year, notificationDate.month, notificationDate.day);

          // Try to find the associated series for this notification
          Series? associatedSeries;
          if (notification is AiringNotification) {
            // Look for a series with matching anilist ID
            for (final series in library.series) {
              if (series.anilistMappings.any((mapping) => mapping.anilistId == notification.animeId)) {
                associatedSeries = series;
                break;
              }
            }
          }

          final calendarEntry = NotificationCalendarEntry(
            notification: notification,
            series: associatedSeries,
          );

          calendarMap.putIfAbsent(dateKey, () => []).add(calendarEntry);
        }
      }
    } catch (e) {
      // Log error but don't fail completely since we might have episodes
      logErr('Error loading notifications', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MiruRyoikiHeaderInfoBarPage(
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

    // Calculate calendar height based on ScreenUtils.height:
    // - If screen height > 720, use the maximum calendar height.
    // - If screen height <= 600, use the minimum calendar height (380).
    // - Between 600 and 720, linearly interpolate from min to max.
    final double screenH = ScreenUtils.height;
    double calendarWidth;
    if (screenH > 720.0) {
      calendarWidth = maxCalendarHeight;
    } else if (screenH <= 600.0) {
      calendarWidth = minCalendarWidth;
    } else {
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
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                });
              },
              child: const Icon(FluentIcons.chevron_left),
            ),
          ),
          Text(
            DateFormat.yMMMM().format(_focusedMonth),
            style: FluentTheme.of(context).typography.subtitle,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Button(
              style: ButtonStyle(padding: ButtonState.all(const EdgeInsets.all(8))),
              onPressed: () {
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              },
              child: const Icon(FluentIcons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(double calendarWidth) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startDay = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day headers
          SizedBox(
            width: calendarWidth,
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
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
                  final isToday = _isSameDay(date, DateTime.now());

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
        child: (isHovering) => Button(
          onPressed: () {
            setState(() {
              if (isSelected) {
                // Toggle filter off/on when clicking the same selected date
                _filterSelectedDate = !_filterSelectedDate;
                if (!_filterSelectedDate) {
                  // Clear selection highlight by moving _selectedDate to a non-matching day (keep logical state)
                  _selectedDate = DateTime(1900); // sentinel: no day in current view will match
                }
              } else {
                _selectedDate = date;
                _filterSelectedDate = true; // enable filter on new selection
              }
              // Turning off today-only if user manually toggles date
              if (_showOnlyTodayEpisodes && !_filterSelectedDate) {
                _showOnlyTodayEpisodes = false;
              }
            });
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
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.error, size: 48, color: Colors.red.light),
          VDiv(16),
          Text(_errorMessage!, style: FluentTheme.of(context).typography.subtitle),
          VDiv(16),
          Button(
            onPressed: _loadReleaseData,
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
    } else {
      // Group all entries (within cache window)
      allEntries.sort((a, b) => a.date.compareTo(b.date));
      final map = <DateTime, List<CalendarEntry>>{};
      for (final entry in allEntries) {
        final k = DateTime(entry.date.year, entry.date.month, entry.date.day);
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

    _firstUpcomingItemIndex = flattenedList.indexWhere((item) => item is EpisodeCalendarEntry && item.episodeInfo.airingDate.isAfter(now));
    _lastItemIndex = flattenedList.length - 1;

    return LayoutBuilder(builder: (context, constraints) {
      return ScrollablePositionedList.builder(
          itemScrollController: _episodeListController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: flattenedList.length + 1,
          itemBuilder: (context, index) {
            if (index == flattenedList.length) return SizedBox(height: _spacerHeight);

            final item = flattenedList[index];

            // Date header
            if (item is DateTime) {
              final date = item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 16.0, left: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getRelativeDateLabel(date),
                      style: Manager.bodyLargeStyle.copyWith(fontWeight: FontWeight.w600, color: lighten(Manager.accentColor.lightest)),
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
                          style: FluentTheme.of(context).typography.caption?.copyWith(
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
                padding: const EdgeInsets.only(bottom: 0.0),
                child: _buildCalendarEntryItem(entry),
              );
            }

            return const SizedBox.shrink();
          });
    });
  }

  Widget _buildCalendarEntryItem(CalendarEntry entry) {
    return switch (entry) {
      EpisodeCalendarEntry episodeEntry => _buildEpisodeItem(episodeEntry.episodeInfo),
      NotificationCalendarEntry notificationEntry => _buildNotificationItem(notificationEntry.notification, notificationEntry.series),
      _ => const SizedBox(), // fallback for abstract CalendarEntry
    };
  }

  Widget _buildNotificationItem(AnilistNotification notification, Series? series) {
    final notificationDate = DateTime.fromMillisecondsSinceEpoch(notification.createdAt * 1000);
    final timeAgo = now.difference(notificationDate);

    return Opacity(
      opacity: 0.7, // Notifications are always in the past, so make them slightly transparent
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        cursor: series != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        tileColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return Colors.blue.withOpacity(0.2);
          return Colors.grey.withOpacity(.15);
        }),
        onPressed: series != null
            ? () {
                widget.onSeriesSelected(series.path);
              }
            : null,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getNotificationIcon(notification),
                size: 16,
                color: Colors.blue.light,
              ),
            ),
            HDivPx(12),
            SizedBox(
              width: 70,
              height: 54,
              child: _buildNotificationImage(notification, series),
            ),
          ],
        ),
        title: Text(
          _getNotificationTitle(notification, series),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notified ${_formatTimeAgo(timeAgo)}',
              style: Manager.bodyStyle.copyWith(color: Colors.blue.lightest),
            ),
            Text(
              DateFormat.yMMMd().add_jm().format(notificationDate),
              style: Manager.captionStyle.copyWith(color: Colors.white.withOpacity(.5)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              Icon(
                FluentIcons.circle_fill,
                color: Colors.blue,
                size: 8,
              ),
            if (series != null) const Icon(FluentIcons.chevron_right),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(AnilistNotification notification) {
    return switch (notification.type) {
      NotificationType.AIRING => FluentIcons.play,
      NotificationType.MEDIA_DATA_CHANGE => FluentIcons.edit,
      NotificationType.MEDIA_MERGE => FluentIcons.merge,
      NotificationType.MEDIA_DELETION => FluentIcons.delete,
    };
  }

  String _getNotificationTitle(AnilistNotification notification, Series? series) {
    return switch (notification) {
      AiringNotification airing => 'Episode ${airing.episode} aired - ${series?.displayTitle ?? airing.media?.title ?? 'Unknown anime'}',
      MediaDataChangeNotification dataChange => '${series?.displayTitle ?? dataChange.media?.title ?? 'Unknown anime'} was updated',
      MediaMergeNotification merge => '${series?.displayTitle ?? merge.media?.title ?? 'Unknown anime'} was merged',
      MediaDeletionNotification deletion => '${deletion.deletedMediaTitle ?? 'Anime'} was deleted',
      _ => 'Unknown notification', // fallback
    };
  }

  Widget _buildNotificationImage(AnilistNotification notification, Series? series) {
    String? imageUrl;

    // Try to get image from series first, then from notification media
    if (series?.bannerImage != null) {
      imageUrl = series!.bannerImage;
    } else {
      switch (notification) {
        case AiringNotification airing:
          imageUrl = airing.media?.coverImage;
        case MediaDataChangeNotification dataChange:
          imageUrl = dataChange.media?.coverImage;
        case MediaMergeNotification merge:
          imageUrl = merge.media?.coverImage;
        case MediaDeletionNotification _:
          imageUrl = null; // No media info for deletion notifications
      }
    }

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: child,
        ),
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.withOpacity(0.3),
          child: const Icon(FluentIcons.photo2),
        ),
      );
    } else {
      return Container(
        color: Colors.grey.withOpacity(0.3),
        child: const Icon(FluentIcons.photo2),
      );
    }
  }

  Widget _buildEpisodeItem(ReleaseEpisodeInfo episodeInfo) {
    final isUpcoming = episodeInfo.airingDate.isAfter(now);
    final timeUntil = episodeInfo.airingDate.difference(now);

    return Opacity(
      opacity: isUpcoming ? 1.0 : 0.7,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        cursor: SystemMouseCursors.click,
        tileColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return Manager.accentColor.light.withOpacity(0.2);
          return Colors.grey.withOpacity(.25);
        }),
        onPressed: () {
          widget.onSeriesSelected(episodeInfo.series.path);
        },
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              episodeInfo.airingEpisode.episode.toString(),
              style: Manager.bodyStyle.copyWith(
                color: lighten(Manager.accentColor.lightest),
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            HDivPx(12),
            SizedBox(
              width: 70,
              height: 54,
              child: episodeInfo.series.bannerImage != null
                  ? Image.network(
                      episodeInfo.series.bannerImage!,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: child,
                      ),
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.withOpacity(0.3),
                        child: const Icon(FluentIcons.photo2),
                      ),
                    )
                  : Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(FluentIcons.photo2),
                    ),
            ),
          ],
        ),
        title: Text(
          'Episode ${episodeInfo.airingEpisode.episode ?? '?'} - ${episodeInfo.series.displayTitle}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUpcoming ? 'Airs in ${_formatDuration(timeUntil)}' : 'Aired ${_formatTimeAgo(timeUntil.abs())}',
              style: Manager.bodyStyle.copyWith(color: Manager.accentColor.lightest),
            ),
            Text(
              DateFormat.yMMMd().add_jm().format(episodeInfo.airingDate),
              style: Manager.captionStyle.copyWith(color: Colors.white.withOpacity(.5)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (episodeInfo.isAvailable)
              Icon(
                FluentIcons.check_mark,
                color: Colors.green,
                size: 16,
              ),
            if (episodeInfo.isWatched)
              Icon(
                FluentIcons.view,
                color: Manager.accentColor,
                size: 16,
              ),
            const Icon(FluentIcons.chevron_right),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  String _getRelativeDateLabel(DateTime date) {
    final today = DateTime.now();
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
