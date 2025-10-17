// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/services/navigation/show_info.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../manager.dart';
import '../../models/notification.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/library/library_provider.dart';
import '../../services/navigation/dialogs.dart';
import '../../utils/color.dart';
import '../../utils/time.dart';
import '../../widgets/buttons/wrapper.dart';
import '../buttons/rotating_loading_button.dart';
import '../notifications/notif.dart';

final GlobalKey<NotificationsContentState> notificationsContentKey = GlobalKey<NotificationsContentState>();

class NotificationsDialog extends ManagedDialog {
  final void Function(BuildContext context)? onMorePressed;

  NotificationsDialog({
    super.key,
    required super.popContext,
    this.onMorePressed,
  }) : super(
          title: null, // Remove the static title
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 513),
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
    _syncNotifications(true);
  }

  /// Filter notifications to exclude those related to hidden series
  List<AnilistNotification> _filterNotifications(List<AnilistNotification> notifications) {
    final library = Provider.of<Library>(context, listen: false);

    /// Return only notifications not related to hidden series (true = keep)
    return notifications.where((notification) {
      int? anilistIdToCheck;

      // Extract AniList ID based on notification type
      switch (notification) {
        case AiringNotification airing:
          anilistIdToCheck = airing.animeId;
          break;
        case RelatedMediaAdditionNotification related:
          anilistIdToCheck = related.mediaId;
          break;
        case MediaDataChangeNotification dataChange:
          anilistIdToCheck = dataChange.mediaId;
          break;
        case MediaMergeNotification merge:
          anilistIdToCheck = merge.mediaId;
          break;
        case MediaDeletionNotification _:
          // Deletion notifications don't have an AniList ID, as the media has been deleted
          return true;
        default:
          logErr('Unknown notification type: ${notification.runtimeType}');
      }

      // Filter out if the AniList ID is in the hidden cache
      if (anilistIdToCheck != null && library.hiddenSeriesService.shouldFilterAnilistId(anilistIdToCheck)) {
        print('hiding: $anilistIdToCheck'); // TODO fix this not updating the ui
        return false;
      }

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

  Future<(List<AnilistNotification>, int)> _fetchNotifications() async {
    final library = Provider.of<Library>(context, listen: false);

    // Focus on airing notifications primarily, with some media change notifications
    final notifications = await _anilistService!.syncNotifications(
      database: library.database,
      types: [NotificationType.AIRING, NotificationType.RELATED_MEDIA_ADDITION, NotificationType.MEDIA_DATA_CHANGE],
      maxPages: 2,
    );

    final unreadCount = await _anilistService!.getUnreadCount(library.database);
    return (notifications, unreadCount);
  }

  Future<void> _syncNotifications([bool forceFetch = false]) async {
    if (_anilistService == null) return;

    setState(() => _isRefreshing = true);

    try {
      List<AnilistNotification> notifications;
      int unreadCount;
      final result = await _fetchNotifications();
      notifications = result.$1;
      unreadCount = result.$2;

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
      if (e.toString().toLowerCase().contains('socket is not connected') || //
          e.toString().toLowerCase().contains('errno = 10057') ||
          e.toString().toLowerCase().contains('offline')) {
        logTrace('Failed to refresh notifications - offline');
      } else
        snackBar("Failed to refresh notifications", exception: e, severity: InfoBarSeverity.error);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // Public method to force refresh notifications
  void refreshNotifications() => _syncNotifications(true);

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

      // Update the release calendar screen if it's open
      releaseCalendarScreenKey.currentState?.updateNotificationReadStatus(notificationId);
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

      // Update the release calendar screen if it's open
      releaseCalendarScreenKey.currentState?.markAllNotificationsAsRead();
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
          padding: const EdgeInsets.only(left: 8.0, right: 0.0, bottom: 12.0, top: 7.0),
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
                    tooltip: 'Refresh notifications',
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
                          style: Manager.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0 || index == _notifications.length + 1) return const SizedBox(height: 4);

                    final notification = _notifications[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: _buildNotificationItem(notification),
                    );
                  },
                ),
        ),
        Opacity(opacity: 0.7, child: Container(height: 2, decoration: DividerTheme.of(context).decoration)),

        const SizedBox(height: 8),

        StandardButton(
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FluentIcons.calendar, size: 12),
              const SizedBox(width: 7),
              Text('View Release Calendar', style: Manager.bodyStyle),
            ],
          ),
          onPressed: () => widget.onMorePressed?.call(context),
        )
      ],
    );
  }

  Widget _buildNotificationItem(AnilistNotification notification) {
    return NotificationCalendarEntryWidget(
      notification,
      null, // Series will be looked up internally
      isDense: true,
      onNotificationRead: (id) {
        _markAsRead(id);
        // TODO: Navigate to series screen or download content pane
      },
    );
  }
}
