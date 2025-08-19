// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/notification.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../widgets/buttons/wrapper.dart';

final GlobalKey<NotificationsContentState> notificationsDialogKey = GlobalKey<NotificationsContentState>();

class NotificationsDialog extends ManagedDialog {
  final void Function(BuildContext context)? onMorePressed;
  final Offset? position;

  NotificationsDialog({
    super.key,
    required super.popContext,
    this.onMorePressed,
    this.position,
  }) : super(
          title: const Text('Notifications'),
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
          contentBuilder: (context, constraints) => _NotificationsContent(
            key: notificationsDialogKey,
            onMorePressed: onMorePressed,
            constraints: constraints,
          ),
        );

  @override
  State<ManagedDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends ManagedDialogState {
  @override
  void initState() {
    super.initState();
    
    // Position the dialog if position is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialog = widget as NotificationsDialog;
      if (dialog.position != null) {
        positionDialog(dialog.position!);
      }
    });
  }
}

class _NotificationsContent extends StatefulWidget {
  final void Function(BuildContext context)? onMorePressed;
  final BoxConstraints constraints;

  const _NotificationsContent({
    super.key,
    this.onMorePressed,
    required this.constraints,
  });

  @override
  NotificationsContentState createState() => NotificationsContentState();
}

class NotificationsContentState extends State<_NotificationsContent> {
  AnilistService? _anilistService;
  List<AnilistNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
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

  Future<void> _loadCachedNotifications() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    try {
      final notifications = await _anilistService!.getCachedNotifications(
        database: library.database,
        limit: 5,
      );
      final unreadCount = await _anilistService!.getUnreadCount(library.database);

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
        });
      }
    } catch (e) {
      // Silently handle cache loading errors
    }
  }

  Future<void> _syncNotifications() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);

    // Don't sync too frequently
    if (_lastSync != null && DateTime.now().difference(_lastSync!).inMinutes < 5) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Focus on airing notifications primarily, with some media change notifications
      final notifications = await _anilistService!.syncNotifications(
        database: library.database,
        types: [NotificationType.AIRING, NotificationType.MEDIA_DATA_CHANGE],
        maxPages: 2,
      );

      final unreadCount = await _anilistService!.getUnreadCount(library.database);

      if (mounted) {
        setState(() {
          _notifications = notifications.take(5).toList();
          _unreadCount = unreadCount;
          _lastSync = DateTime.now();
        });
      }
    } catch (e) {
      // Handle sync errors - maybe show a small indicator
      if (mounted) {
        // Could show a subtle error indicator
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        _notifications = _notifications.map((notification) {
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
        }).whereType<AnilistNotification>().toList();
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
        // Header
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
                      child: Text(
                        'Notifications',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                    ),
                  ),
                  if (_unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Manager.accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
                  Tooltip(
                    message: 'Refresh notifications',
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: ProgressRing(strokeWidth: 1.5),
                            )
                          : const Icon(FluentIcons.refresh, size: 12),
                      onPressed: _isLoading ? null : _syncNotifications,
                    ),
                  ),
                  if (widget.onMorePressed != null)
                    Tooltip(
                      message: 'View release calendar',
                      child: IconButton(
                        icon: const Icon(FluentIcons.calendar, size: 12),
                        onPressed: () => widget.onMorePressed?.call(context),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const Divider(),

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
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastSync == null ? 'Loading notifications...' : 'No recent notifications',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.8),
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
      onPressed: () {
        _markAsRead(notification.id);
        // TODO: Navigate to downloaded content pane
      },
    );
  }

  Widget _buildNotificationIcon(AnilistNotification notification) {
    switch (notification) {
      case AiringNotification airing:
        return _buildMediaImage(airing.media?.coverImage);
      case MediaDataChangeNotification dataChange:
        return _buildMediaImage(dataChange.media?.coverImage);
      case MediaMergeNotification merge:
        return _buildMediaImage(merge.media?.coverImage);
      case MediaDeletionNotification _:
        return Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.7),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Icon(
            FluentIcons.delete,
            size: 14,
            color: Colors.white,
          ),
        );
      default:
        return Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Icon(
            FluentIcons.ringer,
            size: 14,
            color: Colors.white,
          ),
        );
    }
  }

  Widget _buildMediaImage(String? imageUrl) {
    return SizedBox(
      width: 54 * 0.71,
      height: 54,
      child: imageUrl != null
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
