import 'package:fluent_ui/fluent_ui.dart';
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
      final notifications = await _anilistService!.getCachedNotifications(
        database: library.database,
        limit: 10,
      );
      setState(() {
        _unreadCount = notifications.where((n) => !n.isRead).length;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _showNotificationDialog() {
    // Calculate button position relative to screen
    final RenderBox buttonBox = context.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    
    // Position dialog near the button (to the right and slightly below)
    final dialogPosition = Offset(
      buttonPosition.dx - 300, // Offset left to fit within screen
      buttonPosition.dy + buttonSize.height + 8, // Below the button
    );
    
    showManagedDialog(
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
                Icon(
                  FluentIcons.ringer,
                  size: 16,
                  color: isEnabled ? (hasNotifications ? Manager.accentColor : Colors.grey.withOpacity(0.8)) : Colors.grey.withOpacity(0.4),
                ),
                if (hasNotifications && isEnabled)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
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
