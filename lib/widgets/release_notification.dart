// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import 'package:provider/provider.dart';

import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/navigation/dialogs2.dart';
import '../services/navigation/navigation.dart';
import '../utils/screen.dart';
import '../utils/time.dart';
import '../viewmodels/notifications_viewmodel.dart';
import 'animated_icon.dart' as anim_icon;
import 'dialogs/notifications.dart';
import 'dialogs/show_dialog.dart';

/// Widget that shows a notification bell icon with unread count badge.
/// Tapping the icon opens a dialog showing recent notifications.
class ReleaseNotificationWidget extends StatefulWidget {
  final void Function(BuildContext context)? onMorePressed;

  const ReleaseNotificationWidget({
    super.key,
    this.onMorePressed,
  });

  @override
  State<ReleaseNotificationWidget> createState() => _ReleaseNotificationWidgetState();
}

class _ReleaseNotificationWidgetState extends State<ReleaseNotificationWidget> {
  bool _notificationsOpen = false;
  Timer? _refreshTimer;

  NotificationsViewModel get _vm => context.read<NotificationsViewModel>();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
      if (anilistProvider.isLoggedIn) {
        await _vm.refreshUnreadCount();

        // Set up a periodic refresh for notifications
        _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
          if (mounted) {
            _vm.refreshUnreadCount();
          } else {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      // Prevent notification initialization errors from crashing the app
      debugPrint('Error initializing notification service: $e');
    }
  }

  bool _isDialogToggling = false;

  Future<void> _showNotificationDialog(BuildContext context) async {
    // Prevent multiple clicks during toggle
    if (_isDialogToggling || Manager.notificationsPopping) return;

    try {
      final currentDialog = context.read<NavigationManager>().currentView;
      if (context.read<NavigationManager>().hasDialog) {
        _isDialogToggling = true;
        closeDialog();
        //get current top dialog id
        if (currentDialog?.id == "system:notifications") {
          _isDialogToggling = false;
          return;
        }
        await Future.delayed(dimDuration);
        _isDialogToggling = false;
      }
      _notificationsOpen = true;

      if (!context.mounted) return;

      await showPaddedDialog(
        context,
        navigationItem: DialogNavigationItem(
          id: 'system:notifications',
          title: 'Notifications',
          data: {"darkenTitleBar": false},
          onDismiss: () async {
            Manager.notificationsPopping = true;
            await Future.delayed(dimDuration);
            Manager.notificationsPopping = false;
          },
        ),
        barrierOptions: PaddedBarrierOptions(
          userDismissable: true,
          barrierColor: Colors.transparent,
          exactColor: true,
          transluscentBarrier: true,
        ),
        builder: (ctx, item, option) {
          const boxConstraints = BoxConstraints(maxWidth: 480, maxHeight: 513);

          return PaddedDialog.frosted(
            navigationItem: item,
            barrierOptions: option,
            constraints: boxConstraints,
            padding: EdgeInsets.only(right: 36, top: 16),
            content: NotificationsContent(
              key: notificationsContentKey,
              onMorePressed: widget.onMorePressed,
              constraints: boxConstraints,
            ),
            alignment: Alignment.topRight,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            alignment: alignmentFromPixels(ScreenUtils.width - 155, 25, ScreenUtils.screenSize), // Top-right corner
            scale: CurvedAnimation(
              parent: Tween<double>(
                begin: 0,
                end: 1,
              ).animate(animation),
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ).then((_) => _notificationsOpen = false);

      // Refresh the unread count after the dialog is closed
      await _vm.refreshUnreadCount();
    } catch (e) {
      _isDialogToggling = false;
      _notificationsOpen = false;
      debugPrint('Error showing notification dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationsViewModel>().unreadCount;

    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, child) {
        // Always show the notification button, but enable it based on auth state
        final hasNotifications = unreadCount > 0;
        final isEnabled = anilistProvider.isLoggedIn;

        return TooltipWrapper(
          tooltip: isEnabled ? (hasNotifications ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}' : 'No unread notifications') : 'Login to Anilist to see notifications',
          preferBelow: true,
          waitDuration: dimDuration,
          child: (_) => IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: anim_icon.AnimatedIcon(
                    mat.Icon(
                      isEnabled ? (_notificationsOpen ? Symbols.notifications : Symbols.notifications) : mat.Icons.notifications_off,
                      size: 17,
                      color: isEnabled ? (hasNotifications ? Manager.currentDominantColor ?? Manager.accentColor : Colors.white.withOpacity(0.8)) : Colors.white.withOpacity(0.4),
                      weight: 300,
                      fill: _notificationsOpen ? 1.0 : 0.0,
                      grade: 0,
                      opticalSize: 40,
                    ),
                    duration: mediumDuration,
                  ),
                ),
                if (hasNotifications && isEnabled)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FluentTheme.of(context).scaffoldBackgroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: isEnabled && !_isDialogToggling ? () => _showNotificationDialog(context) : null,
          ),
        );
      },
    );
  }
}
