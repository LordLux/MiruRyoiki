import 'package:fluent_ui/fluent_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../services/anilist/anilist_availability.dart';
import '../../../services/connectivity/connectivity_service.dart';
import '../../../utils/color.dart';
import '../../../utils/screen.dart';
import '../../../utils/time.dart';
import 'progress.dart';

/// Defines a left-side status bar info item
class StatusBarInfo {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const StatusBarInfo({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
  });
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late final ConnectivityService _connectivityService;
  late bool _wasOnline;
  bool _showTransientOnlineBanner = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    _wasOnline = _connectivityService.isOnline;
    _connectivityService.isOnlineNotifier.addListener(_handleOnlineChanged);
  }

  void _handleOnlineChanged() {
    final isOnline = _connectivityService.isOnlineNotifier.value;
    if (isOnline == _wasOnline) return;
    _wasOnline = isOnline;

    if (isOnline) {
      setState(() => _showTransientOnlineBanner = true);
      Future.delayed(const Duration(seconds: 3)).then((_) {
        if (!mounted) return;
        setState(() => _showTransientOnlineBanner = false);
      });
    } else {
      setState(() => _showTransientOnlineBanner = false);
    }
  }

  @override
  void dispose() {
    _connectivityService.isOnlineNotifier.removeListener(_handleOnlineChanged);
    super.dispose();
  }

  /// Resolves the left-side info to display
  ///
  /// Priority: offline > "back online" transient > AniList unavailable > null
  StatusBarInfo? _resolveLeftInfo(bool isOnline, bool isAnilistUnavailable) {
    if (!isOnline) {
      return StatusBarInfo(
        icon: Symbols.wifi_off,
        text: 'You are currently offline',
        color: Colors.orange,
      );
    }

    if (_showTransientOnlineBanner) {
      return StatusBarInfo(
        icon: Symbols.wifi,
        text: 'You are back online!',
        color: Colors.green,
      );
    }

    if (isAnilistUnavailable) {
      return StatusBarInfo(
        icon: Symbols.cloud_off,
        text: 'AniList service unavailable',
        color: Colors.red,
        onTap: () => AnilistAvailabilityService().reset(),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scanManager = LibraryScanProgressManager();
    final anilistAvailability = AnilistAvailabilityService();

    return ValueListenableBuilder<bool>(
      valueListenable: _connectivityService.isOnlineNotifier,
      builder: (context, isOnline, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: anilistAvailability.unavailableNotifier,
          builder: (context, isAnilistUnavailable, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: scanManager.showingNotifier,
              builder: (context, isScanShowing, _) {
                final leftInfo = _resolveLeftInfo(isOnline, isAnilistUnavailable);
                final isVisible = isScanShowing || leftInfo != null;

                return AnimatedContainer(
                  duration: mediumDuration,
                  color: getDimmableWhite(context),
                  height: isVisible ? ScreenUtils.kStatusBarHeight : 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: status info with gradient
                      AnimatedSwitcher(
                        duration: shortDuration,
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: leftInfo != null
                            ? _LeftStatusInfo(key: ValueKey(leftInfo.text), info: leftInfo)
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                      // Right side: scan progress
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: LibraryScanProgressIndicator(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LeftStatusInfo extends StatelessWidget {
  final StatusBarInfo info;

  const _LeftStatusInfo({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            info.color.withOpacity(0.95),
            info.color.withOpacity(0.7),
            info.color.withOpacity(0.3),
            info.color.withOpacity(0.1),
            info.color.withOpacity(0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        children: [
          Icon(info.icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info.text,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (info.onTap != null) {
      return GestureDetector(onTap: info.onTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: child));
    }
    return child;
  }
}
