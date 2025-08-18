import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/library/library_provider.dart';
import '../models/series.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/provider/anilist_provider.dart';
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
  final ScrollController _episodeListController = ScrollController();

  // Cache for release data to avoid repeated calculations
  Map<DateTime, List<ReleaseEpisodeInfo>> _releaseCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReleaseData();
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    _episodeListController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    // TODO: Implement auto-scroll to today's episodes or next upcoming episode
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

      // Get date range (±1 week from today)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final endDate = now.add(const Duration(days: 7));

      final Map<DateTime, List<ReleaseEpisodeInfo>> releaseMap = {};

      // Get unique anime IDs to avoid duplicate requests
      final Set<int> animeIds = {};
      for (final series in library.series) {
        if (series.anilistMappings.isNotEmpty) {
          for (final mapping in series.anilistMappings) {
            animeIds.add(mapping.anilistId);
          }
        }
      }

      if (animeIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Use the existing batch API to get upcoming episodes for all anime at once
      // This is more efficient than individual requests
      try {
        final upcomingEpisodes = await anilistProvider.getUpcomingEpisodes(animeIds.toList());

        // Process the results
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

                  releaseMap.putIfAbsent(dateKey, () => []).add(episodeInfo);
                }
              }
            }
          }
        }

        // Sort episodes by airing time within each day
        for (final dayEpisodes in releaseMap.values) {
          dayEpisodes.sort((a, b) => a.airingDate.compareTo(b.airingDate));
        }

        setState(() {
          _releaseCache = releaseMap;
          _errorMessage = null;
          _isLoading = false;
        });
      } catch (e) {
        // If API call fails, show error message
        logErr('API call failed', e);
        setState(() {
          _errorMessage = 'Failed to load episode data. This might be due to Anilist rate limiting.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading release data: ${e.toString()}';
        _isLoading = false;
      });
      logErr('Error loading release data', e);
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
              padding: const EdgeInsets.all(16.0),
              child: _buildEpisodeList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        // Calendar header with navigation
        _buildCalendarHeader(),
        VDiv(16),

        // Calendar grid
        _buildCalendarGrid(),
        VDiv(16),

        // Today button
        MouseButtonWrapper(
          child: (_) => Button(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.calendar_agenda, size: 16),
                const SizedBox(width: 8),
                const Text('Today'),
              ],
            ),
            onPressed: () => setState(
              () {
                _selectedDate = now;
                _focusedMonth = now;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Button(
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
          padding: const EdgeInsets.only(right: 24.0),
          child: Button(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              });
            },
            child: const Icon(FluentIcons.chevron_right),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startDay = firstDayOfMonth.weekday % 7; // 0 = Sunday

    const double maxCalendarHeight = 466.0;
    const double minCalendarHeight = 380.0;

    // Calculate calendar height based on ScreenUtils.height:
    // - If screen height > 720, use the maximum calendar height.
    // - If screen height <= 600, use the minimum calendar height (380).
    // - Between 600 and 720, linearly interpolate from min to max.
    final double screenH = ScreenUtils.height;
    double calendarHeight;
    if (screenH > 720.0) {
      calendarHeight = maxCalendarHeight;
    } else if (screenH <= 600.0) {
      calendarHeight = minCalendarHeight;
    } else {
      final double t = (screenH - 620.0) / (720.0 - 600.0); // 0..1
      calendarHeight = minCalendarHeight + t * (maxCalendarHeight - minCalendarHeight);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day headers
          SizedBox(
            width: calendarHeight,
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
              width: calendarHeight, // Adjust width based on height
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
                  final episodesForDay = _releaseCache[dateKey] ?? [];
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());

                  return _buildCalendarDay(date, episodesForDay, isSelected, isToday);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, List<ReleaseEpisodeInfo> episodes, bool isSelected, bool isToday) {
    final episodeCount = episodes.length;

    return Container(
      margin: const EdgeInsets.all(2),
      child: MouseButtonWrapper(
        child: (isHovering) => Button(
          onPressed: () {
            setState(() {
              _selectedDate = date;
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

              // Episode dots
              if (episodeCount > 0) ...[
                VDiv(4),
                _buildEpisodeDots(episodeCount),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeDots(int count) {
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
              color: Manager.accentColor,
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
    final selectedDateKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final episodesForSelectedDate = _releaseCache[selectedDateKey] ?? [];

    // For weekly view, show all episodes from the past week to next week
    final allEpisodes = _releaseCache.entries
        .where((entry) {
          final daysDifference = entry.key.difference(DateTime.now()).inDays;
          return daysDifference >= -7 && daysDifference <= 7;
        })
        .expand((entry) => entry.value)
        .toList();

    allEpisodes.sort((a, b) => a.airingDate.compareTo(b.airingDate));

    final episodesToShow = episodesForSelectedDate.isEmpty ? allEpisodes : episodesForSelectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          episodesForSelectedDate.isEmpty ? 'Episodes (Past week to next week)' : 'Episodes for ${DateFormat.yMMMd().format(_selectedDate)}',
          style: Manager.subtitleStyle,
        ),
        VDiv(16),
        Expanded(
          child: _isLoading
              ? const Center(child: ProgressRing())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.error, color: Colors.red, size: 48),
                          VDiv(16),
                          Text('Error loading episodes'),
                          VDiv(8),
                          Text(_errorMessage!, style: FluentTheme.of(context).typography.caption),
                          VDiv(16),
                          Button(
                            onPressed: () {
                              setState(() => _errorMessage = null);
                              _loadReleaseData();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : episodesToShow.isEmpty
                      ? const Center(
                          child: Text('No episodes found for this time period'),
                        )
                      : ListView.builder(
                          controller: _episodeListController,
                          itemCount: episodesToShow.length,
                          itemBuilder: (context, index) {
                            return _buildEpisodeItem(episodesToShow[index]);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildEpisodeItem(ReleaseEpisodeInfo episodeInfo) {
    final now = DateTime.now();
    final isUpcoming = episodeInfo.airingDate.isAfter(now);
    final timeUntil = episodeInfo.airingDate.difference(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onPressed: () {
          widget.onSeriesSelected(episodeInfo.series.path);
        },
        leading: SizedBox(
          width: 60,
          height: 40,
          child: episodeInfo.series.bannerImage != null
              ? Image.network(
                  episodeInfo.series.bannerImage!,
                  fit: BoxFit.cover,
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
        title: Text(
          '${episodeInfo.series.displayTitle} - Episode ${episodeInfo.airingEpisode.episode ?? '?'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUpcoming ? 'Airs in ${_formatDuration(timeUntil)}' : 'Aired ${_formatTimeAgo(timeUntil.abs())}',
              style: TextStyle(
                color: isUpcoming ? Manager.accentColor : Colors.grey,
              ),
            ),
            Text(
              DateFormat.yMMMd().add_jm().format(episodeInfo.airingDate),
              style: FluentTheme.of(context).typography.caption,
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
