import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:provider/provider.dart';

import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import '../services/anilist/queries/anilist_service.dart';
import '../services/library/library_provider.dart';
import '../services/navigation/dialogs.dart';
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

  void _showNotificationDialog() async {
    // Calculate button position relative to screen
    final RenderBox buttonBox = context.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    
    // Position dialog near the button (to the right and slightly below)
    final dialogPosition = Offset(
      buttonPosition.dx - 300, // Offset left to fit within screen
      buttonPosition.dy + buttonSize.height + 8, // Below the button
    );
    
    await showManagedDialog(
      context: context,
      id: 'notifications',
      title: 'Notifications',
      canUserPopDialog: true,
      dialogDoPopCheck: () => Manager.canPopDialog,
      builder: (context) => NotificationsDialog(
        popContext: context,
        position: dialogPosition,
        onMorePressed: (context) => widget.onMorePressed?.call(context),
      ),
    );
    
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
                  child: Icon(
                    mat.Icons.notifications,
                    size: 17,
                    color: isEnabled ? (hasNotifications ? Manager.accentColor : Colors.white.withOpacity(0.8)) : Colors.white.withOpacity(0.4),
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
            onPressed: isEnabled ? _showNotificationDialog : null,
          ),
        );
      },
    );
  }
}
