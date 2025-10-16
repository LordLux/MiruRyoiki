import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../manager.dart';
import '../../models/notification.dart';
import '../../models/series.dart';
import '../../utils/color.dart';
import '../../utils/path.dart';
import '../../utils/time.dart';
import '../animated_icon.dart' as anim;
import '../animated_translate.dart';
import '../buttons/animated_icon_label_button.dart';
import '../buttons/button.dart';
import '../no_image.dart';
import '../notification_list_tile.dart';
import '../tooltip_wrapper.dart';

class NotificationCalendarEntryWidget extends StatefulWidget {
  final AnilistNotification notification;
  final Series? series;
  final Function(PathString) onSeriesSelected;
  final Function(int) onNotificationRead;
  final Function(int) onRelatedMediaAdditionNotificationTapped;
  final Function(int) onAddedToList;
  final Function(int, int) onDownloadButton;
  final bool isDense;

  const NotificationCalendarEntryWidget(
    this.notification,
    this.series, {
    super.key,
    required this.onSeriesSelected,
    required this.onNotificationRead,
    required this.onRelatedMediaAdditionNotificationTapped,
    required this.onAddedToList,
    required this.onDownloadButton,
    this.isDense = false,
  });

  @override
  State<NotificationCalendarEntryWidget> createState() => _NotificationCalendarEntryWidgetState();
}

class _NotificationCalendarEntryWidgetState extends State<NotificationCalendarEntryWidget> {
  late final DateTime notificationDate;
  bool _isHovered = false;
  bool _isReadNotifHovered = false;
  bool get isRelatedMediaAdditionNotification => widget.notification is RelatedMediaAdditionNotification && (widget.notification as RelatedMediaAdditionNotification).media != null;
  bool get isNewEpisodeNotification => widget.notification is AiringNotification && (widget.notification as AiringNotification).media != null;

  @override
  void initState() {
    super.initState();
    notificationDate = DateTime.fromMillisecondsSinceEpoch(widget.notification.createdAt * 1000);
  }

  String _getNotificationTitle(AnilistNotification notification, Series? series) {
    return switch (notification) {
      AiringNotification airing => airing.getFormattedTitle(series?.displayTitle),
      RelatedMediaAdditionNotification related => '${series?.displayTitle ?? related.media?.title ?? 'Unknown anime'} was added to Anilist',
      MediaDataChangeNotification dataChange => '${series?.displayTitle ?? dataChange.media?.title ?? 'Unknown anime'} was updated',
      MediaMergeNotification merge => '${series?.displayTitle ?? merge.media?.title ?? 'Unknown anime'} was merged',
      MediaDeletionNotification deletion => '${deletion.deletedMediaTitle ?? 'Unknown Anime'} was deleted',
      _ => 'Unknown notification',
    };
  }

