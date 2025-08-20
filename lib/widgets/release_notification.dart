// ignore_for_file: use_build_context_synchronously

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/dialogs.dart';
import '../services/navigation/navigation.dart';
import 'dialogs/notifications.dart';

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
  AnilistService? _anilistService;
  bool _notificationsOpen = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    if (anilistProvider.isLoggedIn) {
      _anilistService = AnilistService();
      await _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (_anilistService == null) return;

    final library = Provider.of<Library>(context, listen: false);
    try {
      // Get the actual unread count from database instead of counting limited cached results
      final unreadCount = await _anilistService!.getUnreadCount(library.database);
      setState(() {
        _unreadCount = unreadCount;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  bool _isDialogToggling = false;

  void _showNotificationDialog() async {
    // Prevent multiple clicks during toggle
    if (_isDialogToggling || Manager.notificationsPopping) return;

    final currentDialog = Manager.navigation.currentView;
    if (Navigator.of(context, rootNavigator: true).canPop() && currentDialog?.level == NavigationLevel.dialog) {
      _isDialogToggling = true;
      //get current top dialog id
      closeDialog(rootNavigatorKey.currentContext!);
      if (currentDialog?.id == "notifications") {
        _isDialogToggling = false;
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      _isDialogToggling = false;
    }
    _notificationsOpen = true;
    
    if (!context.mounted) return;
    
    await showManagedDialog(
      context: context,
      id: 'notifications',
      title: 'Notifications',
      canUserPopDialog: true,
      dialogDoPopCheck: () => Manager.canPopDialog,
      barrierColor: Colors.transparent,
      overrideColor: true,
      closeExistingDialogs: false,
      transparentBarrier: true,
      onDismiss: () async {
        Manager.notificationsPopping = true;
        await Future.delayed(const Duration(milliseconds: 200));
        Manager.notificationsPopping = false;
      },
      builder: (ctx) => NotificationsDialog(
        popContext: ctx,
        onMorePressed: (ctx2) => widget.onMorePressed?.call(ctx2),
      ),
    ).then((_) => _notificationsOpen = false);

    // Refresh the unread count after the dialog is closed
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnilistProvider>(
      builder: (context, anilistProvider, child) {
        // Always show the notification button, but enable it based on auth state
        final hasNotifications = _unreadCount > 0;
        final isEnabled = anilistProvider.isLoggedIn;

        return Tooltip(
          message: isEnabled ? (hasNotifications ? '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}' : 'No unread notifications') : 'Login to Anilist to see notifications',
          child: IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: mat.Icon(
                    isEnabled ? (_notificationsOpen ? Symbols.notifications : Symbols.notifications) : mat.Icons.notifications_off,
                    size: 17,
                    color: isEnabled ? (hasNotifications ? Manager.accentColor : Colors.white.withOpacity(0.8)) : Colors.white.withOpacity(0.4),
                    weight: 300,
                    fill: _notificationsOpen ? 1.0 : 0.0,
                    grade: 0,
                    opticalSize: 40,
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
            onPressed: isEnabled && !_isDialogToggling ? _showNotificationDialog : null,
          ),
        );
      },
    );
  }
}
