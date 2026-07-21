// ignore_for_file: invalid_use_of_protected_member

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/widgets/buttons/button.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/notification.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../viewmodels/release_calendar_viewmodel.dart';
import '../../widgets/buttons/wrapper.dart';
import '../buttons/rotating_loading_button.dart';
import '../notifications/notif.dart';
import '../number_pill.dart';
import '../tooltip_wrapper.dart';

final GlobalKey<NotificationsContentState> notificationsContentKey = GlobalKey<NotificationsContentState>();

class NotificationsContent extends StatefulWidget {
  final void Function(BuildContext context)? onMorePressed;
  final BoxConstraints constraints;

  const NotificationsContent({super.key, this.onMorePressed, required this.constraints});

  @override
  NotificationsContentState createState() => NotificationsContentState();
}

class NotificationsContentState extends State<NotificationsContent> {
  NotificationsViewModel get _vm => context.read<NotificationsViewModel>();

  @override
  void initState() {
    super.initState();
    _vm.loadCached();
    _vm.sync();
  }

  Future<void> _markAsRead(int notificationId) async {
    final ok = await _vm.markAsRead(notificationId);
    // Update the release calendar's cached entries
    if (ok && mounted) context.read<ReleaseCalendarViewModel>().applyNotificationRead(notificationId);
  }

  Future<void> _markAllAsRead() async {
    final ok = await _vm.markAllAsRead();
    // Update the release calendar's cached entries
    if (ok && mounted) context.read<ReleaseCalendarViewModel>().applyAllNotificationsRead();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();

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
                  if (vm.unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Transform.translate(
                      offset: Offset(0, 4 * Manager.fontSizeMultiplier),
                      child: NumberPill(number: vm.unreadCount),
                    ),
                  ]
                ],
              ),
              Row(
                children: [
                  if (vm.unreadCount > 0)
                    TooltipWrapper(
                      tooltip: 'Mark all as read',
                      child: (_) => IconButton(
                        icon: const Icon(FluentIcons.check_mark, size: 12),
                        onPressed: _markAllAsRead,
                      ),
                    ),
                  RotatingLoadingButton(
                    tooltip: 'Refresh notifications',
                    icon: const Icon(FluentIcons.refresh, size: 12),
                    isLoading: vm.isRefreshing,
                    onPressed: () => vm.sync(),
                  )
                ],
              ),
            ],
          ),
        ),

        RepaintBoundary(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: vm.isRefreshing //
                ? mat.LinearProgressIndicator(
                    color: Manager.currentDominantColor ?? Manager.accentColor,
                    backgroundColor: Color(0xFF484848),
                    minHeight: 2,
                  )
                : Container(height: 2, decoration: DividerTheme.of(context).decoration),
          ),
        ),

        // Notification list
        Flexible(
          child: vm.recentNotifications.isEmpty
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
                          vm.lastSync == null ? 'Loading notifications...' : 'No recent notifications',
                          style: Manager.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.recentNotifications.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0 || index == vm.recentNotifications.length + 1) return const SizedBox(height: 4);

                    final notification = vm.recentNotifications[index - 1];
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
