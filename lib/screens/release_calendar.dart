import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, InkWell;
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/smooth_scroll.dart';

import '../utils/anilist_utils.dart';

import '../models/calendar_entry.dart';
import '../services/navigation/navigation.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../utils/color.dart';
import '../utils/logging.dart';
import '../utils/path.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../viewmodels/release_calendar_viewmodel.dart';
import '../widgets/buttons/button.dart';
import '../widgets/frosted_noise.dart';
import '../widgets/notifications/notif.dart';
import '../widgets/notifications/scheduled.dart';
import '../widgets/number_pill.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/page_template.dart';
import '../manager.dart';
import '../widgets/styled_scrollbar.dart';
import '../widgets/tooltip_wrapper.dart';
import '../enums.dart';
import '../settings.dart';

/// Release Calendar screen.
///
/// All calendar state and data access lives in [ReleaseCalendarViewModel] (registered app-wide in `main.dart`).
/// This widget only renders it and owns view-only concerns: scroll position, keep-alive, and the minute ticker for relative-time labels.
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

class ReleaseCalendarScreenState extends State<ReleaseCalendarScreen> with AutomaticKeepAliveClientMixin {
  Timer? _minuteRefreshTimer; // periodic UI refresh for relative labels & countdowns
  bool _isDisposed = false;
  bool _isTempHidingResults = false;

  /// Indicates if the scroll is currently at the bottom of the list
  bool _isAtBottom = true;

  ReleaseCalendarViewModel get _vm => context.read<ReleaseCalendarViewModel>();

  @override
  bool get wantKeepAlive => true;

  @override
  void activate() {
    super.activate();
    // Reregister and restore on GlobalKey reparent
    NavigationManager.registerActiveScrollController('calendar', widget.scrollController);
    NavigationManager.restoreScrollOffset('calendar', widget.scrollController);
  }

