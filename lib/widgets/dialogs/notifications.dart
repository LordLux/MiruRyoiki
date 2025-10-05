// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/notification.dart';
import '../../models/series.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../utils/color.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/wrapper.dart';
import '../buttons/rotating_loading_button.dart';

final GlobalKey<NotificationsContentState> notificationsContentKey = GlobalKey<NotificationsContentState>();

class NotificationsDialog extends ManagedDialog {
  final void Function(BuildContext context)? onMorePressed;

  NotificationsDialog({
    super.key,
    required super.popContext,
    this.onMorePressed,
  }) : super(
          title: null, // Remove the static title
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500),
          contentBuilder: (context, constraints) => _NotificationsContent(
            key: notificationsContentKey,
            onMorePressed: onMorePressed,
            constraints: constraints,
          ),
          alignment: Alignment.topRight,
        );

  @override
  State<ManagedDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends NotificationManagedDialogState {
  @override
  void initState() {
    super.initState();
    Manager.canPopDialog = true;
  }
}

class _NotificationsContent extends StatefulWidget {
  final void Function(BuildContext context)? onMorePressed;
  final BoxConstraints constraints;

  const _NotificationsContent({super.key, this.onMorePressed, required this.constraints});

  @override
  NotificationsContentState createState() => NotificationsContentState();
}

class NotificationsContentState extends State<_NotificationsContent> {
  AnilistService? _anilistService;
  List<AnilistNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isRefreshing = false;
  DateTime? _lastSync;

  @override
  void initState() {
    super.initState();
    Manager.canPopDialog = true;
    _initializeService();
  }

  void _initializeService() {
    _anilistService = AnilistService();
    _loadCachedNotifications();
    _syncNotifications();
  }

  /// Filter notifications to exclude those related to hidden series
  List<AnilistNotification> _filterNotifications(List<AnilistNotification> notifications) {
    final library = Provider.of<Library>(context, listen: false);

    /// Return only notifications not related to hidden series (true = keep)
    return notifications.where((notification) {
      int? anilistIdToCheck;

      // Extract AniList ID based on notification type
      switch (notification.runtimeType) {
        case AiringNotification _:
          anilistIdToCheck = (notification as AiringNotification).animeId;
          break;
        case RelatedMediaAdditionNotification _:
          anilistIdToCheck = (notification as RelatedMediaAdditionNotification).mediaId;
          break;
        case MediaDataChangeNotification _:
          anilistIdToCheck = (notification as MediaDataChangeNotification).mediaId;
          break;
        case MediaMergeNotification _:
          anilistIdToCheck = (notification as MediaMergeNotification).mediaId;
          break;
        case MediaDeletionNotification _:
          // Deletion notifications don't have an AniList ID, as the media has been deleted
          return true;
      }

      // Filter out if the AniList ID is in the hidden cache
      if (anilistIdToCheck != null && library.hiddenSeriesService.shouldFilterAnilistId(anilistIdToCheck)) {
        print('hiding: $anilistIdToCheck'); // TODO fix this not updating the ui
        return false;}

      return true;
    }).toList();
  }