  String? _getNotificationImageString(AnilistNotification notification) {
    return switch (notification) {
      AiringNotification airing => airing.media?.coverImage,
      RelatedMediaAdditionNotification related => related.media?.coverImage,
      MediaDataChangeNotification dataChange => dataChange.media?.coverImage,
      MediaMergeNotification merge => merge.media?.coverImage,
      MediaDeletionNotification _ => null, // No media info for deletion notifications
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = now.difference(notificationDate);
    final bool hasEpisodeNumber = widget.notification is AiringNotification && !(widget.notification as AiringNotification).isMovie;
    final double offset = hasEpisodeNumber ? calculateOffset((widget.notification as AiringNotification).episode.toString().length) : 0.0;

    return NotificationListTile(
      leading: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: SizedBox(
          width: 50,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (hasEpisodeNumber)
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: TooltipWrapper(
                    tooltip: (widget.notification as AiringNotification).episode.toString(),
                    child: (message) => Text(
                      message,
                      style: Manager.bodyStyle.copyWith(
                        color: lighten(Manager.accentColor.lightest),
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              SizedBox(
                width: 50,
                height: 64,
                child: hasEpisodeNumber 
                    ? AnimatedTranslate(
                        duration: shortDuration,
                        curve: Curves.easeInOut,
                        offset: _isHovered ? Offset(offset, 0) : Offset.zero,
                        child: buildNotificationImage(_getNotificationImageString(widget.notification), widget.series),
                      )
                    : buildNotificationImage(_getNotificationImageString(widget.notification), widget.series),
              ),
            ],
          ),
        ),
      ),
      title: _getNotificationTitle(widget.notification, widget.series),
      contentBuilder: (context, child) {
        if (hasEpisodeNumber)
          return AnimatedTranslate(
            duration: shortDuration,
            curve: Curves.easeInOut,
            offset: _isHovered ? Offset(offset, 0) : Offset.zero,
            child: child,
          );
        return child;
      },
      subtitle: formatTimeAgo(widget.notification, timeAgo),
      timestamp: DateFormat.yMMMd().add_jm().format(notificationDate),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.notification.isRead)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isReadNotifHovered = true),
                onExit: (_) => setState(() => _isReadNotifHovered = false),
                child: Builder(
                  builder: (context) {
                    if (!_isReadNotifHovered)
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          FluentIcons.circle_fill,
                          color: Manager.accentColor.light,
                          size: 8,
                        ),
                      );
                    return StandardButton.icon(
                      isSmall: true,
                      icon: const Icon(Symbols.check),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      onPressed: () async => widget.onNotificationRead(widget.notification.id),
                    );
                  },
                ),
              ),
            ),
          if (isRelatedMediaAdditionNotification && !widget.isDense) // Hide "Add to lists" button in dense mode to save space
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Builder(
                builder: (context) {
                  return AnimatedIconLabelButton(
                    label: 'Add to lists',
                    icon: (isHovered) => anim.AnimatedIcon(Icon(Symbols.add, color: isHovered ? Colors.white : Manager.accentColor.light, weight: 400, grade: 0, opticalSize: 24, size: 18)),
                    onPressed: () => widget.onAddedToList((widget.notification as RelatedMediaAdditionNotification).mediaId),
                    tooltipWaitDuration: const Duration(milliseconds: 700),
                    tooltip: 'Add this entry to Plan to Watch in your Library',
                  );
                },
              ),
            ),
          if (isNewEpisodeNotification && !widget.isDense) // TODO show download button when the episode has not been downloaded yet
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Builder(
                builder: (context) {
                  return AnimatedIconLabelButton(
                    label: 'Download',
                    icon: (isHovered) => anim.AnimatedIcon(Icon(Symbols.download, color: isHovered ? Colors.white : Manager.accentColor.light, weight: 400, grade: 0, opticalSize: 24, size: 18)),
                    onPressed: () async => widget.onDownloadButton((widget.notification as AiringNotification).animeId, (widget.notification as AiringNotification).episode),
                    tooltipWaitDuration: const Duration(milliseconds: 700),
                    tooltip: 'Download this episode',
                  );
                },
              ),
            ),
          if (widget.series != null)
            TooltipWrapper(
              waitDuration: const Duration(milliseconds: 400),
              tooltip: 'View Series details',
              child: (_) => const Icon(FluentIcons.chevron_right),
            ) //
          else if (!widget.isDense) // Show chevron only if not in dense mode to save space
            isRelatedMediaAdditionNotification //
                ? TooltipWrapper(
                    waitDuration: const Duration(milliseconds: 400),
                    tooltip: 'Open in browser',
                    child: (_) => Icon(Symbols.open_in_new, weight: 300, grade: 0, opticalSize: 48, size: 18),
                  )
                : SizedBox(width: 18),
        ],
      ),
      onTap: () => widget.series != null //
          ? widget.onSeriesSelected(widget.series!.path)
          : isRelatedMediaAdditionNotification
              ? widget.onRelatedMediaAdditionNotificationTapped((widget.notification as RelatedMediaAdditionNotification).mediaId)
              : null,
      isTileColored: !widget.notification.isRead, // Highlight unread notifications
    );
  }
}

double calculateOffset(int? length) {
  // Calculate offset based on text length (1 to 4 characters)
  final titleLength = length ?? 1;
  return 8.0 + 9.5 * titleLength; // Base offset + per-character offset
}

Widget buildNotificationImage(String? imageUrl, Series? series) {
  // Use series poster image if available, otherwise fallback to Anilist cover
  if (series != null) {
    return FutureBuilder<ImageProvider?>(
      future: series.getPosterImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image(
              image: snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const NoImageWidget(),
            ),
          );
        } else if (snapshot.hasError || imageUrl == null) {
          return const NoImageWidget();
        } else {
          // Fallback to Anilist cover image while loading
          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: child,
            ),
            errorBuilder: (context, error, stackTrace) => const NoImageWidget(),
          );
        }
      },
    );
  } else if (imageUrl != null) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: child,
      ),
      errorBuilder: (context, error, stackTrace) => const NoImageWidget(),
    );
  } else {
    return const NoImageWidget();
  }
}

String formatTimeAgo(AnilistNotification? notification, Duration duration) {
  String str = "";
  if (duration.inDays > 0)
    str = '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
  else if (duration.inHours > 0)
    str = '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
  else
    str = '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';

  if (notification == null || notification is! RelatedMediaAdditionNotification) str = 'Aired $str';
  return str;
}