  @override
  void initState() {
    super.initState();
    // Initial load
    nextFrame(() => loadReleaseData());
    NavigationManager.registerActiveScrollController('calendar', widget.scrollController);
    NavigationManager.restoreScrollOffset('calendar', widget.scrollController);

    widget.scrollController.addListener(() {
      if (widget.scrollController.hasClients && mounted && !_isDisposed) {
        if (widget.scrollController.offset >= widget.scrollController.position.maxScrollExtent - 20) {
          if (!_isAtBottom) setState(() => _isAtBottom = true);
        } else {
          if (_isAtBottom) setState(() => _isAtBottom = false);
        }
      }
    });

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

  Future<void> loadReleaseData() => _vm.loadReleaseData();

  void toggleOlderNotifications([bool? value]) {
    if (!mounted || _isDisposed) return;
    final turnedOn = _vm.toggleOlderNotifications(value);

    // Auto-scroll when toggled to true
    if (turnedOn && widget.scrollController.hasClients) {
      // Wait for the list to rebuild before calculating scroll position
      nextFrame(() => _autoScrollToScheduledEpisodes());
    }
  }

  void scrollTo(double offset, [int durationMs = 2900]) {
    if (widget.scrollController.hasClients) {
      widget.scrollController
          .animateTo(
        offset,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeOutCubic,
      )
          .then((_) {
        if (mounted) setState(() => _isAtBottom);
      });
    }
  }

  Future<void> _autoScrollToScheduledEpisodes() async {
    if (!widget.scrollController.hasClients) return;

    try {
      // Calculate the number of scheduled episodes and date headers that should be skipped
      int scheduledEpisodeCount = 0;
      int dateHeaderCount = 0;

      // Current entries as the list shows them
      final Map<DateTime, List<CalendarEntry>> entriesByDate = _vm.visibleEntriesByDate;
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final vm = context.watch<ReleaseCalendarViewModel>();

    return MiruRyoikiTemplatePage(
      headerWidget: HeaderWidget(
        title: (_, __) => PageHeader(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Release Calendar'),
              const SizedBox(width: 12),
              AnimatedOpacity(
                opacity: vm.isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: ProgressRing(
                      backgroundColor: Colors.transparent,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        titleLeftAligned: true,
        fixed: 100,
        children: [
          VDiv(8),
        ],
      ),
      headerMaxHeight: 100,
      headerMinHeight: 100,
      floatingButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _isAtBottom
            ? null
            : SizedBox(
                width: 36,
                height: 36,
                child: MouseButtonWrapper(
                  child: (isHovered) => TooltipWrapper(
                    tooltip: 'Scroll to bottom',
                    child: (_) => AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutBack,
                      scale: isHovered ? 1 : 0.666,
                      child: FrostedNoise(
                        child: InkWell(
                          onTap: () {
                            scrollTo(widget.scrollController.position.maxScrollExtent, 300);
                            setState(() => _isAtBottom = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isHovered ? (Manager.currentDominantAccentColor ?? Manager.accentColor).darker.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isHovered ? 5.0 : 10.0),
                            ),
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
      content: _buildContent(vm),
      scrollableContent: false,
      hideInfoBar: true,
      noHeaderBanner: true,
    );
  }

  Widget _buildContent(ReleaseCalendarViewModel vm) {
    return SizedBox(
      height: ScreenUtils.height,
      child: Row(
        children: [
          // Left side - Calendar
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 22.0),
              child: _buildCalendar(vm),
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            color: Colors.white.withOpacity(0.15),
          ),

          // Right side - Episode list
          Expanded(
            flex: 30,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: _buildEpisodeList(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ReleaseCalendarViewModel vm) {
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
    return Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar header with navigation
          _buildCalendarHeader(vm, calendarWidth),
          VDiv(16),

          // Calendar grid
          _buildCalendarGrid(vm, calendarWidth),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(ReleaseCalendarViewModel vm, double calendarWidth) {
    return SizedBox(
      width: calendarWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: StandardButton.icon(
              tooltip: 'Go to previous month',
              onPressed: vm.previousMonth,
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: const Icon(FluentIcons.chevron_left),
              ),
            ),
          ),
          MouseButtonWrapper(
            tooltipWaitDuration: const Duration(milliseconds: 300),
            tooltip: 'Click to go to current date',
            child: (_) => GestureDetector(
              onTap: () => vm.focusToday(),
              child: Text(
                DateFormat.yMMMM().format(vm.focusedMonth),
                style: FluentTheme.of(context).typography.subtitle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: StandardButton.icon(
              tooltip: 'Go to next month',
              onPressed: vm.nextMonth,
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: const Icon(FluentIcons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ReleaseCalendarViewModel vm, double calendarWidth) {
    final settings = SettingsManager();
    final firstDayOfWeekSetting = settings.firstDayOfWeek;

    final daysInMonth = DateTime(vm.focusedMonth.year, vm.focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(vm.focusedMonth.year, vm.focusedMonth.month, 1);

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

                  final date = DateTime(vm.focusedMonth.year, vm.focusedMonth.month, dayOffset);
                  final dateKey = DateTime(date.year, date.month, date.day);
                  final entriesForDay = vm.calendarCache[dateKey] ?? [];
                  final isSelected = _isSameDay(date, vm.selectedDate);
                  final isToday = _isSameDay(date, now);

                  return _buildCalendarDay(vm, date, entriesForDay, isSelected, isToday);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(ReleaseCalendarViewModel vm, DateTime date, List<CalendarEntry> entries, bool isSelected, bool isToday) {
    final entryCount = entries.length;

    return Container(
      margin: const EdgeInsets.all(2),
      child: MouseButtonWrapper(
        tooltip: entryCount > 0 //
            ? '${DateFormat.yMMMd().format(date)}\n$entryCount notification${entryCount > 1 ? 's' : ''}'
            : '${DateFormat.yMMMd().format(date)}\nNo notifications',
        child: (isHovering) => Button(
          onPressed: () => vm.selectDate(date),
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

  Widget _buildEpisodeList(ReleaseCalendarViewModel vm) {
    if (vm.errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.error, size: 48, color: Colors.red.light),
          VDiv(16),
          Text(vm.errorMessage!, style: FluentTheme.of(context).typography.subtitle),
          VDiv(16),
          Button(
            onPressed: loadReleaseData,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (!vm.hasAnyEntries) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.calendar_day, size: 48, color: FluentTheme.of(context).inactiveColor),
          VDiv(16),
          Text('No episodes scheduled', style: FluentTheme.of(context).typography.subtitle),
        ],
      );
    }

    final entriesByDate = vm.visibleEntriesByDate;

    // Today-only filter with nothing today
    if (vm.showOnlyTodayEpisodes && entriesByDate.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.calendar_day, size: 48, color: FluentTheme.of(context).inactiveColor),
          VDiv(16),
          Text('No entries today', style: FluentTheme.of(context).typography.subtitle),
        ],
      );
    }

    final sortedDates = entriesByDate.keys.toList()..sort();

    final List<Object> flattenedList = [];
    final todayKey = DateTime(now.year, now.month, now.day);
    bool dividerInserted = false;
    for (final date in sortedDates) {
      // Insert a divider before the first date that is today or in the future
      if (!dividerInserted && !date.isBefore(todayKey)) {
        // Only add divider if there are past entries before this
        if (flattenedList.isNotEmpty) flattenedList.add(const _PastFutureDivider());
        dividerInserted = true;
      }
      flattenedList.add(date); // Add the date as a header item
      flattenedList.addAll(entriesByDate[date]!); // Add all entries for that date
    }

    final isToday = vm.isSelectedToday;
    final isFutureDate = vm.isSelectedFuture;
    final shouldShowOlderButton = vm.shouldShowOlderButton;

    // If we have no entries to show and should show the button, show a different empty state
    if (entriesByDate.isEmpty && shouldShowOlderButton) {
      return Column(
        children: [
          // Show older notifications button
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0, top: 8.0),
            child: Row(
              children: [
                StandardButton.iconLabel(
                  onPressed: () => toggleOlderNotifications(true),
                  icon: const Icon(FluentIcons.history, size: 14),
                  label: Text(isToday ? 'Show older notifications' : 'Show all notifications'),
                ),
                const Spacer(),
                _buildMarkAllAsReadButton(vm),
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
                  isToday
                      ? 'No episodes scheduled for today'
                      : isFutureDate
                          ? 'No episodes scheduled for this date'
                          : 'No episodes aired on this date',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return AnimatedOpacity(
      duration: shortDuration,
      opacity: _isTempHidingResults ? 0.0 : 1.0,
      curve: Curves.decelerate,
      child: Column(
        children: [
          // Show older notifications button (when conditions are met)
          Row(
            children: [
              if (shouldShowOlderButton) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0, top: 8.0),
                  child: StandardButton.iconLabel(
                    onPressed: () => toggleOlderNotifications(true),
                    icon: const Icon(FluentIcons.history, size: 14),
                    label: Text(isToday ? 'Show older notifications' : 'Show all notifications'),
                  ),
                ),
              ],
              const Spacer(),
              Padding(padding: EdgeInsets.only(top: 8.0, right: 8.0), child: _buildMarkAllAsReadButton(vm)),
            ],
          ),
          // Episode list
          Expanded(
            child: buildStyledScrollbar(
              SmoothScroll(
                controller: widget.scrollController,
                stopScroll: KeyboardState.ctrlPressedNotifier,
                enableSmoothScroll: Manager.animationsEnabled,
                builder: (context, controller, physics) {
                  return ValueListenableBuilder(
                    valueListenable: KeyboardState.ctrlPressedNotifier,
                    builder: (context, isCtrlPressed, _) {
                      return ListView.builder(
                        physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                        controller: controller,
                        cacheExtent: 999999,
                        itemCount: flattenedList.length,
                        itemBuilder: (context, index) {
                          final item = flattenedList[index];

                          // Past/future divider
                          if (item is _PastFutureDivider) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Text(
                                        'Upcoming',
                                        style: Manager.captionStyle.copyWith(
                                          color: FluentTheme.of(context).inactiveColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                            );
                          }

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
                                  NumberPill(number: entriesByDate[date]!.length),
                                ],
                              ),
                            );
                          }

                          if (item is CalendarEntry) {
                            final entry = item;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: _buildCalendarEntryItem(vm, entry),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      );
                    },
                  );
                },
              ),
              widget.scrollController,
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildMarkAllAsReadButton(ReleaseCalendarViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Builder(builder: (context) {
        final unread = vm.unreadCount;
        return StandardButton.iconLabel(
          tooltip: unread == 0 ? 'All notifications are read' : 'Mark all notifications as read',
          isButtonDisabled: unread == 0,
          cursor: unread == 0 ? SystemMouseCursors.basic : SystemMouseCursors.click,
          icon: const Icon(FluentIcons.check_mark, size: 14),
          label: Text('Mark all as read'),
          onPressed: vm.markAllAsRead,
        );
      }),
    );
  }

  Widget _buildCalendarEntryItem(ReleaseCalendarViewModel vm, CalendarEntry entry) {
    try {
      return switch (entry) {
        NotificationCalendarEntry notificationEntry => NotificationCalendarEntryWidget(
            notificationEntry.notification,
            notificationEntry.series,
            onSeriesSelected: widget.onSeriesSelected,
            onDownloadButton: (animeId, episodeId) {
              // TODO callback for when user wants to download this episode -> go to download page with preselected anime/episode
              log('Download button clicked for episode $episodeId of anime ID: $animeId');
              snackBar('Download feature not implemented yet', severity: InfoBarSeverity.warning);
            },
            onAddedToList: (animeId) {
              // TODO show anilist dialog with list preselected to Plan to Watch
              log('Add to list clicked for anime ID: $animeId');
              snackBar('Add to list feature not implemented yet', severity: InfoBarSeverity.warning);
            },
            onRelatedMediaAdditionNotificationTapped: (animeId) {
              logTrace('Opening related media addition notification URL: $kAnilistBaseUrl/anime/$animeId');
              openAnilistAnime(animeId);
            },
            onMediaDataChangeNotificationTapped: (animeId) async {
              logTrace('Opening media data change notification URL: $kAnilistBaseUrl/anime/$animeId');
              openAnilistAnime(animeId);
            },
            onNotificationRead: (notificationId) async {
              // Already read → nothing to do
              if (notificationEntry.notification.isRead) return;
              await vm.markNotificationRead(notificationId);
            },
          ),
        EpisodeCalendarEntry episodeEntry => ScheduledEpisodeCalendarEntryWidget(
            episodeEntry: episodeEntry,
            onNotificationButtonToggled: (series) /* we have the DB id of the series, not anilist id */ {
              // TODO callback for when user wants to be notified about this episode(remember to account for when seriesId is -1)
              log('Notification button toggled for episode ${episodeEntry.episodeInfo.airingEpisode.episode} of series: ${series?.name}');
              snackBar('Notification feature not implemented yet', severity: InfoBarSeverity.warning);
            },
          ),
        _ => const SizedBox(), // fallback for abstract CalendarEntry
      };
    } catch (e) {
      logErr('Error building calendar entry item', e);
      return const SizedBox.shrink();
    }
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

/// Sentinel marker inserted into the flattened list to render a divider between aired entries and scheduled entries
class _PastFutureDivider {
  const _PastFutureDivider();
}