  Future<void> _loadCachedNotifications() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    try {
      final notifications = await _anilistService!.getCachedNotifications(
        database: library.database,
        limit: 20,
      );
      final unreadCount = await _anilistService!.getUnreadCount(library.database);

      // Filter out notifications for hidden series
      final filteredNotifications = _filterNotifications(notifications);

      if (mounted) {
        setState(() {
          _notifications = filteredNotifications.take(5).toList();
          _unreadCount = unreadCount;
        });
      }
    } catch (e) {
      // Silently handle cache loading errors
      logErr("Error loading cached notifications", e);
    }
  }

  Future<void> _syncNotifications() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    // Don't sync too frequently
    if (_lastSync != null && now.difference(_lastSync!).inSeconds < 5) //
      return;

    setState(() => _isRefreshing = true);

    try {
      // Focus on airing notifications primarily, with some media change notifications
      final notifications = await _anilistService!.syncNotifications(
        database: library.database,
        types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
        maxPages: 2,
      );

      final unreadCount = await _anilistService!.getUnreadCount(library.database);

      // Filter out notifications for hidden series
      final filteredNotifications = _filterNotifications(notifications);

      if (mounted) {
        setState(() {
          _notifications = filteredNotifications.take(5).toList();
          _unreadCount = unreadCount;
          _lastSync = now;
        });
      }
    } catch (e) {
      snackBar("Failed to refresh notifications", exception: e, severity: InfoBarSeverity.error);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // Public method to force refresh notifications
  void refreshNotifications() => _syncNotifications();

  // Getter to check if currently refreshing
  bool get isRefreshing => _isRefreshing;

  Future<void> _markAsRead(int notificationId) async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    try {
      await _anilistService!.markAsRead(library.database, notificationId);

      // Update UI
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index >= 0) {
          switch (_notifications[index]) {
            case AiringNotification airing:
              _notifications[index] = airing.copyWith(isRead: true);
            case MediaDataChangeNotification dataChange:
              _notifications[index] = dataChange.copyWith(isRead: true);
            case MediaMergeNotification merge:
              _notifications[index] = merge.copyWith(isRead: true);
            case MediaDeletionNotification deletion:
              _notifications[index] = deletion.copyWith(isRead: true);
          }
        }
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      });
    } catch (e) {
      logErr("Error marking notification $notificationId as read: $e");
    }
  }

  Future<void> _markAllAsRead() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    try {
      await _anilistService!.markAllAsRead(library.database);

      // Update UI
      setState(() {
        _notifications = _notifications
            .map((notification) {
              switch (notification) {
                case AiringNotification airing:
                  return airing.copyWith(isRead: true);
                case MediaDataChangeNotification dataChange:
                  return dataChange.copyWith(isRead: true);
                case MediaMergeNotification merge:
                  return merge.copyWith(isRead: true);
                case MediaDeletionNotification deletion:
                  return deletion.copyWith(isRead: true);
              }
            })
            .whereType<AnilistNotification>()
            .toList();
        _unreadCount = 0;
      });
    } catch (e) {
      // Handle error silently
      logErr("Error marking all notifications as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MouseButtonWrapper(
                    child: (_) => GestureDetector(
                      onTap: () => widget.onMorePressed?.call(context),
                      child: Text('Notifications', style: Manager.titleStyle),
                    ),
                  ),
                  if (_unreadCount > 0)
                    Transform.translate(
                      offset: Offset(0, 4 * Manager.fontSizeMultiplier),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Manager.currentDominantColor ?? Manager.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: TextStyle(
                            color: getTextColor(Manager.currentDominantColor ?? Manager.accentColor, darkColor: lighten(Colors.black, 0.2)),
                            fontSize: 11 * Manager.fontSizeMultiplier,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (_unreadCount > 0)
                    Tooltip(
                      message: 'Mark all as read',
                      child: IconButton(
                        icon: const Icon(FluentIcons.check_mark, size: 12),
                        onPressed: _markAllAsRead,
                      ),
                    ),
                  RotatingLoadingButton(
                    icon: const Icon(FluentIcons.refresh, size: 12),
                    isLoading: _isRefreshing,
                    onPressed: () => _syncNotifications(),
                  )
                ],
              ),
            ],
          ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _isRefreshing //
              ? mat.LinearProgressIndicator(
                  color: Manager.currentDominantColor ?? Manager.accentColor,
                  backgroundColor: Color(0xFF484848),
                  minHeight: 2,
                )
              : Container(height: 2, decoration: DividerTheme.of(context).decoration),
        ),

        // Notification list
        Flexible(
          child: _notifications.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.ringer,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastSync == null ? 'Loading notifications...' : 'No recent notifications',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
        ),
        Divider(),

        const SizedBox(height: 8),

        StandardButton(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FluentIcons.calendar, size: 12),
              const SizedBox(width: 6),
              Text('View Release Calendar'),
            ],
          ),
          onPressed: () => widget.onMorePressed?.call(context),
        )
      ],
    );
  }

  Widget _buildNotificationItem(AnilistNotification notification) {
    return ListTile(
      leading: _buildNotificationIcon(notification),
      title: Text(
        _getNotificationTitle(notification),
        style: TextStyle(
          fontSize: 13,
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatNotificationTime(notification.createdAt),
        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
      ),
      trailing: notification.isRead
          ? null
          : Icon(
              FluentIcons.circle_fill,
              size: 7,
              color: Manager.currentDominantColor ?? Manager.accentColor.light,
            ),
      onPressed: () {
        _markAsRead(notification.id);
        // TODO: Navigate to series screen or download content pane
      },
    );
  }

  Widget _buildNotificationIcon(AnilistNotification notification) {
    // Find the associated series for this notification
    final library = Provider.of<Library>(context, listen: false);
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

    final a = switch (notification) {
      AiringNotification airing => _buildMediaImage(airing.media?.coverImage, associatedSeries),
      MediaDataChangeNotification dataChange => _buildMediaImage(dataChange.media?.coverImage, associatedSeries),
      RelatedMediaAdditionNotification related => _buildMediaImage(related.media?.coverImage, associatedSeries),
      MediaMergeNotification merge => _buildMediaImage(merge.media?.coverImage, associatedSeries),
      MediaDeletionNotification _ => Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.7), borderRadius: BorderRadius.circular(3)),
          child: const Icon(
            FluentIcons.delete,
            size: 14,
            color: Colors.white,
          ),
        ),
      AnilistNotification() => throw UnimplementedError(),
    };
    return Row(children: [
      Container(
        decoration: BoxDecoration(
            color: notification.isRead ? Colors.transparent : Manager.currentDominantColor ?? Manager.accentColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            )),
        height: 54,
        width: 2.5,
      ),
      const SizedBox(width: 2.3),
      a,
    ]);
  }

  Widget _buildMediaImage(String? imageUrl, Series? associatedSeries) {
    return SizedBox(
      width: 54 * 0.71,
      height: 54,
      child: associatedSeries != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: FutureBuilder<ImageProvider?>(
                future: associatedSeries.getPosterImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image(
                      image: snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(
                            FluentIcons.image_pixel,
                            size: 14,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError || imageUrl == null) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        FluentIcons.image_pixel,
                        size: 14,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    // Fallback to Anilist cover image while loading
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(
                            FluentIcons.image_pixel,
                            size: 14,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          : imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(
                          FluentIcons.image_pixel,
                          size: 14,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    FluentIcons.image_pixel,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
    );
  }

  String _getNotificationTitle(AnilistNotification notification) {
    switch (notification) {
      case AiringNotification airing:
        final title = airing.media?.title ?? 'Unknown anime';
        return 'Episode ${airing.episode} of $title aired';
      case RelatedMediaAdditionNotification related:
        final title = related.media?.title ?? 'Unknown anime';
        return '$title was added to Anilist';
      case MediaDataChangeNotification dataChange:
        final title = dataChange.media?.title ?? 'Unknown anime';
        return '$title data was updated';
      case MediaMergeNotification merge:
        final title = merge.media?.title ?? 'Unknown anime';
        return '$title was merged with other entries';
      case MediaDeletionNotification deletion:
        final title = deletion.deletedMediaTitle ?? 'Unknown anime';
        return '$title was deleted';
      default:
        return 'Unknown notification';
    }
  }

  String _formatNotificationTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
