
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/series.dart';
import '../../screens/release_calendar.dart';
import '../../services/library/library_provider.dart';
import '../../utils/color.dart';
import '../../utils/time.dart';
import '../animated_translate.dart';
import '../buttons/animated_icon_label_button.dart';
import '../buttons/button.dart';
import '../notification_list_tile.dart';
import 'notif.dart';

class ScheduledEpisodeCalendarEntryWidget extends StatefulWidget {
  final EpisodeCalendarEntry episodeEntry;
  final Function(Series?) onNotificationButtonToggled;

  const ScheduledEpisodeCalendarEntryWidget({required this.episodeEntry, required this.onNotificationButtonToggled, super.key});

  @override
  State<ScheduledEpisodeCalendarEntryWidget> createState() => _NotificationItemState2();
}

class _NotificationItemState2 extends State<ScheduledEpisodeCalendarEntryWidget> {
  late final bool isUpcoming;
  late final Duration timeUntil;
  late final Series? realSeries;
  late final String? imageUrl;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    isUpcoming = widget.episodeEntry.episodeInfo.airingDate.isAfter(now);
    timeUntil = widget.episodeEntry.episodeInfo.airingDate.difference(now);

    realSeries = _getSeriesFromSchedule(widget.episodeEntry.episodeInfo);
    imageUrl = realSeries?.posterImage;
  }

  Series? _getSeriesFromSchedule(ReleaseEpisodeInfo episodeInfo) {
    final library = Provider.of<Library>(context, listen: false);
    return library.getSeriesByPath(episodeInfo.series.path);
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays}d ${duration.inHours % 24}h';
    if (duration.inHours > 0) return '${duration.inHours}h ${duration.inMinutes % 60}m';
    return '${duration.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final offset = calculateOffset(widget.episodeEntry.episodeInfo.airingEpisode.episode?.toString().length);
    return NotificationListTile(
      leading: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: SizedBox(
          width: 50,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  widget.episodeEntry.episodeInfo.airingEpisode.episode.toString(),
                  style: Manager.bodyStyle.copyWith(
                    color: lighten(Manager.accentColor.lightest),
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 50,
                height: 64,
                child: AnimatedTranslate(
                  duration: shortDuration,
                  curve: Curves.easeInOut,
                  offset: _isHovered ? Offset(offset, 0) : Offset.zero,
                  child: buildNotificationImage(imageUrl, realSeries),
                ),
              ),
            ],
          ),
        ),
      ),
      title: 'Episode ${widget.episodeEntry.episodeInfo.airingEpisode.episode ?? '?'} - ${widget.episodeEntry.episodeInfo.series.displayTitle}',
      contentBuilder: (context, child) {
        return AnimatedTranslate(
          duration: shortDuration,
          curve: Curves.easeInOut,
          offset: _isHovered ? Offset(offset, 0) : Offset.zero,
          child: child,
        );
      },
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: AnimatedIconLabelButton(
          icon: (isHovered) => Icon(Symbols.notification_add, color: isHovered ? Colors.white : Manager.accentColor.light, weight: 400, grade: 0, opticalSize: 24, size: 18),
          label: 'Notify me',
          onPressed: () => widget.onNotificationButtonToggled.call(widget.episodeEntry.episodeInfo.series),
          tooltipWaitDuration: const Duration(milliseconds: 700),
          tooltip: 'Get notified when this episode airs',
        ),
      ),
      subtitle: isUpcoming ? 'Airs in ${_formatDuration(timeUntil)}' : formatTimeAgo(null, timeUntil.abs()),
      timestamp: DateFormat.yMMMd().add_jm().format(widget.episodeEntry.episodeInfo.airingDate),
      onTap: () {},
      isTileColored: false,
    );
  }
}
